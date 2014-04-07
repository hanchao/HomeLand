//
//  GPSLayer.m
//  HomeLand
//
//  Created by chao han on 14-3-17.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "GPSLayer.h"
#import "TrackPoint.h"

@implementation GPSLayer

- (id)init
{
    if( (self = [super init]) )
    {
        [self startLogger];
    }
    return self;
}

- (void) startLogger
{
    if (self.enableLogger) {
        [self stopLogger];
    }
    self.enableLogger = true;
    
    _line = [[AGSMutablePolyline alloc] init];
    [_line addPathToPolyline];
    
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
    _gpxname = [formatter stringFromDate:[NSDate date]];

    _gpx = [GPXRoot rootWithCreator:@"GPSLogger"];
    _gpxTrack = [_gpx newTrack];
    _gpxTrack.name = @"New Track";
    
    [self refresh];
}

- (void) stopLogger
{
    _gpx = nil;
    _gpxTrack = nil;
    
    _line = nil;
    [self removeAllGraphics];
    self.enableLogger = false;
}

- (void) addGPSPoint:(CLLocation *)newLocation
{
//    GPXTrackPoint *gpxTrackPoint = [_gpxTrack newTrackpointWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
//    gpxTrackPoint.elevation = newLocation.altitude;
//    gpxTrackPoint.time = [NSDate date];
    
//    TrackPoint *trackpoint = [[TrackPoint alloc] init];
//    trackpoint.latitude = [NSNumber numberWithFloat:newLocation.coordinate.latitude];
//    trackpoint.longitude = [NSNumber numberWithFloat:newLocation.coordinate.longitude];
//    trackpoint.altitude = [NSNumber numberWithFloat:newLocation.altitude];
//    trackpoint.created = [NSDate date];
//    [_track addTrackpointsObject:trackpoint];
    
    AGSSpatialReference *srWGS84 = [AGSSpatialReference spatialReferenceWithWKID:4326];
    AGSSpatialReference *srMap = [AGSSpatialReference spatialReferenceWithWKID:102100];
    
    AGSPoint *point = [[AGSPoint alloc] initWithX:newLocation.coordinate.longitude y:newLocation.coordinate.latitude spatialReference:srWGS84];
    
    AGSGeometryEngine *geometryEngine = [[AGSGeometryEngine alloc] init];
    AGSPoint *pointMap = (AGSPoint *)[geometryEngine projectGeometry:point toSpatialReference:srMap];
    
    [_line addPointToPath:[[AGSPoint alloc] initWithX:pointMap.x  y:pointMap.y spatialReference:nil]];
    
    NSLog(@"%f %f %f %f %d", point.x,point.y, pointMap.x,pointMap.y,_line.numPoints);
    
    AGSSimpleFillSymbol* myFillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
    myFillSymbol.color = [UIColor colorWithRed:0.1 green:0.2 blue:0.7 alpha:0.5];
    //线的边框还是“线”
    AGSSimpleLineSymbol* myOutlineSymbol = [AGSSimpleLineSymbol simpleLineSymbol];
    myOutlineSymbol.color = [UIColor colorWithRed:0.1 green:0.2 blue:0.7 alpha:0.5];
    myOutlineSymbol.width = 2;
    //set the outline property to myOutlineSymbol
    myFillSymbol.outline = myOutlineSymbol;
    
    AGSSymbol *symbol = myFillSymbol;
    AGSGeometry *geometry = _line;
    
    AGSGraphic*graphic = [AGSGraphic graphicWithGeometry:geometry symbol:symbol attributes:nil];
    [self removeAllGraphics];
    [self addGraphic:graphic];
    
    [self refresh];
}

- (NSString *) gpxName
{
    return _gpxname;
}

- (NSString *) gpxString
{
    return _gpx.gpx;
}

@end
