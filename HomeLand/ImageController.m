//
//  ImageController.m
//  HomeLand
//
//  Created by chao han on 14-3-18.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "ImageController.h"
#import "Photo.h"

@interface ImageController ()

@end

@implementation ImageController

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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = FALSE;
    
    _photos = [Projects sharedProjects].curProject.allPhoto;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // 每个Section的item个数
    return _photos.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: CellIdentifier
                                                            forIndexPath: indexPath];
  //  cell.backgroundColor = [UIColor redColor];
    
    Photo * photo = (Photo *)[_photos objectAtIndex:indexPath.row];
    
    UIImageView* imageView = (UIImageView*) [cell viewWithTag: 100];
    imageView.image = photo.image;
    
    
    return cell;
    
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

@end
