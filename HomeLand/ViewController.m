//
//  ViewController.m
//  HomeLand
//
//  Created by chao han on 14-3-3.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "ViewController.h"
#import "ProjectController.h"
#import "LayerController.h"
#import "MeasureLayer.h"
#import "GPSLayer.h"
#import "EditLayer.h"
#import "AttributeController.h"
#import "RecordController.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import "DXSemiTableViewController.h"
#import "DXSemiViewControllerCategory.h"

@interface ViewController ()
{
    UIPopoverController *_layerPopover;
    //AGSPopupsContainerViewController* _popupVC;
    Reachability* _reach;
    
    MBProgressHUD* _HUD;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    
    // 判断定位操作是否被允许
    if([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.delegate = self;
        // 开始定位
        [_locationManager startUpdatingLocation];
    }
    
    [Projects sharedProjects].mapView = self.mapView;
    [[Projects sharedProjects] initDirectory];

    _reach = [Reachability reachabilityWithHostname:@"services.arcgisonline.com"];
    
    // Tell the reachability that we DON'T want to be reachable on 3G/EDGE/CDMA
    _reach.reachableOnWWAN = NO;
    
    _reach.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"REACHABLE!");
        });
    };
    
    _reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            //没网络的情况下，把在线数据移调
            [self.mapView removeMapLayerWithName:@"基础层"];
            NSLog(@"UNREACHABLE!");
        });
    };
    
    [_reach startNotifier];
    
    [self.mapView addObserver:self
                                forKeyPath:@"mapScale"
                                   options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                                   context:NULL];
    
    [self.editView addObserver:self
                    forKeyPath:@"hidden"
                       options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                       context:NULL];
    
    [self.measureView addObserver:self
                    forKeyPath:@"hidden"
                       options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld)
                       context:NULL];
    
    
    self.mapView.layerDelegate = self;
    self.mapView.touchDelegate = self;
    
    self.mapView.allowCallout = true;
    self.mapView.callout.delegate = self;
    
    [self.measureView hide:NO];
    [self.editView hide:NO];
    
    _HUD = [[MBProgressHUD alloc] init];
    [self.view addSubview:_HUD];
}

- (void)mapViewDidLoad:(AGSMapView *)mapView {
    
    NSLog(@"mapViewDidLoad!");
    [self.mapView.locationDisplay startDataSource];
    
    // register for pan notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:)
                                                 name:AGSMapViewDidEndPanningNotification object:nil];
    
    // register for zoom notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToEnvChange:)
                                                 name:AGSMapViewDidEndZoomingNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = TRUE;
    
    EditLayer *sketchLayer = (EditLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    if (sketchLayer.geometry == nil) {
        self.editpointbutton.selected = NO;
        self.editlinebutton.selected = NO;
        self.editregionbutton.selected = NO;
        self.editautoinput.selected = NO;
    }
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    

}

# pragma table
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gpsloggerTouch:(id)sender {
    GPSLayer *gpsLayer = (GPSLayer *)[self.mapView mapLayerForName:@"GPS layer"];
    
    UIButton *button = (UIButton *)sender;
    if (gpsLayer.enableLogger) {
        [gpsLayer stopLogger];
        button.selected = NO;
    }else{
        [gpsLayer startLogger];
        button.selected = YES;
    }
}

- (IBAction)measureErea:(id)sender {
    
    MeasureLayer *measureLayer = (MeasureLayer *)[self.mapView mapLayerForName:@"Measure layer"];
    measureLayer.measureout = self.measureout;
    [measureLayer setMeasureType:AGSGeometryTypePolygon];
    _mapView.touchDelegate=measureLayer;
    
    self.measurelinebutton.selected = NO;
    self.measureareabutton.selected = YES;
}

- (IBAction)measureLine:(id)sender {
    MeasureLayer *measureLayer = (MeasureLayer *)[self.mapView mapLayerForName:@"Measure layer"];
    measureLayer.measureout = self.measureout;
    [measureLayer setMeasureType:AGSGeometryTypePolyline];
    _mapView.touchDelegate=measureLayer;
    
    self.measurelinebutton.selected = YES;
    self.measureareabutton.selected = NO;
}


- (IBAction)measureRedo:(id)sender {
    MeasureLayer *measureLayer = (MeasureLayer *)[self.mapView mapLayerForName:@"Measure layer"];
    [measureLayer.undoManager redo];
}

