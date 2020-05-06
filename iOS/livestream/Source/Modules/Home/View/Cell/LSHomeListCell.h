//
//  LSHomeListCell.h
//  livestream
//
//  Created by Calvin on 2019/6/14.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"

typedef enum {
   BottomBtnType_Chat = 0,
    BottomBtnType_Mail,
    BottomBtnType_Book
}BottomBtnType;


@protocol LSHomeListCellDelegate <NSObject>

- (void)homeListCellWatchNowBtnDid:(NSInteger)row;
- (void)homeListCellInviteBtnDid:(NSInteger)row;
- (void)homeListCellSendMailBtnDid:(NSInteger)row;
- (void)homeListCellChatNowBtnDid:(NSInteger)row;
- (void)homeListCellSayHiBtnDid:(NSInteger)row;
- (void)homeListCellBookingBtnDid:(NSInteger)row;
- (void)homeListCellFocusBtnDid:(NSInteger)row;
@end

@interface LSHomeListCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatTrailing;

@property (nonatomic, weak) id<LSHomeListCellDelegate> cellDelegate;

@property (nonatomic, weak) IBOutlet LSUIImageViewTopFit *imageViewHeader;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
/** 免费公开直播间 */
@property (weak, nonatomic) IBOutlet LSHighlightedButton *watchNowBtn;
/** 高级私密直播间 */
@property (weak, nonatomic) IBOutlet LSHighlightedButton *vipPrivateBtn;
@property (weak, nonatomic) IBOutlet LSHighlightedButton *chatNowBtn;
@property (weak, nonatomic) IBOutlet LSHighlightedButton *sendMailBtn;
@property (weak, nonatomic) IBOutlet UIImageView *camIcon;
@property (weak, nonatomic) IBOutlet UILabel *onlineStatus;
@property (weak, nonatomic) IBOutlet UIView *liveStatusView;
@property (weak, nonatomic) IBOutlet UILabel *labelRoomTitle;
@property (weak, nonatomic) IBOutlet UIImageView *liveStatus;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *anchorNameCenterX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *anchorNameCenterW;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *watchNowBtnBottom;
@property (weak, nonatomic) IBOutlet UIButton *focusBtn;
@property (weak, nonatomic) IBOutlet UIButton *sayhiBtn;
@property (weak, nonatomic) IBOutlet UIButton *chatBtn;//可为邮件或者预约
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chatBtnX;

@property (weak, nonatomic) IBOutlet UIImageView *watchNowFreeIcon;
@property (weak, nonatomic) IBOutlet UIImageView *inviteFreeIncon;
@property (weak, nonatomic) IBOutlet UILabel *sayHiFreeIcon;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (nonatomic, assign) BottomBtnType btnType;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteBtnBottom;
@property (weak, nonatomic) IBOutlet UIImageView *adImageView;
+ (NSString *)cellIdentifier;
@end
