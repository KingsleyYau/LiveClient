//
//  HangoutDialogViewController.h
//  livestream
//
//  Created by test on 2019/1/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSViewController.h"
#import "LSHangoutListItemObject.h"

@interface HangoutDialogViewController : LSViewController
/** 主播id */
@property (nonatomic, copy) NSString *anchorId;
@property (weak, nonatomic) IBOutlet UIButton *hangOutNowBtn;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *anchorImageView;
@property (weak, nonatomic) IBOutlet UILabel *anchorInviteTips;
@property (weak, nonatomic) IBOutlet UICollectionView *friendView;
@property (weak, nonatomic) IBOutlet UILabel *anchorNameFriend;
/** 主播名字 */
@property (nonatomic, copy) NSString *anchorName;
/** 好友数据 */
@property (nonatomic, strong) LSHangoutListItemObject *item;
- (void)showhangoutView;
@end
