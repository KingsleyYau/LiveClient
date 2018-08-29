//
//  StartHangOutTipView.h
//  livestream
//
//  Created by Randy_Fan on 2018/6/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StartHangOutTipView;
@protocol StartHangOutTipViewDelegate <NSObject>
- (void)requestHangout:(StartHangOutTipView *)view;
- (void)closeHangoutTip:(StartHangOutTipView *)view;
@end

@interface StartHangOutTipView : UIView
@property (weak, nonatomic) IBOutlet UILabel *hangoutTipLabel;
@property (weak, nonatomic) IBOutlet UIImageView *closeImageView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *hangoutButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) id<StartHangOutTipViewDelegate> delegate;

// 首页显示
- (void)showMainHangoutTip;
// 直播间显示
- (void)showLiveRoomHangoutTip;

@end
