//
//  HotViewController.m
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "HotViewController.h"

#import "PlayViewController.h"

#import "GetLiveRoomHotListRequest.h"

#define PageSize 10

@interface HotViewController () <UIScrollViewRefreshDelegate, HotTableViewDelegate>

/**
 *  接口管理器
 */
@property (nonatomic, strong) SessionRequestManager* sessionManager;

/**
 列表
 */
@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation HotViewController

- (void)initCustomParam {
    [super initCustomParam];
    
    self.items = [NSMutableArray array];
    
    self.sessionManager = [SessionRequestManager manager];
}

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if( self.items.count == 0 ) {
        // 已登陆, 没有数据, 下拉控件, 触发调用刷新女士列表
        [self.tableView startPullDown:YES];
    }
    
}

- (void)setupContainView {
    [super setupContainView];
    
    // 初始化主播列表
    [self setupTableView];
}

- (void)setupTableView {
    // 初始化下拉
    [self.tableView initPullRefresh:self pullDown:YES pullUp:YES];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    self.tableView.tableViewDelegate = self;
}

#pragma mark - 数据逻辑
- (void)initTestData {
    LiveRoomInfoItemObject* item = nil;
    
    item = [[LiveRoomInfoItemObject alloc] init];
    item.userId = @"1";
    item.nickName = @"Angelica";
    item.photoUrl = @"http://images3.charmdate.com/woman_photo/C2248/161/C235829-f007f8438f8b56a94575f68f655e788b-1.jpg";
    item.country = @"Ukraine";
    [self.items addObject:item];
    
    item = [[LiveRoomInfoItemObject alloc] init];
    item.userId = @"2";
    item.nickName = @"Marry";
    item.photoUrl = @"http://images3.charmdate.com/woman_photo/C1251/132/C615703-84398ccb04629db648dfb7ee8b64b03c-4.jpg";
    item.country = @"US";
    [self.items addObject:item];
    
    item = [[LiveRoomInfoItemObject alloc] init];
    item.userId = @"3";
    item.nickName = @"Vera";
    item.photoUrl = @"http://images3.charmdate.com/woman_photo/C1610/150/C833381-14784b57f3f37270e79f606e80d33a0c-1.jpg";
    item.country = @"UK";
    [self.items addObject:item];
    
    item = [[LiveRoomInfoItemObject alloc] init];
    item.userId = @"4";
    item.nickName = @"Anna";
    item.photoUrl = @"http://images3.charmdate.com/woman_photo/C3069/169/C251959-754b69462fe0ae1268256e3ba8b712cf-7.jpg";
    item.country = @"Japan";
    [self.items addObject:item];
    
    item = [[LiveRoomInfoItemObject alloc] init];
    item.userId = @"5";
    item.nickName = @"Anastasia";
    item.photoUrl = @"http://images3.charmdate.com/woman_photo/C1425/134/C732634-5e65d3d9d700026a88582b52ff263c47-1.jpg";
    item.country = @"China";
    [self.items addObject:item];
    
    item = [[LiveRoomInfoItemObject alloc] init];
    item.userId = @"C946042";
    item.nickName = @"Darina";
    item.photoUrl = @"http://images3.charmdate.com/woman_photo/C1407/163/C946042-6007062e802e2a3c163be04210ccc0ca-1.jpg";
    item.country = @"China";
    [self.items addObject:item];
    
    item = [[LiveRoomInfoItemObject alloc] init];
    item.userId = @"C946042";
    item.nickName = @"Darina";
    item.photoUrl = @"http://images3.charmdate.com/woman_photo/C1407/163/C946042-89cec41b94eb0e66d5c37083914f1e2c-2.jpg";
    item.country = @"China";
    [self.items addObject:item];

}

- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    if( isReloadView ) {
        self.tableView.items = self.items;
        [self.tableView reloadData];
        
        UITableViewCell* cell = [self.tableView visibleCells].firstObject;
        NSIndexPath *index = [self.tableView indexPathForCell:cell];
        NSInteger row = index.row;
        
        if( self.items.count > 0) {
            if( row < self.items.count ) {
                NSIndexPath* nextLadyIndex = [NSIndexPath indexPathForRow:row inSection:0];
                [self.tableView scrollToRowAtIndexPath:nextLadyIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    }
}

- (void)tableView:(HotTableView *)tableView didSelectItem:(LiveRoomInfoItemObject *)item {
    PlayViewController* vc = [[PlayViewController alloc] initWithNibName:nil bundle:nil];
    vc.liveInfo = item;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 上下拉
- (void)pullDownRefresh {
    self.view.userInteractionEnabled = NO;
    [self getListRequest:NO];
}

- (void)pullUpRefresh {
    self.view.userInteractionEnabled = NO;
    [self getListRequest:YES];
}

#pragma mark - PullRefreshView回调
- (void)pullDownRefresh:(UIScrollView *)scrollView {
    // 下拉刷新回调
    [self pullDownRefresh];
}

- (void)pullUpRefresh:(UIScrollView *)scrollView {
    // 上拉更多回调
    [self pullUpRefresh];
}

#pragma mark 数据逻辑
- (BOOL)getListRequest:(BOOL)loadMore {
    GetLiveRoomHotListRequest *request = [[GetLiveRoomHotListRequest alloc] init];
    
    int start = 1;
    if( !loadMore ) {
        // 刷最新
        start = 1;
        
    } else {
        // 刷更多
        start = self.items?((int)self.items.count + 1):1;
    }
    
    // 每页最大纪录数
    request.start = start;
    request.step = PageSize;

    // 调用接口
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSArray<LiveRoomInfoItemObject *> * _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if( success ) {
                NSLog(@"HotViewController::getLiveRoomHotListRequest( [Success], loadMore : %d, count : %ld )", loadMore, (long)array.count);
                if( !loadMore ) {
                    // 清空列表
                    [self.items removeAllObjects];
                    
                    // 停止头部
                    [self.tableView finishPullDown:YES];
                    
                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];
                    
                }
                
                for(LiveRoomInfoItemObject* item in array) {
                    [self addItemIfNotExist:item];
                }
                
                [self reloadData:YES];
                
                if( !loadMore ) {
                    if( self.items.count > 0 ) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            // 拉到最顶
                            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
                            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                        });
                    }
                }
                
            } else {
                NSLog(@"HotViewController::getLiveRoomHotListRequest( [Fail] )");
                
                if( !loadMore ) {
                    // 停止头部
                    [self.tableView finishPullDown:YES];
                    
                } else {
                    // 停止底部
                    [self.tableView finishPullUp:YES];
                    
                }
                
                [self reloadData:YES];
                
            }
            
            self.view.userInteractionEnabled = YES;
        });
        
    };
    return [self.sessionManager sendRequest:request];
}

- (void)addItemIfNotExist:(LiveRoomInfoItemObject* _Nonnull)itemNew {
    bool bFlag = NO;
    
    for(LiveRoomInfoItemObject* item in self.items) {
        if( [item.userId isEqualToString:itemNew.userId] ) {
            // 已经存在
            bFlag = true;
            break;
        }
    }
    
    if( !bFlag ) {
        // 不存在
        [self.items addObject:itemNew];
    }
}

@end
