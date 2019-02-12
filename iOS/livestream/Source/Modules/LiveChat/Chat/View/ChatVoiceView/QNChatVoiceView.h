//
//  ChatVoiceView.h
//  dating
//
//  Created by Calvin on 17/4/26.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
@protocol ChatVoiceViewDelegate <NSObject>

- (void)sendVoice:(NSString *)voice time:(int)time;
@end

@interface QNChatVoiceView : UIView

@property (nonatomic,weak) id<ChatVoiceViewDelegate> delegate;
@property BOOL isFail;
// 录音按钮按下
-(void)voiceButtonTouchDown;
// 手指在录音按钮内部时离开
-(void)voiceButtonTouchUpInside;
// 手指在录音按钮外部时离开
-(void)voiceButtonTouchUpOutside;
// 手指移动到录音按钮内部
-(void)voiceButtonDragInside;
// 手指移动到录音按钮外部
-(void)voiceButtonDragOutside;

+ (BOOL)canRecord;
@end
