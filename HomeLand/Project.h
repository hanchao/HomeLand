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
#import "Photo.h"
//#import "GPX/GPX.h"

#define HL_POINT @"点"
#define HL_LINE @"线"
#define HL_REGION @"面"

#define HL_L_TPK 0
#define HL_L_SPATIALTE 1
#define HL_L_TMS 2

@interface LayerDefinition : NSObject<NSCoding>

@property (nonatomic) NSString* name;
@property (nonatomic) int type;
@property (nonatomic) BOOL visible;
@end

@interface Project : NSObject
{
    sqlite3 *_basehandle;
    sqlite3 *_handle;
}

@property (weak, nonatomic) AGSMapView *mapView;
@property (nonatomic) BOOL opened;
@property (nonatomic) NSString * path;
@property (nonatomic) NSMutableArray *layers;

- (id)init;

-(BOOL) create:(NSString *)path;
-(BOOL) open:(NSString *)path;
-(BOOL) save;
-(BOOL) close;

-(NSMutableArray*) allFieldInfo:(AGSGeometryType)geometryType;
-(BOOL) addGeometry:(AGSGeometry*)geometry;
-(BOOL) addGraphic:(AGSGraphic*)graphic;
-(BOOL) saveGraphic:(AGSGraphic*)graphic;
-(BOOL) removeGraphic:(AGSGraphic*)graphic;

-(NSMutableArray*) search:(NSString *)key;

-(NSString *) addPhoto:(Photo*)photo;
-(NSInteger) photoCount;
-(NSMutableArray*) allPhoto;
-(UIImage *) photoWithName:(NSString *)name;

-(BOOL) saveTrack:(NSString *)gpx Name:(NSString *)name;

-(NSMutableArray*) allFieldInfoBase:(NSString *)name;


-(NSMutableArray *)allBaseLayerName;
-(NSMutableArray *)allLayerName;

-(void)refreshBaseLayerEnvelope:(AGSEnvelope *)envelop;
-(NSMutableArray *)queryAtLayer:(NSString *)name Envelope:(AGSEnvelope *)envelop;

-(BOOL) openTpk:(NSString*) path;
@end
