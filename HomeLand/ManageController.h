//
//  ManageController.h
//  HomeLand
//
//  Created by chao han on 14-3-25.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "Projects.h"
#import "Project.h"

@interface ManageController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate>
{
    NSArray *_layerName;
}

@property (weak, nonatomic) IBOutlet UITableView *recordTable;
@property (weak, nonatomic) IBOutlet UIButton *selectLayerButton;
@property (weak, nonatomic) IBOutlet UIPickerView *layerPicker;
@property (weak, nonatomic) IBOutlet UIView *selectView;
- (IBAction)selectlayerTouch:(id)sender;
- (IBAction)selectedLayerTouch:(id)sender;

@end