- (IBAction)measureUndo:(id)sender {
    MeasureLayer *measureLayer = (MeasureLayer *)[self.mapView mapLayerForName:@"Measure layer"];
    [measureLayer.undoManager undo];
}

- (IBAction)measureClear:(id)sender {
    MeasureLayer *measureLayer = (MeasureLayer *)[self.mapView mapLayerForName:@"Measure layer"];
    [measureLayer clear];
    self.measureout.hidden = true;
}

- (IBAction)editpoint:(id)sender {
    EditLayer *sketchLayer = (EditLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    //点
    sketchLayer.geometry = [[AGSMutablePoint alloc] initWithX:NAN y:NAN spatialReference:_mapView.spatialReference];
    _mapView.touchDelegate=sketchLayer;
    
    self.editpointbutton.selected = YES;
    self.editlinebutton.selected = NO;
    self.editregionbutton.selected = NO;
}

- (IBAction)editline:(id)sender {
    EditLayer *sketchLayer = (EditLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    //线
    sketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:_mapView.spatialReference];
    _mapView.touchDelegate=sketchLayer;
    
    self.editpointbutton.selected = NO;
    self.editlinebutton.selected = YES;
    self.editregionbutton.selected = NO;
}

- (IBAction)editRegion:(id)sender {
    EditLayer *sketchLayer = (EditLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    //面
    sketchLayer.geometry = [[AGSMutablePolygon alloc] initWithSpatialReference:_mapView.spatialReference];
    _mapView.touchDelegate=sketchLayer;
    
    self.editpointbutton.selected = NO;
    self.editlinebutton.selected = NO;
    self.editregionbutton.selected = YES;
}

- (IBAction)editDeleteSelect:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除记录" message:@"是否删除记录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if(buttonIndex == 1)
    {
//        callout.representedFeature;
//        [[Projects sharedProjects].curProject removeGraphic:graphic];
//        [self mapView.callout dismiss];
//        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)editMoveSelect:(id)sender {
}

- (IBAction)editProperty:(id)sender {
}

- (IBAction)viewAll:(id)sender {
    AGSEnvelope *fullEnvelope = self.mapView.maxEnvelope;
    [self.mapView zoomToEnvelope:fullEnvelope animated:YES];
}

- (IBAction)goMyPos:(id)sender {
    
    if (self.mapView.locationDisplay.mapLocation == nil) {
        _HUD.yOffset = 300;
        _HUD.mode = MBProgressHUDModeText;
        _HUD.labelText = @"无法获取当前位置";
        [_HUD show:YES];
        
        [_HUD hide:YES afterDelay:2.0];
        return;
    }
    double x = self.mapView.locationDisplay.mapLocation.x;
    double y = self.mapView.locationDisplay.mapLocation.y;
    
    AGSPoint *point = [[AGSPoint alloc] initWithX:x y:y spatialReference:[AGSSpatialReference wgs84SpatialReference]];
    
    [self.mapView centerAtPoint:point animated:YES];
    

    //[self.mapView.callout showCalloutAt:point screenOffset:<#(CGPoint)#> animated:<#(BOOL)#>
}

- (IBAction)gpsinput:(id)sender {
    EditLayer *sketchLayer = (EditLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    [sketchLayer addGPSPoint:_locationManager.location];
}

- (IBAction)autoinput:(id)sender {
    EditLayer *sketchLayer = (EditLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    sketchLayer.autoInput = !sketchLayer.autoInput;
    
    self.editautoinput.selected = sketchLayer.autoInput;
}

- (IBAction)editredo:(id)sender {
    EditLayer *sketchLayer = (EditLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    [sketchLayer.undoManager redo];
}

- (IBAction)editundo:(id)sender {
    EditLayer *sketchLayer = (EditLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    [sketchLayer.undoManager undo];
}

- (IBAction)editsave:(id)sender {
//    EditLayer *sketchLayer = (EditLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
//    [[Projects sharedProjects].curProject addGeometry:sketchLayer.geometry];
//    [sketchLayer clear];
    
    EditLayer *sketchLayer = (EditLayer *)[[Projects sharedProjects].curProject.mapView mapLayerForName:@"Sketch layer"];
    if(sketchLayer.geometry == nil)
        return;
    
    UIStoryboard * storyBoard;
    AttributeController *projectController;
    
    storyBoard  = [UIStoryboard
                   storyboardWithName:@"Main_iPad" bundle:nil];
    
    projectController = [storyBoard instantiateViewControllerWithIdentifier:@"AttributeController"];
    [self.navigationController pushViewController:projectController animated:YES];
    
}

- (IBAction)editclear:(id)sender {
    EditLayer *sketchLayer = (EditLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    [sketchLayer clear];
    sketchLayer.geometry = nil;
    
    self.editpointbutton.selected = NO;
    self.editlinebutton.selected = NO;
    self.editregionbutton.selected = NO;
    self.editautoinput.selected = NO;
}

- (IBAction)openProjecTouch:(id)sender {
    [self openProject];
}

- (IBAction)LayerManageTouch:(id)sender {
//    UIStoryboard * storyBoard;
//    LayerController *projectController;
//    
//    storyBoard  = [UIStoryboard
//                   storyboardWithName:@"Main_iPad" bundle:nil];
//    
//    projectController = [storyBoard instantiateViewControllerWithIdentifier:@"LayerController"];
//    //projectController.graphic = callout.representedFeature;
//    
//    _layerPopover = [[UIPopoverController alloc] initWithContentViewController:projectController];
//    //    [colorPickerPopover presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender
//    //                               permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
//    
//    CGRect rect=[[UIScreen mainScreen] bounds];
//    _layerPopover.popoverContentSize = CGSizeMake(rect.size.width/2, rect.size.height);
//    
//    [_layerPopover presentPopoverFromRect:((UIView *)sender).frame inView:self.mapView permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES ];
//    return ;
}

- (IBAction)photographTouch:(id)sender {
    [self photograph];
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (IBAction)photoManageTouch:(id)sender {
    
    NSMutableArray *allPhoto = [Projects sharedProjects].curProject.allPhoto;
    
    // Create array of MWPhoto objects
    _photos = [NSMutableArray array];
    for (int i=0; i<allPhoto.count; i++) {
        Photo *photo = (Photo *)[allPhoto objectAtIndex:i];
        MWPhoto *mwphoto = [MWPhoto photoWithImage:photo.image];
        mwphoto.caption = photo.fileName;
        [_photos addObject:mwphoto];
    }

    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    browser.enableGrid = YES;
    browser.startOnGrid = YES;
    browser.displayNavArrows = YES;


    [self.navigationController pushViewController:browser animated:YES];

}

- (IBAction)DataInputTouch:(id)sender {
    [self openEdit];
}

- (IBAction)DataSearchTouch:(id)sender {
    self.searchbar.hidden = !self.searchbar.hidden;
    if (!self.searchbar.hidden) {
        [self.searchbar becomeFirstResponder];
    }
    
}

- (IBAction)DataManageTouch:(id)sender {
//    
//    DXSemiTableViewController *tg = [DXSemiTableViewController new];
//    self.leftSemiViewController = tg;
}

- (IBAction)MeasureTouch:(id)sender {
    [self openmeasure];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    GPSLayer *gpsLayer = (GPSLayer *)[self.mapView mapLayerForName:@"GPS layer"];
    if (gpsLayer.enableLogger) {
        [gpsLayer addGPSPoint:newLocation];
        
        //保存轨迹文件
        //[[Projects sharedProjects].curProject saveTrack:gpsLayer.gpxString Name:gpsLayer.gpxName];
    }
    
    
    EditLayer *sketchLayer = (EditLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    if (sketchLayer.autoInput) {
        [sketchLayer addGPSPoint:newLocation];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {

}

-(void) selectphoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;   // 设置委托
    imagePickerController.sourceType = sourceType;
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];  //需要以模态的形式展示
}

-(void) photograph
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    //判断是否有摄像头
    if(![UIImagePickerController isSourceTypeAvailable:sourceType])
    {
        return;
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;   // 设置委托
    imagePickerController.sourceType = sourceType;
    imagePickerController.allowsEditing = YES;
    [self presentViewController:imagePickerController animated:YES completion:nil];  //需要以模态的形式展示
}

#pragma mark -
#pragma mark UIImagePickerController Method

//完成拍照
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil)
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self performSelector:@selector(saveImage:) withObject:image];
    
}
//用户取消拍照
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//将照片保存到disk上
-(void)saveImage:(UIImage *)image
{
    
    double x = self.mapView.locationDisplay.mapLocation.x;
    double y = self.mapView.locationDisplay.mapLocation.y;
    
    AGSPoint *point = [[AGSPoint alloc] initWithX:x y:y spatialReference:[AGSSpatialReference wgs84SpatialReference]];
    
    Photo * photo = [[Photo alloc] init];
    photo.image = image;
    photo.point = point;
    [[Projects sharedProjects].curProject addPhoto:photo];
}

-(void) openProject
{
    //OpenProjectController *openProjectController = [[OpenProjectController alloc] init];
    //[self presentViewController:openProjectController animated:YES completion:nil];  //需要以模态的形式展示
//    UIStoryboard * storyBoard;
//    ProjectController *projectController;
//
//    storyBoard  = [UIStoryboard
//                   storyboardWithName:@"Main_iPad" bundle:nil];
//    
//    projectController = [storyBoard instantiateViewControllerWithIdentifier:@"ProjectController"];
//    
//    [self.navigationController pushViewController:projectController animated:YES];
    
    if(![[Projects sharedProjects] openProject:@"Project"])
    {
        [[Projects sharedProjects] createProject:@"Project"];
        if(![[Projects sharedProjects] openProject:@"Project"]){
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"打开工程失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            [alert show];
            _HUD.yOffset = 300;
            _HUD.mode = MBProgressHUDModeText;
            _HUD.labelText = @"打开工程失败";
            [_HUD show:YES];
            
            [_HUD hide:YES afterDelay:2.0];
        }
    }
    else
    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"打开工程成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//        [alert show];
        _HUD.yOffset = 300;
        _HUD.mode = MBProgressHUDModeText;
        _HUD.labelText = @"打开工程成功";
        [_HUD show:YES];
        
        [_HUD hide:YES afterDelay:2.0];
    }
}

-(void) openmeasure
{
    if (!self.editView.hidden) {
        self.editView.hidden = true;
        EditLayer *sketchLayer = (EditLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
        sketchLayer.autoInput = NO;
        self.mapView.touchDelegate=nil;
        sketchLayer.geometry=nil;
        [sketchLayer clear];
        
        self.editpointbutton.selected = NO;
        self.editlinebutton.selected = NO;
        self.editregionbutton.selected = NO;
        self.editautoinput.selected = NO;
    }
    self.measureView.hidden = !self.measureView.hidden;
    if (!self.measureView.hidden) {
        
    }else{
        MeasureLayer *measureLayer = (MeasureLayer *)[self.mapView mapLayerForName:@"Measure layer"];
        self.mapView.touchDelegate=nil;
        measureLayer.geometry=nil;
        [measureLayer clear];
        self.measureout.hidden = true;
        
        self.measurelinebutton.selected = NO;
        self.measureareabutton.selected = NO;
    }
}

-(void) openEdit
{
    if (!self.measureView.hidden) {
        self.measureView.hidden = true;
        MeasureLayer *measureLayer = (MeasureLayer *)[self.mapView mapLayerForName:@"Measure layer"];

        self.mapView.touchDelegate=nil;
        measureLayer.geometry=nil;
        [measureLayer clear];
        
        self.measurelinebutton.selected = NO;
        self.measureareabutton.selected = NO;
    }
    self.editView.hidden = !self.editView.hidden;
    if (!self.editView.hidden) {
        
    }else{
        EditLayer *sketchLayer = (EditLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
        sketchLayer.autoInput = NO;
        self.mapView.touchDelegate=nil;
        sketchLayer.geometry=nil;
        [sketchLayer clear];
        
        self.editpointbutton.selected = NO;
        self.editlinebutton.selected = NO;
        self.editregionbutton.selected = NO;
        self.editautoinput.selected = NO;
    }
}



- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath compare:@"hidden"] == NSOrderedSame && object == self.editView) {
        self.editbutton.selected = ![[change objectForKey:NSKeyValueChangeNewKey] boolValue];
    }else if ([keyPath compare:@"hidden"] == NSOrderedSame && object == self.measureView) {
        self.measurebutton.selected = ![[change objectForKey:NSKeyValueChangeNewKey] boolValue];
    }else if ([keyPath compare:@"mapScale"] == NSOrderedSame && object == self.mapView){
        NSString *scaleInfo;
        if (self.mapView.mapScale > 10000) {
            scaleInfo = [[NSString alloc] initWithFormat:@"1:%.02f万",self.mapView.mapScale/10000];
        }else{
            scaleInfo = [[NSString alloc] initWithFormat:@"1:%.02f",self.mapView.mapScale];
        }
        self.mapScaleLabel.text = scaleInfo;
    }
}

-(void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    NSLog(@"didClickAtPoint");
}


-(BOOL)callout:(AGSCallout*)callout willShowForFeature:(id<AGSFeature>)feature layer:(AGSLayer<AGSHitTestable>*)layer mapPoint:(AGSPoint*)mapPoint{
    NSLog(@"willShowForFeature");
	//Specify the callout's contents
    
    EditLayer *sketchLayer = (EditLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    if (sketchLayer.isEditing) {
        return NO;
    }
    
    MeasureLayer *measureLayer = (MeasureLayer *)[self.mapView mapLayerForName:@"Measure layer"];
    if (measureLayer.isMeasure) {
        return NO;
    }
    
    if ([layer.name isEqualToString:@"GPS layer"]) {
        return NO;
    }
    
    self.mapView.callout.customView = nil;
    self.mapView.callout.title = nil;
    self.mapView.callout.image = nil;
    
    if ([layer.name isEqualToString:@"照片"]) {
        NSString *filename = (NSString*)[feature attributeForKey:@"filename"];

        UIImage *image = [[Projects sharedProjects].curProject photoWithName:filename];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0,0,image.size.width/2, image.size.height/2);
        self.mapView.callout.customView = imageView;
        return YES;
    }
    
//    if ([layer.name compare:@"DMD"] == NSOrderedSame ) {
//        self.mapView.callout.title = (NSString*)[feature attributeForKey:@"NAME"];
//    }else if ([layer.name compare:@"WPZFTB"] == NSOrderedSame ) {
//        self.mapView.callout.title = (NSString*)[feature attributeForKey:@"TBBH"];
//    }else if ([layer.name compare:@"TDPW"] == NSOrderedSame ) {
//        self.mapView.callout.title = (NSString*)[feature attributeForKey:@"SPZWH"];
//    }else{
//        self.mapView.callout.title = (NSString*)[feature attributeForKey:@"name"];
//    }
    
    if ([feature hasAttributeForKey:@"NAME"]) {
        self.mapView.callout.title = (NSString*)[feature attributeForKey:@"NAME"];
    }else if ([feature hasAttributeForKey:@"name"]) {
        self.mapView.callout.title = (NSString*)[feature attributeForKey:@"name"];
    }else if ([feature hasAttributeForKey:@"TBBH"]) {
        self.mapView.callout.title = (NSString*)[feature attributeForKey:@"TBBH"];
    }else if ([feature hasAttributeForKey:@"SPZWH"]) {
        self.mapView.callout.title = (NSString*)[feature attributeForKey:@"SPZWH"];
    }else if ([feature hasAttributeForKey:@"BSM"]) {
        self.mapView.callout.title = (NSString*)[feature attributeForKey:@"BSM"];
    }else{
        self.mapView.callout.title = @"未命名";
    }

    if(self.mapView.callout.title.length == 0)
    {
        self.mapView.callout.title = @"未命名";
    }
    
    if ([feature hasAttributeForKey:@"photoname"]) {
        NSString *photoname = (NSString*)[feature attributeForKey:@"photoname"];
        UIImage *image = [[Projects sharedProjects].curProject photoWithName:photoname];
        self.mapView.callout.image = image;
    }
    
 //   AGSGraphicsLayer *graphicsLayer = (AGSGraphicsLayer *)layer;
 //   [graphicsLayer setSelected:YES forGraphic:feature];

	return YES;
}

- (void)didClickAccessoryButtonForCallout:(AGSCallout *)callout
{
    NSLog(@"didClickAccessoryButtonForCallout");

        UIStoryboard * storyBoard;
        AttributeController *projectController;
    
        storyBoard  = [UIStoryboard
                       storyboardWithName:@"Main_iPad" bundle:nil];
    
        projectController = [storyBoard instantiateViewControllerWithIdentifier:@"AttributeController"];
    projectController.graphic = (AGSGraphic *)callout.representedFeature;
        [self.navigationController pushViewController:projectController animated:YES];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"LayerSegue"] ||
        [segue.identifier isEqualToString:@"ManageSegue"]) {
        
        UIStoryboardPopoverSegue *popoverSegue;
        popoverSegue=(UIStoryboardPopoverSegue *)segue;
        
        UIPopoverController *popoverController;
        popoverController=popoverSegue.popoverController;
        
        popoverController.delegate = self;

        CGRect rect=[[UIScreen mainScreen] bounds];

        popoverController.popoverContentSize = CGSizeMake(rect.size.width/2, rect.size.height*4/5);
    }
    
//    UIViewController * destinationViewController = (UIViewController *)segue.destinationViewController;
//    destinationViewController.navigationController.navigationBarHidden = FALSE;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarSearchButtonClicked");
    
    _HUD.mode = MBProgressHUDModeIndeterminate;
    _HUD.labelText = NSLocalizedString(@"查询中", nil);
    [_HUD show:YES];
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSMutableArray * result = [[Projects sharedProjects].curProject search:searchBar.text];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (result == nil || result.count == 0) {
                //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有查询的数据" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                //        [alert show];
                _HUD.yOffset = 300;
                _HUD.mode = MBProgressHUDModeText;
                _HUD.labelText = @"没有查询的数据";
                [_HUD show:YES];
                
                [_HUD hide:YES afterDelay:2.0];
                
                [searchBar resignFirstResponder];
                return;
            }
            else
            {
                [_HUD hide:YES];
            }
            
            searchBar.hidden = YES;
            
            UIStoryboard * storyBoard;
            RecordController *recordController;
            
            storyBoard  = [UIStoryboard
                           storyboardWithName:@"Main_iPad" bundle:nil];
            
            recordController = [storyBoard instantiateViewControllerWithIdentifier:@"RecordController"];
            
            recordController.searchResults = result;
            [self.navigationController pushViewController:recordController animated:YES];
        });
    });
    
    [searchBar resignFirstResponder];
    
