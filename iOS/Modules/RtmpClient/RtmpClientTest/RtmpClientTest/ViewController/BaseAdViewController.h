//
//  BaseAdViewController.h
//  Cartoon
//
//  Created by Max on 2021/5/7.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^AdRewardHandler)(BOOL success);
@interface BaseAdViewController : BaseViewController
- (void)tryAllAD:(AdRewardHandler _Nullable)rewardHandler;
- (void)tryLoadAD;
- (BOOL)tryShowAD:(AdRewardHandler _Nullable)rewardHandler;
- (BOOL)showInterstitialAD:(AdRewardHandler _Nullable)rewardHandler;
- (BOOL)showRewardAD:(AdRewardHandler _Nullable)rewardHandler;
- (BOOL)showRewardInsertAD:(AdRewardHandler _Nullable)rewardHandler;
- (void)showBanner;
@end

NS_ASSUME_NONNULL_END
