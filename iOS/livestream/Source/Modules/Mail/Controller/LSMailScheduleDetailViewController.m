//
//  LSScheduleDetailViewController.m
//  livestream
//
//  Created by test on 2020/3/24.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSMailScheduleDetailViewController.h"
#import "LSScheduleNoteCell.h"
#import "LSScheduleFootCell.h"
#import "LSScheduleActionCell.h"
#import "LSScheduleMailHeadCell.h"
#import "LSScheduleContentCell.h"
#import "LSPrepaidInfoView.h"
#import "LiveModule.h"
#import "LiveUrlHandler.h"
#import "LSGetEmfDetailRequest.h"
#import "DialogTip.h"
#import "LSImageViewLoader.h"
#import "LSOtherOptionView.h"
#import "LSPrePaidPickerView.h"
#import "LSPrePaidManager.h"
#import "LSSendMailViewController.h"
#import "LiveModule.h"
#import "LiveUrlHandler.h"
#import "LSAcceptDiaglog.h"
#import "LSChooseDialog.h"
#import "LSDecelineDialog.h"
#import "LSScheduleTipsCell.h"
#import "LiveRoomCreditRebateManager.h"
#import "LSAddCreditsViewController.h"

#define ROW_TYPE @"ROW_TYPE"
#define ROW_SIZE @"ROW_SIZE"

#define NavNormalHeight 64
#define NavIphoneXHeight 88
typedef enum {
    RowTypeHead,
    RowTypeNote,
    RowTypeContent,
    RowTypeAction,
    RowTypeScheduleTips,
    RowTypeFoot,
} RowType;

@interface LSMailScheduleDetailViewController ()<UITableViewDataSource,UITableViewDelegate,LSScheduleFootCellDelegate,LSScheduleActionCellDelegate,UIScrollViewDelegate,LSOtherOptionViewDelegate,LSPrePaidPickerViewDelegate,LSScheduleContentCellDelegate,LSPrePaidManagerDelegate,LSDecelineDialogDelegate,LSAcceptDiaglogDelegate,LSPurchaseCreditsViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UIView *noCreditsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *errorViewY;
@property (nonatomic, strong) NSMutableArray *typeArray;
@property (nonatomic, strong) LSPrepaidInfoView *perpaidInfoView;
@property (nonatomic, copy) NSString *noteContent;
// 单击收起输入控件手势
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) LSHttpLetterDetailItemObject *item;
@property (nonatomic, strong) LSOtherOptionView *otherOptionView;
@property (nonatomic, strong) LSPrePaidPickerView * pickerView;
@property (nonatomic, strong) LSPurchaseCreditsView *purchaseCreditView;
/** 是否发送邮件 */
@property (nonatomic, assign) BOOL isReplyMail;
/** 是否接受 */
@property (nonatomic, assign) BOOL isAccept;

@property (nonatomic, strong) UILabel *navTitleLabel;
@property (nonatomic, strong) UIButton *navLeftBtn;

@property (nonatomic, assign) NSInteger selectedRow;//选中的国家
@property (nonatomic, assign) NSInteger selectedZoneRow;//选中的时区
@property (nonatomic, assign) NSInteger selectedDurationRow;//选中的时长
@property (nonatomic, assign) NSInteger selectedYearRow;//选中的日期
@property (nonatomic, assign) NSInteger selectedBeginTimeRow;//选中的开始时间
@end

@implementation LSMailScheduleDetailViewController

- (void)dealloc {
    [[LSPrePaidManager manager] removeDelegate:self];
}

- (void)initCustomParam {
    [super initCustomParam];
    self.isShowNavBar = NO;
    self.noteContent = @"";
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.typeArray = [NSMutableArray array];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
 
    self.navLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.navLeftBtn addTarget:self action:@selector(backToAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.navLeftBtn setImage:[UIImage imageNamed:@"LS_Nav_Back_b"] forState:UIControlStateNormal];
    if (IS_IPHONE_X) {
      self.navLeftBtn.frame = CGRectMake(0, 44, 30, 44);
    }else {
        self.navLeftBtn.frame = CGRectMake(0, 20, 30, 44);
    }
    [self.view addSubview:self.navLeftBtn];
    
    [[LSPrePaidManager manager] addDelegate:self];
    
    self.isShowNavBar = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[LiveRoomCreditRebateManager creditRebateManager] getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
    }];
    [self getMailDetail:self.letterItem.letterId isUpdate:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.purchaseCreditView removeShowCreditView];
}

