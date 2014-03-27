//
//  EditLayer.m
//  HomeLand
//
//  Created by chao han on 14-3-18.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "EditLayer.h"

@implementation EditLayer

@synthesize autoInput;

-(void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)graphics
{
    [super mapView:mapView didClickAtPoint:screen mapPoint:mappoint features:graphics];
    
//    [self.localFeatureTableLayer clearSelection];
//    if (features){
//        for (AGSGDBFeature *feature in [features valueForKey:@"Offline Feature Layer"]) {
//            [self.localFeatureTableLayer setSelected:YES forFeature:feature];
//        }
//    }

 //   if (self.geometry == nil) {
//        if (graphics.allValues.count>0) {
//            NSArray *layer = (NSArray *)[graphics.allValues objectAtIndex:0];
//            if (layer.count>0) {
//                AGSGraphic *graphic = (AGSGraphic *)[layer objectAtIndex:0];
//                self.geometry = graphic.geometry;
//            }
//        }
 //   }
    
}

- (void) addGPSPoint:(CLLocation *)newLocation
{
    AGSSpatialReference *srWGS84 = [AGSSpatialReference spatialReferenceWithWKID:4326];
    AGSSpatialReference *srMap = [AGSSpatialReference spatialReferenceWithWKID:102100];
    
    AGSPoint *point = [[AGSPoint alloc] initWithX:newLocation.coordinate.longitude y:newLocation.coordinate.latitude spatialReference:srWGS84];
    
    AGSGeometryEngine *geometryEngine = [[AGSGeometryEngine alloc] init];
    AGSPoint *pointMap = (AGSPoint *)[geometryEngine projectGeometry:point toSpatialReference:srMap];
    
    //add to last
    [self insertVertex:pointMap inPart:0 atIndex:-1];
    
}

- (BOOL) isEditing
{
    return self.geometry != nil;
}

@end
