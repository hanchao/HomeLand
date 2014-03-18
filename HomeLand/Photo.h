//
//  Photo.h
//  HomeLand
//
//  Created by chao han on 14-3-18.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface Photo : NSObject

@property (nonatomic) UIImage* image;
@property (nonatomic) AGSPoint* point;
@property (nonatomic) NSString* fileName;


@end
