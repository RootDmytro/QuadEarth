//
//  AirportInfo.h
//  HelloEarth
//
//  Created by Anton Smyshliaiev on 9/22/17.
//  Copyright © 2017 HW Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AirportInfo : NSObject

@property (nonatomic, assign) int uniqueId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) double lon;

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *civmil;
@property (nonatomic, copy) NSString *ifr;

- (instancetype)initWithUniqueId:(int)uniqueId name:(NSString *)name latitude:(double)lat longitude:(double)lon;

- (NSString *)airportImageName;

@end