// 初始化预约没点弹层
- (void)setupPurchaseCreditView:(NSString *)photoUrl anchorName:(NSString *)anchorName{
    self.purchaseCreditView = [[LSPurchaseCreditsView alloc] init];
    self.purchaseCreditView.delegate = self;
    [self.purchaseCreditView setupCreditView:photoUrl];
}

- (void)showPurchaseCreditView {
    [self.purchaseCreditView setupCreditTipIsAccept:YES name:self.item.anchorNickName credit:[LiveRoomCreditRebateManager creditRebateManager].mCredit];
    [self.purchaseCreditView showLSCreditViewInView:self.navigationController.view];
}

- (void)purchaseDidAction {
    [self.purchaseCreditView removeShowCreditView];
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)getMailDetail:(NSString *)mailId isUpdate:(BOOL)isUpdate {
    [self showAndResetLoading];
    LSGetEmfDetailRequest *request = [[LSGetEmfDetailRequest alloc] init];
    request.emfId = mailId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSHttpLetterDetailItemObject *item) {
        NSLog(@"LSMailScheduleDetailViewController::getMailDeatail (请求预约信件详情 success : %@, errnum : %d, errmsg : %@, letterId : %@)", BOOL2SUCCESS(success), errnum, errmsg, item.letterId);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAndResetLoading];
            if (success) {
                [self setupPurchaseCreditView:item.anchorAvatar anchorName:item.anchorNickName];
                self.noteContent = self.isInBoxSheduleDetail ? [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Anchor_Description"),item.anchorNickName] : [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Your_Description"),item.anchorNickName];
                self.item = item;
                [self reloadData:YES];
                self.letterItem.hasRead = YES;
                // 刷新列表已读信息
                if ([self.scheduleDetailDelegate
                        respondsToSelector:@selector(lsMailScheduleDetailViewController:haveReadScheduleDetailMail:index:)]) {
                    [self.scheduleDetailDelegate lsMailScheduleDetailViewController:self haveReadScheduleDetailMail:self.letterItem index:self.mailIndex];
                }
                // 是否接受和拒绝更新状态
                if (isUpdate) {
                    // 是否直接发信
                    if (self.isReplyMail) {
                        // 直接接收和拒绝显示dialog后,1秒后才跳转
                        NSString *dialogTips = self.isAccept ? NSLocalizedStringFromSelf(@"Accept_Schedule") : NSLocalizedStringFromSelf(@"Decelined_Schedule");
                        [[DialogTip dialogTip] showDialogTip:self.view tipText:dialogTips];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self sendMailAction];
                        });
                
                    }else {
                        // 接受和拒绝弹窗
                        if (self.isAccept) {
                            LSAcceptDiaglog *acceptDialog = [LSAcceptDiaglog dialog];
                            acceptDialog.acceptDelegate = self;
                            [acceptDialog showAcceptDiaglog:self.navigationController.view];
                            
                        }else {
                            LSDecelineDialog *decelineDialog = [LSDecelineDialog dialog];
                            decelineDialog.decilineDelegate = self;
                            [decelineDialog showDecelineDialog:self.navigationController.view];
                        }
                        
                    }
                }
            } else {
                if (errnum ==HTTP_LCC_ERR_LETTER_NO_CREDIT_OR_NO_STAMP) {
                    self.noCreditsView.hidden = NO;
                }else{
                    self.noCreditsView.hidden = YES;
                   [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
                }
               
                [self reloadData:NO];
                
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}


- (IBAction)addCreditsBtnDid:(id)sender {
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)reloadData:(BOOL)isSuccess {
    // 主tableView
    NSMutableArray *array = [NSMutableArray array];
    NSMutableDictionary *dictionary = nil;
    CGSize viewSize;
    NSValue *rowSize;
    if (isSuccess) {
        self.errorView.hidden = YES;
        self.tableView.scrollEnabled = YES;
        // 头部
         dictionary = [NSMutableDictionary dictionary];
         viewSize = CGSizeMake(self.tableView.frame.size.width, [LSScheduleMailHeadCell cellHeight]);
         rowSize = [NSValue valueWithCGSize:viewSize];
         [dictionary setValue:rowSize forKey:ROW_SIZE];
         [dictionary setValue:[NSNumber numberWithInteger:RowTypeHead] forKey:ROW_TYPE];
         [array addObject:dictionary];
         
         // 提示
         dictionary = [NSMutableDictionary dictionary];
         viewSize = CGSizeMake(self.tableView.frame.size.width, [LSScheduleNoteCell cellHeight:screenSize.width detailString:self.noteContent]);
         rowSize = [NSValue valueWithCGSize:viewSize];
         [dictionary setValue:rowSize forKey:ROW_SIZE];
         [dictionary setValue:[NSNumber numberWithInteger:RowTypeNote] forKey:ROW_TYPE];
         [array addObject:dictionary];
         
         dictionary = [NSMutableDictionary dictionary];
         viewSize = CGSizeMake(self.tableView.frame.size.width, [LSScheduleContentCell cellHeight:screenSize.width detailString:self.item.letterContent]);
         rowSize = [NSValue valueWithCGSize:viewSize];
         [dictionary setValue:rowSize forKey:ROW_SIZE];
         [dictionary setValue:[NSNumber numberWithInteger:RowTypeContent] forKey:ROW_TYPE];
         [array addObject:dictionary];
         
         
         if (self.isInBoxSheduleDetail) {
             dictionary = [NSMutableDictionary dictionary];
             CGFloat cellHeight = self.item.scheduleInfo.status != LSSCHEDULEINVITESTATUS_PENDING ?[LSScheduleActionCell cellOneBtnHeight]:[LSScheduleActionCell cellTotalHeight];
             viewSize = CGSizeMake(self.tableView.frame.size.width,cellHeight);
             rowSize = [NSValue valueWithCGSize:viewSize];
             [dictionary setValue:rowSize forKey:ROW_SIZE];
             [dictionary setValue:[NSNumber numberWithInteger:RowTypeAction] forKey:ROW_TYPE];
             [array addObject:dictionary];
             
             dictionary = [NSMutableDictionary dictionary];
             viewSize = CGSizeMake(self.tableView.frame.size.width, [LSScheduleTipsCell cellHeight]);
             rowSize = [NSValue valueWithCGSize:viewSize];
             [dictionary setValue:rowSize forKey:ROW_SIZE];
             [dictionary setValue:[NSNumber numberWithInteger:RowTypeScheduleTips] forKey:ROW_TYPE];
             [array addObject:dictionary];
         }

         dictionary = [NSMutableDictionary dictionary];
         viewSize = CGSizeMake(self.tableView.frame.size.width, [LSScheduleFootCell cellHeight]);
         rowSize = [NSValue valueWithCGSize:viewSize];
         [dictionary setValue:rowSize forKey:ROW_SIZE];
         [dictionary setValue:[NSNumber numberWithInteger:RowTypeFoot] forKey:ROW_TYPE];
         [array addObject:dictionary];
    }else {
        // 头部
         dictionary = [NSMutableDictionary dictionary];
         viewSize = CGSizeMake(self.tableView.frame.size.width, [LSScheduleMailHeadCell cellHeight]);
         rowSize = [NSValue valueWithCGSize:viewSize];
         [dictionary setValue:rowSize forKey:ROW_SIZE];
         [dictionary setValue:[NSNumber numberWithInteger:RowTypeHead] forKey:ROW_TYPE];
         [array addObject:dictionary];
        
        self.errorView.hidden = NO;
        CGFloat y = 20;
        if (IS_IPHONE_X) {
            y = 44;
        }
        self.tableView.scrollEnabled = NO;
        self.errorViewY.constant = y + [LSScheduleMailHeadCell cellHeight];
    }
    self.typeArray = array;
    [self.tableView reloadData];
}


#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        number = self.typeArray.count;
    }
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        NSDictionary *dictionarry = [self.typeArray objectAtIndex:indexPath.row];
        CGSize viewSize;
        NSValue *value = [dictionarry valueForKey:ROW_SIZE];
        [value getValue:&viewSize];
        height = viewSize.height;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    NSDictionary *dictionarry = [self.typeArray objectAtIndex:indexPath.row];

    // 大小
    CGSize viewSize;
    NSValue *value = [dictionarry valueForKey:ROW_SIZE];
    [value getValue:&viewSize];

    // 类型
    RowType type = (RowType)[[dictionarry valueForKey:ROW_TYPE] intValue];

    switch (type) {
        case RowTypeHead:{
            LSScheduleMailHeadCell *cell = [LSScheduleMailHeadCell getUITableViewCell:tableView];
            NSString * url = @"";
            NSString * name = @"";
            if (self.item.anchorAvatar.length > 0) {
                url = self.item.anchorAvatar;
            }
            if (self.letterItem.anchorAvatar.length > 0) {
                url = self.letterItem.anchorAvatar;
            }
            if (self.item.anchorNickName.length >0) {
                name = self.item.anchorNickName;
            }
            if (self.letterItem.anchorNickName.length > 0) {
                name = self.letterItem.anchorNickName;
            }
            [[LSImageViewLoader loader] loadHDListImageWithImageView:cell.headImageView options:SDWebImageRefreshCached imageUrl:url placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:nil];
            cell.nameLabel.text = self.isInBoxSheduleDetail ? [NSString stringWithFormat:@"From: %@",name] : [NSString stringWithFormat:@"To: %@",name];
            cell.onlineView.hidden = !self.item.onlineStatus;
            result = cell;
        }break;
        case RowTypeNote: {
            LSScheduleNoteCell *cell = [LSScheduleNoteCell getUITableViewCell:tableView];
            cell.contentLabel.text = self.noteContent;
            result = cell;
        }break;
        case RowTypeContent:{
            LSScheduleContentCell *cell = [LSScheduleContentCell getUITableViewCell:tableView];
            [cell setupData:self.item isInbox:self.isInBoxSheduleDetail];
            cell.contentDelegate = self;
            result = cell;
        }break;
        case RowTypeAction:{
            LSScheduleActionCell *cell = [LSScheduleActionCell getUITableViewCell:tableView];
            cell.actionDelegate = self;
            [cell updateMailScheduelUI:self.item];
            result = cell;
        }break;
        case RowTypeScheduleTips:{
            LSScheduleTipsCell *cell = [LSScheduleTipsCell getUITableViewCell:tableView];
            result = cell;
        }break;
        case RowTypeFoot:{
            LSScheduleFootCell *cell = [LSScheduleFootCell getUITableViewCell:tableView];
            cell.footCellDelegate = self;
            result = cell;
        }break;
        default:
            break;
    }
 

    return result;
}



