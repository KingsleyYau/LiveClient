//
//  LSGreetingVideoPlayView.h
//  livestream
//
//  Created by Randy_Fan on 2018/11/28.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSMailAttachmentModel.h"

@class LSGreetingVideoPlayView;
@protocol LSGreetingVideoPlayViewDelegate <NSObject>
@optional
- (void)greetingVideoPlayView:(LSGreetingVideoPlayView *)view noReplyReplayVideo:(LSMailAttachmentModel *)model;
- (void)greetingVideoPlayView:(LSGreetingVideoPlayView *)view replyGreeting:(LSMailAttachmentModel *)model;
- (void)greetingVideoPlayView:(LSGreetingVideoPlayView *)view isReplyReplayVideo:(LSMailAttachmentModel *)model;
@end

@interface LSGreetingVideoPlayView : UIView
// 视频播放界面
@property (weak, nonatomic) IBOutlet UIView *videoPlayView;
// 视频封面图片
@property (weak, nonatomic) IBOutlet UIImageView *videoCoverImageView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activiView;

// 播放结束界面
@property (weak, nonatomic) IBOutlet UIView *endView;
// 未回复结束界面
@property (weak, nonatomic) IBOutlet UIView *noReplyView;
@property (weak, nonatomic) IBOutlet UILabel *videoTimeLabel;
// 已回复结束界面
@property (weak, nonatomic) IBOutlet UIView *isReplyView;

@property (nonatomic, weak) id<LSGreetingVideoPlayViewDelegate> delegate;

@property (nonatomic, strong) LSMailAttachmentModel *item;

- (void)setupDetail;
- (void)activiViewIsShow:(BOOL)isShow;

@end
