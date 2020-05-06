//
//  LSPushNoticeViewController.m
//  livestream
//
//  Created by test on 2018/9/25.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSPushNoticeViewController.h"
#import "LSPushSettingTableViewCell.h"
#import "LSGetPushConfigRequest.h"
#import "LSSetPushConfigRequest.h"
#import "LSSessionRequestManager.h"
#import "LiveModule.h"
#import "DialogIconTips.h"
#import "DialogTip.h"

#define ROW_TYPE @"ROW_TYPE"
#define ROW_SIZE @"ROW_SIZE"
typedef enum {
    RowTypePrivateMsg,
    RowTypeMail,
    RowTypeSayHi,
} RowType;
@interface LSPushNoticeViewController ()<UITableViewDataSource,UITableViewDelegate,LSPushSettingTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UIButton *openSettingBtn;
@property (weak, nonatomic) IBOutlet UIView *turnOnNoticeTipView;
@property (weak, nonatomic) IBOutlet LSTableView *tableView;
@property (nonatomic, copy) NSArray* tableViewArray;
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
/** isPriMsgAppPush */
@property (nonatomic, assign) BOOL isPriMsgAppPush;
/** isMailAppPush */
@property (nonatomic, assign) BOOL isMailAppPush;
/** isSayHiAppPush */
@property (nonatomic, assign) BOOL isSayHiAppPush;

@end

@implementation LSPushNoticeViewController

- (void)initCustomParam {
    [super initCustomParam];
    self.navigationItem.title = NSLocalizedString(@"Push Notifications", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.openSettingBtn.layer.cornerRadius = 22;
    self.openSettingBtn.layer.masksToBounds = YES;
    self.sessionManager = [LSSessionRequestManager manager];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)reloadData:(BOOL)isReload {
    // 主tableView
    NSMutableArray *array = [NSMutableArray array];
    
    NSMutableDictionary *dictionary = nil;
    CGSize viewSize;
    NSValue *rowSize;
    
    // 图片
//    dictionary = [NSMutableDictionary dictionary];
//    viewSize = CGSizeMake(self.tableView.frame.size.width,[LSPushSettingTableViewCell cellHeight]);
//    rowSize = [NSValue valueWithCGSize:viewSize];
//    [dictionary setValue:rowSize forKey:ROW_SIZE];
//    [dictionary setValue:[NSNumber numberWithInteger:RowTypePrivateMsg] forKey:ROW_TYPE];
//    [array addObject:dictionary];
    
    // 邮件
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [LSPushSettingTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeMail] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    // sayhi
    dictionary = [NSMutableDictionary dictionary];
    viewSize = CGSizeMake(self.tableView.frame.size.width, [LSPushSettingTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeSayHi] forKey:ROW_TYPE];
    [array addObject:dictionary];
    
    
    self.tableViewArray = array;
    if (isReload) {
        [self.tableView reloadData];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[UIApplication sharedApplication] currentUserNotificationSettings].types  == UIUserNotificationTypeNone) {
        self.turnOnNoticeTipView.hidden = NO;
    }else {
//        [self reloadData:YES];
        [self getPushConfig];
    }
}

- (IBAction)openSettingAction:(id)sender {
    CGFloat currentVersion =  [UIDevice currentDevice].systemVersion.floatValue;
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if (currentVersion >= 10.0) {
        if( [[UIApplication sharedApplication] canOpenURL:url] ) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL  success) {
                
            }];
            
        }
    }else if (currentVersion >= 8.0) {
        if( [[UIApplication sharedApplication] canOpenURL:url] ) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }

}


