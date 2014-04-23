//
//  LayerController.h
//  HomeLand
//
//  Created by chao han on 14-3-7.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "Projects.h"
#import "Project.h"
#import "PSDirectoryPickerController.h"

@interface LayerController : UITableViewController<PSDirectoryPickerDelegate>

- (IBAction)layerswitch:(id)sender;

@end
