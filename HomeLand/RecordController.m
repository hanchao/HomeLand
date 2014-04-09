//
//  RecordController.m
//  HomeLand
//
//  Created by chao han on 14-3-25.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "RecordController.h"
#import "AttributeController.h"

@interface RecordController ()

@end

@implementation RecordController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationController.navigationBarHidden = FALSE;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return self.graphics.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier
                                                            forIndexPath: indexPath];

    AGSGraphic *graphic = (AGSGraphic *)[self.graphics objectAtIndex:indexPath.row];
    
    int fid = [graphic attributeAsIntForKey:@"id" exists:nil];
    NSString *name;
    NSString * layerName = [graphic attributeAsStringForKey:@"LayerName_Query"];
    if ([layerName compare:@"DMD"] == NSOrderedSame ) {
        name = [graphic attributeAsStringForKey:@"NAME"];
        fid = [graphic attributeAsIntForKey:@"PK_UID" exists:nil];
    }else if ([layerName compare:@"WPZFTB"] == NSOrderedSame ) {
        name = [graphic attributeAsStringForKey:@"TBBH"];
        fid = [graphic attributeAsIntForKey:@"PK_UID" exists:nil];
    }else if ([layerName compare:@"TDPW"] == NSOrderedSame ) {
        name = [graphic attributeAsStringForKey:@"SPZWH"];
        fid = [graphic attributeAsIntForKey:@"PK_UID" exists:nil];
    }else{
        name = [graphic attributeAsStringForKey:@"name"];
    }
    
    UILabel* labelid = (UILabel*) [cell viewWithTag: 100];
    labelid.text = [NSString stringWithFormat:@"%d",fid];
    
    UILabel* labelname = (UILabel*) [cell viewWithTag: 200];
    labelname.text = name;
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
        AGSGraphic *graphic = (AGSGraphic *)[self.graphics objectAtIndex:indexPath.row];
        
        UIStoryboard * storyBoard;
        AttributeController *projectController;
        
        storyBoard  = [UIStoryboard
                       storyboardWithName:@"Main_iPad" bundle:nil];
        
        projectController = [storyBoard instantiateViewControllerWithIdentifier:@"AttributeController"];
        projectController.graphic = graphic;
    projectController.isQuery = YES;
    //NSLog(@"%@ %d",graphic.layer.name, indexPath.row);
    
        [self.navigationController pushViewController:projectController animated:YES];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
