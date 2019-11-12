//
//  LSGiftCollectionView.m
//  livestream
//
//  Created by Calvin on 2019/9/20.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSGiftCollectionView.h"
#import "LSGiftManager.h"
@interface LSGiftCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource>
// 九宫格控件
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

// 失败提示
@property (nonatomic, weak) IBOutlet UIButton *tipBtn;

// 礼物下载管理器
@property (nonatomic, strong) LSGiftManager *giftManager;
// 显示的礼物数组
@property (nonatomic, strong) NSArray<LSGiftManagerItem *> *giftArray;
// 是否改变选中礼物
@property (nonatomic, assign) BOOL isChanceSelect;

@property (weak, nonatomic) IBOutlet UIImageView *loading;
@end

@implementation LSGiftCollectionView

- (instancetype)init {
    self = [super init];
    if (self) {
         self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectedIndexPath = -1;
    self.isChanceSelect = YES;
    
    self.giftManager = [LSGiftManager manager];
    
    NSMutableArray * images = [NSMutableArray array];
    for (int i = 1; i <= 7; i++) {
        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"Prelive_Loading%d",i]];
        [images addObject:image];
    }
    self.loading.animationImages = images;
    self.loading.animationDuration = 0.6;
    [self.loading startAnimating];
    
    // 初始化界面
    [self setupCollectionView];
}

- (void)dealloc {
    // 清空直播间礼物列表
    [self.giftManager removeRoomGiftList];
}

- (void)setupCollectionView {
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    NSBundle *bundle = [LiveBundle mainBundle];
    UINib *nib = [UINib nibWithNibName:@"LSVIPLiveGiftListCell" bundle:bundle];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[LSVIPLiveGiftListCell cellIdentifier]];
}

#pragma mark - 数据逻辑
- (void)reloadData {
    WeakObject(self, weakSelf);
    self.loading.hidden = NO;
    if ([self.giftTypeId isEqualToString:@"Free"]) {
        if (self.giftArray.count <= 0) {
            // 背包礼物
            [self.giftManager getPraviteRoomBackpackGiftList:self.liveRoom.roomId
                                                finshHandler:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList) {
                                                    [weakSelf reloadDataWithArray:success isFree:YES giftList:giftList];
                                                }];
        } else {
            self.loading.hidden = YES;
            [self.collectionView reloadData];
        }
    }else if ([self.giftTypeId isEqualToString:@"All"]) {
        // 普通礼物
        [self.giftManager getRoomGiftList:self.liveRoom.roomId
                             finshHandler:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList) {
                                 [weakSelf reloadDataWithArray:success isFree:NO giftList:giftList];                             }];
    }else {
        [self.giftManager getGiftTypeContent:self.liveRoom.roomId typeID:self.giftTypeId finshHandler:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList) {
            [weakSelf reloadDataWithArray:success isFree:NO giftList:giftList];
        }];
    }
}

- (void)selectItem:(LSGiftManagerItem *)item {
    // 选中指定礼物
    NSInteger nextIndexPath = [self.giftArray indexOfObject:item];
    
    if (self.selectedIndexPath != nextIndexPath) {
        self.selectedIndexPath = nextIndexPath;
        self.isChanceSelect = YES;
    } else {
        self.isChanceSelect = NO;
    }
    
    //    NSInteger index = [self.giftArray indexOfObject:item];
    //    self.pageControl.currentPage = index / 8;
    //    self.collectionView.contentOffset = CGPointMake(self.pageControl.currentPage * self.collectionView.frame.size.width, 0);
    
    [self.collectionView reloadData];
}

