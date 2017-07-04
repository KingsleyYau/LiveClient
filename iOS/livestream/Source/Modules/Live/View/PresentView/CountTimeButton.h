//
//  CountTimeButton.h
//  UIWidget
//
//  Created by test on 2017/6/19.
//  Copyright © 2017年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CountTimeButton;
typedef NSString* (^CountDownChanging)(CountTimeButton *countDownButton,NSInteger second);
typedef NSString* (^CountDownFinished)(CountTimeButton *countDownButton,NSInteger second);
typedef void (^TouchedCountDownButtonHandler)(CountTimeButton *countDownButton,NSInteger tag);

@interface CountTimeButton : UIButton

/** 文字 */
@property (nonatomic, strong) NSString* titleName;
//倒计时按钮点击回调
- (void)countDownButtonHandler:(TouchedCountDownButtonHandler)touchedCountDownButtonHandler;
//开始倒计时
- (void)startCountDownWithSecond:(NSUInteger)second;
// 倒计时变化
- (void)countDownChanging:(CountDownChanging)countDownChanging;
// 倒计时完成
- (void)countDownFinished:(CountDownFinished)countDownFinished;
//停止倒计时
- (void)stopCountDown;
@end
