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


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    //self.mapView.hidden = YES;
    
//    [self.rightBarView setDelegate:self];
//    [self.rightBarView setDataSource:self];

//    UIButton *pButton = [[UIButton alloc] initWithFrame:CGRectMake(0,0,100,100)];
//    [pButton setTitle:@"返回" forState:UIControlStateNormal];
//    [self.mapView addSubview:pButton];
    
    // 判断定位操作是否被允许
    if([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.delegate = self;
        // 开始定位
        [_locationManager startUpdatingLocation];
    }
    
    _buttonTitle = [[NSArray alloc] initWithObjects:@"打开工程", @"图层管理",@"照片采集",@"照片浏览",@"图斑采集",@"图斑查询",@"图斑管理",@"量算",@"导出数据",nil];
    
    [Projects sharedProjects].mapView = self.mapView;
    [[Projects sharedProjects] initDirectory];

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
}

- (void)mapViewDidLoad:(AGSMapView *)mapView {
    
    [self.mapView.locationDisplay startDataSource];
    
    
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
    AGSEnvelope *fullEnvelope = self.mapView.baseLayer.fullEnvelope;
    [self.mapView zoomToEnvelope:fullEnvelope animated:YES];
}

- (IBAction)goMyPos:(id)sender {
    
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
    
}

- (IBAction)editclear:(id)sender {
    EditLayer *sketchLayer = (EditLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    [sketchLayer clear];
    sketchLayer.geometry = nil;
}

- (IBAction)openProjecTouch:(id)sender {
    [self openProject];
}

- (IBAction)LayerManageTouch:(id)sender {
    [self openLayer];
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
        [[Projects sharedProjects].curProject saveTrack:gpsLayer.gpxString Name:gpsLayer.gpxName];
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
}

-(void) openLayer
{
    //OpenProjectController *openProjectController = [[OpenProjectController alloc] init];
    //[self presentViewController:openProjectController animated:YES completion:nil];  //需要以模态的形式展示
    
//    UIStoryboard * storyBoard;
//    LayerController *layerController;
//    
//    storyBoard  = [UIStoryboard
//                   storyboardWithName:@"Main_iPad" bundle:nil];
//    
//    layerController = [storyBoard instantiateViewControllerWithIdentifier:@"LayerController"];
//    
//    [self.navigationController pushViewController:layerController animated:YES];
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
    
	self.mapView.callout.title = (NSString*)[feature attributeForKey:@"name"];
    if (self.mapView.callout.title.length == 0) {
        self.mapView.callout.title = @"未命名";
    }
    
    NSString *photoname = (NSString*)[feature attributeForKey:@"photoname"];
    UIImage *image = [[Projects sharedProjects].curProject photoWithName:photoname];
    self.mapView.callout.image = image;
	return YES;
}

- (void)didClickAccessoryButtonForCallout:(AGSCallout *)callout
{
    NSLog(@"didClickAccessoryButtonForCallout");
    
//    AttributeController *attributeController = [[AttributeController alloc] init];
//    [self presentViewController:attributeController animated:YES completion:nil];
    
        UIStoryboard * storyBoard;
        AttributeController *projectController;
    
        storyBoard  = [UIStoryboard
                       storyboardWithName:@"Main_iPad" bundle:nil];
    
        projectController = [storyBoard instantiateViewControllerWithIdentifier:@"AttributeController"];
    projectController.graphic = callout.representedFeature;
        [self.navigationController pushViewController:projectController animated:YES];
    
//    LayerController *attributeController = [[LayerController alloc] init];
//    [self presentViewController:attributeController animated:YES completion:nil];
    
//    AGSPopupsContainerViewController* popupVC;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    if ([segue.identifier isEqualToString:@"PushMapViewController"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        
//        Track *track = [self.tracks objectAtIndex:indexPath.row];
//        
//        MapViewController *viewController = (MapViewController *)segue.destinationViewController;
//        viewController.track = track;
//    }
    
//    UIViewController * destinationViewController = (UIViewController *)segue.destinationViewController;
//    destinationViewController.navigationController.navigationBarHidden = FALSE;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarSearchButtonClicked");
    
    NSMutableArray * result = [[Projects sharedProjects].curProject search:searchBar.text];
    if (result == nil || result.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有查询的数据" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    [searchBar resignFirstResponder];
    searchBar.hidden = YES;
    
    UIStoryboard * storyBoard;
    RecordController *recordController;
    
    storyBoard  = [UIStoryboard
                   storyboardWithName:@"Main_iPad" bundle:nil];
    
    recordController = [storyBoard instantiateViewControllerWithIdentifier:@"RecordController"];
    
    recordController.graphics = result;
    [self.navigationController pushViewController:recordController animated:YES];
}

@end




