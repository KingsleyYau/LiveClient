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
#import "LSAutoInvitationClickLogRequest.h"
@interface MainNotificaitonView () <TYCyclePagerViewDataSource, TYCyclePagerViewDelegate>
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
    self.pagerView = [[TYCyclePagerView alloc] initWithFrame:self.bounds];
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

    if (self.pagerView.curIndex == 0 && self.items.count > 1) {
        [self.pagerView scrollToItemAtIndex:self.pagerView.curIndex + 1 animate:NO];
    }
    [self.pagerView scrollToItemAtIndex:0 animate:YES];
}

- (void)deleteCollectionViewRow {

    if (self.items.count > 0 && self.pagerView.curIndex == self.items.count) {
        [self.pagerView scrollToItemAtIndex:self.pagerView.curIndex - 1 animate:YES];
        [self performSelector:@selector(uiReloadData) withObject:nil afterDelay:0.3];
    } else {
        [self.pagerView reloadData];
    }
}

- (void)uiReloadData {
    [self.pagerView reloadData];
}

#pragma mark - TYCyclePagerViewDataSource

- (NSInteger)numberOfItemsInPagerView:(TYCyclePagerView *)pageView {
    return self.items.count;
}

- (UICollectionViewCell *)pagerView:(TYCyclePagerView *)pagerView cellForItemAtIndex:(NSInteger)index {
    MainNotificaitonCell *cell = [pagerView dequeueReusableCellWithReuseIdentifier:[MainNotificaitonCell cellIdentifier] forIndex:index];

    LSMainNotificaitonModel *model = [self.items objectAtIndex:index];
    if (model.msgType == MsgStatus_Chat) {
        cell.chatNotificationView.hidden = NO;
        cell.liveNotificationView.hidden = YES;
        [cell loadChatNotificationViewUI:model];
    } else {
        cell.chatNotificationView.hidden = YES;
        cell.liveNotificationView.hidden = NO;
        [cell loadLiveNotificationViewUI:model];
    }

    [cell.scheduledTimeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pagerViewCell:)]];

    [cell startCountdown:model.createTime];
    return cell;
}

- (TYCyclePagerViewLayout *)layoutForPagerView:(TYCyclePagerView *)pageView {
    TYCyclePagerViewLayout *layout = [[TYCyclePagerViewLayout alloc] init];
    layout.itemSize = CGSizeMake(CGRectGetWidth(pageView.frame) * 0.85, self.frame.size.height);
    layout.itemSpacing = 6;
    //layout.minimumAlpha = 0.3;
    layout.itemHorizontalCenter = YES;
    return layout;
}

- (void)pagerView:(TYCyclePagerView *)pageView didSelectedItemCell:(__kindof UICollectionViewCell *)cell atIndex:(NSInteger)index {
}

- (void)pagerViewCell:(UITapGestureRecognizer *)tap {

    NSInteger index = self.pagerView.curIndex;

    LSMainNotificaitonModel *model = [self.items objectAtIndex:index];
    if (model.msgType == MsgStatus_Chat) {
        NSURL *url = [[LiveUrlHandler shareInstance] createLiveChatByanchorId:model.userId anchorName:model.userName];
        [[LiveUrlHandler shareInstance] handleOpenURL:url];
    } else {
        [self sendAutoInvitationHangoutLog:model.userId isAuto:model.isAuto];
        NSURL *url = [[LiveUrlHandler shareInstance] createUrlToHangoutByRoomId:@"" anchorId:model.userId anchorName:model.userName hangoutAnchorId:@"" hangoutAnchorName:@""];
        [[LiveUrlHandler shareInstance] handleOpenURL:url];
    }

    [[LSMainNotificationManager manager] selectedShowArrayRowItem:model];
}

- (BOOL)sendAutoInvitationHangoutLog:(NSString *)anchorId isAuto:(BOOL)isAuto {
    LSSessionRequestManager *sessionManager = [LSSessionRequestManager manager];
    LSAutoInvitationClickLogRequest *request = [[LSAutoInvitationClickLogRequest alloc] init];
    request.anchorId = anchorId;
    request.isAuto = isAuto;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"MainNotificaitonView :: sendAutoInvitationHangoutLog success %@,errmsg : %@", BOOL2YES(success), errmsg);
        });
    };
    return [sessionManager sendRequest:request];
}
@end
