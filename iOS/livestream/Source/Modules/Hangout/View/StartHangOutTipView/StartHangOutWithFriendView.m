//
//  StartHangOutWithFriendView.m
//  livestream
//
//  Created by test on 2019/1/17.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "StartHangOutWithFriendView.h"
#import "LSShadowView.h"
#import "LSHangoutFriendCollectionViewCell.h"
#import "LiveUrlHandler.h"
#import "LiveModule.h"

@interface StartHangOutWithFriendView()<UICollectionViewDelegate,UICollectionViewDataSource>
/** 数组个数 */
@property (nonatomic, assign) NSInteger count;
@end


@implementation StartHangOutWithFriendView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.hangOutNowBtn.layer.cornerRadius = self.hangOutNowBtn.frame.size.height / 2;
    self.hangOutNowBtn.layer.masksToBounds = YES;
    self.bgView.layer.cornerRadius = 5;
    self.bgView.layer.masksToBounds = YES;

    self.friendView.dataSource = self;
    self.friendView.delegate = self;
    
    UINib *nib = [UINib nibWithNibName:@"LSHangoutFriendCollectionViewCell" bundle:[LiveBundle mainBundle] ];
    [self.friendView registerNib:nib forCellWithReuseIdentifier:[LSHangoutFriendCollectionViewCell cellIdentifier]];
    
    LSShadowView *shadowView = [[LSShadowView alloc] init];
    [shadowView showShadowAddView:self.bgView];
    
    LSShadowView *shadowView1 = [[LSShadowView alloc] init];
    [shadowView1 showShadowAddView:self.hangOutNowBtn];
}



- (void)showMainHangoutTip:(UIView *)view {

    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    if (self && view) {
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(view.mas_centerY);
            make.centerX.equalTo(view.mas_centerX);
            make.width.equalTo(@(276));
            make.height.equalTo(@(380));
        }];
        
    }
    
}
- (IBAction)hangOutNowClickAction:(id)sender {
    [self removeFromSuperview];
   
//    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToHangoutByRoomId:@"" anchorId:self.item.anchorId anchorName:self.item.nickName];
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToHangoutByRoomId:@"" anchorId:self.item.anchorId anchorName:self.item.nickName hangoutAnchorId:@"" hangoutAnchorName:@""];
    [[LiveModule module].serviceManager handleOpenURL:url];
//    if ([self.hangOutDelegate respondsToSelector:@selector(startHangOutWithFriendViewStartToHangout:)]) {
//        [self.hangOutDelegate startHangOutWithFriendViewStartToHangout:self];
//    }
    
}

- (IBAction)closeAction:(id)sender {
    [self removeFromSuperview];
}

- (void)reloadFriendView {
    self.anchorInviteTips.text = [NSString stringWithFormat:@"Hang-out with ｛%@｝, and inviting any of her friends to join with you.",self.item.nickName];
    LSImageViewLoader *loader =  [LSImageViewLoader loader];
    [loader refreshCachedImage:self.anchorImageView
                                     options:SDWebImageRefreshCached
                                    imageUrl:self.item.avatarImg
                            placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    NSInteger count = 0;
    if (self.item.friendsInfoList.count > 3) {
        count =  4;
    }else {
        count = self.item.friendsInfoList.count + 1;
    }
    self.count = count;
    // TODO:刷新推荐列表
    self.friendViewWidth.constant = [LSHangoutFriendCollectionViewCell cellWidth] * count + ((count - 1) * 20);
    
    if (self.friendViewWidth.constant > self.frame.size.width * 0.9) {
        self.friendViewWidth.constant = self.frame.size.width * 0.9;
    }
    [self.friendView reloadData];
}

#pragma mark - 推荐逻辑
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSHangoutFriendCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LSHangoutFriendCollectionViewCell cellIdentifier] forIndexPath:indexPath];

    if (indexPath.row > self.count - 2) {
        cell.imageView.image = [UIImage imageNamed:@"Live_More_HangOut"];
    }else {
        LSFriendsInfoItemObject *item = [self.item.friendsInfoList objectAtIndex:indexPath.row];
        cell.anchorName.text = item.anchorId;
        cell.imageView.image = nil;
        [cell.imageViewLoader stop];
        [cell.imageViewLoader loadImageWithImageView:cell.imageView
                                             options:0
                                            imageUrl:item.anchorImg
                                    placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row <= self.count - 2) {
        [self removeFromSuperview];
        LSFriendsInfoItemObject *item = [self.item.friendsInfoList objectAtIndex:indexPath.row];
        NSURL *url = [[LiveUrlHandler shareInstance] createUrlToAnchorDetail:item.anchorId];
        [[LiveUrlHandler shareInstance] handleOpenURL:url];
 
    }
}


@end
