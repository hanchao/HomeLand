//
//  Project.h
//  HomeLand
//
//  Created by chao han on 14-3-5.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../libspatialite/headers/spatialite/sqlite3.h"
#import "../libspatialite/headers/spatialite/gaiageo.h"
#import "../libspatialite/headers/spatialite.h"
#import <ArcGIS/ArcGIS.h>
//#import "GPX/GPX.h"

@interface Project : NSObject
{
    sqlite3 *_handle;
}

@property (weak, nonatomic) AGSMapView *mapView;
@property (nonatomic) BOOL opened;
@property (nonatomic) NSString * path;
@property (nonatomic) NSMutableArray *layers;

- (id)init;

-(BOOL) create:(NSString *)path;
-(BOOL) open:(NSString *)path;
-(BOOL) close;

-(BOOL) addGeometry:(AGSGeometry*)geometry;
-(BOOL) addPhote:(UIImage*)image atPoint:(AGSPoint *)point;

-(BOOL) saveTrack:(NSString *)gpx Name:(NSString *)name;

@end
