//
//  MeasureLayer.m
//  HomeLand
//
//  Created by chao han on 14-3-17.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "MeasureLayer.h"

@implementation MeasureLayer
@synthesize measureout;


- (void) setMeasureType:(AGSGeometryType)geometryType
{
    switch (geometryType) {
        case AGSGeometryTypePolyline:
        {
            //线
            self.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:nil];
            break;
        }
        case AGSGeometryTypePolygon:
        {
            //面
            self.geometry = [[AGSMutablePolygon alloc] initWithSpatialReference:nil];
            break;
        }
        default:
            break;
    }
}

- (void) clear
{
    [super clear];
}

- (BOOL) isMeasure
{
    return self.geometry != nil;
}

-(void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features
{
    [super mapView:mapView didClickAtPoint:screen mapPoint:mappoint features:features];
    
    //计算结果
    NSString *measureInfo;
    AGSGeometryEngine *geometryEngine = [[AGSGeometryEngine alloc] init];
    if (AGSGeometryTypeForGeometry(self.geometry) == AGSGeometryTypePolyline) {
        double length = [geometryEngine lengthOfGeometry:self.geometry];
      
        if(length == 0.0)
        {
            return;
        }
        if (length > 1000) {
            measureInfo = [[NSString alloc] initWithFormat:@"长度%.02f公里",length/1000];
        }
        else{
            measureInfo = [[NSString alloc] initWithFormat:@"长度%.02f米",length];
        }
    }
    else if (AGSGeometryTypeForGeometry(self.geometry) == AGSGeometryTypePolygon) {
        double area = fabs([geometryEngine areaOfGeometry:self.geometry]);
        
        if(area == 0.0)
        {
            return;
        }
        if (area > 1000000) {
            measureInfo = [[NSString alloc] initWithFormat:@"面积%.02f平方公里",area/1000000];
        }
        else{
            measureInfo = [[NSString alloc] initWithFormat:@"面积%.02f平方米",area];
        }
    }
    else{
        return;
    }
    
    self.measureout.text = measureInfo;
    self.measureout.hidden = false;
}

@end
