//
//  EditLayer.h
//  HomeLand
//
//  Created by chao han on 14-3-18.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface EditLayer : AGSSketchGraphicsLayer

@property (nonatomic) BOOL autoInput;

- (void) addGPSPoint:(CLLocation *)newLocation;

- (BOOL) isEditing;

@end