- (void)reloadDataWithArray:(BOOL)success isFree:(BOOL)isFree giftList:(NSArray *)giftList {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loading.hidden = YES;
        if (success) {
            if (!isFree) {
                NSMutableArray * array = [NSMutableArray array];
                for (LSGiftManagerItem * item in giftList) {
                    if (item.roomInfoItem.isShow) {
                        [array addObject:item];
                    }
                }
                self.giftArray = array;
            }
            else {
                self.giftArray = giftList;
            }
            
            if( self.giftArray.count == 0 ) {
                // 没有数据
                [self setButtonImage:NO];
                
            } else {
                self.tipBtn.hidden = YES;
            }
            [self.collectionView reloadData];
        } else {
            // 刷新失败
            [self setButtonImage:YES];
        }
    });
}

- (void)setButtonImage:(BOOL)isRetry {
    
    self.tipBtn.hidden = NO;
    if (isRetry) {
        [self.tipBtn setImage:[UIImage imageNamed:@"Hangout_Invite_Fail"] forState:UIControlStateNormal];
        [self.tipBtn setTitle:NSLocalizedStringFromSelf(@"RETRY_TIP") forState:UIControlStateNormal];
        // self.tipBtn.userInteractionEnabled = YES;
        [self.tipBtn addTarget:self action:@selector(reloadAction) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [self.tipBtn setImage:[UIImage imageNamed:@"Live_No_Yet_Gifts"] forState:UIControlStateNormal];
        [self.tipBtn setTitle:NSLocalizedStringFromSelf(@"GIFT_TIP") forState:UIControlStateNormal];
        // self.tipBtn.userInteractionEnabled = NO;
    }
}

#pragma mark - 点击事件
- (void)reloadAction {
    // 隐藏提示
    self.tipBtn.hidden = YES;
    // 刷新数据
    [self reloadData];
}



#pragma mark - 礼物内容委托(UICollectionViewDataSource)
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.giftArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    LSVIPLiveGiftListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LSVIPLiveGiftListCell cellIdentifier] forIndexPath:indexPath];
    if (indexPath.row < self.giftArray.count) {
        LSGiftManagerItem *item = self.giftArray[indexPath.row];
        [cell updateItem:item type:self.giftTypeId];
        
        cell.giftCreditLabel.font = [UIFont systemFontOfSize:11];
        
        //        BOOL bSelectedItem = NO;
        //        if (self.selectedIndexPath == indexPath.row) {
        //            bSelectedItem = YES;
        //
        //        } else if (self.selectedIndexPath == -1 && indexPath.row == 0) {
        //            bSelectedItem = YES;
        //
        //            // 默认选中第一个
        //            self.selectedIndexPath = 0;
        //        }
        //
        //        if( bSelectedItem ) {
        //            cell.selectCell = YES;
        //            self.selectGiftItem = item;
        //
        //            if (self.isChanceSelect) {
        //                if ([self.vcDelegate respondsToSelector:@selector(didChangeGiftItem:item:)]) {
        //                    [self.vcDelegate didChangeGiftItem:self item:item];
        //                }
        //                self.isChanceSelect = NO;
        //            }
        //        }
        //
        //        // 刷新选中状态
        //        [cell reloadSelectedItem];
        
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 设置选中礼物cell的可选按钮
    if (indexPath.row < self.giftArray.count) {
        LSGiftManagerItem *item = self.giftArray[indexPath.row];
        
        //        if (self.selectedIndexPath != indexPath.row) {
        //            self.selectedIndexPath = indexPath.row;
        //
        //            self.isChanceSelect = YES;
        //
        //
        //        } else {
        //            self.isChanceSelect = NO;
        //        }
        if ([self.delegate respondsToSelector:@selector(didSendGiftItem:item:)]) {
            [self.delegate didSendGiftItem:self item:item];
        }
        
        
        [self.collectionView reloadData];
        [UIView setAnimationsEnabled:NO];
        [collectionView performBatchUpdates:^{
        }
                                 completion:^(BOOL finished) {
                                     [UIView setAnimationsEnabled:YES];
                                 }];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat w = (SCREEN_WIDTH - 26*2 - 22* 3)/ 4;
    return CGSizeMake(w, w+16);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(26, 26, 26, 26);//分别为上、左、下、右
}

@end
