//
//  HangOutControlView.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/11.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HangOutControlView;
@protocol HangOutControlViewDelegate <NSObject>
- (void)closeControlView:(HangOutControlView *)view;
- (void)muteOrOpenMicrophone:(HangOutControlView *)view;
- (void)silentOrLoudSound:(HangOutControlView *)view;
- (void)endHangOutLiveRoom:(HangOutControlView *)view;
@end

@interface HangOutControlView : UIView

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UIButton *muteButton;

@property (weak, nonatomic) IBOutlet UIButton *silentButton;

@property (weak, nonatomic) IBOutlet UIButton *endButton;

@property (weak, nonatomic) id<HangOutControlViewDelegate> delagate;

+ (instancetype)controlView;

@end
