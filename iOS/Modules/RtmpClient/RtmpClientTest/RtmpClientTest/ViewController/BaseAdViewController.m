//
//  BaseAdViewController.m
//  Cartoon
//
//  Created by Max on 2021/5/7.
//

#import "BaseAdViewController.h"
#import "AppDelegate.h"
#import <Masonry/Masonry.h>
#import "BaseAdHeader.h"

@import GoogleMobileAds;

@interface BaseAdViewController () <GADFullScreenContentDelegate, GADBannerViewDelegate>
@property (strong) GADInterstitialAd *interstitial;
@property (strong) GADRewardedAd *rewardedAd;
@property (strong) GADRewardedInterstitialAd *rewardedInterstitialAd;
@property (strong) GADBannerView *bannerView;
@property (assign) BOOL adShowed;
@property (assign) UIView *originalView;
@end

@implementation BaseAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.bannerView.adUnitID = AD_BANNER;
    self.bannerView.rootViewController = self;
    self.bannerView.delegate = self;

    self.adShowed = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.viewDidAppearEver) {
        [self tryLoadAD];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self tryOnceAD:nil];
    [self showBanner];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.originalView = self.view;
    UIView *containerView = [[UIView alloc] initWithFrame:self.view.frame];
    [containerView addSubview:self.view];
    
    [self.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView);
        make.top.equalTo(containerView);
        make.right.equalTo(containerView);
        make.bottom.equalTo(containerView);
    }];
    
    self.view = containerView;
}

#pragma mark - 广告
- (void)tryAllAD:(AdRewardHandler)rewardHandler {
    if (!AppShareDelegate().subscribed) {
        [self tryLoadAD];
        [self tryShowAD:rewardHandler];
        [self showBanner];
    } else {
        if (rewardHandler) {
            rewardHandler(YES);
        }
    }
}

- (void)tryLoadAD {
    if (!self.interstitial) {
        [self loadInterstitialAD];
    }
    if (!self.rewardedAd) {
        [self loadRewardAD];
    }
    if (!self.rewardedInterstitialAd) {
        [self loadRewardInsertAD];
    }
}

- (BOOL)tryShowAD:(AdRewardHandler)rewardHandler {
    BOOL canPresent = [self showRewardInsertAD:rewardHandler];
    if (!canPresent) {
        canPresent = [self showRewardAD:rewardHandler];
    }
    if (!canPresent) {
        canPresent = [self showInterstitialAD:rewardHandler];
    }
    if (!canPresent) {
        if (rewardHandler) {
            rewardHandler(NO);
        }
    }
    return canPresent;
}

- (void)tryOnceAD:(AdRewardHandler)rewardHandler {
    if (!self.adShowed) {
        [self tryShowAD:rewardHandler];
    }
}

- (void)showBanner {
    [self.bannerView removeFromSuperview];
    if (!AppShareDelegate().subscribed) {
        [self.view addSubview:self.bannerView];
        [self.originalView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.top.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.bannerView.mas_top);
        }];
        [self.bannerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
        [self.view layoutIfNeeded];
        [self.bannerView loadRequest:[GADRequest request]];
    } else {
        [self.originalView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.top.equalTo(self.view);
            make.right.equalTo(self.view);
            make.bottom.equalTo(self.view);
        }];
    }
}

#pragma mark - 插页广告
- (void)loadInterstitialAD {
    if (!AppShareDelegate().subscribed) {
        GADRequest *request = [GADRequest request];
        [GADInterstitialAd loadWithAdUnitID:AD_INTERSTITIAL
                                    request:request
                          completionHandler:^(GADInterstitialAd *ad, NSError *error) {
                              if (error) {
                                  NSLog(@"Load interstitial ad fail with error: %@", [error localizedDescription]);
                              } else {
                                  NSLog(@"Load interstitial ad sucess %@", ad);
                                  self.interstitial = ad;
                                  self.interstitial.fullScreenContentDelegate = self;
                              }
                          }];
    }
}

