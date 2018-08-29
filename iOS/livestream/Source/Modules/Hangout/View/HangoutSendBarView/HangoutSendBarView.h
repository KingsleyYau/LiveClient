//
//  HangoutSendBarView.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/15.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRoomTextField.h"
#import "LiveRoom.h"

@class HangoutSendBarView;
@protocol HangoutSendBarViewDelegate <NSObject>

- (void)sendBarEmotionAction:(HangoutSendBarView *)sendBarView isSelected:(BOOL)isSelected;
- (void)sendBarSendAction:(HangoutSendBarView *)sendBarView;

@end

@interface HangoutSendBarView : UIView <LSCheckButtonDelegate, UITextFieldDelegate>

@property (weak, nonatomic) id<HangoutSendBarViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet LiveRoomTextField *inputTextField;

@property (weak, nonatomic) IBOutlet LSCheckButton * emotionBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emotionBtnWidth;

@property (nonatomic, strong) UIColor *placeholderColor;

@property (nonatomic, strong) LiveRoom *liveRoom;

@end
