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
    
    
    self.mapView.layerDelegate = self;
    self.mapView.touchDelegate = self;

}

- (void)mapViewDidLoad:(AGSMapView *)mapView {
    
    [self.mapView.locationDisplay startDataSource];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = TRUE;
}

# pragma table
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gpsloggerTouch:(id)sender {
    GPSLayer *gpsLayer = (GPSLayer *)[self.mapView mapLayerForName:@"GPS layer"];
    if (gpsLayer.enableLogger) {
        [gpsLayer stopLogger];
    }else{
        [gpsLayer startLogger];
    }
}

- (IBAction)measureErea:(id)sender {
    
    MeasureLayer *measureLayer = (MeasureLayer *)[self.mapView mapLayerForName:@"Measure layer"];
    measureLayer.measureout = self.measureout;
    [measureLayer setMeasureType:AGSGeometryTypePolygon];
    _mapView.touchDelegate=measureLayer;
}

- (IBAction)measureLine:(id)sender {
    MeasureLayer *measureLayer = (MeasureLayer *)[self.mapView mapLayerForName:@"Measure layer"];
    measureLayer.measureout = self.measureout;
    [measureLayer setMeasureType:AGSGeometryTypePolyline];
    _mapView.touchDelegate=measureLayer;
}

- (IBAction)measure:(id)sender {
    
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
    AGSSketchGraphicsLayer *sketchLayer = (AGSSketchGraphicsLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    //点
    sketchLayer.geometry = [[AGSMutablePoint alloc] initWithX:NAN y:NAN spatialReference:_mapView.spatialReference];
    _mapView.touchDelegate=sketchLayer;
}

- (IBAction)editline:(id)sender {
    AGSSketchGraphicsLayer *sketchLayer = (AGSSketchGraphicsLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    //线
    sketchLayer.geometry = [[AGSMutablePolyline alloc] initWithSpatialReference:_mapView.spatialReference];
    _mapView.touchDelegate=sketchLayer;
}

- (IBAction)editRegion:(id)sender {
    AGSSketchGraphicsLayer *sketchLayer = (AGSSketchGraphicsLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    //面
    sketchLayer.geometry = [[AGSMutablePolygon alloc] initWithSpatialReference:_mapView.spatialReference];
    _mapView.touchDelegate=sketchLayer;
}

- (IBAction)editDeleteSelect:(id)sender {
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
}

- (IBAction)gpsinput:(id)sender {
}

- (IBAction)autoinput:(id)sender {
}

- (IBAction)editredo:(id)sender {
    AGSSketchGraphicsLayer *sketchLayer = (AGSSketchGraphicsLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    [sketchLayer.undoManager redo];
}

- (IBAction)editundo:(id)sender {
    AGSSketchGraphicsLayer *sketchLayer = (AGSSketchGraphicsLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    [sketchLayer.undoManager undo];
}

- (IBAction)editsave:(id)sender {
    AGSSketchGraphicsLayer *sketchLayer = (AGSSketchGraphicsLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    [[Projects sharedProjects].curProject addGeometry:sketchLayer.geometry];
    [sketchLayer clear];
}

- (IBAction)editclear:(id)sender {
    AGSSketchGraphicsLayer *sketchLayer = (AGSSketchGraphicsLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
    [sketchLayer clear];
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

- (IBAction)photoManageTouch:(id)sender {
}

- (IBAction)DataInputTouch:(id)sender {
    [self openEdit];
}

- (IBAction)DataSearchTouch:(id)sender {
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
        AGSSketchGraphicsLayer *sketchLayer = (AGSSketchGraphicsLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
        self.mapView.touchDelegate=nil;
        sketchLayer.geometry=nil;
        [sketchLayer clear];
    }
    self.measureView.hidden = !self.measureView.hidden;
    if (!self.measureView.hidden) {
        
    }else{
        MeasureLayer *measureLayer = (MeasureLayer *)[self.mapView mapLayerForName:@"Measure layer"];
        [measureLayer.undoManager undo];
        self.mapView.touchDelegate=nil;
        measureLayer.geometry=nil;
        [measureLayer clear];
        self.measureout.hidden = true;
    }
}

-(void) openEdit
{
    if (!self.measureView.hidden) {
        self.measureView.hidden = true;
            MeasureLayer *measureLayer = (MeasureLayer *)[self.mapView mapLayerForName:@"Measure layer"];
            [measureLayer.undoManager undo];
            self.mapView.touchDelegate=nil;
            measureLayer.geometry=nil;
            [measureLayer clear];
    }
    self.editView.hidden = !self.editView.hidden;
    if (!self.editView.hidden) {
        
    }else{
        AGSSketchGraphicsLayer *sketchLayer = (AGSSketchGraphicsLayer *)[self.mapView mapLayerForName:@"Sketch layer"];
        [sketchLayer.undoManager undo];
        self.mapView.touchDelegate=nil;
        sketchLayer.geometry=nil;
        [sketchLayer clear];
    }
}



- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    NSString *scaleInfo;
    if (self.mapView.mapScale > 100000) {
        scaleInfo = [[NSString alloc] initWithFormat:@"1:%.02fkm",self.mapView.mapScale/100000];
    }
    else{
        scaleInfo = [[NSString alloc] initWithFormat:@"1:%.02fm",self.mapView.mapScale/100];
    }
    self.mapScaleLabel.text = scaleInfo;
}

-(void)mapView:(AGSMapView *)mapView didClickAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    NSLog(@"grg");
    
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

@end




