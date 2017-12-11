//
//  SQLiteDatabase.m
//  HelloEarth
//
//  Created by Anton Smyshliaiev on 9/22/17.
//  Copyright © 2017 HW Corporation. All rights reserved.
//

#import "SQLiteDatabase.h"
#import "AirportInfo.h"
#import <sqlite3.h>


@interface SQLiteDatabase ()

@property (nonatomic, assign) sqlite3 *database;

@end


@implementation SQLiteDatabase

+ (instancetype)sharedInstance {
	static SQLiteDatabase *_sharedInstance;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedInstance = [[self alloc] init];
	});
	
    return _sharedInstance;
}

- (instancetype)init {
	self = [super init];
    if (self != nil) {
        NSString *sqLiteDb = [[NSBundle mainBundle] pathForResource:@"airports"
                                                             ofType:@"sqlite"];
        
        if (sqlite3_open([sqLiteDb UTF8String], &_database) != SQLITE_OK) {
            NSLog(@"Failed to open database!");
        }
    }
    return self;
}


- (NSArray<AirportInfo *> *)getAirports {
    
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    NSString *query = @"SELECT rowid, name, latitude, lon FROM airports limit 10";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(self.database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int uniqueId = sqlite3_column_int(statement, 0);
            char *nameChars = (char *) sqlite3_column_text(statement, 1);
            double lat = sqlite3_column_double(statement, 2);
            double lon = sqlite3_column_double(statement, 3);
            NSString *name = [[NSString alloc] initWithUTF8String:nameChars];
            AirportInfo *info = [[AirportInfo alloc] initWithUniqueId:uniqueId name:name latitude:lat longitude:lon];
                                 
            [retval addObject:info];
        }
        sqlite3_finalize(statement);
    }
    return retval;
    
}

- (NSArray<AirportInfo *> *)getAirportsLL:(MaplyCoordinate)ll UR:(MaplyCoordinate)ur
{
    
    NSMutableArray<AirportInfo *> *retval = [[NSMutableArray alloc] init];
    
    @synchronized(self)
    {
    
    NSString *query = [NSString stringWithFormat:@"SELECT rowid, name, latitude, lon FROM airports where latitude >= %f and latitude < %f and lon >= %f and lon < %f", ll.y*180/3.14, ur.y*180/3.14, ll.x*180/3.14, ur.x*180/3.14];
    
    NSLog(@"query: %@", query);
		
    //NSString *query = @"SELECT rowid, name, latitude, lon FROM airports limit 10";
    
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(self.database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int uniqueId = sqlite3_column_int(statement, 0);
            char *nameChars = (char *) sqlite3_column_text(statement, 1);
            double lat = sqlite3_column_double(statement, 2);
            double lon = sqlite3_column_double(statement, 3);
            NSString *name = [[NSString alloc] initWithUTF8String:nameChars];
            AirportInfo *info = [[AirportInfo alloc] initWithUniqueId:uniqueId name:name latitude:lat longitude:lon];
            
            [retval addObject:info];
        }
        sqlite3_finalize(statement);
    }
    }
    return retval;
    
}

- (void)dealloc {
	if (self.database != NULL) {
		sqlite3_close(self.database);
		self.database = NULL;
	}
}

@end
