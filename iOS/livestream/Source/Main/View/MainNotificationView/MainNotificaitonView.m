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
#import "TYCyclePagerView.h"
@interface MainNotificaitonView ()<TYCyclePagerViewDataSource, TYCyclePagerViewDelegate>
@property (nonatomic, strong) TYCyclePagerView *pagerView;
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
    self.pagerView = [[TYCyclePagerView alloc]initWithFrame:self.bounds];
    self.pagerView.backgroundColor = [UIColor clearColor];
    self.pagerView.isInfiniteLoop = NO;
    self.pagerView.autoScrollInterval = 0;
    self.pagerView.dataSource = self;
    self.pagerView.delegate = self;
    [self addSubview:self.pagerView];
    
     [self.pagerView registerNib:[UINib nibWithNibName:@"MainNotificaitonCell" bundle:[LiveBundle mainBundle]] forCellWithReuseIdentifier:[MainNotificaitonCell cellIdentifier]];
}

- (void)reloadData {
    [self.pagerView reloadData];
    
    if (self.pagerView.curIndex == 0 && [LSMainNotificationManager manager].items.count > 1) {
        [self.pagerView.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.pagerView.curIndex + 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
    }
    
    [self.pagerView.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

- (void)deleteCollectionViewRow {
    
    if ([LSMainNotificationManager manager].items.count > 0 && self.pagerView.curIndex == [LSMainNotificationManager manager].items.count) {
         [self.pagerView.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.pagerView.curIndex - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        [self performSelector:@selector(uiReloadData) withObject:nil afterDelay:0.3];
    }else {
      [self.pagerView.collectionView reloadData];
    }
}

- (void)uiReloadData {
    [self.pagerView.collectionView reloadData];
}

#pragma mark - TYCyclePagerViewDataSource

- (NSInteger)numberOfItemsInPagerView:(TYCyclePagerView *)pageView {
    return [LSMainNotificationManager manager].items.count;
}

- (UICollectionViewCell *)pagerView:(TYCyclePagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
    MainNotificaitonCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:[MainNotificaitonCell cellIdentifier] forIndex:index];
    
    LSMainNotificaitonModel * model = [[LSMainNotificationManager manager].items objectAtIndex:index];
    NSLog(@"=======%@===%d===%d",model.contentStr,[LSMainNotificationManager manager].items.count,index);
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

- (TYCyclePagerViewLayout *)layoutForPagerView:(TYCyclePagerView *)pageView {
    TYCyclePagerViewLayout *layout = [[TYCyclePagerViewLayout alloc]init];
    layout.itemSize = CGSizeMake(CGRectGetWidth(pageView.frame)*0.85, self.frame.size.height);
    layout.itemSpacing = 10;
    //layout.minimumAlpha = 0.3;
    layout.itemHorizontalCenter = YES;
    return layout;
}

- (void)pagerView:(TYCyclePagerView *)pageView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index {
    
    LSMainNotificaitonModel * model = [[LSMainNotificationManager manager].items objectAtIndex:index];
    if (model.msgType == MsgStatus_Chat) {
        NSURL * url = [[LiveUrlHandler shareInstance]createLiveChatByanchorId:model.userId anchorName:model.userName];
        [[LiveUrlHandler shareInstance]handleOpenURL:url];
    }
    else {
        NSURL * url = [[LiveUrlHandler shareInstance]createUrlToHangoutByRoomId:@"" anchorId:model.userId anchorName:model.userName hangoutAnchorId:@"" hangoutAnchorName:@""];
        [[LiveUrlHandler shareInstance]handleOpenURL:url];
        
    }
    [[LSMainNotificationManager manager] selectedShowArrayRow:index];
}

@end
