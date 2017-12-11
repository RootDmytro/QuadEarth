//
//  ConnectionContainer.m
//  HelloEarth
//
//  Created by Dmytro Yaropovetsky on 10/18/17.
//  Copyright © 2017 HW Corporation. All rights reserved.
//

#import "ConnectionContainer.h"
#import "SQLiteStatement.h"

@interface ConnectionContainer ()

@property (nonatomic, assign, readwrite) sqlite3 *connection;
@property (nonatomic, strong) NSLock *access;

@end

@implementation ConnectionContainer

- (instancetype)initWithFilePath:(NSString *)filePath {
	self = [super init];
	if (self != nil) {
		self.access = [NSLock new];
		if (sqlite3_open(filePath.UTF8String, &_connection) != SQLITE_OK) {
			NSLog(@"Failed to open database!");
			self = nil;
		}
	}
	return self;
}

- (void)dealloc {
	if (self.connection != NULL) {
		sqlite3_close(self.connection);
		self.connection = NULL;
	}
}

- (BOOL)tryAccess:(void (^)(ConnectionContainer *connection))accessBlock {
	BOOL granted = [self.access tryLock];
	if (granted) {
		accessBlock(self);
		[self.access unlock];
	}
	return granted;
}

- (SQLiteStatement *)makeStatementWithQuery:(NSString *)query {
	return [[SQLiteStatement alloc] initWithQuery:query connection:self.connection];
}

@end
