//
//  LSMyCartViewController.m
//  livestream
//
//  Created by Randy_Fan on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSMyCartViewController.h"
#import "AnchorPersonalViewController.h"
#import "LSStoreDetailViewController.h"
#import "LSStoreListToLadyViewController.h"

#import "LSMyCartCell.h"
#import "LSShadowView.h"
#import "DialogTip.h"

#import "LSGetCartGiftListRequest.h"
#import "LSChangeCartGiftNumberRequest.h"
#import "LSRemoveCartGiftRequest.h"
#import "LSRequestManager.h"
#import "LSCheckOutViewController.h"

#define CELLHEIGHT(num) 140 + (num * 70)

@interface LSMyCartViewController ()<UITableViewDelegate,UITableViewDataSource,LSMyCartCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIView *failViews;
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;

@property (weak, nonatomic) IBOutlet UIView *noDataViews;
@property (weak, nonatomic) IBOutlet UIButton *chooseBtn;

@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@property (nonatomic, strong) NSMutableArray<LSMyCartItemObject *> *cartList;

@property (nonatomic, strong) DialogTip *dialogTipView;

@property (nonatomic, assign) BOOL isOffset;

@property (nonatomic, assign) CGRect convertView;

@property (nonatomic, assign) CGRect convertTable;

@end

@implementation LSMyCartViewController

- (void)dealloc {
    
}

- (void)initCustomParam {
    [super initCustomParam];
    
    self.sessionManager = [LSSessionRequestManager manager];
    
    self.cartList = [[NSMutableArray alloc] init];
    
    self.dialogTipView = [DialogTip dialogTip];
    
    self.isOffset = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.navigationTitle = @"My Cart";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.failViews.hidden = YES;
    self.retryBtn.layer.cornerRadius = 5;
    self.retryBtn.layer.masksToBounds = YES;
    LSShadowView *shadow1 = [[LSShadowView alloc] init];
    [shadow1 showShadowAddView:self.retryBtn];
    
    self.noDataViews.hidden = YES;
    self.chooseBtn.layer.cornerRadius = 5;
    self.chooseBtn.layer.masksToBounds = YES;
    LSShadowView *shadow2 = [[LSShadowView alloc] init];
    [shadow2 showShadowAddView:self.chooseBtn];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];

    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
    
    [self sendRequestGetCartList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.dialogTipView removeShow];
    [self.view endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSMyCartItemObject *item = [self.cartList objectAtIndex:indexPath.row];
    return CELLHEIGHT(item.giftList.count);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cartList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSMyCartItemObject *item = [self.cartList objectAtIndex:indexPath.row];
    LSMyCartCell *cell = [LSMyCartCell getUITableViewCell:tableView];
    [cell setupContent:item];
    cell.delegate = self;
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isOffset) {
        [self.view endEditing:YES];
    }
}

#pragma mark - LSMyCartCellDelegate
- (void)didSelectAnchorInfo:(LSMyCartItemObject *)item {
    // 进入主播详情页
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = item.anchorItem.anchorId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
}

