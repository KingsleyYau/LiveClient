//
//  LSHomeCollectionView.h
//  livestream
//
//  Created by Calvin on 2019/6/14.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRoomInfoItemObject.h"
#import "HotHeadView.h"
#import "LSHomeListCell.h"
#import "LSLoginManager.h"
#import "HomeVouchersManager.h"
@protocol LSHomeCollectionViewDelegate <NSObject>

- (void)waterfallView:(UICollectionView *)waterfallView didSelectItem:(LiveRoomInfoItemObject *)item;

- (void)waterfallView:(UICollectionView *)waterfallView homeListCellWatchNowBtnDid:(LiveRoomInfoItemObject *)item;
- (void)waterfallView:(UICollectionView *)waterfallView homeListCellInviteBtnDid:(LiveRoomInfoItemObject *)item;
- (void)waterfallView:(UICollectionView *)waterfallView homeListCellSendMailBtnDid:(LiveRoomInfoItemObject *)item;
- (void)waterfallView:(UICollectionView *)waterfallView homeListCellChatNowBtnDid:(LiveRoomInfoItemObject *)item;
- (void)waterfallView:(UICollectionView *)waterfallView homeListCellSayHiBtnDid:(LiveRoomInfoItemObject *)item;
- (void)waterfallView:(UICollectionView *)waterfallView homeListCellBookingBtnDid:(LiveRoomInfoItemObject *)item;
- (void)waterfallView:(UICollectionView *)waterfallView homeListCellFocusBtnDid:(LiveRoomInfoItemObject *)item;

- (void)waterfallView:(UICollectionView *)waterfallView homeListHotHeadBtnDid:(NSInteger )row;

@optional
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
@end

@interface LSHomeCollectionView : UICollectionView<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,LSHomeListCellDelegate,HotHeadViewDelegate>

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, strong) HotHeadView * headView;
@property (strong, nonatomic) NSArray *iconArray;
@property (strong, nonatomic) NSArray *titleArray;
@property (nonatomic, assign) BOOL isShowHead;
@property (nonatomic, weak) id <LSHomeCollectionViewDelegate> collectionViewDelegate;
@property (nonatomic, strong) NSMutableDictionary * cellIdentifierDic;
@end

