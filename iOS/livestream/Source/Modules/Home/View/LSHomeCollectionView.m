//
//  LSHomeCollectionView.m
//  livestream
//
//  Created by Calvin on 2019/6/14.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSHomeCollectionView.h"

@implementation LSHomeCollectionView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    self.delegate = self;
    self.dataSource = self;
    
    self.alwaysBounceVertical = YES;
    
    self.cellIdentifierDic = [NSMutableDictionary dictionary];
    
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HotHeadView"];
    
}

- (void)setIsShowHead:(BOOL)isShowHead {
    _isShowHead = isShowHead;
    if (_isShowHead) {
        [self reloadData];
    } else {
        [self reloadData];
    }
}

#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = [self.cellIdentifierDic objectForKey:[NSString stringWithFormat:@"CellRow%ld", indexPath.row]];
    if(identifier == nil){
           identifier = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"CellRow%ld", indexPath.row]];
           [self.cellIdentifierDic setObject:identifier forKey:[NSString stringWithFormat:@"CellRow%ld", indexPath.row]];
        //注册cell
           [self registerNib:[UINib nibWithNibName:@"LSHomeListCell" bundle:[LiveBundle mainBundle]] forCellWithReuseIdentifier:identifier];
    }
    LSHomeListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    if(!cell){
           cell = [[[LiveBundle mainBundle]loadNibNamed:@"LSHomeListCell" owner:self options:nil]lastObject];
       }
    cell.cellDelegate = self;
    // 数据填充
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:indexPath.row];
    
    cell.tag = indexPath.row;
    if (item.adItem) {
        cell.watchNowFreeIcon.hidden = YES;
        cell.inviteFreeIncon.hidden = YES;
        cell.onlineStatus.hidden = YES;
        cell.chatNowBtn.hidden = YES;
        cell.watchNowBtn.hidden = YES;
        cell.vipPrivateBtn.hidden = YES;
        cell.liveStatusView.hidden = YES;
        cell.camIcon.hidden = YES;
        cell.sendMailBtn.hidden = YES;
        cell.chatBtn.hidden = YES;
        cell.focusBtn.hidden = YES;
        cell.sayhiBtn.hidden = YES;
        // 广告图片
        cell.adImageView.hidden = NO;
        // 创建新的
        cell.imageViewLoader = [LSImageViewLoader loader];
        // 加载
        [cell.imageViewLoader loadHDListImageWithImageView:cell.adImageView options:SDWebImageRefreshCached imageUrl:item.adItem.image placeholderImage:[UIImage imageNamed:@"Home_HotAndFollow_ImageView_Placeholder"] finishHandler:nil];
    }else {
        cell.chatBtn.hidden = NO;
        cell.focusBtn.hidden = NO;
        cell.sayhiBtn.hidden = NO;
        // 广告图片
        cell.adImageView.hidden = YES;
        // 房间名
        cell.labelRoomTitle.text = item.nickName;
        
        [cell.imageViewLoader stop];
        [cell.imageViewLoader loadHDListImageWithImageView:cell.imageViewHeader
                                                   options:0
                                                  imageUrl:item.roomPhotoUrl
                                          placeholderImage:[UIImage imageNamed:@"Home_HotAndFollow_ImageView_Placeholder"]
                                             finishHandler:nil];
        
        //是否有SayHi权限
        if ([LSLoginManager manager].loginItem.userPriv.isSayHiPriv) {
            cell.sayhiBtn.hidden = NO;
            cell.chatBtnX.constant = 0;
            cell.sayHiFreeIcon.hidden = NO;
        }else {
            cell.sayhiBtn.hidden = YES;
            cell.chatBtnX.constant = -25;
            cell.sayHiFreeIcon.hidden = YES;
        }
        //是否关注主播
        UIImage * followImage = item.isFollow?[UIImage imageNamed:@"LS_Home_Follow"]:[UIImage imageNamed:@"LS_Home_Unfollow"];
        [cell.focusBtn setImage:followImage forState:UIControlStateNormal];
        
        if (item.onlineStatus == ONLINE_STATUS_LIVE) {
            cell.sendMailBtn.hidden = YES;
            cell.chatNowBtn.hidden = YES;
            cell.watchNowBtn.hidden = YES;
            cell.liveStatusView.hidden = YES;
            cell.vipPrivateBtn.hidden = YES;
            cell.watchNowFreeIcon.hidden = YES;
            cell.inviteFreeIncon.hidden = YES;
            cell.camIcon.hidden = YES;
            cell.onlineStatus.hidden = NO;
            cell.anchorNameCenterX.constant = -30;
            cell.anchorNameCenterW.constant = cell.tx_width - cell.onlineStatus.tx_width - 20;
            cell.watchNowBtnBottom.constant = 6;
            cell.inviteBtnBottom.constant = 5;
            
            if (item.roomType == HTTPROOMTYPE_FREEPUBLICLIVEROOM || item.roomType == HTTPROOMTYPE_CHARGEPUBLICLIVEROOM) {
                // 公开直播间
                cell.btnType = BottomBtnType_Chat;
                cell.watchNowBtn.hidden = NO;
                cell.liveStatusView.hidden = NO;
                NSMutableArray *animationPublicRTArray = [NSMutableArray array];
                for (int i = 1; i <= 3; i++) {
                    NSString *imageName = [NSString stringWithFormat:@"Home_HotAndFollow_ImageView_Live%d", i];
                    UIImage *image = [UIImage imageNamed:imageName];
                    [animationPublicRTArray addObject:image];
                }
                cell.liveStatus.animationImages = animationPublicRTArray;
                cell.liveStatus.animationRepeatCount = 0;
                cell.liveStatus.animationDuration = 0.6;
                [cell.liveStatus startAnimating];
                
                if ([[HomeVouchersManager manager]isShowWatchNowFree:item.userId]) {
                    cell.watchNowFreeIcon.hidden = NO;
                }
                else {
                    cell.watchNowFreeIcon.hidden = YES;
                }
                
                if (item.priv.isHasOneOnOneAuth) {
                    cell.vipPrivateBtn.hidden = NO;
                    if ([[HomeVouchersManager manager] isShowInviteFree:item.userId]) {
                        //显示Free
                        cell.inviteFreeIncon.hidden = NO;
                        
                    } else {
                        //不显示Free
                        cell.inviteFreeIncon.hidden = YES;
                    }
                }
                else {
                    cell.vipPrivateBtn.hidden = YES;
                    cell.watchNowBtnBottom.constant = -34;
                }
                
            }else  {
                // 普通私密和付费私密,没有直播间
                // 是否有私密邀请的权限权限
                cell.watchNowBtn.hidden = YES;
                cell.btnType = BottomBtnType_Mail;
                if (item.priv.isHasOneOnOneAuth) {
                    cell.sendMailBtn.hidden = YES;
                    cell.chatNowBtn.hidden = NO;
                    cell.vipPrivateBtn.hidden = NO;
                    cell.camIcon.hidden = NO;
                    cell.inviteBtnBottom.constant = 45;
                    if ([[HomeVouchersManager manager] isShowInviteFree:item.userId]) {
                        //显示Free
                        cell.inviteFreeIncon.hidden = NO;
                        
                    } else {
                        //不显示Free
                        cell.inviteFreeIncon.hidden = YES;
                    }
                    
                } else {
                    // 没有私密邀请权限判断是否livechat在线显示对应按钮
                    if (item.chatOnlineStatus == IMCHATONLINESTATUS_ONLINE) {
                        cell.chatNowBtn.hidden = NO;
                        cell.sendMailBtn.hidden = YES;
                        cell.vipPrivateBtn.hidden = YES;
                    } else {
                        cell.sendMailBtn.hidden = NO;
                        cell.chatNowBtn.hidden = YES;
                        cell.vipPrivateBtn.hidden = YES;
                    }
                }
            }
            
        }else {
            // 不在线,只能显示发送邮件的按钮
            cell.watchNowFreeIcon.hidden = YES;
            cell.inviteFreeIncon.hidden = YES;
            cell.onlineStatus.hidden = YES;
            cell.chatNowBtn.hidden = YES;
            cell.watchNowBtn.hidden = YES;
            cell.vipPrivateBtn.hidden = YES;
            cell.liveStatusView.hidden = YES;
            cell.camIcon.hidden = YES;
            cell.sendMailBtn.hidden = NO;
            cell.anchorNameCenterX.constant = 0;
            cell.anchorNameCenterW.constant = cell.tx_width - 20;
            //变成预约按钮
            cell.btnType = BottomBtnType_Book;
        }
        
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.collectionViewDelegate respondsToSelector:@selector(waterfallView:didSelectItem:)]) {
        
        [self.collectionViewDelegate waterfallView:self didSelectItem:[self.items objectAtIndex:indexPath.row]];
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    if (self.isShowHead) {
        return CGSizeMake(screenSize.width, 88);
    }
    return CGSizeMake(screenSize.width, 0);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *view = [[UICollectionReusableView alloc] init];
    if (kind == UICollectionElementKindSectionHeader) {
        view = [self dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HotHeadView" forIndexPath:indexPath];
        if (!self.headView) {
            self.headView = [[HotHeadView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, 88)];
            self.headView.delagate = self;
            [view addSubview:self.headView];
        }
        
        self.headView.titleArray = self.titleArray;
        self.headView.iconArray = self.iconArray;
        
    }
    return view;
}

- (void)didSelectHeadViewItemWithIndex:(NSInteger)row {
    if ([self.collectionViewDelegate respondsToSelector:@selector(waterfallView:homeListHotHeadBtnDid:)]) {
        [self.collectionViewDelegate waterfallView:self homeListHotHeadBtnDid:row];
    }
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat proportion =screenSize.width==320?1.85:1.8;
    CGFloat w = (screenSize.width - 30) / 2.0;
    CGFloat h = w * proportion;
    return CGSizeMake(w, h);
}

#pragma mark - 滚动界面回调 (UIScrollViewDelegate)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.collectionViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.collectionViewDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.collectionViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.collectionViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)homeListCellWatchNowBtnDid:(NSInteger)row {
    if ([self.collectionViewDelegate respondsToSelector:@selector(waterfallView:homeListCellWatchNowBtnDid:)]) {
        [self.collectionViewDelegate waterfallView:self homeListCellWatchNowBtnDid:[self.items objectAtIndex:row]];
    }
}

