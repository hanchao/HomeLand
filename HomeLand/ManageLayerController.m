//
//  ManageController.m
//  HomeLand
//
//  Created by chao han on 14-3-25.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "ManageLayerController.h"
#import "AttributeController.h"
#import "ManageRecordController.h"
@interface ManageLayerController ()

@end

@implementation ManageLayerController

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
    self.navigationController.navigationBarHidden = FALSE;
    
    _layerName = [[Projects sharedProjects].curProject allLayerName];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = FALSE;
    
//    if (_curLayerName.length != 0) {
//        self.selectlayerEdit.text = _curLayerName;
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//// returns the number of 'columns' to display.
//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
//{
//    return 1;
//}
//
//// returns the # of rows in each component..
//-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
//{
//	return [_layerName count];
//}
//
//-(UIView *)pickerView:(UIPickerView *)pickerView
//		  titleForRow:(NSInteger)row
//		 forComponent:(NSInteger)component
//{
//	
//	return [_layerName objectAtIndex:row];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (IBAction)selectlayerTouch:(id)sender {
//    self.selectView.hidden = NO;
//}
//
//- (IBAction)selectedLayerTouch:(id)sender {
//    self.selectView.hidden = YES;
//    
//    NSInteger row = [self.layerPicker selectedRowInComponent:0];
//    
//    _curLayerName = [_layerName objectAtIndex:row];
//    self.selectlayerEdit.text = _curLayerName;
//    [self.recordTable reloadData];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSString *layername = self.selectlayerEdit.text;
//    AGSGraphicsLayer *graphicsLayer = (AGSGraphicsLayer *)[[Projects sharedProjects].curProject.mapView mapLayerForName:layername];
//    
//    if (graphicsLayer != nil) {
//        return graphicsLayer.graphicsCount;
//    }
//    return 0;
    return [_layerName count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    cell.textLabel.text = [_layerName objectAtIndex:indexPath.row];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSString *curLayerName = [_layerName objectAtIndex:indexPath.row];
    
    UIStoryboard * storyBoard;
    ManageRecordController *manageRecordController;
    
    storyBoard  = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    
    manageRecordController = [storyBoard instantiateViewControllerWithIdentifier:@"ManageRecordController"];
    
    manageRecordController.curLayerName = curLayerName;
    
    [self.navigationController pushViewController:manageRecordController animated:YES];
}

@end
