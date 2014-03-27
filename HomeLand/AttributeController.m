//
//  AttributeController.m
//  HomeLand
//
//  Created by chao han on 14-3-20.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "AttributeController.h"
#import "Projects.h"
#import "Project.h"
#import "EditLayer.h"
#import "FieldInfo.h"


@interface AttributeController ()


@end

@implementation AttributeController

@synthesize isAddNew;
@synthesize graphic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveFeature:)];
    button.title = @"保存";
    self.navigationItem.rightBarButtonItem = button;
    
//    UIBarButtonItem *buttonSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveFeature:)];
//    
//    UIBarButtonItem *buttonDelete = [[UIBarButtonItem alloc] initWithTitle:@"删除" style: UIBarButtonItemStylePlain target:self action:@selector(saveFeature:)];
//    
//    
//    self.navigationItem.rightBarButtonItems = @[buttonSave,buttonDelete];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = FALSE;
    
    EditLayer *sketchLayer = (EditLayer *)[[Projects sharedProjects].curProject.mapView mapLayerForName:@"Sketch layer"];
    
    if(sketchLayer.geometry != nil)
    {
        AGSGeometryType geometryType = AGSGeometryTypeForGeometry(sketchLayer.geometry);
    
        _fieldInfos = [[Projects sharedProjects].curProject allFieldInfo:geometryType];
        
        self.isAddNew = TRUE;
    }
    else
    {
        self.isAddNew = false;
        
        UIBarButtonItem *buttonSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveFeature:)];
        
        UIBarButtonItem *buttonDelete = [[UIBarButtonItem alloc] initWithTitle:@"删除" style: UIBarButtonItemStylePlain target:self action:@selector(deleteFeature:)];


        self.navigationItem.rightBarButtonItems = @[buttonSave,buttonDelete];
        
        //self.graphic.allAttributes.allKeys
        AGSGeometryType geometryType = AGSGeometryTypeForGeometry(self.graphic.geometry);
        
        _fieldInfos = [[Projects sharedProjects].curProject allFieldInfo:geometryType];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _fieldInfos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier
                                                            forIndexPath: indexPath];
    
    if(self.isAddNew)
    {
        FieldInfo *fieldInfo = (FieldInfo *)[_fieldInfos objectAtIndex:indexPath.row];
        UILabel* label = (UILabel*) [cell viewWithTag: 100];
        UITextField* testField = (UITextField*) [cell viewWithTag: 300];
        
        label.text = [Projects chinesename:fieldInfo.name];
        
        
        if ([fieldInfo.name compare:@"photoname"] == NSOrderedSame ||
            [fieldInfo.name compare:@"照片"] == NSOrderedSame) {
            UIButton* botton = (UIButton*) [cell viewWithTag: 400];
            botton.hidden = NO;
            testField.enabled = NO;
        }
        else if ([fieldInfo.name compare:@"id"] == NSOrderedSame ||
                 [fieldInfo.name compare:@"time"] == NSOrderedSame )
        {
            testField.enabled = NO;
        }
    }
    else
    {
        UILabel* label = (UILabel*) [cell viewWithTag: 100];
        UITextField* testField = (UITextField*) [cell viewWithTag: 300];
        
        FieldInfo *fieldInfo = (FieldInfo *)[_fieldInfos objectAtIndex:indexPath.row];
        
        label.text = [Projects chinesename:fieldInfo.name];
        testField.text = [self.graphic.allAttributes objectForKey:fieldInfo.name];
        
        if ([fieldInfo.name compare:@"photoname"] == NSOrderedSame ||
            [fieldInfo.name compare:@"照片"] == NSOrderedSame) {
            UIButton* botton = (UIButton*) [cell viewWithTag: 400];
            botton.hidden = NO;
            testField.enabled = NO;
        }
        else if ([fieldInfo.name compare:@"id"] == NSOrderedSame ||
                 [fieldInfo.name compare:@"time"] == NSOrderedSame )
        {
            testField.enabled = NO;
        }
    }

    
    return cell;
}

- (IBAction)saveFeature:(id)sender {
    NSLog(@"保存记录");
    
    EditLayer *sketchLayer = (EditLayer *)[[Projects sharedProjects].curProject.mapView mapLayerForName:@"Sketch layer"];
    //[[Projects sharedProjects].curProject addGeometry:sketchLayer.geometry];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    int count = [self.tableview numberOfRowsInSection:0];
    
    for (int i=0; i<count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        //NSIndexPath *indexPath = [NSIndexPath alloc] init
        UITableViewCell *cell = [self.tableview cellForRowAtIndexPath:indexPath];
        
        UILabel* label = (UILabel*) [cell viewWithTag: 100];
        UITextField* testField = (UITextField*) [cell viewWithTag: 300];
        
        //NSLog(@"Key:%@,Value:%@",[Projects enname:label.text],testField.text);
        if ([label.text compare:@"编号"] == NSOrderedSame ||
            [label.text compare:@"时间"] == NSOrderedSame) {
            continue;
        }
        
        if(self.isAddNew)
            [dict setObject:testField.text forKey:[Projects enname:label.text]];
        else
            [self.graphic setValue:testField.text forKey:[Projects enname:label.text]];
        
    }
    
    if(self.isAddNew)
    {
        AGSGraphic*graphic = [AGSGraphic graphicWithGeometry:sketchLayer.geometry symbol:nil attributes:dict];
    
        [[Projects sharedProjects].curProject addGraphic:graphic];
    
        [sketchLayer clear];
        sketchLayer.geometry = nil;
    }
    else
    {
        [[Projects sharedProjects].curProject saveGraphic:self.graphic];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)deleteFeature:(id)sender {
    if(!self.isAddNew)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"删除记录" message:@"是否删除记录" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
        alert.alertViewStyle = UIAlertViewStyleDefault;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if(buttonIndex == 1)
    {
        [[Projects sharedProjects].curProject removeGraphic:graphic];
        [[Projects sharedProjects].curProject.mapView.callout dismiss];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)TextField_DidEndOnExit:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)photo:(id)sender {
    
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
    _image = image;
    
    int count = [self.tableview numberOfRowsInSection:0];
    
    for (int i=0; i<count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        //NSIndexPath *indexPath = [NSIndexPath alloc] init
        UITableViewCell *cell = [self.tableview cellForRowAtIndexPath:indexPath];
        
        UILabel* label = (UILabel*) [cell viewWithTag: 100];
        UITextField* testField = (UITextField*) [cell viewWithTag: 300];
        
        //NSLog(@"Key:%@,Value:%@",[Projects enname:label.text],testField.text);
        if ([label.text compare:@"照片"] == NSOrderedSame) {

            double x = [Projects sharedProjects].curProject.mapView.locationDisplay.mapLocation.x;
            double y = [Projects sharedProjects].curProject.mapView.locationDisplay.mapLocation.y;
            
            AGSPoint *point = [[AGSPoint alloc] initWithX:x y:y spatialReference:[AGSSpatialReference wgs84SpatialReference]];
            
            Photo * photo = [[Photo alloc] init];
            photo.image = image;
            photo.point = point;
            NSString *filename = [[Projects sharedProjects].curProject addPhoto:photo];
            
            testField.text = filename;
        }
        
        
    }
    

}
@end
