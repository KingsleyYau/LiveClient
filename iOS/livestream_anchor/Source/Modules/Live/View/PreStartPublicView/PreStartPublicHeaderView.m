//
//  PreStartPublicHeaderView.m
//  livestream_anchor
//
//  Created by test on 2018/3/2.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "PreStartPublicHeaderView.h"
#import "LiveStreamPublisher.h"
#import "LiveStreamPlayer.h"


@interface PreStartPublicHeaderView()

@property (strong) LiveStreamPlayer *palyer;
@property (strong) LiveStreamPublisher *publisher;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *videoLoadView;


@end


@implementation PreStartPublicHeaderView

+ (PreStartPublicHeaderView *)headerView {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:nil options:nil];
    PreStartPublicHeaderView* view = [nibs objectAtIndex:0];
    [view setupVideoPlay];
    [view hiddenVideoLoadView];
    return view;
}


- (void)setupVideoPlay {
    self.publisher = [LiveStreamPublisher instance];
    [self.publisher initCapture];
    self.publisher.publishView = self.videoView;
    self.videoView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
}


- (void)startPreViewVideoPlay {
    [self.publisher startPreview];
}

- (void)stopPreViewVideoPlay {
    [self.publisher stopPreview];
}
- (IBAction)closeAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(preStartPublicHeaderViewCloseAction:)]) {
        [self.delegate preStartPublicHeaderViewCloseAction:self];
    }
}

- (void)showVideoLoadView {
    self.videoLoadView.hidden = NO;
    [self.videoLoadView startAnimating];
}

- (void)hiddenVideoLoadView {
    self.videoLoadView.hidden = YES;
    [self.videoLoadView stopAnimating];
}

@end

