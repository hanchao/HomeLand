//
//  OpenProjectTableViewController.m
//  HomeLand
//
//  Created by chao han on 14-3-5.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "ProjectController.h"
#import "Projects.h"
#import "Project.h"

@implementation ProjectController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createProject:)];
    button.title = @"新建";
    self.navigationItem.rightBarButtonItem = button;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = FALSE;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [Projects sharedProjects].projects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier
                                                            forIndexPath: indexPath];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = [[Projects sharedProjects].projects objectAtIndex: indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{//请求数据源提交的插入或删除指定行接收者。
    if (editingStyle ==UITableViewCellEditingStyleDelete) {//如果编辑样式为删除样式
        if (indexPath.row<[Projects sharedProjects].projects.count) {
            [[Projects sharedProjects] deleteProjectByIndex:indexPath.row];//移除数据源的数据
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];//移除tableView中的数据
        }
    }
}

//点击某一行时候触发的事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //if ([tableView isEqual:myTableView]) {
        NSLog(@"%@",[NSString stringWithFormat:@"Cell %ld in Section %ld is selected",(long)indexPath.row,(long)indexPath.section]);
    
    NSString* title = [[Projects sharedProjects].projects objectAtIndex: indexPath.row];
    
    if(![[Projects sharedProjects] openProject:title])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"打开工程失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    self.navigationController.navigationBarHidden = TRUE;
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)editProject:(id)sender {
    NSLog(@"编辑工程");
    self.tableView.editing = YES;
}

- (IBAction)createProject:(id)sender {
    NSLog(@"新建工程");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"新建工程" message:@"输入工程名称" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (IBAction)openButtonTouch:(id)sender {
    
    NSString* title = [[sender titleLabel] text];

    if(![[Projects sharedProjects] openProject:title])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"打开工程失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    self.navigationController.navigationBarHidden = TRUE;
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if(buttonIndex == 1)
    {
        //得到输入框
        UITextField *tf=[alertView textFieldAtIndex:0];
        if(![[Projects sharedProjects] createProject:tf.text])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"创建工程失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            return;
        }

        self.navigationController.navigationBarHidden = TRUE;
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
