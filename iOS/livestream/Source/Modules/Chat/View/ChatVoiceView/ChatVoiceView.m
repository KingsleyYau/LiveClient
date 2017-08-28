//
//  ChatVoiceView.m
//  dating
//
//  Created by Calvin on 17/4/26.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "ChatVoiceView.h"
#import "Mp3Recorder.h"
@interface ChatVoiceView ()<Mp3RecorderDelegate>
@property (nonatomic,strong) UIView * bgView;
@property (nonatomic,strong) NSTimer *countDownTimer;
@property (nonatomic,strong) UILabel *numLabel;
@property (nonatomic,strong) UILabel *infoLabel;
@property (nonatomic,assign) int time;
@property (nonatomic,strong) Mp3Recorder * mp3;
@property (nonatomic,strong) UIView *volumeView;
@end

@implementation ChatVoiceView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.mp3 = [[Mp3Recorder alloc]initWithDelegate:self];
        
        self.bgView = [[UIView alloc]initWithFrame:CGRectMake(screenSize.width/2 - 50, screenSize.height/2 - 60, 130, 143)];
        self.bgView.backgroundColor = [UIColor blackColor];
        self.bgView.layer.masksToBounds = YES;
        self.bgView.layer.cornerRadius = 8;
        [self addSubview:self.bgView];
        
        self.numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 30, 90, 60)];
        self.numLabel.text = @"0";
        self.numLabel.textColor = [UIColor whiteColor];
        self.numLabel.textAlignment = NSTextAlignmentCenter;
        self.numLabel.font = [UIFont systemFontOfSize:70];
        self.numLabel.hidden = YES;
        [self.bgView addSubview:self.numLabel];
        
        self.infoLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.numLabel.frame.origin.x, self.numLabel.frame.origin.y + self.numLabel.frame.size.height , self.bgView.frame.size.width - self.numLabel.frame.origin.x * 2, 40)];
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
    self.volumeView = [[UIView alloc]initWithFrame:CGRectMake(self.numLabel.frame.size.width + 5, 40, 86, 50)];
    [self.bgView addSubview:self.volumeView];
}
// 录音按钮按下
-(void)voiceButtonTouchDown
{
    self.infoLabel.text = @"Drop to send \n Upglide to cancel";
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
    self.infoLabel.text = @"Drop to send \n Upglide to cancel";
}

// 手指移动到录音按钮外部
-(void)voiceButtonDragOutside
{
    self.infoLabel.text = @"Drop to cancel";
}

- (void)countDownTime
{
    self.time += [self.countDownTimer timeInterval];
    self.countDownCount = 15 - self.time;
    self.numLabel.text = [NSString stringWithFormat:@"%d",self.countDownCount];
    
    if (self.countDownCount <= 5) {
        self.numLabel.hidden = NO;
        
        if (self.countDownCount == 0) {
            [self voiceButtonTouchUpInside];
            [self removeFromSuperview];
        }
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
            self.infoLabel.text = @"Too short to send";
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
    }else if (0.20<volume<=0.30) {
        num = 2;
    } else if (0.30<volume<=0.40) {
        num = 3;
    }else if (0.40<volume<=0.50) {
        num = 4;
    }else if (0.50<volume<=0.60) {
        num = 5;
    }else if (0.60<volume<=0.70) {
        num = 6;
    }else if (0.70<volume<=0.80) {
        num = 7;
    }else if (0.80<volume<=0.90) {
        num = 8;
    }else {
        num = 9;
    }

    
    for (int i = 0; i < num; i++) {
        
        CGFloat w = 15 + i *2;
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
