//
//  ConnectionPool.m
//  HelloEarth
//
//  Created by Dmytro Yaropovetsky on 10/18/17.
//  Copyright © 2017 HW Corporation. All rights reserved.
//

#import "ConnectionPool.h"
#import "ConnectionContainer.h"

@interface ConnectionPool ()

@property (nonatomic, strong) NSArray<ConnectionContainer *> *connectionContainers;
@property (nonatomic, strong) NSLock *poolAccessLock;

@end

@implementation ConnectionPool

- (instancetype)initWithFilePath:(NSString *)filePath {
	self = [self init];
	if (self) {
		self.connectionContainers = [NSArray new];
		self.poolAccessLock = [NSLock new];
		self.filePath = filePath;
	}
	return self;
}

- (void)fetchExclusiveConnection:(void (^)(ConnectionContainer *connection))resultBlock {
	
	NSArray<ConnectionContainer *> *connectionContainers = self.connectionContainers;
	for (ConnectionContainer *connection in connectionContainers) {
		if ([connection tryAccess:resultBlock]) {
			return;
		}
	}
	
	ConnectionContainer *newConnection = [[ConnectionContainer alloc] initWithFilePath:self.filePath];
	[newConnection tryAccess:resultBlock];
	
	[self.poolAccessLock lock];
	self.connectionContainers = [self.connectionContainers arrayByAddingObject:newConnection];
	[self.poolAccessLock unlock];
}

@end
