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
@end

@implementation BaseAdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
    self.bannerView.adUnitID = AD_BANNER;
    self.bannerView.rootViewController = self;
    self.bannerView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self tryLoadAD];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - 广告
- (void)tryAllAD {
    [self tryLoadAD];
    [self tryShowAD];
    [self showBanner];
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

- (BOOL)tryShowAD {
    BOOL canPresent = [self showRewardInsertAD];
    if (!canPresent) {
        canPresent = [self showRewardAD];
    }
    if (!canPresent) {
        canPresent = [self showInterstitialAD];
    }
    return canPresent;
}

- (void)showBanner {
    [self.bannerView removeFromSuperview];
    if (!AppShareDelegate().subscribed) {
        [self.bannerView loadRequest:[GADRequest request]];
        [self.view addSubview:self.bannerView];
        [self.bannerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
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

- (BOOL)showInterstitialAD {
    BOOL canPresent = NO;
    if (!AppShareDelegate().subscribed) {
        NSError *error;
        canPresent = [self.interstitial canPresentFromRootViewController:self error:&error];
        if (canPresent) {
            [self.interstitial presentFromRootViewController:self];
            self.interstitial = nil;
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

- (BOOL)showRewardAD {
    BOOL canPresent = NO;
    if (!AppShareDelegate().subscribed) {
        NSError *error;
        canPresent = [self.rewardedAd canPresentFromRootViewController:self error:&error];
        if (canPresent) {
            [self.rewardedAd presentFromRootViewController:self
                                  userDidEarnRewardHandler:^{
                                      NSLog(@"User earn reward %@", self.rewardedAd.adReward);
                                      self.rewardedAd = nil;
                                  }];
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

- (BOOL)showRewardInsertAD {
    BOOL canPresent = NO;
    if (!AppShareDelegate().subscribed) {
        NSError *error;
        canPresent = [self.rewardedInterstitialAd canPresentFromRootViewController:self error:&error];
        if (canPresent) {
            [self.rewardedInterstitialAd presentFromRootViewController:self
                                              userDidEarnRewardHandler:^{
                                                  NSLog(@"User earn reward %@", self.rewardedInterstitialAd.adReward);
                                                  self.rewardedInterstitialAd = nil;
                                              }];
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
