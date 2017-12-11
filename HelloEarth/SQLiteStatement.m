//
//  SQLiteStatement.m
//  QuadEarth
//
//  Created by Dmytro Yaropovetsky on 10/19/17.
//  Copyright © 2017 HW Corporation. All rights reserved.
//

#import "SQLiteStatement.h"
#import <sqlite3.h>


@interface SQLiteStatement ()

@property (nonatomic, strong, readwrite) NSDictionary<NSString *, NSNumber *> *indexByName;
@property (nonatomic, copy, readwrite) NSString *query;
@property (nonatomic, assign, readwrite) sqlite3_stmt *statement;
@property (nonatomic, assign, readwrite) int status;

@end

@implementation SQLiteStatement

- (instancetype)initWithQuery:(NSString *)query {
	self = [self init];
	if (self) {
		self.query = query;
	}
	return self;
}

- (instancetype)initWithQuery:(NSString *)query connection:(sqlite3 *)connection {
	self = [self initWithQuery:query];
	if (self) {
		self.query = query;
		[self prepareForConnection:connection];
	}
	return self;
}

- (void)dealloc {
	[self finalizeStatement];
}

- (BOOL)prepareForConnection:(sqlite3 *)connection {
	NSAssert(self.statement == NULL, @"Statement is already prepared and not finalized.");
	
	[self finalizeStatement];
	self.status = sqlite3_prepare_v2(connection, self.query.UTF8String, -1, &_statement, NULL);
	
	if (self.isOK) {
		NSMutableDictionary<NSString *, NSNumber *> *indexByName = [NSMutableDictionary new];
		int count = sqlite3_column_count(self.statement);
		
		for (int i = 0; i < count; i++) {
			const char *zName = sqlite3_column_name(self.statement, i);
			NSString *name = [NSString stringWithUTF8String:zName];
			
			if (name) {
				indexByName[name] = @(i);
			}
		}
		
		self.indexByName = indexByName.copy;
	}
	
	return self.isOK;
}

- (void)finalizeStatement {
	if (self.statement != NULL) {
		sqlite3_finalize(self.statement);
		self.statement = NULL;
	}
}

#pragma mark -

- (BOOL)step {
	NSAssert(self.statement != NULL, @"Statement is not prepared or already finalized.");
	
	self.status = sqlite3_step(self.statement);
	return self.gotRow;
}

- (void)iterateOverRows:(void (^)(SQLiteStatement *statement, BOOL *stop))iterator {
	NSAssert(self.statement != NULL, @"Statement is not prepared or already finalized.");
	
	BOOL stop = NO;
	while (!stop && [self step]) {
		iterator(self, &stop);
	}
}

#pragma mark -

- (BOOL)isOK {
	return self.status == SQLITE_OK;
}

- (BOOL)gotRow {
	return self.status == SQLITE_ROW;
}

- (BOOL)isDone {
	return self.status == SQLITE_DONE;
}

#pragma mark -

- (double)doubleForIndex:(int)index {
	NSAssert(self.statement != NULL, @"Statement is not prepared or already finalized.");
	return sqlite3_column_double(self.statement, index);
}

- (int)intForIndex:(int)index {
	NSAssert(self.statement != NULL, @"Statement is not prepared or already finalized.");
	return sqlite3_column_int(self.statement, index);
}

- (int64_t)int64ForIndex:(int)index {
	NSAssert(self.statement != NULL, @"Statement is not prepared or already finalized.");
	return sqlite3_column_int64(self.statement, index);
}

- (NSString *)stringForIndex:(int)index {
	NSAssert(self.statement != NULL, @"Statement is not prepared or already finalized.");
	return [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(self.statement, index)];
}

#pragma mark -

- (double)doubleForColumn:(NSString *)column {
	NSNumber *index = self.indexByName[column];
	NSAssert(index != nil, @"Column %@ not found.", column);
	return index != nil ? [self doubleForIndex:index.intValue] : 0;
}

- (int)intForColumn:(NSString *)column {
	NSNumber *index = self.indexByName[column];
	NSAssert(index != nil, @"Column %@ not found.", column);
	return index != nil ? [self intForIndex:index.intValue] : 0;
}

- (int64_t)int64ForColumn:(NSString *)column {
	NSNumber *index = self.indexByName[column];
	NSAssert(index != nil, @"Column %@ not found.", column);
	return index != nil ? [self int64ForIndex:index.intValue] : 0;
}

- (NSString *)stringForColumn:(NSString *)column {
	NSNumber *index = self.indexByName[column];
	NSAssert(index != nil, @"Column %@ not found.", column);
	return index != nil ? [self stringForIndex:index.intValue] : nil;
}

@end
