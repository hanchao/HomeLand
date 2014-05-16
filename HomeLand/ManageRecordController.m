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
{
    NSMutableArray *_searchResult;
}

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
    
    CGRect rect=[[UIScreen mainScreen] bounds];
    
    self.contentSizeForViewInPopover = CGSizeMake(rect.size.width/2, rect.size.height*4/5);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = FALSE;
    
//    if (_curLayerName.length != 0) {
//        self.selectlayerEdit.text = _curLayerName;
//    }
    
    if ([self.curLayerName isEqualToString:HL_POINT] ||
        [self.curLayerName isEqualToString:HL_LINE] ||
        [self.curLayerName isEqualToString:HL_REGION]) {
        _searchResult = [[Projects sharedProjects].curProject search:@"" Layer:self.curLayerName];

    }else{
        _searchResult = [[Projects sharedProjects].curProject searchBase:@"" Layer:self.curLayerName];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchResult.count;
}
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];
    
    AGSGraphic *graphic = (AGSGraphic *)[_searchResult objectAtIndex:indexPath.row];
    
    int fid = 0;
    if ([graphic hasAttributeForKey:@"id"]) {
        fid = [graphic attributeAsIntForKey:@"id" exists:nil];
    }else if ([graphic hasAttributeForKey:@"PK_UID"]){
        fid = [graphic attributeAsIntForKey:@"PK_UID" exists:nil];
    }
    
    NSString *name;
    if ([graphic hasAttributeForKey:@"NAME"]) {
        name = (NSString*)[graphic attributeForKey:@"NAME"];
    }else if ([graphic hasAttributeForKey:@"name"]) {
        name = (NSString*)[graphic attributeForKey:@"name"];
    }else if ([graphic hasAttributeForKey:@"TBBH"]) {
        name = (NSString*)[graphic attributeForKey:@"TBBH"];
    }else if ([graphic hasAttributeForKey:@"SPZWH"]) {
        name = (NSString*)[graphic attributeForKey:@"SPZWH"];
    }else if ([graphic hasAttributeForKey:@"BSM"]) {
        name = (NSString*)[graphic attributeForKey:@"BSM"];
    }
    
    UILabel* labelid = (UILabel*) [cell viewWithTag: 100];
    labelid.text = [NSString stringWithFormat:@"%d",fid];
    
    UILabel* labelname = (UILabel*) [cell viewWithTag: 200];
    labelname.text = name;
    
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AGSGraphic *graphic = (AGSGraphic *)[_searchResult objectAtIndex:indexPath.row];
    
    UIStoryboard * storyBoard;
    AttributeController *projectController;
    
    storyBoard  = [UIStoryboard
                   storyboardWithName:@"Main_iPad" bundle:nil];
    
    projectController = [storyBoard instantiateViewControllerWithIdentifier:@"AttributeController"];
    projectController.graphic = graphic;
    projectController.isQuery = YES;
    projectController.isInPop = YES;
    //NSLog(@"%@ %d",graphic.layer.name, indexPath.row);
    
    [self.navigationController pushViewController:projectController animated:YES];
    
    
}

@end
