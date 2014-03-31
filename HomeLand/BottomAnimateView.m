//
//  BottomAnimateView.m
//  HomeLand
//
//  Created by chao han on 14-3-31.
//  Copyright (c) 2014年 chao han. All rights reserved.
//

#import "BottomAnimateView.h"

@implementation BottomAnimateView
{
    BOOL _hidden;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self hideAtStart];
    }
    return self;
}

- (void)hideAtStart
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height);
    _hidden = YES;
}

- (BOOL)isHidden{
    return _hidden;
}

- (void)setHidden:(BOOL) ahidden
{
    if (ahidden == self.hidden) {
        return;
    }
    if (self.hidden) {
        [self show:YES];
    }else{
        [self hide:YES];
    }
}

- (void)hide:(BOOL)animated {
    if (!_hidden) {
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^(void) {
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height);
            }];
        }else{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height, self.frame.size.width, self.frame.size.height);
        }

        _hidden = YES;
    }
}

- (void)show:(BOOL)animated {
    if (_hidden) {
        if (animated) {
            [UIView animateWithDuration:0.3 animations:^(void) {
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.frame.size.height, self.frame.size.width, self.frame.size.height);
            }];
        }else{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.frame.size.height, self.frame.size.width, self.frame.size.height);
        }
        _hidden = NO;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
