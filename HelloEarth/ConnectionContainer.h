//
//  ConnectionContainer.h
//  HelloEarth
//
//  Created by Dmytro Yaropovetsky on 10/18/17.
//  Copyright © 2017 HW Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class SQLiteStatement;

@interface ConnectionContainer : NSObject

@property (nonatomic, assign, readonly) sqlite3 *connection;

- (instancetype)initWithFilePath:(NSString *)filePath;

- (BOOL)tryAccess:(void (^)(ConnectionContainer *connection))accessBlock;

- (SQLiteStatement *)makeStatementWithQuery:(NSString *)query;

@end
