//
//  AirportsDatabase.h
//  HelloEarth
//
//  Created by Anton Smyshliaiev on 9/22/17.
//  Copyright © 2017 HW Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AirportsDatabaseProtocol.h"


@interface AirportsDatabase : NSObject <AirportsDatabaseProtocol>

+ (instancetype)sharedInstance;

@end
