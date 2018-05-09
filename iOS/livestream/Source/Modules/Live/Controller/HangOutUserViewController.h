//
//  HangOutUserViewController.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/7.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LiveRoom.h"

#import <GPUImage.h>
#import "GiftStatisticsView.h"

@interface HangOutUserViewController : LSGoogleAnalyticsViewController

@property (nonatomic, strong) LiveRoom *liveRoom;

@property (weak, nonatomic) IBOutlet GPUImageView *videoView;

@property (weak, nonatomic) IBOutlet UIView *comboGiftView;

@property (weak, nonatomic) IBOutlet GiftStatisticsView *giftCountView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftCountViewWidth;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UIView *backgroundView;


@end
