//
//  WGSQLiteLayer.m
//  HelloEarth
//
//  Created by Anton Smyshliaiev on 9/22/17.
//  Copyright © 2017 HW Corporation. All rights reserved.
//

#import "WGSQLiteLayer.h"
#import "AirportInfo.h"

@interface WGSQLiteLayer ()

@property (nonatomic, strong) id<AirportsDatabaseProtocol> sqliteDatabase;

@property (nonatomic, strong) NSMutableDictionary<NSString *, MaplyTexture *> *markerTexturesByName;

@end

@implementation WGSQLiteLayer

static const int MaxDebugColors = 10;
static const int debugColors[MaxDebugColors] = {0x86812D, 0x5EB9C9, 0x2A7E3E, 0x4F256F, 0xD89CDE, 0x773B28, 0x333D99, 0x862D52, 0xC2C653, 0xB8583D};

- (instancetype)initWithDatabase:(id<AirportsDatabaseProtocol>)database {
    self = [super init];
	
	if (self != nil) {
		self.sqliteDatabase = database;
		self.markerTexturesByName = [NSMutableDictionary new];
	}
    
    return self;
}

- (void)startFetchForTile:(MaplyTileID)tileID forLayer:(MaplyQuadPagingLayer *)layer {
//    // bounding box for tile
//    MaplyBoundingBox bbox;
//    [layer geoBoundsforTile:tileID ll:&bbox.ll ur:&bbox.ur];
//
//    NSLog(@"startFetchForTile!");
//         
//    // let the layer know the tile is done
//    [layer tileDidLoad:tileID];
//    
    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		//[self showTileInfo:tileID layer:layer];
		[self showMarkers:tileID layer:layer];
		[layer tileDidLoad:tileID];
	});
}

- (MaplyTexture *)textureWithName:(NSString *)textureName layer:(MaplyQuadPagingLayer *)layer {
	return self.markerTexturesByName[textureName] ?: (self.markerTexturesByName[textureName] = [layer.viewC addTexture:[UIImage imageNamed:textureName] desc:nil mode:MaplyThreadCurrent]);
}

- (void)showMarkers:(MaplyTileID)tileID layer:(MaplyQuadPagingLayer *)layer
{
    // Add in a little delay
    //if (true) usleep(0.215 * 1e6);
    
    if (tileID.level > _maxZoom) {
        [layer tileFailedToLoad:tileID];
    } else {
        MaplyCoordinate ll,ur;
        [layer geoBoundsforTile:tileID ll:&ll ur:&ur];
        MaplyCoordinate center;
        center.x = (ll.x+ur.x)/2.0;  center.y = (ll.y+ur.y)/2.0;
        
        NSArray<AirportInfo *> *airports = [self.sqliteDatabase getAirportsLL:ll UR:ur];
        NSMutableArray<MaplyScreenMarker *> *markers = [NSMutableArray arrayWithCapacity:airports.count];
		
        for (AirportInfo *airportInfo in airports) {
            MaplyCoordinate coord = MaplyCoordinateMakeWithDegrees(airportInfo.lon, airportInfo.lat);
            MaplyScreenMarker *marker = [[MaplyScreenMarker alloc] init];
            marker.loc = coord;
			marker.image = [self textureWithName:airportInfo.airportImageName ?: @"airport-civil-vfr"
										   layer:layer];
            marker.size = CGSizeMake(16,16);
            //marker.layoutSize = CGSizeMake(0.0, 0.0);
            marker.layoutImportance = 1;
            
//                NSString *arpName = [NSString stringWithFormat:@"%@",airportInfo.name];
//                if ([[dictTiles allKeys] containsObject:arpName] == false) {
//                    [markers addObject:marker];
//                    [dictTiles setObject:@"" forKey:arpName];
//                }
            [markers addObject:marker];

        }

        //MaplyCoordinate coord = MaplyCoordinateMakeWithDegrees(0.0 + drand48(), 0.0 + drand48());
        
        [layer.viewC addScreenMarkers:markers desc:@{//kMaplyClusterGroup: @(0)
													 } mode:MaplyThreadAny];
        //[layer.viewC addScreenMarkers:markers desc:nil mode:MaplyThreadAny];
        
//        NSUInteger keyCount = [dictTiles count];
//        NSLog(@"dictionay count: %i", keyCount);

    }
}

- (void)showTileInfo:(MaplyTileID)tileID layer:(MaplyQuadPagingLayer *)layer
{
    // Add in a little delay
//    if (true) usleep(0.215 * 1e6);
	
    if (tileID.level > _maxZoom)
    {
        [layer tileFailedToLoad:tileID];
    } else {
        MaplyCoordinate ll,ur;
        [layer geoBoundsforTile:tileID ll:&ll ur:&ur];
        MaplyCoordinate center;
        center.x = (ll.x+ur.x)/2.0;
		center.y = (ll.y+ur.y)/2.0;
        MaplyCoordinate coords[4];
        double spanX = ur.x - ll.x;
        double spanY = ur.y - ll.y;
        coords[0] = MaplyCoordinateMake(ll.x+spanX*0.1, ll.y+spanY*0.1);
        coords[1] = MaplyCoordinateMake(ll.x+spanX*0.1, ur.y-spanY*0.1);
        coords[2] = MaplyCoordinateMake(ur.x-spanX*0.1, ur.y-spanY*0.1);
        coords[3] = MaplyCoordinateMake(ur.x-spanX*0.1, ll.y+spanY*0.1);
        
        // Color rectangle with outline
        int hexColor = debugColors[tileID.level % MaxDebugColors];
        CGFloat red = (((hexColor) >> 16) & 0xFF)/255.0;
        CGFloat green = (((hexColor) >> 8) & 0xFF)/255.0;
        CGFloat blue = (((hexColor) >> 0) & 0xFF)/255.0;
        UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:0.75];
		MaplyVectorObject *rect = [[MaplyVectorObject alloc] initWithLineString:coords numCoords:4 attributes:nil];
		MaplyComponentObject *compObj0 = [layer.viewC addVectors:@[rect]
															desc:@{kMaplyFilled: @(true),
																   kMaplyColor: color,
																   kMaplyEnable: @NO,
																   kMaplyDrawPriority: @(kMaplyVectorDrawPriorityDefault+100+tileID.level)
																   }
															mode:MaplyThreadCurrent];
		MaplyComponentObject *compObj1 = [layer.viewC addVectors:@[rect]
															desc:@{kMaplyFilled: @(false),
																   kMaplyColor: [UIColor whiteColor],
																   kMaplyEnable: @NO,
																   kMaplyDrawPriority: @(kMaplyVectorDrawPriorityDefault+101+tileID.level)
																   }
															mode:MaplyThreadCurrent];
        
        // Label
        MaplyScreenLabel *label = [[MaplyScreenLabel alloc] init];
        label.loc = center;
        label.text = [NSString stringWithFormat:@"%d: (%d,%d)", tileID.level, tileID.x, tileID.y];
		MaplyComponentObject *compObj2 = [layer.viewC addScreenLabels:@[label]
																 desc:@{kMaplyFont: [UIFont systemFontOfSize:18.0],
																		kMaplyJustify: @"center",
																		kMaplyEnable: @NO,
																		kMaplyTextOutlineSize: @(1.0)
																		}
																 mode:MaplyThreadCurrent];
        
        [layer addData:@[compObj0, compObj1, compObj2] forTile:tileID];
        
        
    }
}

@end
