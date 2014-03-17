//
//  Projects.h
//  HomeLand
//
//  Created by chao han on 14-3-5.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Project.h"
@interface Projects : NSObject

+ (Projects *)sharedProjects;

- (NSString *) projectDirectory;

- (void) initDirectory;

- (BOOL) createProject:(NSString *) name;
- (BOOL) openProject:(NSString *) name;
- (BOOL) deleteProjectByIndex:(int) index;
- (BOOL) deleteProjectByName:(NSString *) name;
@property (weak, nonatomic) AGSMapView *mapView;
@property (nonatomic) NSMutableArray *projects;
@property (nonatomic) int curProjectIndex;
@property (nonatomic) Project* curProject;
@end
