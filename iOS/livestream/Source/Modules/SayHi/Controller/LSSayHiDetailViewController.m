//
//  LSSayHiDetailViewController.m
//  livestream
//
//  Created by Calvin on 2019/4/18.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiDetailViewController.h"
#import "LSSayHiDetailHeadView.h"
#import "LSSayHiChooseView.h"
#import "LSSayHiReadReplyCell.h"
#import "LSSayHiUnreadReplyCell.h"
#import "LSSayHiNoReplyCell.h"
@interface LSSayHiDetailViewController ()<UITableViewDelegate,UITableViewDataSource,LSSayHiDetailHeadViewDelegate,LSSayHiUnreadReplyCellDelegate,LSSayHiReadReplyCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) LSSayHiChooseView * chooseView;
@property (nonatomic, strong) NSMutableArray * items;
@property (nonatomic, assign) BOOL test;
@end

@implementation LSSayHiDetailViewController

- (void)dealloc {
    NSLog(@"LSSayHiDetailViewController::dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.items = [NSMutableArray array];
    
    self.test = YES;
}

- (void)setupContainView {
    [super setupContainView];
    
    LSSayHiDetailHeadView * headView = [[LSSayHiDetailHeadView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 145)];
    headView.delegate = self;
    [self.tableView setTableHeaderView:headView];
    [self.tableView reloadData];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    self.navigationTitle = @"My Say Hi";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideChooseView];
}

#pragma mark - 接口请求

- (void)buyMail {
    
}

#pragma mark - 显示排序选择器
- (void)showChooseView {
    if (!self.chooseView) {
        self.chooseView = [[LSSayHiChooseView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 200, self.tableView.tableHeaderView.tx_height, 190, 143)];
        [self.view addSubview:self.chooseView];
        self.chooseView.isSelectedUnread = YES;
    }
    else {
        [self hideChooseView];
    }
}

- (void)hideChooseView {
    [self.chooseView removeFromSuperview];
    self.chooseView = nil;
}
#pragma mark - SayHiDetailHeadDelegate
- (void)sayHiDetailHeadViewDidSortBtn {
    [self showChooseView];
}

- (void)sayHiDetailHeadViewDidNoteBtn {
    
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return [LSSayHiNoReplyCell cellHeight];
    }
    if (indexPath.row == 1) {
        return [LSSayHiUnreadReplyCell cellHeight];
    }
    if (indexPath.row == 2) {
        return [LSSayHiReadReplyCell cellHeight:@"" isUnfold:self.test];
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = nil;
    if (indexPath.row == 0) {
        LSSayHiNoReplyCell * noReplyCell = [LSSayHiNoReplyCell getUITableViewCell:tableView];
        cell = noReplyCell;
    }
    if (indexPath.row == 1) {
        LSSayHiUnreadReplyCell * unreadReplyCell = [LSSayHiUnreadReplyCell getUITableViewCell:tableView];
        unreadReplyCell.cellDelegate = self;
        cell = unreadReplyCell;
    }
    if (indexPath.row == 2) {
        LSSayHiReadReplyCell * readReplyCell = [LSSayHiReadReplyCell getUITableViewCell:tableView];
        readReplyCell.cellDelegate = self;
        cell = readReplyCell;
    }
    
  
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hideChooseView];
}

- (void)sayHiReadReplyCellArrowBtnDid {
    self.test = !self.test;
    [self.tableView reloadData];
}

- (void)sayHiUnreadReplyCellReadNowBtnDid {
    
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"SayHiAgainTip"]) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedStringFromSelf(@"BUY_TIP") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self buyMail];
        }];
        UIAlertAction * aginAction = [UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"AGAIN_TIP") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"SayHiAgainTip"];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }];
        UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:okAction];
        [alertController addAction:aginAction];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else {
        [self buyMail];
    }
}
@end
