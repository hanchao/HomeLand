//
//  LayerController.m
//  HomeLand
//
//  Created by chao han on 14-3-7.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "LayerController.h"


@implementation LayerController
{
    UIBarButtonItem *_buttonAdd;
    
    UIBarButtonItem *_buttonEdit;
    
    UIBarButtonItem *_buttonDone;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _buttonAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addLayer:)];
    
    _buttonEdit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editLayer:)];

    _buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editLayer:)];
    
    self.navigationItem.rightBarButtonItems = @[_buttonAdd,_buttonEdit];

}

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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)
sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSUInteger fromRow = [sourceIndexPath row];
    NSUInteger toRow = [destinationIndexPath row];
    
    AGSLayer * layer = [[Projects sharedProjects].curProject.mapView.mapLayers objectAtIndex:fromRow];
    [[Projects sharedProjects].curProject.mapView removeMapLayer:layer];
    [[Projects sharedProjects].curProject.mapView insertMapLayer:layer withName:layer.name atIndex:toRow];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:
(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AGSLayer * layer = [[Projects sharedProjects].curProject.mapView.mapLayers objectAtIndex:row];
        [[Projects sharedProjects].curProject.mapView removeMapLayer:layer];

        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (IBAction)addLayer:(id)sender {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    PSDirectoryPickerController *directoryPicker = [[PSDirectoryPickerController alloc] initWithRootDirectory:documentsDirectory];
    
    [directoryPicker setDelegate:self];
    [directoryPicker setPrompt:@"选择tpk文件"];
    [directoryPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [self presentModalViewController:directoryPicker animated:YES];
}

- (IBAction)editLayer:(id)sender {
    self.tableView.editing = !self.tableView.editing;
    if (self.tableView.editing) {
        self.navigationItem.rightBarButtonItems = @[_buttonAdd,_buttonDone];
    }
    else{
        self.navigationItem.rightBarButtonItems = @[_buttonAdd,_buttonEdit];
    }
    
}

- (void)directoryPickerController:(PSDirectoryPickerController *)picker didFinishPickingDirectoryAtPath:(NSString *)path
{
    [[Projects sharedProjects].curProject openTpk:path];
    [self.tableView reloadData];
}

@end
