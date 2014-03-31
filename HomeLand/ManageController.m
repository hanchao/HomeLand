//
//  ManageController.m
//  HomeLand
//
//  Created by chao han on 14-3-25.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "ManageController.h"
#import "AttributeController.h"
@interface ManageController ()

@end

@implementation ManageController

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
    
    _layerName = @[@"Point",@"Line",@"Region"];
    
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

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [_layerName count];
}

-(UIView *)pickerView:(UIPickerView *)pickerView
		  titleForRow:(NSInteger)row
		 forComponent:(NSInteger)component
{
	
	return [_layerName objectAtIndex:row];
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

- (IBAction)selectlayerTouch:(id)sender {
    self.selectView.hidden = NO;
}

- (IBAction)selectedLayerTouch:(id)sender {
    self.selectView.hidden = YES;
    
    NSInteger row = [self.layerPicker selectedRowInComponent:0];
    
    _curLayerName = [_layerName objectAtIndex:row];
    self.selectlayerEdit.text = _curLayerName;
    [self.recordTable reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *layername = self.selectlayerEdit.text;
    AGSGraphicsLayer *graphicsLayer = (AGSGraphicsLayer *)[[Projects sharedProjects].curProject.mapView mapLayerForName:layername];
    
    if (graphicsLayer != nil) {
        return graphicsLayer.graphicsCount;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier
                                                            forIndexPath: indexPath];
    
    NSString *layername = self.selectlayerEdit.text;
    AGSGraphicsLayer *graphicsLayer = (AGSGraphicsLayer *)[[Projects sharedProjects].curProject.mapView mapLayerForName:layername];
    
    if (graphicsLayer != nil) {
        AGSGraphic *graphic = (AGSGraphic *)[graphicsLayer.graphics objectAtIndex:indexPath.row];
        
        int fid = [graphic attributeAsIntForKey:@"id" exists:nil];
        NSString *name = [graphic attributeAsStringForKey:@"name"];
        
        UILabel* labelid = (UILabel*) [cell viewWithTag: 100];
        labelid.text = [NSString stringWithFormat:@"%d",fid];
        
        UILabel* labelname = (UILabel*) [cell viewWithTag: 200];
        labelname.text = name;
//        NSString *record = [NSString stringWithFormat:@"%d %@",fid,name];
//        cell.textLabel.text = record;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *layername = self.selectlayerEdit.text;
    AGSGraphicsLayer *graphicsLayer = (AGSGraphicsLayer *)[[Projects sharedProjects].curProject.mapView mapLayerForName:layername];
    
    if (graphicsLayer != nil) {
        AGSGraphic *graphic = (AGSGraphic *)[graphicsLayer.graphics objectAtIndex:indexPath.row];
        
        UIStoryboard * storyBoard;
        AttributeController *projectController;
    
        storyBoard  = [UIStoryboard
                   storyboardWithName:@"Main_iPad" bundle:nil];
    
        projectController = [storyBoard instantiateViewControllerWithIdentifier:@"AttributeController"];
        projectController.graphic = graphic;
        [self.navigationController pushViewController:projectController animated:YES];
    }
    
}

@end
