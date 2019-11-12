//
//  PullRefreshView.m
//  UIWidget
//
//  Created by Max on 16/6/15.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import "LSPullRefreshView.h"

#import "LSDateFormatter.h"

#import "NSBundle+DeviceFamily.h"
#import "LSUIWidgetBundle.h"

#define FLIP_ANIMATION_DURATION 0.18f

@implementation LSPullRefreshView
+ (instancetype)pullRefreshView:(id)owner {
    NSBundle *bundle = [LSUIWidgetBundle resourceBundle];
    NSArray *nibs = [bundle loadNibNamedWithFamily:@"LSPullRefreshView" owner:owner options:nil];
    LSPullRefreshView *view = [nibs objectAtIndex:0];

    view.bounds = CGRectMake(0, 0, view.frame.size.width, 60);
    view.arrowImageView.hidden = YES;
    
    NSMutableArray *iconArray = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 7
         ; i++) {
        NSString *imgStr = [[[LSUIWidgetBundle resourceBundle] bundlePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"PullRefreshLoading%d.png", i]];
        UIImage *image = [UIImage imageNamed:imgStr];
        [iconArray addObject:image];
    }
    view.loadingActivity.animationImages = iconArray;
    view.loadingActivity.animationRepeatCount = 0;
    view.loadingActivity.animationDuration = 0.6;
    [view.loadingActivity startAnimating];
    view.loadingActivity.hidden = NO;

    view.statusTipsNormal = @"Pull to Refresh";
    view.statusTipsPulling = @"Release to Refresh";
    view.statusTipsLoading = @"Refreshing...";
    view.statusTipsLoadFinish = @"Refresh finish";

    view.lastUpdateLabel.text = @"";
    view.state = PullRefreshNormal;
    view.down = YES;
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //    self.bgView.backgroundColor = [UIColor colorWithRed:243.0f/255 green:243.0f/255 blue:243.0f/255 alpha:1];
}

- (void)setup {
    self.statusLabel.text = self.statusTipsNormal;
    self.arrowImageView.transform = self.normalTransform;
}

- (void)setDown:(BOOL)down {
    _down = down;
    if (_down) {
        self.normalTransform = CGAffineTransformIdentity;
        self.pullingTransform = CGAffineTransformMakeRotation(M_PI);

    } else {
        self.normalTransform = CGAffineTransformMakeRotation(M_PI);
        self.pullingTransform = CGAffineTransformIdentity;
    }
}

- (void)setState:(PullRefreshState)state {
    if (_state != state) {
        switch (state) {
            case PullRefreshNormal: {
                //                NSLog(@"PullRefreshView::setState( PullRefreshNormal )");
                //                self.arrowImageView.hidden = NO;
                //                self.activityView.hidden = YES;
                self.arrowImageView.hidden = YES;
                
                self.loadingActivity.hidden = NO;
                [self.loadingActivity stopAnimating];
                
                self.statusLabel.text = self.statusTipsNormal;

                if (_state == PullRefreshPulling || _state == PullRefreshLoadFinish) {
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:FLIP_ANIMATION_DURATION];
                    self.arrowImageView.transform = self.normalTransform;
                    [UIView commitAnimations];
                }

            } break;
            case PullRefreshPulling: {
                //                NSLog(@"PullRefreshView::setState( PullRefreshPulling )");
                //                self.arrowImageView.hidden = NO;
                //                self.activityView.hidden = YES;
                self.arrowImageView.hidden = YES;
                
                self.loadingActivity.hidden = NO;
                [self.loadingActivity stopAnimating];
                
                self.statusLabel.text = self.statusTipsPulling;

                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:FLIP_ANIMATION_DURATION];
                self.arrowImageView.transform = self.pullingTransform;
                [UIView commitAnimations];

            } break;
            case PullRefreshLoading: {
                //                NSLog(@"PullRefreshView::setState( PullRefreshLoading )");
                //                self.arrowImageView.hidden = YES;
                //                self.activityView.hidden = NO;
                self.arrowImageView.hidden = YES;
                
                self.loadingActivity.hidden = NO;
                [self.loadingActivity startAnimating];
                
                self.statusLabel.text = self.statusTipsLoading;

            } break;
            case PullRefreshLoadFinish: {
                //                NSLog(@"PullRefreshView::setState( PullRefreshLoadFinish )");
                self.arrowImageView.hidden = YES;
                
                self.loadingActivity.hidden = NO;
                [self.loadingActivity stopAnimating];
                
                self.statusLabel.text = self.statusTipsLoadFinish;
                self.lastUpdateLabel.text = [LSDateFormatter toStringToday:[NSDate dateWithTimeIntervalSinceNow:0]];

            } break;
            default:
                break;
        }
        // 替换状态
        _state = state;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