#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        number = self.tableViewArray.count;
    }
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    
    if([tableView isEqual:self.tableView]) {
        // 主tableview
        NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
        CGSize viewSize;
        NSValue *value = [dictionarry valueForKey:ROW_SIZE];
        [value getValue:&viewSize];
        height = viewSize.height;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
    
    // 大小
    CGSize viewSize;
    NSValue *value = [dictionarry valueForKey:ROW_SIZE];
    [value getValue:&viewSize];
    
    // 类型
    RowType type = (RowType)[[dictionarry valueForKey:ROW_TYPE] intValue];
    LSPushSettingTableViewCell *cell = [LSPushSettingTableViewCell getUITableViewCell:tableView];
    cell.pushSettingDelegate = self;
    switch (type) {
        case RowTypePrivateMsg:{
            cell.pushSettingTitle.text = @"Private Messages";
            cell.pushSwitch.on = self.isPriMsgAppPush;
        }break;
        case RowTypeMail: {
            cell.pushSettingTitle.text = @"Mails from CharmLive";
            cell.pushSwitch.on = self.isMailAppPush;
        }break;
        case RowTypeSayHi:{
            cell.pushSettingTitle.text = @"New Say Hi Response";
            cell.pushSwitch.on = self.isSayHiAppPush;
        }break;
        default:
            break;
    }
    result = cell;
    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (void)lsPushSettingTableViewCellDelegate:(LSPushSettingTableViewCell *)cell didChangeStatus:(UISwitch *)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
    // 类型
    RowType type = (RowType)[[dictionarry valueForKey:ROW_TYPE] intValue];
    switch (type) {
        case RowTypePrivateMsg:{
            [self setPushPrivateMessage:sender.isOn];
        }break;
        case RowTypeMail:{
            [self setupPushMail:sender.isOn];
        }break;
        case RowTypeSayHi: {
            [self setupPushSayHi:sender.isOn];
        }break;
        default:
            break;
    }

}


/**
 获取推送配置

 @return 是否成功
 */
- (BOOL)getPushConfig {
    LSGetPushConfigRequest *request = [[LSGetPushConfigRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSAppPushConfigItemObject *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.isPriMsgAppPush = item.isPriMsgAppPush;
                self.isMailAppPush = item.isMailAppPush;
                self.isSayHiAppPush = item.isSayHiAppPush;
                [self reloadData:YES];
            }else {
                [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            }
        });
    };
    

    return [self.sessionManager sendRequest:request];
}


/**
 设置推送配置

 @param isPush 是否推送
 @return 是否成功
 */
- (BOOL)setPushPrivateMessage:(BOOL)isPush {
    if (isPush) {
        [[LiveModule module].analyticsManager reportActionEvent:TurnOnMessagePush eventCategory:EventCategoryMessage];
    }else {
        [[LiveModule module].analyticsManager reportActionEvent:TurnOffMessagePush eventCategory:EventCategoryMessage];
    }
    LSSetPushConfigRequest *request = [[LSSetPushConfigRequest alloc] init];
    request.isPriMsgAppPush = isPush;
    request.isMailAppPush = self.isMailAppPush;
    request.isSayHiAppPush = self.isSayHiAppPush;
    [self showLoading];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                self.isPriMsgAppPush = isPush;
                [[DialogIconTips dialogIconTips] showDialogIconTips:self.view tipText:@"Done" tipIcon:nil];
            }else {
                [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            }
            [self reloadData:YES];
        });

    };
    
    
    return [self.sessionManager sendRequest:request];
}


/**
 设置邮件推送配送

 @param isPush 是否推送
 @return 是否成功
 */
- (BOOL)setupPushMail:(BOOL)isPush {
    if (isPush) {
        [[LiveModule module].analyticsManager reportActionEvent:TurnOnNewMailPush eventCategory:EventCategoryMail];
    }else {
        [[LiveModule module].analyticsManager reportActionEvent:TurnOffNewMailPush eventCategory:EventCategoryMail];
    }
    LSSetPushConfigRequest *request = [[LSSetPushConfigRequest alloc] init];
    request.isMailAppPush = isPush;
    request.isPriMsgAppPush = self.isMailAppPush;
    request.isSayHiAppPush = self.isSayHiAppPush;
    [self showLoading];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                self.isMailAppPush = isPush;
                [[DialogIconTips dialogIconTips] showDialogIconTips:self.view tipText:@"Done" tipIcon:nil];
            }else {
                [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            }
            [self reloadData:YES];
        });
    };
    
    
    return [self.sessionManager sendRequest:request];
}



/**
 设置sayhi推送

 @param isPush 是否推送
 @return 是否成功
 */
- (BOOL)setupPushSayHi:(BOOL)isPush {
    LSSetPushConfigRequest *request = [[LSSetPushConfigRequest alloc] init];
    request.isMailAppPush = self.isMailAppPush;
    request.isPriMsgAppPush = self.isMailAppPush;
    request.isSayHiAppPush = isPush;
    [self showLoading];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                self.isSayHiAppPush = isPush;
                [[DialogIconTips dialogIconTips] showDialogIconTips:self.view tipText:@"Done" tipIcon:nil];
            }else {
                [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            }
            [self reloadData:YES];
        });
    };
    
    
    return [self.sessionManager sendRequest:request];
}
@end
