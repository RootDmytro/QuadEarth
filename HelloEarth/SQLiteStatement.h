//
//  SQLiteStatement.h
//  QuadEarth
//
//  Created by Dmytro Yaropovetsky on 10/19/17.
//  Copyright © 2017 HW Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct sqlite3_stmt sqlite3_stmt;
typedef struct sqlite3 sqlite3;

@interface SQLiteStatement : NSObject

@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSNumber *> *indexByName;
@property (nonatomic, copy, readonly) NSString *query;
@property (nonatomic, assign, readonly) sqlite3_stmt *statement;
@property (nonatomic, assign, readonly) int status;

- (instancetype)initWithQuery:(NSString *)query;
- (instancetype)initWithQuery:(NSString *)query connection:(sqlite3 *)connection;

- (BOOL)prepareForConnection:(sqlite3 *)connection;
- (void)finalizeStatement;

- (BOOL)step;
- (void)iterateOverRows:(void (^)(SQLiteStatement *statement, BOOL *stop))iterator;

- (BOOL)isOK;
- (BOOL)gotRow;
- (BOOL)isDone;

- (double)doubleForIndex:(int)index;
- (int)intForIndex:(int)index;
- (int64_t)int64ForIndex:(int)index;
- (NSString *)stringForIndex:(int)index;

- (double)doubleForColumn:(NSString *)column;
- (int)intForColumn:(NSString *)column;
- (int64_t)int64ForColumn:(NSString *)column;
- (NSString *)stringForColumn:(NSString *)column;

@end
