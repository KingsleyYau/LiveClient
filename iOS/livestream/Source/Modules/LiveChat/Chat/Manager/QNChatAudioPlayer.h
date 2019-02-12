//
//  ChatAudioPlayer.h
//  dating
//
//  Created by Calvin on 17/4/27.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>


@protocol ChatAudioPlayerDelegate <NSObject>
@optional
- (void)chatAudioPlayerBeiginPlay;
- (void)chatAudioPlayerDidFinishPlay;
- (void)chatAudioPlayerFailPlay;
@end

@interface QNChatAudioPlayer : NSObject

@property (nonatomic, weak)id <ChatAudioPlayerDelegate>delegate;
+ (QNChatAudioPlayer *)sharedInstance;
@property (nonatomic,assign) BOOL isPlaying;
-(void)playSongWithUrl:(NSString *)songUrl;
-(void)playSongWithData:(NSData *)songData path:(NSString *)path;

- (void)stopSound;
- (void)removNotification;
- (void)removDelegate;
@end
