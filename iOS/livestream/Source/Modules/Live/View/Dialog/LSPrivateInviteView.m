//
//  LSPrivateInviteView.m
//  livestream
//
//  Created by test on 2019/6/11.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSPrivateInviteView.h"
#import "LSImageViewLoader.h"
#import "LiveUrlHandler.h"
#import "HomeVouchersManager.h"
#define defaultCount 30

@interface LSPrivateInviteView()
@property (strong , nonatomic) NSTimer *declineTimer;
@property (nonatomic, strong) LSImageViewLoader *loader;
@property (nonatomic, assign) NSInteger totalCount;
@end



@implementation LSPrivateInviteView

+ (instancetype)initPrivateInviteView {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSPrivateInviteView" owner:nil options:nil];
    LSPrivateInviteView* view = [nibs objectAtIndex:0];
    view.contentView.layer.cornerRadius = 5.0f;
    view.contentView.layer.masksToBounds = YES;
    view.startOneOnOneBtn.layer.cornerRadius = view.startOneOnOneBtn.frame.size.height * 0.5f;
    view.startOneOnOneBtn.layer.masksToBounds = YES;
    view.loader = [LSImageViewLoader loader];
    view.anchorIcon.layer.cornerRadius = view.anchorIcon.frame.size.width * 0.5f;
    view.anchorIcon.layer.masksToBounds = YES;
    view.totalCount = defaultCount;
    return view;
}

- (void)showPrivateViewInView:(UIView *)view {
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    if (self && view) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.leading.trailing.equalTo(view);
        }];

    }
    self.inviteMsg.text = [NSString stringWithFormat:@"%@ is inviting your to start One-on-One broadcast!",self.item.anchorName];
    
    UIImageView *imageV = [[UIImageView alloc] init];
    [self.loader loadImageFromCache:imageV options:SDWebImageRefreshCached imageUrl:self.item.anchorPhotoUrl placeholderImage:[UIImage imageNamed:@""] finishHandler:^(UIImage *image) {
        [self.anchorIcon setImage:image forState:UIControlStateNormal];
    }];
    
    // 是否有私密试聊卷
    BOOL isFree = NO;
    if ([[HomeVouchersManager manager] isShowInviteFree:self.item.anchorId]) {
        isFree = YES;
    }

    self.freeIcon.hidden = !isFree;
    
    [self.declineTimer fire];
}

- (void)timerStart:(NSTimer *)time {
    if (self.totalCount <= 0) {
        [self removeShow];
        return;
    }
    self.totalCount--;
    NSString *title = [NSString stringWithFormat:@"%lus Decline",(long)self.totalCount];
    NSMutableAttributedString *atts = [[NSMutableAttributedString alloc] initWithString:title attributes:@{
                                                                                                           NSUnderlineStyleAttributeName :@(NSUnderlineStyleSingle)
                                                                                                                        }];
    [self.declineBtn setAttributedTitle:atts forState:UIControlStateNormal];
}

- (NSTimer *)declineTimer {
    if (!_declineTimer) {
        _declineTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                       selector:@selector(timerStart:)
                                                    userInfo:nil
                                                     repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_declineTimer forMode:NSRunLoopCommonModes];
    }
    return _declineTimer;
}

- (void)stopTimer {
    if (_declineTimer) {
        [_declineTimer invalidate];
        _declineTimer = nil;
    }
}


- (void)removeShow {
    [self stopTimer];
    [self removeFromSuperview];
}

- (IBAction)declineAction:(id)sender {
    [self removeShow];
}

- (IBAction)startOneOnOneAction:(id)sender {
    [self removeShow];
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToInviteByRoomId:@"" anchorId:self.item.anchorId roomType:LiveRoomType_Private];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}
@end
