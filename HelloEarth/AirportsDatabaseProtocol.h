//
//  AirportsDatabaseProtocol.h
//  HelloEarth
//
//  Created by Dmytro Yaropovetsky on 10/18/17.
//  Copyright © 2017 HW Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WhirlyGlobeMaplyComponent/MaplyCoordinate.h>

@class AirportInfo;

@protocol AirportsDatabaseProtocol

- (NSArray<AirportInfo *> *)getAirports;
- (NSArray<AirportInfo *> *)getAirportsLL:(MaplyCoordinate)ll UR:(MaplyCoordinate)ur;

@end
