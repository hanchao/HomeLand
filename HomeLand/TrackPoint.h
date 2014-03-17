//
//  TrackPoint.h
//  GPSLogger
//
//  Created by NextBusinessSystem on 12/01/26.
//  Copyright (c) 2012 NextBusinessSystem Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Track;

@interface TrackPoint : NSObject

@property (nonatomic) NSNumber * longitude;
@property (nonatomic) NSNumber * latitude;
@property (nonatomic) NSDate * created;
@property (nonatomic) NSNumber * altitude;

- (CLLocationCoordinate2D)coordinate;

@end
