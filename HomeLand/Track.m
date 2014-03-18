//
//  Track.m
//  GPSLogger
//
//  Created by NextBusinessSystem on 12/01/26.
//  Copyright (c) 2012 NextBusinessSystem Co., Ltd. All rights reserved.
//

#import "Track.h"
#import "TrackPoint.h"


@implementation Track

@synthesize created;
@synthesize trackpoints;

- (void)addTrackpointsObject:(TrackPoint *)value
{
    [self.trackpoints addObject:value];
}

@end
