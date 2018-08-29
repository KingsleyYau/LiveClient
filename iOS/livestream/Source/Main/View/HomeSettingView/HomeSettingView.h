//
//  SettingView.h
//  dating
//
//  Created by Calvin on 17/7/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HomeSettingView;
@protocol HomeSettingViewDelegate <NSObject>
@optional;
// 侧滑栏即将隐藏
- (void)settingViewWillHide;
// 打开换站控件
- (void)settingViewChangeSiteClick;
// 打开QN个人资料页
- (void)settingViewOpenProfileClick;
// 打开等级说明页
- (void)settingViewOpenLevelExplain;

- (void)homeSettingViewPushVCIndex:(NSIndexPath *)indexPath;
@end

@interface HomeSettingView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) id<HomeSettingViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (nonatomic, strong) PersonalProfile * item;
@property (nonatomic, assign) BOOL isShowSettingView;
 

//显示侧滑栏
- (void)showSettingView;
//隐藏侧滑栏
- (void)hideSettingView;

@end