//    if (result == nil || result.count == 0) {
////        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有查询的数据" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
////        [alert show];
//        _HUD.yOffset = 300;
//        _HUD.mode = MBProgressHUDModeText;
//        _HUD.labelText = @"没有查询的数据";
//        [_HUD show:YES];
//        
//        [_HUD hide:YES afterDelay:2.0];
//        
//        [searchBar resignFirstResponder];
//        return;
//    }
//    [searchBar resignFirstResponder];
//    searchBar.hidden = YES;
//    
//    UIStoryboard * storyBoard;
//    RecordController *recordController;
//    
//    storyBoard  = [UIStoryboard
//                   storyboardWithName:@"Main_iPad" bundle:nil];
//    
//    recordController = [storyBoard instantiateViewControllerWithIdentifier:@"RecordController"];
//    
//    recordController.graphics = result;
//    [self.navigationController pushViewController:recordController animated:YES];
}

// The method that should be called when the notification arises
- (void)respondToEnvChange: (NSNotification*) notification {
    
    //create the string containing the new map extent NSString*
    NSString* theString = [[NSString alloc] initWithFormat:@"xmin = %f,\nymin = %f,\nxmax = %f,\nymax = %f", _mapView.visibleAreaEnvelope.xmin,
                           _mapView.visibleAreaEnvelope.ymin, _mapView.visibleAreaEnvelope.xmax,
                           _mapView.visibleAreaEnvelope.ymax];
    
    NSLog(@"%@",theString);
    
    [[Projects sharedProjects].curProject refreshBaseLayerEnvelope:_mapView.visibleAreaEnvelope];
    
//
//    //display the new map extent in a simple alert
//    UIAlertView* alertView = [[UIAlertView alloc]	initWithTitle:@"Finished Panning"
//                                                        message:theString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alertView show];
    
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    UIViewController *viewController = popoverController.contentViewController;
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)viewController;
        if ([navigationController.visibleViewController isKindOfClass:[LayerController class]]) {
            [[Projects sharedProjects].curProject save];
            [[Projects sharedProjects].curProject refreshMaxEnvelope];
        }
    }
}

@end




