//
//  MeasureLayer.h
//  HomeLand
//
//  Created by chao han on 14-3-17.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface MeasureLayer : AGSSketchGraphicsLayer


@property (weak, nonatomic) UILabel *measureout;

- (void) setMeasureType:(AGSGeometryType)geometryType;
- (void) clear;

-(void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint features:(NSDictionary *)features;

@end
