//
//  ShareManager.m
//  livestream
//
//  Created by randy on 2017/12/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ShareManager.h"
#import "LSSetShareSucRequest.h"
#import <AccountSDK/AccountSDK.h>
#import <Social/Social.h>

@implementation ShareManager

+ (instancetype)manager{
    
    static ShareManager *manager = nil;
    if (!manager) {
        manager = [[ShareManager alloc] init];
    }
    return manager;
}

- (void)sendShareForUserId:(NSString *)userId anchorId:(NSString *)anchorId shareType:(ShareType)shareType shareHandler:(ShareHandler)shareHandler {
    LSGetShareLinkRequest *request = [[LSGetShareLinkRequest alloc] init];
    request.shareuserId = userId;
    request.anchorId = anchorId;
    request.shareType = shareType;
    request.sharePageType = SHAREPAGETYPE_FREEROOM;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull shareId, NSString * _Nonnull shareLink) {
        NSLog(@"ShareManager::sendShareforUserId( [请求分享链接], success:%d, errnum:%ld, errmsg:%@, shareId:%@, shareLink:%@ )", success, (long)errnum, errmsg, shareId, shareLink);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                ACCountSDKShareItem *shareItem = [[ACCountSDKShareItem alloc] init];
                shareItem.type = ACCountSDKShareItemType_Link;
                shareItem.url = shareLink;
                
                if (shareType == SHARETYPE_FACEBOOK) {
                    [[AccountSDKManager shareInstance] shareItem:AccountSDKType_Facebook vc:self.presentVC shareItem:shareItem handler:^(BOOL success, NSError *error) {
                        NSLog(@"ShareManager::facebookShareAction( [Facebook分享], success : %d, error : %@ )", success, error);
                        if (success) {
                            [self shareSuccessNotice:shareId];
                        }
                        shareHandler(success, error.domain, shareId);
                    }];
                } else if (shareType == SHARETYPE_TWITTER) {
                    [[AccountSDKManager shareInstance] shareItem:AccountSDKType_Twitter vc:self.presentVC shareItem:shareItem handler:^(BOOL success, NSError *error) {
                        NSLog(@"ShareManager::twitterShareAction( [Twitter分享], success : %d, error : %@ )", success, error);
                        if (success) {
                            [self shareSuccessNotice:shareId];
                        }
                        shareHandler(success, error.domain, shareId);
                    }];
                }
            } else {
                shareHandler(success, errmsg, shareId);
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}

- (void)shareSuccessNotice:(NSString *)shareId {
    LSSetShareSucRequest *request = [[LSSetShareSucRequest alloc] init];
    request.shareId = shareId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        NSLog(@"ShareManager::shareSuccessNotice [Finish], succes:%d, errnum:%ld, errmsg:%@",success, (long)errnum, errmsg);
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}

- (BOOL)copyLinkToClipboard:(NSString *)shareLink {
    BOOL bFlag = NO;
    UIPasteboard *pab = [UIPasteboard generalPasteboard];
    if (shareLink.length < 1) {
        return bFlag;
    }
    [pab setString:shareLink];
    if (pab) {
        bFlag = YES;
    }
    return bFlag;
}

- (void)systemsShareForShareLink:(NSString *)shareLink finishHandler:(SystemsShareHandler)finishHandler {
    
    NSURL *url = [NSURL URLWithString:shareLink];
    if (url != nil) {
        NSArray *shareUrl = @[url];
        UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:shareUrl applicationActivities:nil];
        [self.presentVC presentViewController:activity animated:YES completion:nil];
        [activity setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            NSLog(@"ShareManager::systemsShareForShareLink [系统分享] activityType : %@, success : %d, error : %@",activityType, completed, activityError);
            
        }];
    }
}

@end
