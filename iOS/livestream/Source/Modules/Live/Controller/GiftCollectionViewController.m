//
//  GiftCollectionViewController.m
//  livestream
//
//  Created by Max on 2018/5/29.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "GiftCollectionViewController.h"

#import "GiftItemCollectionViewCell.h"
#import "GiftItemLayout.h"

#import "LSGiftManager.h"

@interface GiftCollectionViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
// 九宫格控件
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
// 分页指示器
@property (nonatomic, weak) IBOutlet UIPageControl *pageControl;
// 失败提示界面
@property (nonatomic, weak) IBOutlet UIView *requestFailView;
// 失败提示
@property (nonatomic, weak) IBOutlet UILabel *requestFailLabel;
// 空数据提示
@property (nonatomic, weak) IBOutlet UILabel *tipsLabel;
// 礼物下载管理器
@property (nonatomic, strong) LSGiftManager *giftManager;
// 显示的礼物数组
@property (nonatomic, strong) NSArray<LSGiftManagerItem *> *giftArray;
@end

@implementation GiftCollectionViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];

    self.selectedIndexPath = -1;

    self.giftManager = [LSGiftManager manager];
}

- (void)dealloc {
    // 清空直播间礼物列表
    [self.giftManager removeRoomGiftList];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 初始化界面
    [self setupCollectionView];
    [self setupPageControl];
    [self setupFailView];
    // 刷新数据
    [self reloadAction:nil];
}

- (void)setupPageControl {
    // 分页
    self.pageControl.numberOfPages = 0;
    self.pageControl.currentPage = 0;
    [self.pageControl addTarget:self action:@selector(pageControlAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)setupCollectionView {
    NSBundle *bundle = [LiveBundle mainBundle];
    UINib *nib = [UINib nibWithNibName:@"GiftItemCollectionViewCell" bundle:bundle];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier]];
}

- (void)setupFailView {
    switch (self.type) {
        case GiftListTypeNormal: {
            // 普通礼物
            self.tipsLabel.text = NSLocalizedStringFromSelf(@"NORMAL_NO_LIST_TIP");
        } break;
        case GiftListTypeBackpack: {
            // 背包礼物
            self.tipsLabel.text = NSLocalizedStringFromSelf(@"BACKPACK_NO_LIST_TIP");
        } break;
        default:
            break;
    }
}

#pragma mark - 数据逻辑
- (void)reloadData {
    // TODO:获取礼物列表
    switch (self.type) {
        case GiftListTypeNormal: {
            // 普通礼物
            [self.giftManager getRoomGiftList:self.liveRoom.roomId
                                 finshHandler:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList) {
                                     [self reloadDataWithArray:success giftList:giftList];
                                     if ([self.vcDelegate respondsToSelector:@selector(didChangeGiftList:)]) {
                                         [self.vcDelegate didChangeGiftList:self];
                                     }
                                 }];
        } break;
        case GiftListTypeBackpack: {
            // 背包礼物
            [self.giftManager getRoomBackpackGiftList:self.liveRoom.roomId
                                         finshHandler:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList) {
                                             [self reloadDataWithArray:success giftList:giftList];
                                         }];
        } break;
        default:
            break;
    }
    
    [self.collectionView reloadData];
}

- (void)selectItem:(LSGiftManagerItem *)item {
    // 选中指定礼物
    self.selectedIndexPath = [self.giftArray indexOfObject:item];
    
    NSInteger index = [self.giftArray indexOfObject:item];
    self.pageControl.currentPage = index / 8;
    self.collectionView.contentOffset = CGPointMake(self.pageControl.currentPage * self.collectionView.frame.size.width, 0);
    
    [self.collectionView reloadData];
}

- (void)reloadDataWithArray:(BOOL)success giftList:(NSArray *)giftList {
    if (success) {
        self.giftArray = giftList;
        if( giftList.count == 0 ) {
            // 没有数据
            self.tipsLabel.hidden = NO;
        }
        [self.collectionView reloadData];
    } else {
        // 刷新失败
        self.tipsLabel.hidden = YES;
        self.requestFailView.hidden = NO;
    }
}

#pragma mark - 点击事件
- (IBAction)reloadAction:(id)sender {
    // 隐藏失败界面
    self.requestFailView.hidden = YES;
    // 隐藏提示
    self.tipsLabel.hidden = YES;
    // 刷新数据
    [self reloadData];
}

#pragma mark - 分页指示器委托(UICollectionViewDataSource)
- (void)pageControlAction:(UIPageControl *)sender {
    CGSize viewSize = self.collectionView.frame.size;
    CGRect rect = CGRectMake(sender.currentPage * viewSize.width, 0, viewSize.width, viewSize.height);
    [self.collectionView scrollRectToVisible:rect animated:YES];
}

#pragma mark - 礼物内容委托(UICollectionViewDataSource)
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.giftArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.pageControl.hidden) {
        self.pageControl.hidden = NO;
    }

    GiftItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    if (indexPath.row < self.giftArray.count) {
        LSGiftManagerItem *item = self.giftArray[indexPath.row];
        [cell updateItem:item manLevel:self.liveRoom.imLiveRoom.manLevel lovelLevel:self.liveRoom.imLiveRoom.loveLevel type:self.type];
        
        BOOL bSelectedItem = NO;
        if (self.selectedIndexPath == indexPath.row) {
            bSelectedItem = YES;
            
        } else if (self.selectedIndexPath == -1 && indexPath.row == 0) {
            bSelectedItem = YES;
            
            // 默认选中第一个
            self.selectedIndexPath = 0;
        }
        
        if( bSelectedItem ) {
            cell.selectCell = YES;
            self.selectGiftItem = item;
            
            if ([self.vcDelegate respondsToSelector:@selector(didChangeGiftItem:item:)]) {
                [self.vcDelegate didChangeGiftItem:self item:item];
            }
        }

        // 刷新选中状态
        [cell reloadSelectedItem];

        // 刷新页数 小高表布局
        GiftItemLayout *layout = (GiftItemLayout *)self.collectionView.collectionViewLayout;
        if (self.pageControl.numberOfPages != layout.pageCount) {
            self.pageControl.numberOfPages = layout.pageCount;
        }
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 设置选中礼物cell的可选按钮
    if (indexPath.row < self.giftArray.count) {
        LSGiftManagerItem *item = self.giftArray[indexPath.row];

        if (self.selectedIndexPath != indexPath.row) {
            self.selectedIndexPath = indexPath.row;

            if ([self.vcDelegate respondsToSelector:@selector(didChangeGiftItem:item:)]) {
                [self.vcDelegate didChangeGiftItem:self item:item];
            }
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 刷新选择分页
    GiftItemLayout *layout = (GiftItemLayout *)self.collectionView.collectionViewLayout;
    if (self.pageControl.currentPage != layout.currentPage) {
        self.pageControl.currentPage = layout.currentPage;
    }
}
@end
