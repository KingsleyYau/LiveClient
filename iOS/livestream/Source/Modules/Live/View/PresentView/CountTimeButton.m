//
//  CountTimeButton.m
//  UIWidget
//
//  Created by test on 2017/6/19.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "CountTimeButton.h"

@interface CountTimeButton()

/** 倒计时时间 */
@property (nonatomic, assign) NSInteger second;
/** 倒计时的总时间 */
@property (nonatomic, assign) NSInteger totalSecond;
/** 计时器 */
@property (nonatomic, strong) NSTimer *timer;

@end




@implementation CountTimeButton

- (void)awakeFromNib {
    [super awakeFromNib];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self setTitleEdgeInsets:UIEdgeInsetsMake(10, 0, 0, 0)];
}

- (void)stop {
    NSLog(@"CountTimeButton::stop()");
    
    self.countDownChanging = nil;
    self.countDownFinished = nil;
    self.touchedCountDownButtonHandler = nil;
    [self stopCountDown];
    
}

#pragma mark touche action
- (void)countDownButtonHandler:(TouchedCountDownButtonHandler)touchedCountDownButtonHandler{
    [self addTarget:self action:@selector(touched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)touched:(CountTimeButton*)sender {
    if (self.touchedCountDownButtonHandler) {
        self.touchedCountDownButtonHandler(sender,sender.tag);
    }
}

#pragma mark count down method
- (void)startCountDownWithSecond:(NSUInteger)totalSecond {
    self.totalSecond = totalSecond;
    self.second = totalSecond;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(timerStart:) userInfo:nil repeats:YES];

    [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}
- (void)timerStart:(NSTimer *)theTimer {

    self.second--;
    
    
    if (self.second <= 0.0) {
        [self stopCountDown];
    }else{
        if (self.countDownChanging){
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
              self.titleLabel.numberOfLines = 0;
            [self setAttributedTitle:self.countDownChanging(self,self.second) forState:UIControlStateNormal];
            [self setAttributedTitle:self.countDownChanging(self,self.second) forState:UIControlStateDisabled];
            
        }else{
            NSString *title = [NSString stringWithFormat:@"%zd\n combo",self.second];
            self.titleLabel.numberOfLines = 0;
            self.titleLabel.textAlignment = NSTextAlignmentCenter;
            [self setTitle:title forState:UIControlStateNormal];
            [self setTitle:title forState:UIControlStateDisabled];
            
        }
    }
}

- (void)stopCountDown{
    if (self.timer) {
        if ([self.timer respondsToSelector:@selector(isValid)]) {
            if ([self.timer isValid]) {
                [self.timer invalidate];
//                self.second = self.totalSecond;
                if (self.countDownFinished) {
                    self.titleLabel.numberOfLines = 0;
                    [self setAttributedTitle:self.countDownFinished(self,self.second)forState:UIControlStateNormal];
                    [self setAttributedTitle:self.countDownFinished(self,self.second)forState:UIControlStateDisabled];
                    
                }else {
                    self.titleLabel.numberOfLines = 0;
                    [self setTitle:self.titleName forState:UIControlStateNormal];
                    [self setTitle:self.titleName forState:UIControlStateDisabled];
                    
                }
            }
        }
    }
}
#pragma mark block
- (void)countDownChanging:(CountDownChanging)countDownChanging{
    self.countDownChanging = countDownChanging;

}
- (void)countDownFinished:(CountDownFinished)countDownFinished{
    self.countDownFinished = countDownFinished;
}


- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
  
    
}
@end
