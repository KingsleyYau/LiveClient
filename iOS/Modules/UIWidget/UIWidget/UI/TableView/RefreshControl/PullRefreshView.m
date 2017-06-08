//
//  PullRefreshView.m
//  UIWidget
//
//  Created by Max on 16/6/15.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import "PullRefreshView.h"
#import "NSBundle+DeviceFamily.h"
#import "Header.h"
#import "NSDate+ToString.h"

#define FLIP_ANIMATION_DURATION 0.18f

@implementation PullRefreshView
+ (instancetype)pullRefreshView:(id)owner {
    NSArray *nibs = [UIWIDGETBUNDLE loadNibNamedWithFamily:@"PullRefreshView" owner:owner options:nil];
    PullRefreshView* view = [nibs objectAtIndex:0];
    
//    // iOS 7
//    if( view.arrowImageView.image == nil ) {
//        NSString* imgStr = [NSString stringWithFormat:@"%@/%@", UIWIDGETBUNDLE_NAME, @"Arrow"];
//        view.arrowImageView.image = [UIImage imageNamed:imgStr];
//    }
    
    view.bounds = CGRectMake(0, 0, view.frame.size.width, 60);
//    view.arrowImageView.hidden = NO;
//    view.activityView.hidden = YES;
    view.arrowImageView.hidden = YES;
    view.activityView.hidden = NO;
    [view.activityView startAnimating];
    
    view.statusTipsNormal = @"Pull to Refresh";
    view.statusTipsPulling = @"Release to Refresh";
    view.statusTipsLoading = @"Refreshing...";
    view.statusTipsLoadFinish = @"Refresh finish";
    
    view.lastUpdateLabel.text = @"";
    view.state = PullRefreshNormal;
    view.down = YES;
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
//    self.bgView.backgroundColor = [UIColor colorWithRed:243.0f/255 green:243.0f/255 blue:243.0f/255 alpha:1];
}


- (void)setup {
    self.statusLabel.text = self.statusTipsNormal;
    self.arrowImageView.transform = self.normalTransform;
}

- (void)setDown:(BOOL)down {
    _down = down;
    if( _down ) {
        self.normalTransform = CGAffineTransformIdentity;
        self.pullingTransform = CGAffineTransformMakeRotation(M_PI);
        
    } else {
        self.normalTransform = CGAffineTransformMakeRotation(M_PI);
        self.pullingTransform = CGAffineTransformIdentity;
        
    }
}

- (void)setState:(PullRefreshState)state {
    if( _state != state ) {
        switch (state) {
            case PullRefreshNormal:{
//                NSLog(@"PullRefreshView::setState( PullRefreshNormal )");
//                self.arrowImageView.hidden = NO;
//                self.activityView.hidden = YES;
                self.arrowImageView.hidden = YES;
                self.activityView.hidden = NO;
                [self.activityView stopAnimating];
                self.statusLabel.text = self.statusTipsNormal;
                
                if( _state == PullRefreshPulling || _state == PullRefreshLoadFinish ) {
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDuration:FLIP_ANIMATION_DURATION];
                    self.arrowImageView.transform = self.normalTransform;
                    [UIView commitAnimations];
                }

            }break;
            case PullRefreshPulling:{
//                NSLog(@"PullRefreshView::setState( PullRefreshPulling )");
//                self.arrowImageView.hidden = NO;
//                self.activityView.hidden = YES;
                self.arrowImageView.hidden = YES;
                self.activityView.hidden = NO;
                [self.activityView stopAnimating];
//                [self.activityView startAnimating];
                self.statusLabel.text = self.statusTipsPulling;
                
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:FLIP_ANIMATION_DURATION];
                self.arrowImageView.transform = self.pullingTransform;
                [UIView commitAnimations];
                
            }break;
            case PullRefreshLoading:{
//                NSLog(@"PullRefreshView::setState( PullRefreshLoading )");
//                self.arrowImageView.hidden = YES;
//                self.activityView.hidden = NO;
                self.arrowImageView.hidden = YES;
                self.activityView.hidden = NO;
                [self.activityView startAnimating];
                self.statusLabel.text = self.statusTipsLoading;
                
            }break;
            case PullRefreshLoadFinish:{
//                NSLog(@"PullRefreshView::setState( PullRefreshLoadFinish )");
                self.arrowImageView.hidden = YES;
                self.activityView.hidden = NO;
                [self.activityView stopAnimating];
                self.statusLabel.text = self.statusTipsLoadFinish;
                self.lastUpdateLabel.text = [[NSDate dateWithTimeIntervalSinceNow:0] toStringToday];
                
            }break;
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
