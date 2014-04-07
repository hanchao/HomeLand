//
//  LayerController.m
//  HomeLand
//
//  Created by chao han on 14-3-7.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "LayerController.h"

@implementation LayerController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = FALSE;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [Projects sharedProjects].curProject.mapView.mapLayers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier
                                                            forIndexPath: indexPath];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    AGSLayer *layer = [[Projects sharedProjects].curProject.mapView.mapLayers objectAtIndex:indexPath.row];

    //cell.textLabel.text = layer.name;
    UILabel* label = (UILabel*) [cell viewWithTag: 100];
    label.text =layer.name;
    UISwitch* layerswitch = (UISwitch*) [cell viewWithTag: 200];
    layerswitch.on = layer.visible;
    layerswitch.accessibilityLabel = layer.name;
    
    return cell;
}

- (IBAction)layerswitch:(id)sender {
    UISwitch *layerswitch = (UISwitch *)sender;
    AGSLayer *layer = [[Projects sharedProjects].curProject.mapView mapLayerForName:layerswitch.accessibilityLabel];
    layer.visible = layerswitch.on;
}
@end
