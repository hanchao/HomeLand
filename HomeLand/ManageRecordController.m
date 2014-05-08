//
//  ManageController.m
//  HomeLand
//
//  Created by chao han on 14-3-25.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "ManageRecordController.h"
#import "AttributeController.h"
@interface ManageRecordController ()

@end

@implementation ManageRecordController

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
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/
//
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
//
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
    
    return cell;
}
//
//    NSString *layername = self.selectlayerEdit.text;
//    AGSGraphicsLayer *graphicsLayer = (AGSGraphicsLayer *)[[Projects sharedProjects].curProject.mapView mapLayerForName:layername];
//    
//    if (graphicsLayer != nil) {
//        AGSGraphic *graphic = (AGSGraphic *)[graphicsLayer.graphics objectAtIndex:indexPath.row];
//        
//        int fid = 0;
//        if ([graphic hasAttributeForKey:@"id"]) {
//            fid = [graphic attributeAsIntForKey:@"id" exists:nil];
//        }else if ([graphic hasAttributeForKey:@"PK_UID"]){
//            fid = [graphic attributeAsIntForKey:@"PK_UID" exists:nil];
//        }
//        
//        NSString *name;
//        if ([graphic hasAttributeForKey:@"NAME"]) {
//            name = (NSString*)[graphic attributeForKey:@"NAME"];
//        }else if ([graphic hasAttributeForKey:@"name"]) {
//            name = (NSString*)[graphic attributeForKey:@"name"];
//        }else if ([graphic hasAttributeForKey:@"TBBH"]) {
//            name = (NSString*)[graphic attributeForKey:@"TBBH"];
//        }else if ([graphic hasAttributeForKey:@"SPZWH"]) {
//            name = (NSString*)[graphic attributeForKey:@"SPZWH"];
//        }else if ([graphic hasAttributeForKey:@"BSM"]) {
//            name = (NSString*)[graphic attributeForKey:@"BSM"];
//        }
//            
////
////        if ([graphic.layer.name compare:@"DMD"] == NSOrderedSame ) {
////            name = [graphic attributeAsStringForKey:@"NAME"];
////            fid = [graphic attributeAsIntForKey:@"PK_UID" exists:nil];
////        }else if ([graphic.layer.name compare:@"WPZFTB"] == NSOrderedSame ) {
////            name = [graphic attributeAsStringForKey:@"TBBH"];
////            fid = [graphic attributeAsIntForKey:@"PK_UID" exists:nil];
////        }else if ([graphic.layer.name compare:@"TDPW"] == NSOrderedSame ) {
////            name = [graphic attributeAsStringForKey:@"SPZWH"];
////            fid = [graphic attributeAsIntForKey:@"PK_UID" exists:nil];
////        }else{
////            name = [graphic attributeAsStringForKey:@"name"];
////        }
//        
//        UILabel* labelid = (UILabel*) [cell viewWithTag: 100];
//        labelid.text = [NSString stringWithFormat:@"%d",fid];
//        
//        UILabel* labelname = (UILabel*) [cell viewWithTag: 200];
//        labelname.text = name;
////        NSString *record = [NSString stringWithFormat:@"%d %@",fid,name];
////        cell.textLabel.text = record;
//    }
//    return cell;
//}
//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    NSString *layername = self.selectlayerEdit.text;
//    AGSGraphicsLayer *graphicsLayer = (AGSGraphicsLayer *)[[Projects sharedProjects].curProject.mapView mapLayerForName:layername];
//    
//    if (graphicsLayer != nil) {
//        AGSGraphic *graphic = (AGSGraphic *)[graphicsLayer.graphics objectAtIndex:indexPath.row];
//        
//        UIStoryboard * storyBoard;
//        AttributeController *projectController;
//    
//        storyBoard  = [UIStoryboard
//                   storyboardWithName:@"Main_iPad" bundle:nil];
//    
//        projectController = [storyBoard instantiateViewControllerWithIdentifier:@"AttributeController"];
//        projectController.graphic = graphic;
//        [self.navigationController pushViewController:projectController animated:YES];
//    }
//    
//}

@end
