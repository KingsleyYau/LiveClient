//
//  Mp3Recorder.h
//  BloodSugar
//
//  Created by PeterPan on 14-3-24.
//  Copyright (c) 2014年 shake. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Mp3RecorderDelegate <NSObject>
@optional
- (void)failRecord;
- (void)beginConvert;
- (void)endConvertWithMP3Path:(NSString *)voicePath;
- (void)volume:(double)volume;
@end

@interface Mp3Recorder : NSObject
@property (nonatomic, weak) id<Mp3RecorderDelegate> delegate;

- (id)initWithDelegate:(id<Mp3RecorderDelegate>)delegate;
- (void)startRecord:(NSString *)pathName;
- (void)stopRecord;
- (void)cancelRecord;

@end
