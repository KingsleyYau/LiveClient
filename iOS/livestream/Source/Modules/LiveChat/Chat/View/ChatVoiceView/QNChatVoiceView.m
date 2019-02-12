//
//  ChatVoiceView.m
//  dating
//
//  Created by Calvin on 17/4/26.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "QNChatVoiceView.h"
#import "Mp3Recorder.h"
@interface QNChatVoiceView ()<Mp3RecorderDelegate>
@property (nonatomic,strong) UIView * bgView;
@property (nonatomic,strong) NSTimer *countDownTimer;
@property (nonatomic,strong) UILabel *numLabel;
@property (nonatomic,strong) UILabel *infoLabel;
@property (nonatomic,assign) int time;
@property (nonatomic,strong) Mp3Recorder * mp3;
@property (nonatomic,strong) UIView *volumeView;
@end

@implementation QNChatVoiceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.mp3 = [[Mp3Recorder alloc]initWithDelegate:self];
        
        self.bgView = [[UIView alloc]initWithFrame:CGRectMake(screenSize.width/2 - 50, screenSize.height/2 - 60, 100, 110)];
        self.bgView.backgroundColor = [UIColor blackColor];
        self.bgView.layer.masksToBounds = YES;
        self.bgView.layer.cornerRadius = 8;
        [self addSubview:self.bgView];
        
        self.numLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 50, 30)];
        self.numLabel.text = @"0";
        self.numLabel.textColor = [UIColor whiteColor];
        self.numLabel.textAlignment = NSTextAlignmentCenter;
        self.numLabel.font = [UIFont systemFontOfSize:40];
        [self.bgView addSubview:self.numLabel];
        
        self.infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.numLabel.frame.origin.x, self.numLabel.frame.origin.y + self.numLabel.frame.size.height + 10, self.bgView.frame.size.width - self.numLabel.frame.origin.x * 2, 40)];
        self.infoLabel.numberOfLines = 0;
        self.infoLabel.textColor = [UIColor whiteColor];
        self.infoLabel.font = [UIFont systemFontOfSize:13];
        self.infoLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgView addSubview:self.infoLabel];
        
        [self initVolumeView];
    }
    return self;
}

- (void)initVolumeView
{
    [self.volumeView removeFromSuperview];
    self.volumeView = [[UIView alloc]initWithFrame:CGRectMake(self.numLabel.frame.origin.x + self.numLabel.frame.size.width + 10, 20, 50, 30)];
    [self.bgView addSubview:self.volumeView];
}
// 录音按钮按下
-(void)voiceButtonTouchDown
{
    self.infoLabel.text = @"Slide up to cancel";
    self.time = 0;
    self.numLabel.text = @"0";
    self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownTime) userInfo:nil repeats:YES];
    [self.mp3 startRecord:[NSString stringWithFormat:@"%0.f",[[NSDate date] timeIntervalSince1970]]];
}

// 手指在录音按钮内部时离开
-(void)voiceButtonTouchUpInside
{
    if (self.countDownTimer) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
        [self.mp3 stopRecord];
    }
}

// 手指在录音按钮外部时离开
-(void)voiceButtonTouchUpOutside
{
    if (self.countDownTimer) {
        [self.countDownTimer invalidate];
        self.countDownTimer = nil;
        self.time = 0;
        [self.mp3 cancelRecord];
    }
}

// 手指移动到录音按钮内部
-(void)voiceButtonDragInside
{
     self.infoLabel.text = @"Slide up to cancel";
}

// 手指移动到录音按钮外部
-(void)voiceButtonDragOutside
{
    self.infoLabel.text = @"Release to cancel";
}

- (void)countDownTime
{
    self.time += [self.countDownTimer timeInterval];
    self.numLabel.text = [NSString stringWithFormat:@"%d",self.time];
    if (self.time >= 30.0f) {
        [self voiceButtonTouchUpInside];
        [self removeFromSuperview];
    }
}

#pragma mark - Mp3RecorderDelegate

//回调录音资料
- (void)endConvertWithMP3Path:(NSString *)voicePath
{
    if (voicePath.length > 0) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(sendVoice:time:)]){
            [self.delegate sendVoice:voicePath time:self.time];
        }
    }
    self.time = 0;
    self.isFail = NO;
}

- (void)failRecord
{
    //录音失败
    NSLog(@"录音失败");
    if (self.time <= 1) {
        [self.volumeView removeFromSuperview];
        self.isFail = YES;
        self.numLabel.frame = CGRectMake(0, 20, self.bgView.frame.size.width, 40);
        if (self.time ==1) {
            self.numLabel.text = @"!";
            self.infoLabel.text = @"Message too short";
        }
        else
        {
            self.numLabel.text = @"0";
            self.infoLabel.text = @"Hold to speak";
        }
        [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:2];
        [self voiceButtonTouchUpOutside];
    }
 
}


- (void)volume:(double)volume
{
    [self initVolumeView];
    
    NSInteger num = 0;
    if (volume <= 0.20) {
        num = 1;
    }else if (0.20<volume<=0.40) {
        num = 2;
    } else if (0.40<volume<=0.60) {
        num = 3;
    }else if (0.60<volume<=0.80) {
        num = 4;
    }else {
        num = 5;
    }
    
    for (int i = 0; i < num; i++) {
        
        CGFloat w = 10 + i *2;
        CGFloat y = self.volumeView.frame.size.height - i * 6;
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, y - 5, w, 4)];
        view.backgroundColor = [UIColor whiteColor];
        [self.volumeView addSubview:view];
    }
}

+ (BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0) {
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"DidAudioPermissions"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                }
            }];
        }
    }
    return bCanRecord;
}

@end
