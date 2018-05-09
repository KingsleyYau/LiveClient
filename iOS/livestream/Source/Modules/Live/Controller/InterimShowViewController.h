//
//  InterimShowViewController.h
//  livestream
//
//  Created by Calvin on 2018/5/2.
//  Copyright © 2018年 net.qdating. All rights reserved.
//  节目过渡页

#import <UIKit/UIKit.h>
#import "LiveRoom.h"
#import "ShowListView.h"
#import "LSGoogleAnalyticsViewController.h"
@interface InterimShowViewController : LSGoogleAnalyticsViewController

#pragma mark - 直播间信息
@property (nonatomic, strong) LiveRoom *liveRoom;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loading;
@property (weak, nonatomic) IBOutlet UIButton *reloadBtn;
@property (weak, nonatomic) IBOutlet UIButton *bookBtn;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet ShowListView *showView;
@end
