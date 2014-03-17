//
//  GPSLayer.h
//  HomeLand
//
//  Created by chao han on 14-3-17.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>
#import "Track.h"
#import "GPX/GPX.h"

@interface GPSLayer : AGSGraphicsLayer
{
    AGSMutablePolyline *_line;
    NSString *_gpxname;
    //Track * _track;
    GPXRoot *_gpx;
    GPXTrack *_gpxTrack;
}

@property (nonatomic) BOOL enableLogger;

- (void) startLogger;
- (void) stopLogger;
- (void) addGPSPoint:(CLLocation *)newLocation;
- (NSString *) gpxName;
- (NSString *) gpxString;
@end
