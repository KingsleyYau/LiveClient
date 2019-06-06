//
//  Mp3Recorder.m
//  BloodSugar
//
//  Created by PeterPan on 14-3-24.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import "Mp3Recorder.h"
#import "lame.h"
#import <AVFoundation/AVFoundation.h>

@interface Mp3Recorder()<AVAudioRecorderDelegate>
{
    NSTimer *timer;
}
@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, copy) NSString *path;
@end

@implementation Mp3Recorder

#pragma mark - Init Methods

- (id)initWithDelegate:(id<Mp3RecorderDelegate>)delegate
{
    if (self = [super init]) {
        _delegate = delegate;
    }
    return self;
}

- (void)setRecorder
{
    _recorder = nil;
    NSError *recorderSetupError = nil;
    NSURL *url = [NSURL fileURLWithPath:[self cafPath]];
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    //录音格式 无法使用
    [settings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    //采样率
    [settings setValue :[NSNumber numberWithFloat:11025.0] forKey: AVSampleRateKey];//44100.0
    //通道数
    [settings setValue :[NSNumber numberWithInt:2] forKey: AVNumberOfChannelsKey];
    //音频质量,采样质量
    [settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    _recorder = [[AVAudioRecorder alloc] initWithURL:url
                                            settings:settings
                                               error:&recorderSetupError];
    if (_recorder) {
        _recorder.meteringEnabled = YES;
        _recorder.delegate = self;
        [_recorder prepareToRecord];
        
        //设置定时检测
        timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
    }
    else
    {
        NSLog(@"%@",[recorderSetupError description]);
    }

}

- (void)detectionVoice
{
    [_recorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
    double lowPassResults = pow(10, (0.05 * [_recorder peakPowerForChannel:0]));
    
    [self.delegate volume:lowPassResults];
    
}

- (void)setSesstion
{
    _session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [_session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    if(_session == nil)
    {
        NSLog(@"Error creating session: %@", [sessionError description]);
    }
    else
    {
        [_session setActive:YES error:nil];
    }
}

#pragma mark - Public Methods

- (void)startRecord:(NSString *)pathName
{
    self.path = pathName;
    [self setSesstion];
    [self setRecorder];
    [_recorder record];
}


- (void)stopRecord
{
    double cTime = _recorder.currentTime;
    [_recorder stop];
    [timer invalidate];
    timer = nil;
    if (cTime > 1) {
        [self audio_PCMtoMP3];
    }else {
        
        //[_recorder deleteRecording];
        
        if ([_delegate respondsToSelector:@selector(failRecord)]) {
            [_delegate failRecord];
        }
    }
    
//    if(_session)
//        [_session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (void)cancelRecord
{
    [_recorder stop];
    [timer invalidate];
    timer = nil;
    //[_recorder deleteRecording];
    
//    if(_session)
//        [_session setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (void)deleteMp3Cache
{
    [self deleteFileWithPath:[self mp3Path]];
}

- (void)deleteCafCache
{
    [self deleteFileWithPath:[self cafPath]];
}

- (void)deleteFileWithPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager removeItemAtPath:path error:nil])
    {
        NSLog(@"删除以前的mp3文件");
    }
}

#pragma mark - Convert Utils
- (void)audio_PCMtoMP3
{
    NSString *cafFilePath = [self cafPath];
    NSString *mp3FilePath = [self mp3Path];
    
    // remove the old mp3 file
    [self deleteMp3Cache];

    if (_delegate && [_delegate respondsToSelector:@selector(beginConvert)]) {
        [_delegate beginConvert];
    }
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:1], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:1], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 11025.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {
//        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategorySoloAmbient error: nil];
    }
    
    [self deleteCafCache];
   
    if (_delegate && [_delegate respondsToSelector:@selector(endConvertWithMP3Path:)]) {
        [_delegate endConvertWithMP3Path:[self mp3Path]];
    }
}

#pragma mark - Path Utils
- (NSString *)cafPath
{
    NSString *cafPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.caf",self.path]];
    
        //NSString *cafPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"mp3.caf"];
    return cafPath;
}

- (NSString *)mp3Path
{
    NSString *mp3Path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",self.path]];
     //NSString *mp3Path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"mp3.mp3"];
    return mp3Path;
}

@end
