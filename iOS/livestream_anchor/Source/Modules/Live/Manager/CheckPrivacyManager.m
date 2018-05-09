//
//  CheckPrivacyManager.m
//  livestream_anchor
//
//  Created by Randy_Fan on 2018/3/28.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "CheckPrivacyManager.h"
#import "LiveStreamSession.h"

@interface CheckPrivacyManager()<UIAlertViewDelegate>

@end

@implementation CheckPrivacyManager

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)checkPrivacyIsOpen:(CheckHandler)handler {
    
    [[LiveStreamSession session] checkCanVideo:^(BOOL granted) {
        if (granted) {
            [[LiveStreamSession session] checkCanAudio:^(BOOL granted) {
                if (granted) {
                    handler(granted);
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showOpenAudioAlert];
                    });
                }
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showOpenVideoAlert];
            });
        }
    }];
}

- (void)showOpenVideoAlert {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"ALERT_VIDEO_TIP", @"ALERT_VIDEO_TIP") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"CANCEL") otherButtonTitles:NSLocalizedString(@"SETTING", @"SETTING"), nil];
    [alertView show];
}

- (void)showOpenAudioAlert {
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"ALERT_AUDIO_TIP", @"ALERT_AUDIO_TIP") delegate:self cancelButtonTitle:NSLocalizedString(@"CANCEL", @"CANCEL") otherButtonTitles:NSLocalizedString(@"SETTING", @"SETTING"), nil];
    [alertView show];
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:appSettings];
    } else {
        if ([self.checkDelegate respondsToSelector:@selector(cancelPrivacy)]) {
            [self.checkDelegate cancelPrivacy];
        }
    }
}

@end
