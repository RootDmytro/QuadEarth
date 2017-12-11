//
//  WGSQLiteLayer.h
//  HelloEarth
//
//  Created by Anton Smyshliaiev on 9/22/17.
//  Copyright © 2017 HW Corporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WhirlyGlobeMaplyComponent/WhirlyGlobeComponent.h>
#import "SQLiteDatabase.h"

@interface WGSQLiteLayer : NSObject <MaplyPagingDelegate>

@property (nonatomic, assign) int minZoom;
@property (nonatomic, assign) int maxZoom;
@property (nonatomic, assign) bool useDelay;

// Create with the search string we'll use
//- (id)initWithSearch:(NSString *)search;
- (id)initWithDatabase:(id<AirportsDatabaseProtocol>)database;


@end