- (void)homeListCellInviteBtnDid:(NSInteger)row {
    if ([self.collectionViewDelegate respondsToSelector:@selector(waterfallView:homeListCellInviteBtnDid:)]) {
        [self.collectionViewDelegate waterfallView:self homeListCellInviteBtnDid:[self.items objectAtIndex:row]];
    }
}

- (void)homeListCellSendMailBtnDid:(NSInteger)row {
    if ([self.collectionViewDelegate respondsToSelector:@selector(waterfallView:homeListCellSendMailBtnDid:)]) {
        [self.collectionViewDelegate waterfallView:self homeListCellSendMailBtnDid:[self.items objectAtIndex:row]];
    }
}

- (void)homeListCellChatNowBtnDid:(NSInteger)row {
    if ([self.collectionViewDelegate respondsToSelector:@selector(waterfallView:homeListCellChatNowBtnDid:)]) {
        [self.collectionViewDelegate waterfallView:self homeListCellChatNowBtnDid:[self.items objectAtIndex:row]];
    }
}

- (void)homeListCellSayHiBtnDid:(NSInteger)row {
    if ([self.collectionViewDelegate respondsToSelector:@selector(waterfallView:homeListCellSayHiBtnDid:)]) {
        [self.collectionViewDelegate waterfallView:self homeListCellSayHiBtnDid:[self.items objectAtIndex:row]];
    }
}

- (void)homeListCellBookingBtnDid:(NSInteger)row {
    if ([self.collectionViewDelegate respondsToSelector:@selector(waterfallView:homeListCellBookingBtnDid:)]) {
        [self.collectionViewDelegate waterfallView:self homeListCellBookingBtnDid:[self.items objectAtIndex:row]];
    }
}

- (void)homeListCellFocusBtnDid:(NSInteger)row {
    if ([self.collectionViewDelegate respondsToSelector:@selector(waterfallView:homeListCellFocusBtnDid:)]) {
        [self.collectionViewDelegate waterfallView:self homeListCellFocusBtnDid:[self.items objectAtIndex:row]];
    }
}
@end