#pragma mark - footCellDelegate
- (void)lsScheduleFootCellDidClickLink:(LSScheduleFootCell *)cell {
    NSURL *url = [[LiveUrlHandler shareInstance] createScheduleList:LiveUrlScheduleListTypePending];
    [[LiveModule module].serviceManager handleOpenURL:url];
}


- (void)lsScheduleFootCell:(LSScheduleFootCell *)cell didClickHowWork:(UIButton *)btn {
    self.perpaidInfoView = nil;
    [self.perpaidInfoView removeFromSuperview];
    self.perpaidInfoView = [[LSPrepaidInfoView alloc]init];
    [self.navigationController.view addSubview:self.perpaidInfoView];
}

#pragma mark - actionCellDelegate
- (void)lsScheduleActionCell:(LSScheduleActionCell *)cell didClickOther:(UIButton *)btn {
    // 获取中心点
    CGPoint buttonCenter = CGPointMake(btn.bounds.origin.x + btn.bounds.size.width/2,
                                              btn.bounds.origin.y + btn.bounds.size.height/2);

    // 获取在tableview上的相对位置
    CGPoint btnOrigin1 = [btn convertPoint:buttonCenter toView:self.tableView];
    
    // 在tableview上弹出对应弹层
    if (!self.otherOptionView) {
        LSOtherOptionView *otherOptionView = [LSOtherOptionView ohterOptionWithDelegate:self];
        CGRect frame = otherOptionView.frame;
        frame.origin.y = btnOrigin1.y - otherOptionView.frame.size.height ;
        otherOptionView.frame = frame;
        [self.tableView addSubview:otherOptionView];
        CGPoint center = otherOptionView.center;
        center.x = self.view.center.x;
        otherOptionView.center = center;
        self.otherOptionView = otherOptionView;

        [self addSingleTap];
    }
}


