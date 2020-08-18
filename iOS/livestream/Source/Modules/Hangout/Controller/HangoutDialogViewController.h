//
//  HangoutDialogViewController.h
//  livestream
//
//  Created by test on 2019/1/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSViewController.h"
#import "LSHangoutListItemObject.h"
@class HangoutDialogViewController;
@protocol HangoutDialogViewControllerDelegate <NSObject>
@optional
- (void)hangoutDialogViewController:(HangoutDialogViewController *)vc didClickHangoutBtn:(UIButton *)sender;
@end

@interface HangoutDialogViewController : LSViewController
/** 主播id */
@property (nonatomic, copy) NSString *anchorId;
@property (weak, nonatomic) IBOutlet UIButton *hangOutNowBtn;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *anchorImageView;
@property (weak, nonatomic) IBOutlet UILabel *anchorInviteTips;
@property (weak, nonatomic) IBOutlet LSCollectionView *friendView;
@property (weak, nonatomic) IBOutlet UILabel *anchorNameFriend;
/** 主播名字 */
@property (nonatomic, copy) NSString *anchorName;
/** 好友数据 */
@property (nonatomic, strong) LSHangoutListItemObject *item;
/** 是否使用链接跳转 */
@property (nonatomic, assign) BOOL useUrlHandler;
/** 代理 */
@property (nonatomic, weak) id<HangoutDialogViewControllerDelegate> dialogDelegate;
@property (weak, nonatomic) IBOutlet UIView *anchorContentView;

- (void)showhangoutView;
@end
