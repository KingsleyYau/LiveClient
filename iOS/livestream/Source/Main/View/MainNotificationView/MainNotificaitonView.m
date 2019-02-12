//
//  MainNotificaitonView.m
//  livestream
//
//  Created by Calvin on 2019/1/18.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "MainNotificaitonView.h"
#import "LSMainNotificationManager.h"
#import "LSMainNotificaitonModel.h"
#import "MainNotificaitonCell.h"
#import "LiveUrlHandler.h"
@interface MainNotificaitonView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView * collectinView;
@property (nonatomic, assign) NSInteger nowRow;
@end

@implementation MainNotificaitonView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self createUI];
    }
    return self;
}

- (void)createUI {
    self.nowRow = 0;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    self.collectinView = [[UICollectionView alloc]initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectinView.backgroundColor = [UIColor clearColor];
    self.collectinView.pagingEnabled = YES;
    self.collectinView.showsVerticalScrollIndicator = NO;
    self.collectinView.showsHorizontalScrollIndicator = NO;
    self.collectinView.delegate = self;
    self.collectinView.dataSource = self;
    [self addSubview:self.collectinView];
     [self.collectinView registerNib:[UINib nibWithNibName:@"MainNotificaitonCell" bundle:[LiveBundle mainBundle]] forCellWithReuseIdentifier:[MainNotificaitonCell cellIdentifier]];
}

- (void)reloadData {
    [self.collectinView reloadData];
    
    if (self.nowRow == 0 && [LSMainNotificationManager manager].items.count > 1) {
        [self.collectinView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.nowRow + 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
    }
    
    [self.collectinView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

- (void)deleteCollectionViewRow:(NSInteger)row {
    
    if ([LSMainNotificationManager manager].items.count > 0) {
         [self.collectinView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.nowRow - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        [self.collectinView reloadData];
    }}

#pragma mark collectionView代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [LSMainNotificationManager manager].items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MainNotificaitonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[MainNotificaitonCell cellIdentifier] forIndexPath:indexPath];
    
    LSMainNotificaitonModel * model = [[LSMainNotificationManager manager].items objectAtIndex:indexPath.row];
 
    if (model.msgType == MsgStatus_Chat) {
        cell.chatNotificationView.hidden = NO;
        cell.liveNotificationView.hidden = YES;
        [cell loadChatNotificationViewUI:model];
    }
    else {
        cell.chatNotificationView.hidden = YES;
        cell.liveNotificationView.hidden = NO;
        [cell loadLiveNotificationViewUI:model];
    }
    
    [cell startCountdown:model.createTime];
    
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.frame.size.width, self.frame.size.height);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.nowRow = indexPath.row;
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 
    LSMainNotificaitonModel * model = [[LSMainNotificationManager manager].items objectAtIndex:indexPath.row];
    if (model.msgType == MsgStatus_Chat) {
        NSURL * url = [[LiveUrlHandler shareInstance]createLiveChatByanchorId:model.userId anchorName:model.userName];
        [[LiveUrlHandler shareInstance]handleOpenURL:url];
    }
    else {
        NSURL * url = [[LiveUrlHandler shareInstance]createUrlToHangoutByRoomId:nil anchorId:model.userId anchorName:model.userName hangoutAnchorId:nil hangoutAnchorName:nil];
        [[LiveUrlHandler shareInstance]handleOpenURL:url];
        
    }
    [[LSMainNotificationManager manager] selectedShowArrayRow:indexPath.row];
}

@end