- (void)lsScheduleActionCell:(LSScheduleActionCell *)cell didAcceptSchedule:(UIButton *)btn {
    // 同意预约
    self.isReplyMail = NO;
    self.isAccept = YES;
    [self showLoading];
    [[LSPrePaidManager manager]sendAcceptScheduleInvite:self.item.scheduleInfo.inviteId duration:self.item.scheduleInfo.duration infoObj:nil];
}


- (void)lsScheduleActionCell:(LSScheduleActionCell *)cell didAcceptScheduleByReplyMail:(UIButton *)btn {
    // 同意预约并发邮件
    self.isReplyMail = YES;
    self.isAccept = YES;
    [self showLoading];
    [[LSPrePaidManager manager] sendAcceptScheduleInvite:self.item.scheduleInfo.inviteId duration:self.item.scheduleInfo.duration infoObj:nil];
}

- (void)onRecvSendAcceptSchedule:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg statusUpdateTime:(NSInteger)statusUpdateTime scheduleInviteId:(NSString *)inviteId duration:(int)duration roomInfoItem:(ImScheduleRoomInfoObject *)roomInfoItem {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoading];
        if (errnum == HTTP_LCC_ERR_SUCCESS) {
            [self getMailDetail:self.letterItem.letterId isUpdate:YES];
        }else {
            if (errnum == HTTP_LCC_ERR_SCHEDULE_NO_CREDIT) {
                [self showPurchaseCreditView];
            }else {
                [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            }

        }

    });
}

