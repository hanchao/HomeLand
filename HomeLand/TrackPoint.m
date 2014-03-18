//
//  TrackPoint.m
//  GPSLogger
//
//  Created by NextBusinessSystem on 12/01/26.
//  Copyright (c) 2012 NextBusinessSystem Co., Ltd. All rights reserved.
//

#import "TrackPoint.h"
#import "Track.h"


@implementation TrackPoint

@synthesize longitude;
@synthesize latitude;
@synthesize created;
@synthesize altitude;


- (CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(self.latitude.floatValue, self.longitude.floatValue);
}

@end