- (BOOL)showInterstitialAD:(AdRewardHandler)rewardHandler {
    BOOL canPresent = NO;
    if (!AppShareDelegate().subscribed) {
        NSError *error;
        canPresent = [self.interstitial canPresentFromRootViewController:self error:&error];
        if (canPresent) {
            [self.interstitial presentFromRootViewController:self];
            self.interstitial = nil;
            self.adShowed = YES;
            if (rewardHandler) {
                rewardHandler(YES);
            }
        } else {
            NSLog(@"Insert ad wasn't ready %@", error);
        }
    }
    return canPresent;
}

#pragma mark - 激励广告
- (void)loadRewardAD {
    if (!AppShareDelegate().subscribed) {
        GADRequest *request = [GADRequest request];
        [GADRewardedAd loadWithAdUnitID:AD_REWARD
                                request:request
                      completionHandler:^(GADRewardedAd *_Nullable rewardedAd, NSError *_Nullable error) {
                          if (error) {
                              NSLog(@"Load reward ad fail, %@", [error localizedDescription]);
                          } else {
                              NSLog(@"Load reward ad success %@, %@", rewardedAd.adUnitID, rewardedAd.responseInfo);
                              self.rewardedAd = rewardedAd;
                              self.rewardedAd.fullScreenContentDelegate = self;
                          }
                      }];
    }
}

- (BOOL)showRewardAD:(AdRewardHandler)rewardHandler {
    BOOL canPresent = NO;
    if (!AppShareDelegate().subscribed) {
        NSError *error;
        canPresent = [self.rewardedAd canPresentFromRootViewController:self error:&error];
        if (canPresent) {
            [self.rewardedAd presentFromRootViewController:self
                                  userDidEarnRewardHandler:^{
                                      NSLog(@"User earn reward %@", self.rewardedAd.adReward);
                                      self.rewardedAd = nil;
                                      if (rewardHandler) {
                                          rewardHandler(YES);
                                      }
                                  }];
            self.adShowed = YES;
        } else {
            NSLog(@"Reward ad wasn't ready %@", error);
        }
    }
    return canPresent;
}

#pragma mark - 插页激励广告
- (void)loadRewardInsertAD {
    if (!AppShareDelegate().subscribed) {
        GADRequest *request = [GADRequest request];
        [GADRewardedInterstitialAd loadWithAdUnitID:AD_REWARD_INTERST
                                            request:request
                                  completionHandler:^(GADRewardedInterstitialAd *_Nullable rewardedInterstitialAd, NSError *_Nullable error) {
                                      if (error) {
                                          NSLog(@"Load reward insert ad fail, %@", [error localizedDescription]);
                                      } else {
                                          NSLog(@"Load reward insert ad success %@, %@", rewardedInterstitialAd.adUnitID, rewardedInterstitialAd.responseInfo);
                                          self.rewardedInterstitialAd = rewardedInterstitialAd;
                                          self.rewardedInterstitialAd.fullScreenContentDelegate = self;
                                      }
                                  }];
    }
}

- (BOOL)showRewardInsertAD:(AdRewardHandler)rewardHandler {
    BOOL canPresent = NO;
    if (!AppShareDelegate().subscribed) {
        NSError *error;
        canPresent = [self.rewardedInterstitialAd canPresentFromRootViewController:self error:&error];
        if (canPresent) {
            [self.rewardedInterstitialAd presentFromRootViewController:self
                                              userDidEarnRewardHandler:^{
                                                  NSLog(@"User earn reward %@", self.rewardedInterstitialAd.adReward);
                                                  self.rewardedInterstitialAd = nil;
                                                  if (rewardHandler) {
                                                      rewardHandler(YES);
                                                  }
                                              }];
            self.adShowed = YES;
        } else {
            NSLog(@"Reward-Insert ad wasn't ready %@", error);
        }
    }
    return canPresent;
}

#pragma mark - 广告回调
/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"Ad did fail to present full screen content.");
}

/// Tells the delegate that the ad presented full screen content.
- (void)adDidPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"Ad did present full screen content.");
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"Ad did dismiss full screen content.");
    [self tryLoadAD];
}

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"");
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
    NSLog(@"");
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
    NSLog(@"");
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
    NSLog(@"");
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
    NSLog(@"");
}
@end
