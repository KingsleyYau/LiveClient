//
//  LiveFinshViewController.h
//  livestream
//
//  Created by randy on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"
#import "LiveRoom.h"
#import "ZBLSRequestManager.h"

@interface LiveFinshViewController : LSGoogleAnalyticsViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewHotBtn;
@property (nonatomic, assign) ZBLCC_ERR_TYPE errType;
@property (nonatomic, copy) NSString *errMsg;
@property (nonatomic, strong) LiveRoom *liveRoom;

- (void)handleError:(ZBLCC_ERR_TYPE)errType errMsg:(NSString *)errMsg;

@end