#pragma mark - lsOtherOptionViewDelegate

- (void)lsOtherOptionView:(LSOtherOptionView *)ohterOptionView sendMail:(UIButton *)sendMailBtn {
    self.otherOptionView = nil;
    // 发邮件
    [self sendMailAction];
}


- (void)lsOtherOptionView:(LSOtherOptionView *)ohterOptionView decline:(UIButton *)declineBtn {
    self.otherOptionView = nil;
    // 拒绝
    [[LSChooseDialog dialog] showDialog:self.navigationController.view cancelBlock:^{
        
    } actionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isReplyMail = NO;
            self.isAccept = NO;
            [self showLoading];
            [[LSPrePaidManager manager] sendDeclinedScheduleInvite:self.item.scheduleInfo.inviteId];
        });
        
    }];
    
}

- (void)lsOtherOptionView:(LSOtherOptionView *)ohterOptionView declineAndSendMail:(UIButton *)declineAndSendMailbtn {
    self.otherOptionView = nil;
    // 拒绝
    [[LSChooseDialog dialog] showDialog:self.navigationController.view cancelBlock:^{
        
    } actionBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            self.isReplyMail = YES;
            self.isAccept = NO;
            [self showLoading];
            [[LSPrePaidManager manager] sendDeclinedScheduleInvite:self.item.scheduleInfo.inviteId];
        });
        
    }];
//    [[LSPrePaidManager manager] sendDeclinedScheduleInvite:self.item.scheduleInfo.inviteId];
}

- (void)onRecvSendDeclinedSchedule:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg statusUpdateTime:(NSInteger)statusUpdateTime {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hideLoading];
        if (errnum == HTTP_LCC_ERR_SUCCESS) {
            // 重新更新状态
            [self getMailDetail:self.letterItem.letterId isUpdate:YES];
        }else {
            [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
        }
        
    });
}


- (void)lsDecelineDialogDecline:(LSDecelineDialog *)view {
    [self sendMailAction];
}

- (void)lsAcceptDiaglogAccept:(LSAcceptDiaglog *)view {
     [self sendMailAction];
}


- (void)sendMailAction {
    NSURL *url = [[LiveUrlHandler shareInstance] createSendmailByanchorId:self.item.anchorId anchorName:self.item.anchorNickName emfiId:self.item.letterId];
    [[LiveModule module].serviceManager handleOpenURL:url];
}

