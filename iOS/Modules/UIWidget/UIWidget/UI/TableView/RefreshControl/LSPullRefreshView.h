//
//  PullRefreshView.h
//  UIWidget
//
//  Created by Max on 16/6/15.
//  Copyright © 2016年 drcom. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PullRefreshNormal = 0,
    PullRefreshPulling,
    PullRefreshLoading,
    PullRefreshLoadFinish
} PullRefreshState;

@interface LSPullRefreshView : UIView
@property (nonatomic, assign) IBOutlet UIActivityIndicatorView* activityView;
@property (nonatomic, assign) IBOutlet UIImageView* arrowImageView;
@property (nonatomic, assign) IBOutlet UILabel* statusLabel;
@property (nonatomic, assign) IBOutlet UILabel* lastUpdateLabel;
@property (nonatomic, assign) PullRefreshState state;
@property (nonatomic, assign) BOOL down;
@property (nonatomic) CGAffineTransform normalTransform;
@property (nonatomic) CGAffineTransform pullingTransform;

@property (nonatomic, strong) NSString* statusTipsNormal;
@property (nonatomic, strong) NSString* statusTipsPulling;
@property (nonatomic, strong) NSString* statusTipsLoading;
@property (nonatomic, strong) NSString* statusTipsLoadFinish;
@property (weak, nonatomic) IBOutlet UIView *bgView;

+ (instancetype)pullRefreshView:(id)owner;
- (void)setup;

@end
