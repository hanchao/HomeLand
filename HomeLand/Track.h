//
//  Track.h
//  GPSLogger
//
//  Created by NextBusinessSystem on 12/01/26.
//  Copyright (c) 2012 NextBusinessSystem Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TrackPoint;

@interface Track : NSObject

@property (nonatomic) NSDate * created;
@property (nonatomic) NSMutableArray *trackpoints;

- (void)addTrackpointsObject:(TrackPoint *)value;


@end