#pragma mark - 输入控件管理
- (void)addSingleTap {
    if (self.singleTap == nil) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeOtherOptionView)];
        [self.tableView addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if (self.singleTap) {
        [self.tableView removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
    }
}

- (void)closeOtherOptionView {
    [self removeSingleTap];
    [self.otherOptionView removeFromSuperview];
    self.otherOptionView = nil;
}
#pragma mark - prepaidDateView

- (void)lsScheduleContentCell:(LSScheduleContentCell *)cell didChooseTime:(UIButton *)btn {
    self.pickerView = [[LSPrePaidPickerView alloc]init];
    self.pickerView.delegate = self;
    [self.view.window addSubview:self.pickerView];
    for (int i = 0;i<[LSPrePaidManager manager].creditsArray.count;i++) {
        LSScheduleDurationItemObject * cItem = [LSPrePaidManager manager].creditsArray[i];
        if (cItem.duration == self.item.scheduleInfo.duration) {
            self.pickerView.selectTimeRow  = i;
        }
    }
    self.pickerView.items =  [[LSPrePaidManager manager] getCreditArray];
    [self.pickerView reloadData];
}



- (NSArray *)getPickerData:(UIButton *)button {
   
    NSMutableArray * array = [NSMutableArray array];
    for (LSScheduleDurationItemObject * item in [LSPrePaidManager manager].creditsArray) {
        NSString * str = [NSString stringWithFormat:@"%d Minutes - %0.2f Credits %0.2f Credits",item.duration,item.credit,item.originalCredit];
        NSString * str1 = [NSString stringWithFormat:@"%0.2f Credits",item.originalCredit];
        NSMutableAttributedString * attrStr =  [[LSPrePaidManager manager] newCreditsStr:str credits:str1];
        [array addObject:attrStr];
    }
    return array;
  
}


- (void)removePrePaidPickerView {
    [self.pickerView removeFromSuperview];
    self.pickerView = nil;
}

- (void)prepaidPickerViewSelectedRow:(NSInteger)row {
 
    [self.pickerView removeFromSuperview];
    self.pickerView = nil;
    LSScheduleDurationItemObject * item = [[LSPrePaidManager manager].creditsArray objectAtIndex:row];
    self.selectedDurationRow = row;
    self.item.scheduleInfo.duration = item.duration;
    int duration = item.duration;
    self.item.scheduleInfo.duration = duration;
    [self.tableView reloadData];
    
//    [self pickerViewSelectedRow:row];
}

- (void)updateCredits:(LSScheduleDurationItemObject *)item withCreditBtn:(UIButton *)btn{
    [LSPrePaidManager manager].duration = [NSString stringWithFormat:@"%d",item.duration];
    if (item.credit != item.originalCredit) {
          NSString * str = [NSString stringWithFormat:@"%d Minutes - %0.2f Credits %0.2f Credits",item.duration,item.credit,item.originalCredit];
             NSString * str1 = [NSString stringWithFormat:@"%0.2f Credits",item.originalCredit];
         NSMutableAttributedString * attrStr =  [[LSPrePaidManager manager] newCreditsStr:str credits:str1];
          [btn setAttributedTitle:attrStr forState:UIControlStateNormal];
    } else {
        NSString * str = [NSString stringWithFormat:@"%d Minutes - %0.2f Credits",item.duration,item.credit];
        NSMutableAttributedString * attrStr =  [[LSPrePaidManager manager] newCreditsStr:str credits:@""];
       [btn setAttributedTitle:attrStr forState:UIControlStateNormal];
    }
}

#pragma mark - UISCrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.otherOptionView removeFromSuperview];
    self.otherOptionView = nil;
  
    [self setupAlphaStatus:self.tableView];
    
}

// 设置透明状态
- (void)setupAlphaStatus:(UIScrollView *)scrollView {
    CGFloat navHeight = NavNormalHeight;

    if (IS_IPHONE_X) {
        navHeight = NavIphoneXHeight;
    }

    CGFloat per = scrollView.contentOffset.y / navHeight;
    if (scrollView.contentOffset.y >= navHeight) {
        [self setNeedsNavigationBackground:1];
    } else {
        [self setNeedsNavigationBackground:per];
    }
}

- (void)setNeedsNavigationBackground:(CGFloat)alpha {
    // 导航栏背景透明度设置
    [super setNavigationBackgroundAlpha:alpha];
    self.navTitleLabel.alpha = alpha;
}


- (void)backToAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
