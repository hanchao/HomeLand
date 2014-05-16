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
    return self.searchResults.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    SearchResult *searchResult = (SearchResult *)[self.searchResults objectAtIndex:section];

    return searchResult.graphics.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SearchResult *searchResult = (SearchResult *)[self.searchResults objectAtIndex:section];
    return searchResult.layerName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier
                                                            forIndexPath: indexPath];
    
    //return cell;
    SearchResult *searchResult = (SearchResult *)[self.searchResults objectAtIndex:indexPath.section];
    
    AGSGraphic *graphic = (AGSGraphic *)[searchResult.graphics objectAtIndex:indexPath.row];
    
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SearchResult *searchResult = (SearchResult *)[self.searchResults objectAtIndex:indexPath.section];
    
    AGSGraphic *graphic = (AGSGraphic *)[searchResult.graphics objectAtIndex:indexPath.row];
        
        UIStoryboard * storyBoard;
        AttributeController *projectController;
        
        storyBoard  = [UIStoryboard
                       storyboardWithName:@"Main_iPad" bundle:nil];
        
        projectController = [storyBoard instantiateViewControllerWithIdentifier:@"AttributeController"];
        projectController.graphic = graphic;
    projectController.isQuery = YES;
    
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
