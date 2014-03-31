//
//  ViewController.h
//  HomeLand
//
//  Created by chao han on 14-3-3.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "Project.h"
#import "Projects.h"
#import "GPX/GPX.h"
#import "BottomAnimateView.h"
#import "../MWPhotoBrowser/Classes/MWPhotoBrowser.h"

@interface ViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate,CLLocationManagerDelegate,AGSMapViewLayerDelegate,AGSMapViewTouchDelegate,AGSCalloutDelegate,UIAlertViewDelegate,UISearchBarDelegate,MWPhotoBrowserDelegate>
{
    NSArray* _buttonTitle;
    CLLocationManager *_locationManager;
    NSMutableArray *_photos;
}
@property (strong, nonatomic) IBOutlet AGSMapView *mapView;
@property (weak, nonatomic) IBOutlet BottomAnimateView *measureView;
@property (weak, nonatomic) IBOutlet BottomAnimateView *editView;
@property (weak, nonatomic) IBOutlet UILabel *measureout;
@property (weak, nonatomic) IBOutlet UILabel *mapScaleLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchbar;
@property (weak, nonatomic) IBOutlet UIButton *measurebutton;
@property (weak, nonatomic) IBOutlet UIButton *editbutton;
@property (weak, nonatomic) IBOutlet UIButton *measureareabutton;
@property (weak, nonatomic) IBOutlet UIButton *measurelinebutton;
@property (weak, nonatomic) IBOutlet UIButton *editpointbutton;
@property (weak, nonatomic) IBOutlet UIButton *editlinebutton;
@property (weak, nonatomic) IBOutlet UIButton *editregionbutton;
@property (weak, nonatomic) IBOutlet UIButton *editautoinput;


- (IBAction)gpsloggerTouch:(id)sender;
- (IBAction)leftButtonTouch:(id)sender;
- (IBAction)measureErea:(id)sender;
- (IBAction)measureLine:(id)sender;
- (IBAction)measure:(id)sender;
- (IBAction)measureRedo:(id)sender;
- (IBAction)measureUndo:(id)sender;
- (IBAction)measureClear:(id)sender;
- (IBAction)editpoint:(id)sender;
- (IBAction)editline:(id)sender;
- (IBAction)editRegion:(id)sender;
- (IBAction)editDeleteSelect:(id)sender;
- (IBAction)editMoveSelect:(id)sender;
- (IBAction)editProperty:(id)sender;


- (IBAction)viewAll:(id)sender;
- (IBAction)goMyPos:(id)sender;
- (IBAction)opengps:(id)sender;
- (IBAction)edittype:(id)sender;
- (IBAction)gpsinput:(id)sender;
- (IBAction)autoinput:(id)sender;
- (IBAction)editredo:(id)sender;
- (IBAction)editundo:(id)sender;
- (IBAction)editsave:(id)sender;
- (IBAction)editclear:(id)sender;
- (IBAction)openProjecTouch:(id)sender;
- (IBAction)LayerManageTouch:(id)sender;
- (IBAction)photographTouch:(id)sender;
- (IBAction)photoManageTouch:(id)sender;
- (IBAction)DataInputTouch:(id)sender;
- (IBAction)DataSearchTouch:(id)sender;
- (IBAction)DataManageTouch:(id)sender;
- (IBAction)MeasureTouch:(id)sender;

@end
