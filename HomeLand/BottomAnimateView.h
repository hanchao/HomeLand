//
//  BottomAnimateView.h
//  HomeLand
//
//  Created by chao han on 14-3-31.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomAnimateView : UIView

@property(nonatomic,getter=isHidden) BOOL              hidden;  

- (void)hideAtStart;
- (BOOL)isHidden;
- (void)setHidden:(BOOL) ahidden;

- (void)hide:(BOOL)animated;

- (void)show:(BOOL)animated;

@end
