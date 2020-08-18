//
//  LSAnchorDetailCardViewController.h
//  livestream
//
//  Created by test on 2019/6/6.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSViewController.h"
#import "LSImageViewLoader.h"
#import "LiveRoom.h"

NS_ASSUME_NONNULL_BEGIN
@class LSAnchorDetailCardViewController;
@protocol LSAnchorDetailCardViewControllerDelegate <NSObject>
@optional;
- (void)lsAnchorDetailCardViewController:(LSAnchorDetailCardViewController *)vc didAddFavorite:(BOOL)favorite;

@end

@interface LSAnchorDetailCardViewController : LSViewController
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIButton *anchorIcon;
@property (weak, nonatomic) IBOutlet UIButton *anchorName;
@property (weak, nonatomic) IBOutlet UILabel *anchorProfile;
@property (weak, nonatomic) IBOutlet UILabel *anchorDetail;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *anchorHeadImage;

@property (weak, nonatomic) IBOutlet UIView *actionView;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, strong) LSImageViewLoader *loader;
@property (weak, nonatomic) IBOutlet UIButton *favouriteBtn;
@property (nonatomic, strong) LiveRoom *item;
/** 代理 */
@property (nonatomic, weak) id<LSAnchorDetailCardViewControllerDelegate> anchorDetailDelegate;

- (void)loadAchorDetail:(UIViewController *)vc;
- (void)dismissView;
@end

NS_ASSUME_NONNULL_END
