//
//  LSRecentWatchViewController.m
//  livestream
//
//  Created by Randy_Fan on 2019/3/21.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "LSRecentWatchViewController.h"
#import "LSChatDetailVideoViewController.h"
#import "LSChatAccessoryListViewController.h"

#import "RecentWatchCollectionViewCell.h"

#import "LSQueryRecentVideoListRequest.h"
#import "LSSessionRequestManager.h"
#import "LSLoginManager.h"

#import "QNMessage.h"

@interface LSRecentWatchViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewRefreshDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIImageView *noDataImageView;

@property (weak, nonatomic) IBOutlet UILabel *noDataLabel;

@property (strong, nonatomic) NSMutableArray<LSLCRecentVideoItemObject *> *videoItems;

@property (strong, nonatomic) NSMutableArray<QNMessage *> *msgItems;

@property (strong, nonatomic) LSSessionRequestManager *sessionManager;

@end

@implementation LSRecentWatchViewController

- (void)dealloc {
    [self.collectionView unSetupPullRefresh];
}

- (void)initCustomParam {
    [super initCustomParam];
    
    self.videoItems = [[NSMutableArray alloc] init];
    self.msgItems = [[NSMutableArray alloc] init];
    self.sessionManager = [LSSessionRequestManager manager];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedStringFromSelf(@"Recent Watched")];
    
    UINib *nib = [UINib nibWithNibName:[RecentWatchCollectionViewCell cellIdentifier] bundle:[LiveBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[RecentWatchCollectionViewCell cellIdentifier]];
    
    [self.collectionView setupPullRefresh:self pullDown:YES pullUp:NO];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.alwaysBounceVertical = YES;
    
    [self isShowNoDataView:NO tip:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 默认下拉刷新
    if (!self.viewDidAppearEver) {
        [self.collectionView startLSPullDown:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)isShowNoDataView:(BOOL)isShow tip:(NSString *)tip {
    self.noDataImageView.hidden = !isShow;
    self.noDataLabel.hidden = !isShow;
    self.noDataLabel.text = tip;
}

#pragma mark - UIScrollViewRefreshDelegate
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    [self pullDownRefresh];
}

- (void)pullDownRefresh {
    // TODO:下拉刷新    
    self.view.userInteractionEnabled = NO;
    if (self.womanId.length > 0) {
        [self getRecentWatched];
    }
}

- (void)getRecentWatched {
    WeakObject(self, weakSelf);
    LSQueryRecentVideoListRequest *request = [[LSQueryRecentVideoListRequest alloc] init];
    request.userSid = [LSLoginManager manager].loginItem.sessionId;
    request.userId = [LSLoginManager manager].loginItem.userId;
    request.womanId = self.womanId;
    request.finishHandler = ^(BOOL success, NSString *errnum, NSString *errmsg, NSArray<LSLCRecentVideoItemObject *> *itemArray) {
        NSLog(@"LSRecentWatchViewController:getRecentWatched([获取最近已看微视频列表] success : %@, errnum : %@, errmsg : %@, count : %lu)",BOOL2SUCCESS(success), errnum, errmsg, (unsigned long)itemArray.count);
        dispatch_async(dispatch_get_main_queue(), ^{
            // 停止头部
            [weakSelf.collectionView finishLSPullDown:NO];
            
            [weakSelf.videoItems removeAllObjects];
            [weakSelf.msgItems removeAllObjects];
            
            if (success) {
                if (itemArray.count > 0) {
                    [weakSelf isShowNoDataView:NO tip:nil];
                    
                    for (LSLCRecentVideoItemObject *obj in itemArray) {
                        [weakSelf.videoItems addObject:obj];
                        
                        LSLCLiveChatMsgItemObject *item = [[LSLCLiveChatMsgItemObject alloc] init];
                        item.fromId = weakSelf.womanId;
                        item.inviteId = obj.inviteid;
                        item.videoMsg = [[LSLCLiveChatMsgVideoItem alloc] init];
                        item.videoMsg.videoUrl = obj.videoUrl;
                        item.videoMsg.videoId = obj.videoId;
                        item.videoMsg.videoDesc = obj.title;
                        item.videoMsg.charge = YES;
                        
                        QNMessage *message = [[QNMessage alloc] init];
                        message.sender = MessageSenderLady;
                        message.type = MessageTypeVideo;
                        message.liveChatMsgItemObject = item;
                        message.recentVideoItemObject = obj;
                        
                        [weakSelf.msgItems addObject:message];
                    }
                } else {
                    [weakSelf isShowNoDataView:YES tip:NSLocalizedStringFromSelf(@"NO_DATA_TIP")];
                }
            } else {
                [weakSelf isShowNoDataView:YES tip:NSLocalizedString(@"List_FailTips", @"List_FailTips")];
            }
            [weakSelf.collectionView reloadData];
            weakSelf.view.userInteractionEnabled = YES;
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - UICollectionViewDelegate / UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videoItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSLCRecentVideoItemObject *obj = self.videoItems[indexPath.row];
    
    RecentWatchCollectionViewCell *cell = [RecentWatchCollectionViewCell getUICollectionViewCell:collectionView indexPath:indexPath];
    [cell setupCellContent:obj];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LSChatAccessoryListViewController *vc = [[LSChatAccessoryListViewController alloc] initWithNibName:nil bundle:nil];
    vc.items = self.msgItems;
    vc.row = indexPath.row;
    LSNavigationController * nav = [[LSNavigationController alloc]initWithRootViewController:vc];
    [self presentViewController:nav animated:NO completion:nil];}


@end
