//
//  LSFeedBackViewController.h
//  livestream
//
//  Created by test on 2017/12/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LSFeedTextView.h"

@interface LSFeedBackViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet LSFeedTextView *feedTextView;
@property (weak, nonatomic) IBOutlet UILabel *textCount;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet LSFeedTextView *emailTextView;
@property (weak, nonatomic) IBOutlet UIView *successView;

@end
