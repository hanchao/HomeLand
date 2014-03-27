//
//  AttributeController.h
//  HomeLand
//
//  Created by chao han on 14-3-20.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface AttributeController : UIViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate>
{
    NSMutableArray* _fieldInfos;
    UIImage *_image;
}

@property (nonatomic) BOOL isAddNew;
@property (nonatomic) AGSGraphic* graphic;

@property (weak, nonatomic) IBOutlet UITableView *tableview;
- (IBAction)TextField_DidEndOnExit:(id)sender;
- (IBAction)photo:(id)sender;

@end
