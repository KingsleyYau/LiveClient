//
//  LiveSendBarView.h
//  livestream
//
//  Created by randy on 2017/8/28.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRoomTextField.h"
#import "LiveRoom.h"

@class LiveSendBarView;
@protocol LiveSendBarViewDelegate <NSObject>

- (void)sendBarLouserAction:(LiveSendBarView *)sendBarView isSelected:(BOOL)isSelected;
- (void)sendBarEmotionAction:(LiveSendBarView *)sendBarView isSelected:(BOOL)isSelected;
- (void)sendBarSendAction:(LiveSendBarView *)sendBarView;

@end

@interface LiveSendBarView : UIView <LSCheckButtonDelegate, UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet id<LiveSendBarViewDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIImageView *sendBarBgImageView;

@property (weak, nonatomic) IBOutlet UIView *inputBackGroundView;

@property (weak, nonatomic) IBOutlet UIImageView *inputBackGroundImageView;

@property (weak, nonatomic) IBOutlet LSCheckButton * louderBtn;

@property (weak, nonatomic) IBOutlet LiveRoomTextField *inputTextField;

@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@property (weak, nonatomic) IBOutlet LSCheckButton * emotionBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emotionBtnWidth;

@property (nonatomic, strong) UIImage *louderBtnImage;
@property (nonatomic, strong) UIColor *placeholderColor;

@property (nonatomic, strong) LiveRoom *liveRoom;

- (IBAction)sendAction:(id)sender;

/** 发送按钮可用 */
- (void)sendButtonNotUser;

/** 发送按钮不可用 */
- (void)sendButtonCanUser;

@end
