//
//  ChatAudioPlayer.m
//  dating
//
//  Created by Calvin on 17/4/27.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "QNChatAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface QNChatAudioPlayer ()<AVAudioPlayerDelegate>
@property (nonatomic,strong)AVAudioPlayer *player;
@end

@implementation QNChatAudioPlayer

+ (QNChatAudioPlayer *)sharedInstance
{
    static QNChatAudioPlayer *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        
    });    
    return sharedInstance;
}

-(void)playSongWithUrl:(NSString *)songUrl
{
    //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:UIDeviceProximityStateDidChangeNotification object:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
    else
    {
        NSLog(@"添加近距离事件监听失败");
    }
    
    NSData *songData = [NSData dataWithContentsOfFile:songUrl];
    [self playSongWithData:songData path:songUrl];

}

-(void)playSongWithData:(NSData *)songData path:(NSString *)path
{
    if (self.player) {
        [self.player stop];
        self.player.delegate = nil;
        self.player = nil;
    }
    
    NSError *playerError;
    
    self.player = [[AVAudioPlayer alloc]initWithData:songData error:&playerError];
    if (!self.player) {
        
        self.player = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:path] error:&playerError];
        
        if (!self.player) {            
            NSLog(@"failed to init AudioPlayer. error: %@", playerError.description);

            if ([self.delegate respondsToSelector:@selector(chatAudioPlayerFailPlay)]) {
                [self.delegate chatAudioPlayerFailPlay];
            }
            //播放失败
            [self removNotification];
            return;
        }
    }
    self.player.volume = 1.0f;
    self.player.delegate = self;
    [self.player play];
    self.isPlaying = YES;
    if ([self.delegate respondsToSelector:@selector(chatAudioPlayerBeiginPlay)]) {
    [self.delegate chatAudioPlayerBeiginPlay];
    }
}


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{    
    if ([self.delegate respondsToSelector:@selector(chatAudioPlayerDidFinishPlay)]) {
       [self.delegate chatAudioPlayerDidFinishPlay];
    }
    self.isPlaying = NO;
    [self stopSound];
}

- (void)stopSound
{
    if (self.player && self.player.isPlaying) {
        self.isPlaying = NO;
        [self.player stop];
        [self removNotification];
    }
}

- (void)removDelegate
{
    self.player.delegate = nil;
    self.player = nil;
    
//    AVAudioSession *avSession = [AVAudioSession sharedInstance];
//    [avSession setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (void)removNotification
{
    //删除近距离事件监听
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    if ([UIDevice currentDevice].proximityMonitoringEnabled == YES) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceProximityStateDidChangeNotification object:nil];
    }
    else
    {
       // NSLog(@"删除近距离事件监听失败");
    }
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
  
    //切换回扬声器
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    //NSLog(@"播放完成");
}

#pragma mark - 处理近距离监听触发事件
-(void)sensorStateChange:(NSNotificationCenter *)notification
{
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)//黑屏
    {
        NSLog(@"切换到听筒模式");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
    }
    else//没黑屏幕
    {
        NSLog(@"切换到扬声器模式");
        NSError * error;
        [[AVAudioSession sharedInstance] setActive:YES error:&error];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
       
    }
}

@end
