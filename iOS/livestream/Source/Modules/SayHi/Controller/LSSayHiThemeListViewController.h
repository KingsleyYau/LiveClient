//
//  LSSayHiThemeListViewController.h
//  livestream
//
//  Created by Randy_Fan on 2019/4/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSGoogleAnalyticsPageViewController.h"
#import "LSSayHiManager.h"

@class LSSayHiThemeListViewController;
@protocol LSSayHiThemeListViewControllerDelegate <NSObject>
- (void)didShowSelectThemeWord:(LSSayHiThemeListViewController *)vc index:(NSInteger)index;
- (void)didSelectThemeWithItem:(LSSayHiThemeItemObject *)theme;
- (void)didSelectWordWithItem:(LSSayHiTextItemObject *)word;
- (void)didSubmitSayHi;
@end

@interface LSSayHiThemeListViewController : LSGoogleAnalyticsPageViewController

@property (weak, nonatomic) IBOutlet UIButton *selectThemeBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectWordBtn;

@property (weak, nonatomic) id<LSSayHiThemeListViewControllerDelegate> delegate;

- (void)showButtonViewOrSegmentView:(BOOL)isShow;
- (void)changeSegementSelect:(NSInteger)index;

@end