- (void)didSelectContinueShop:(LSMyCartItemObject *)item {
    // 进入加入购物车成功页
    LSStoreListToLadyViewController *vc = [[LSStoreListToLadyViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = item.anchorItem.anchorId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didSelectChectOut:(LSMyCartItemObject *)item {
    // 进入checkout页
    LSCheckOutViewController *vc = [[LSCheckOutViewController alloc] initWithNibName:nil bundle:nil];
    vc.anchorId = item.anchorItem.anchorId;
    vc.anchorName = item.anchorItem.anchorNickName;
    vc.anchorImageUrl = item.anchorItem.anchorAvatarImg;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didChangeCartGiftNum:(LSMyCartStoreCell *)cell item:(LSCartGiftItem *)item num:(int)num {
    // 修改购物车礼物数量
    [self sendRequestChangeGiftNum:cell item:item num:num];
}

- (void)disShowChangeError {
    // 提示购物车礼物数量错误
    [self.dialogTipView showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"CHANGE_NUM_ERROR")];
}

- (void)didRemoveCartGift:(LSMyCartCell *)cell item:(LSCartGiftItem *)item {
    // 移除购物车礼物
    [self sendRequestRemoveGift:item cell:cell];
}

- (void)didCartGiftInfo:(LSCartGiftItem *)item {
    // 进入礼物详情界面
    LSStoreDetailViewController *vc = [[LSStoreDetailViewController alloc] initWithNibName:nil bundle:nil];
    vc.giftId = item.giftId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didGetConvertRectToVc:(UITextField *)textField rect:(CGRect)rect {
    // 开始编辑textField    
    self.convertTable = [textField convertRect:rect toView:self.tableView];
    self.convertView = [textField convertRect:rect toView:self.view];
}

#pragma mark - HTTP请求
- (void)sendRequestGetCartList {
    [self showAndResetLoading];
    LSGetCartGiftListRequest *request = [[LSGetCartGiftListRequest alloc] init];
    request.start = 0;
    request.step = 100;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int total, NSArray<LSMyCartItemObject *> *array) {
        NSLog(@"LSMyCartViewController::sendRequestGetCartList[获取MyCart列表 success : %@, errnum : %d, errmsg : %@, total : %d]", BOOL2SUCCESS(success),errnum,errmsg,total);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAndResetLoading];
            if (success) {
                [self.cartList removeAllObjects];
                
                [self shownoDataViews:NO orFail:NO];
                if (total > 0) {
                    [self.cartList addObjectsFromArray:array];
                    self.tableView.hidden = NO;
                    [self.tableView reloadData];
                } else {
                    [self shownoDataViews:YES orFail:NO];
                }
            } else {
                [self shownoDataViews:NO orFail:YES];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)sendRequestChangeGiftNum:(LSMyCartStoreCell *)cell item:(LSCartGiftItem *)item num:(int)num {
    [self showAndResetLoading];
    LSChangeCartGiftNumberRequest *requset = [[LSChangeCartGiftNumberRequest alloc] init];
    requset.anchorId = item.anchorId;
    requset.giftId = item.giftId;
    requset.giftNumber = num;
    requset.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
        NSLog(@"LSMyCartViewController::sendRequestChangeGiftNum[请求修改鲜花礼品数量 success : %@, errnum : %d, errmsg : %@]",BOOL2SUCCESS(success),errnum,errmsg);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAndResetLoading];
            [cell changeGiftNum:num success:success];
            if (!success) {
                [self.dialogTipView showDialogTip:self.view tipText:errmsg];
            }
        });
    };
    [self.sessionManager sendRequest:requset];
}

- (void)sendRequestRemoveGift:(LSCartGiftItem *)item cell:(LSMyCartCell *)cell {
    [self showAndResetLoading];
    LSRemoveCartGiftRequest *request = [[LSRemoveCartGiftRequest alloc] init];
    request.anchorId = item.anchorId;
    request.giftId = item.giftId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
        NSLog(@"LSMyCartViewController::sendRequestRemoveGift[请求删除鲜花礼品 success : %@, errnum : %d, errmsg : %@]",BOOL2SUCCESS(success),errnum,errmsg);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAndResetLoading];
            if (success) {
                [self sendRequestGetCartList];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - 界面事件
- (IBAction)retryAction:(id)sender {
    [self sendRequestGetCartList];
}

- (IBAction)chooseGiftAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shownoDataViews:(BOOL)noData orFail:(BOOL)fail {
    self.noDataViews.hidden = !noData;
    self.failViews.hidden = !fail;
    self.tableView.hidden = !noData && !fail ? NO : YES;
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap {
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    // 从表情键盘切换成系统键盘,保存普通表情的富文本属性
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    if (self.isOffset) {
        self.isOffset = !self.isOffset;
    }
}

- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    if (height != 0) {
        CGFloat offSet = self.convertTable.origin.y + 40 - (self.view.tx_height - height);
        CGFloat viewOffSet = self.convertView.origin.y + 40 - (self.view.tx_height - height);
        if (offSet > 0 && viewOffSet > 0) {
            self.isOffset = YES;
            self.tableView.contentOffset = CGPointMake(0, offSet);
        }
    }
}

@end
