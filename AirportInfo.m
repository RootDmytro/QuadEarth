//
//  AirportInfo.m
//  HelloEarth
//
//  Created by Anton Smyshliaiev on 9/22/17.
//  Copyright © 2017 HW Corporation. All rights reserved.
//

#import "AirportInfo.h"

@implementation AirportInfo

- (instancetype)initWithUniqueId:(int)uniqueId name:(NSString *)name latitude:(double)lat longitude:(double)lon {
	self = [super init];
	if (self != nil) {
        self.uniqueId = uniqueId;
        self.name = name;
        self.lat = lat;
        self.lon = lon;
    }
    return self;
}

- (NSString *)airportImageName {
	static NSDictionary *airportTypes = nil;
	
	static dispatch_once_t onceToken1;
	dispatch_once(&onceToken1, ^{
		airportTypes = @{@"W": @"seaplane",
						 @"HP": @"heliport",
						 @"L": [NSNull null], // Large
						 @"S": [NSNull null], // Small
						 @"M": [NSNull null], // Medium
						 @"??": [NSNull null],
						 @"NULL": [NSNull null]};
	});
	
	NSString *airportType = airportTypes[self.type.uppercaseString];
	if ([[NSNull null] isEqual:airportType]) {
		airportType = nil;
	}
	
	
	static NSDictionary *civilOrMilitaries = nil;
	static dispatch_once_t onceToken2;
	dispatch_once(&onceToken2, ^{
		civilOrMilitaries = @{@"CIV": @"civil", @"CIVIL": @"civil", @"MIL": @"military"};
	});
	
	// Civil or military
	NSString *civilOrMilitary = civilOrMilitaries[self.civmil.uppercaseString];
	if (civilOrMilitary == nil) {
		civilOrMilitary = @"civil";
	}
	
	// VFR/IFR
	static NSDictionary *flightRules = nil;
	static dispatch_once_t onceToken3;
	dispatch_once(&onceToken3, ^{
		flightRules = @{@"IFR": @"ifr",
						@"VFR": @"vfr",
						@"VFRX": @"vfr",
						};
	});
	NSString *flightRule = flightRules[self.ifr.uppercaseString] ?: @"vfr";
	
	// Construct image name
	NSString *imageName = nil;
	if (airportType) {
		imageName = [NSString stringWithFormat:@"airport-%@-%@-%@", airportType, civilOrMilitary, flightRule];
	} else {
		imageName = [NSString stringWithFormat:@"airport-%@-%@", civilOrMilitary, flightRule];
	}
	
	//	NSAssert(imageName.length > 0, @"Failed to find airport image");
	return imageName;
}

@end
