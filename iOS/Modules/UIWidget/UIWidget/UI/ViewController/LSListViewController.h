//
//  ListViewController.h
//  UIWidget
//
//  Created by test on 2017/9/25.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "LSViewController.h"
@class LSListViewController;
@protocol LSListViewControllerDelegate <NSObject>
@optional

- (void)lsListViewController:(LSListViewController *)listView didClick:(UIButton *)sender;

@end

@interface LSListViewController : LSViewController

/** 错误页 */
@property (nonatomic, strong) UIView* failView;
/** 没数据页 */
@property (nonatomic, strong) UIView* noDataView;
/** 没数据页 */
@property (nonatomic, strong) UILabel *noDataTip;;
/** 没数据图标 */
@property (nonatomic, strong) UIImageView *noDataIcon;
/** 错误提示 */
@property (nonatomic, strong) UILabel *failTips;

/** 重试按钮 */
@property (nonatomic, strong) UIButton *failBtn;

/** 错误提示文字 */
@property (nonatomic, copy) NSString *failTipsText;
/** 错误按钮文字 */
@property (nonatomic, copy) NSString *failBtnText;
/** 代理 */
@property (nonatomic, weak) id<LSListViewControllerDelegate> listDelegate;
/** 错误图标 */
@property (nonatomic, strong) UIImageView *failIcon;
/** 修改失败页提示(已设置默认值)  */
- (void)reloadFailViewFailTipsText:(NSString *)failTipsText failBtnText:(NSString *)failBtnText;

- (void)lsListViewControllerDidClick:(UIButton *)sender;

// 首页刷新列表
- (void)viewDidAppearGetList:(BOOL)isSwitchSite;

// 首页设置刷新标志位
- (void)setupLoadData:(BOOL)isLoadData;

// 首页设置第一次登录标志位
- (void)setupFirstLogin:(BOOL)isFirstLogin;

// 更新未读数量
- (void)reloadUnreadNum;

- (void)showNoDataView;

- (void)hideNoDataView;
@end
