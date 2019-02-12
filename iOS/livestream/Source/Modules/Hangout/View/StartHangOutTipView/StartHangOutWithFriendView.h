//
//  StartHangOutWithFriendView.h
//  livestream
//
//  Created by test on 2019/1/17.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
#import "LSShadowView.h"
#import "LSHangoutListItemObject.h"
@class StartHangOutWithFriendView;
@protocol StartHangOutWithFriendViewDelegate <NSObject>
@optional
- (void)startHangOutWithFriendViewStartToHangout:(StartHangOutWithFriendView *)view;
@end


@interface StartHangOutWithFriendView : UIView
@property (weak, nonatomic) IBOutlet UIButton *hangOutNowBtn;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *anchorImageView;
@property (weak, nonatomic) IBOutlet UILabel *anchorInviteTips;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *friendViewWidth;
@property (weak, nonatomic) IBOutlet UICollectionView *friendView;

/** 好友数据 */
@property (nonatomic, strong) LSHangoutListItemObject *item;
/** 代理 */
@property (nonatomic, weak) id<StartHangOutWithFriendViewDelegate> hangOutDelegate;
- (void)showMainHangoutTip:(UIView *)view;
- (void)reloadFriendView;
@end
