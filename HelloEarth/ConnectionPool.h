//
//  ConnectionPool.h
//  HelloEarth
//
//  Created by Dmytro Yaropovetsky on 10/18/17.
//  Copyright © 2017 HW Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ConnectionContainer;

@interface ConnectionPool : NSObject

@property (nonatomic, copy) NSString *filePath;

- (instancetype)initWithFilePath:(NSString *)filePath;
- (void)fetchExclusiveConnection:(void (^)(ConnectionContainer *connection))resultBlock;

@end
