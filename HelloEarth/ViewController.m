//
//  ViewController.m
//  HelloEarth
//
//  Created by Anton Smyshliaiev on 9/21/17.
//  Copyright © 2017 HW Corporation. All rights reserved.
//

#import "ViewController.h"
#import "WGSQLiteLayer.h"
#import "SQLiteDatabase.h"
#import "AirportsDatabase.h"
#import "AirportInfo.h"

#import <WhirlyGlobeMaplyComponent/WhirlyGlobeComponent.h>

@interface ViewController ()

@property (nonatomic, strong) WhirlyGlobeViewController *globeViewController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create an empty globe and add it to the view
    self.globeViewController = [[WhirlyGlobeViewController alloc] init];
    [self.view addSubview:self.globeViewController.view];
    self.globeViewController.view.frame = self.view.bounds;
    [self addChildViewController:self.globeViewController];


    // we want a black background for a globe, a white background for a map.
    self.globeViewController.clearColor = (self.globeViewController != nil) ? [UIColor blackColor] : [UIColor whiteColor];
    
    // and thirty fps if we can get it ­ change this to 3 if you find your app is struggling
    self.globeViewController.frameInterval = 2;
    
    // set up the data source
    MaplyMBTileSource *tileSource = [[MaplyMBTileSource alloc] initWithMBTiles:@"osmbasemap"];
    
    // set up the layer
    MaplyQuadImageTilesLayer *layer = [[MaplyQuadImageTilesLayer alloc] initWithCoordSystem:tileSource.coordSys
																				 tileSource:tileSource];
    layer.handleEdges = (self.globeViewController != nil);
    layer.coverPoles = (self.globeViewController != nil);
    layer.requireElev = false;
    layer.waitLoad = false;
    layer.drawPriority = 0;
    layer.singleLevelLoading = false;
    [self.globeViewController addLayer:layer];
    
    // start up over San Francisco, center of the universe
    if (self.globeViewController != nil) {
        self.globeViewController.height = 0.8;
//        [globeViewC animateToPosition:MaplyCoordinateMakeWithDegrees(2.4192,37.7793)
//                                 time:1.0];
        [self.globeViewController setPosition:MaplyCoordinateMakeWithDegrees(31.4192, 51.7793) height:1];
    }
    
    
    [self setupCartoDBLayer:self.globeViewController];
    
//    NSArray *airports = [SQLiteDatabase database].getAirports;
//    for (AirportInfo *info in airports) {
//        NSLog(@"%d: %@, %.2f, %.2f", info.uniqueId, info.name, info.lat, info.lon);
//    }
}


- (void)setupCartoDBLayer:(MaplyBaseViewController *)baseLayer
{
    //    NSString *search = @"SELECT the_geom,address,ownername,numfloors FROM mn_mappluto_13v1 WHERE the_geom && ST_SetSRID(ST_MakeBox2D(ST_Point(%f, %f), ST_Point(%f, %f)), 4326) LIMIT 2000;";
    //
    WGSQLiteLayer *wgsqliteLayer = [[WGSQLiteLayer alloc] initWithDatabase:[AirportsDatabase sharedInstance]];
    wgsqliteLayer.minZoom = 4;
    wgsqliteLayer.maxZoom = 5;
    MaplySphericalMercator *coordSys = [[MaplySphericalMercator alloc] initWebStandard];
    MaplyQuadPagingLayer *quadLayer = [[MaplyQuadPagingLayer alloc] initWithCoordSystem:coordSys delegate:wgsqliteLayer];
    
    quadLayer.singleLevelLoading = true;
    quadLayer.useTargetZoomLevel = true;
    quadLayer.importance = 256*256;
    quadLayer.useParentTileBounds = false;

    
    [baseLayer addLayer:quadLayer];
}

@end
