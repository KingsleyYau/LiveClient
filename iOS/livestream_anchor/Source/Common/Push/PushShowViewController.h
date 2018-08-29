//
//  PushShowViewController.h
//  livestream_anchor
//
//  Created by Calvin on 2018/5/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSGoogleAnalyticsViewController.h"
@interface PushShowViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *AcceptBtnW;
@property (strong) NSURL *url;
@property (nonatomic, copy) NSString *tips;
@property (nonatomic, copy) NSString *anchorId;
@property (nonatomic, copy) NSString * liveShowId;
@property (nonatomic, assign) BOOL isShowAcceptBtn;
@end
