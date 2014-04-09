//
//  Projects.m
//  HomeLand
//
//  Created by chao han on 14-3-5.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "Projects.h"

@implementation Projects

@synthesize mapView;
@synthesize projects;
@synthesize curProjectIndex;

+ (Projects *)sharedProjects {
    static id sharedProjects = nil;
    if (!sharedProjects) {
        sharedProjects = [[self alloc] init];
    }
    return sharedProjects;
}

+ (NSString *)chinesename:(NSString *) enname
{
    if ([enname compare:@"id"] == NSOrderedSame) {
        return @"编号";
    }else if ([enname compare:@"name"] == NSOrderedSame) {
        return @"名称";
    }else if ([enname compare:@"time"] == NSOrderedSame) {
        return @"时间";
    }else if ([enname compare:@"photoname"] == NSOrderedSame) {
        return @"照片";
    }else if ([enname compare:@"field1"] == NSOrderedSame) {
        return @"字段1";
    }else if ([enname compare:@"field2"] == NSOrderedSame) {
        return @"字段2";
    }else if ([enname compare:@"field3"] == NSOrderedSame) {
        return @"字段3";
    }else{
        return enname;
    }
}

+ (NSString *)enname:(NSString *) chinesename
{
    if ([chinesename compare:@"编号"] == NSOrderedSame) {
        return @"id";
    }else if ([chinesename compare:@"名称"] == NSOrderedSame) {
        return @"name";
    }else if ([chinesename compare:@"时间"] == NSOrderedSame) {
        return @"time";
    }else if ([chinesename compare:@"照片"] == NSOrderedSame) {
        return @"photoname";
    }else if ([chinesename compare:@"字段1"] == NSOrderedSame) {
        return @"field1";
    }else if ([chinesename compare:@"字段2"] == NSOrderedSame) {
        return @"field2";
    }else if ([chinesename compare:@"字段3"] == NSOrderedSame) {
        return @"field3";
    }else{
        return chinesename;
    }
}

-(void) initDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 工程目录
    NSString *projectDirectory = self.projectDirectory;
    BOOL isDirectory;
    if(![fileManager fileExistsAtPath:projectDirectory isDirectory:&isDirectory])
    {
        [fileManager createDirectoryAtPath:projectDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }

    self.projects = [[NSMutableArray alloc] init];
    
    NSError *error;
    NSArray *projectDirs = [fileManager contentsOfDirectoryAtPath:projectDirectory error:&error];
    for (int i=0; i<projectDirs.count; i++) {
        NSString *projectName = [projectDirs objectAtIndex:i];
        NSString *projectDir = [projectDirectory stringByAppendingPathComponent:projectName];
        if([fileManager fileExistsAtPath:projectDir isDirectory:&isDirectory])
        {
            if(isDirectory)
            {
                [self.projects addObject:projectName];
            }
        }
    }
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSString *curProjectName = [defaults stringForKey:@"curProjectName"];
//    if (curProjectName != nil) {
//        [self openProject:curProjectName];
//    }else{
//        [self createProject:@"DefaultProject"];
//        [self openProject:@"DefaultProject"];
//    }
    if (![self openProject:@"DefaultProject"]) {
        [self createProject:@"DefaultProject"];
        [self openProject:@"DefaultProject"];
    }
}

- (NSString *) projectDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"Project"];
}


- (BOOL) createProject:(NSString *) name
{
    [self.curProject close];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 工程目录
    NSString *projectDirectory = self.projectDirectory;
    
    NSString *curprojectDir = [projectDirectory stringByAppendingPathComponent:name];
    
    if([fileManager fileExistsAtPath:curprojectDir])
    {
        return FALSE;
    }
    
    [fileManager createDirectoryAtPath:curprojectDir withIntermediateDirectories:YES attributes:nil error:nil];

    Project *project = [[Project alloc] init];
    project.mapView = self.mapView;
    [project create:curprojectDir];
    [self.projects addObject:name];
    
    self.curProject = project;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:name forKey:@"curProjectName"];
    [defaults synchronize];
    return TRUE;
}

- (BOOL) openProject:(NSString *) name
{
    [self.curProject close];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 工程目录
    NSString *projectDirectory = self.projectDirectory;
    
    NSString *curprojectDir = [projectDirectory stringByAppendingPathComponent:name];
    
    if(![fileManager fileExistsAtPath:curprojectDir])
    {
        return FALSE;
    }
    
    Project *project = [[Project alloc] init];
    project.mapView = self.mapView;
    [project open:curprojectDir];
    
    self.curProject = project;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:name forKey:@"curProjectName"];
    [defaults synchronize];
    return TRUE;
}
- (BOOL) deleteProjectByIndex:(int) index
{
    NSString *name = [self.projects objectAtIndex:index];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 工程目录
    NSString *projectDirectory = self.projectDirectory;
    
    NSString *curprojectDir = [projectDirectory stringByAppendingPathComponent:name];
    
    [fileManager removeItemAtPath:curprojectDir error:nil];
    
    [self.projects removeObjectAtIndex:index];
    return TRUE;
}

- (BOOL) deleteProjectByName:(NSString *) name
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 工程目录
    NSString *projectDirectory = self.projectDirectory;
    
    NSString *curprojectDir = [projectDirectory stringByAppendingPathComponent:name];
    
    [fileManager removeItemAtPath:curprojectDir error:nil];
    
    [self.projects delete:name];
    return TRUE;
}

@end
