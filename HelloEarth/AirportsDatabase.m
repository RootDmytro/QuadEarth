//
//  AirportsDatabase.m
//  HelloEarth
//
//  Created by Anton Smyshliaiev on 9/22/17.
//  Copyright © 2017 HW Corporation. All rights reserved.
//

#import "AirportsDatabase.h"
#import "AirportInfo.h"
#import "ConnectionPool.h"
#import "ConnectionContainer.h"
#import "SQLiteStatement.h"

#define sqlite3_column_string(statement, index) [[NSString alloc] initWithUTF8String:(char *)sqlite3_column_text (statement, index)]

@implementation AirportInfo (SQLite)

- (instancetype)initWithStatement:(SQLiteStatement *)statement {
	self = [self init];
	
	if (self != nil) {
		self.uniqueId = [statement intForColumn:@"rowid"];
		self.name = [statement stringForColumn:@"name"];
		self.lat = [statement doubleForColumn:@"latitude"];
		self.lon = [statement doubleForColumn:@"lon"];
		self.type = [statement stringForColumn:@"type"];
		self.civmil = [statement stringForColumn:@"civmil"];
		self.ifr = [statement stringForColumn:@"ifr"];
	}
	
	return self;
}

@end


@implementation ConnectionContainer (AirportsDatabase)

- (NSArray<AirportInfo *> *)fetchByQuery:(NSString *)query {
	NSMutableArray<AirportInfo *> *retval = [[NSMutableArray alloc] init];
	
	SQLiteStatement *statement = [self makeStatementWithQuery:query];
	if (statement.isOK) {
		[statement iterateOverRows:^(SQLiteStatement *statement, BOOL *stop) {
			[retval addObject:[[AirportInfo alloc] initWithStatement:statement]];
		}];
	}
	
	return retval;
}

@end


@interface AirportsDatabase ()

@property (nonatomic, strong) ConnectionPool *connectionPool;

@end


@implementation AirportsDatabase

+ (instancetype)sharedInstance {
	static AirportsDatabase *_sharedInstance;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[self alloc] init];
	});
	
    return _sharedInstance;
}

- (instancetype)init {
	self = [super init];
    if (self != nil) {
        NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"airports" ofType:@"sqlite"];
		self.connectionPool = [[ConnectionPool alloc] initWithFilePath:sqLiteDb];
    }
    return self;
}


- (NSArray<AirportInfo *> *)getAirports {
    NSString *query = @"SELECT rowid, name, latitude, lon, type, civmil, ifr FROM airports LIMIT 10";
	
	NSArray<AirportInfo *> * __block retval = nil;
	[self.connectionPool fetchExclusiveConnection:^(ConnectionContainer *connection) {
		retval = [connection fetchByQuery:query];
	}];
	
    return retval;
    
}

- (NSArray<AirportInfo *> *)getAirportsLL:(MaplyCoordinate)ll UR:(MaplyCoordinate)ur {
	double deg = 180 / M_PI;
    NSString *query = [NSString stringWithFormat:@""
					   " SELECT * "
					   " FROM airports "
					   " WHERE latitude >= %f AND latitude < %f AND lon >= %f AND lon < %f "
					   " ORDER BY airport_of_entry DESC, iata > '' DESC, icao > '' DESC, rowid DESC ",
					   ll.y * deg, ur.y * deg, ll.x * deg, ur.x * deg];
	
	NSLog(@"query: %@", query);
	
	NSArray<AirportInfo *> * __block retval = nil;
	[self.connectionPool fetchExclusiveConnection:^(ConnectionContainer *connection) {
		retval = [connection fetchByQuery:query];
	}];
	
    return retval;
    
}

@end
