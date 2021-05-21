//
//  BaseAdViewController.h
//  Cartoon
//
//  Created by Max on 2021/5/7.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseAdViewController : BaseViewController
- (void)tryAllAD;
- (void)tryLoadAD;
- (BOOL)tryShowAD;
- (BOOL)showInterstitialAD;
- (BOOL)showRewardAD;
- (BOOL)showRewardInsertAD;
- (void)showBanner;
@end

NS_ASSUME_NONNULL_END
