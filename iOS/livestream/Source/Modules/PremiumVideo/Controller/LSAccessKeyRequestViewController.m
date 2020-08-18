//
//  LSAccessKeyRequestViewController.m
//  livestream
//
//  Created by Albert on 2020/7/29.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSAccessKeyRequestViewController.h"
#import "QNSementView.h"
#import "LSGetPremiumVideoKeyRequestListRequest.h"
#import "LSSessionRequestManager.h"
#import "LSPremiumRequestFooterView.h"
#import "LSRecommendPremiumVideoListRequest.h"
#import "LSGetPremiumVideoListRequest.h"
#import "LSAddInterestedPremiumVideoRequest.h"
#import "LSDeleteInterestedPremiumVideoRequest.h"
#import "DialogTip.h"
#import "LSPremiumVideoDetailViewController.h"
#import "AnchorPersonalViewController.h"
#import "LSRemindeSendPremiumVideoKeyRequest.h"
#import "LSSendPremiumVideoKeyRequest.h"
#import "LSMailDetailViewController.h"
#import "LSConfigManager.h"
#import "LSTipsDialogView.h"
#import "LiveWebViewController.h"
#define PageSize (20)

@interface LSAccessKeyRequestViewController ()<LSPremiumRequestTableViewDelegate,LSPremiumInterestViewDelegate, LSMailDetailViewControllerrDelegate>
@property (nonatomic, strong) NSMutableArray *items;
@property (strong, nonatomic) QNSementView *segment;
@property (nonatomic, assign) int page;
@property (nonatomic, assign) LSAccessKeyType type;
@property (nonatomic, strong) LSSessionRequestManager *sessionRequestManager;

@property (strong, nonatomic) LSPremiumInterestView *interestView;
@property (nonatomic, strong) NSMutableArray *interestItems;

@end

@implementation LSAccessKeyRequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.items = [NSMutableArray array];
    self.page = 0;
    self.type = LSACCESSKEYTYPES_REPLY;
    self.sessionRequestManager = [LSSessionRequestManager manager];
        
    self.interestItems = [NSMutableArray array];
    
    [self setupSubViews];
    [self setupTableView];
    //[self reloadData:YES];
}

-(void)setupSubViews
{
    [self.tipLabel setFont:[UIFont fontWithName:@"ArialMT" size:14]];
    [self.richLabel setFont:[UIFont fontWithName:@"ArialMT" size:14]];
    
    NSString *str = @"To get started,check the stunning videos and click on the   to send your requests.Go now.";
    NSMutableAttributedString *richText = [[NSMutableAttributedString alloc] initWithString:str];
    
    [richText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialMT" size:14] range:NSMakeRange(0, str.length)];
    [richText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:102/255.f green:102/255.f blue:102/255.f alpha:1] range:NSMakeRange(0, str.length)];
    
    [richText addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:[str  rangeOfString:@"Go now"]];//设置下划线
    [richText addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0 green:102/255.f blue:255./255.f alpha:1] range:[str rangeOfString:@"Go now"]];
    
    NSRange range = [str rangeOfString:@"click on the "];
    
    NSTextAttachment *attchment = [[NSTextAttachment alloc]init];
    attchment.image = [UIImage imageNamed:@"LS_Video_Tip_Key"];//设置图片
    CGFloat paddingTop = [self.richLabel font].lineHeight - [self.richLabel font].pointSize;
    attchment.bounds = CGRectMake(0,-paddingTop,[self.richLabel font].ascender,[self.richLabel font].ascender);
    
    NSAttributedString *string =
    [NSAttributedString attributedStringWithAttachment:(NSTextAttachment *)(attchment)];
    [richText insertAttributedString:string atIndex:range.location + range.length];//插入到第几个下标
    
    [richText addAttribute:NSLinkAttributeName value:@"GoNow://" range:[[richText string] rangeOfString:@"Go now"]];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    style.alignment = NSTextAlignmentCenter;
    [richText addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, str.length)];

    [self.richLabel setAttributedText:richText];
    
    CGRect rect = [richText boundingRectWithSize:CGSizeMake(self.richLabel.bounds.size.width, MAXFLOAT)
                                         options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    CGFloat height = ceil(rect.size.height);
    self.richLabelH.constant = height;
    
    [self.richLabel addTapGesture:self sel:@selector(richLabelTap:)];
    
    self.interestView = [[LSPremiumInterestView alloc] init];
    self.interestView.delegate = self;
    [self.interestView setHidden:YES];
    [self.view addSubview:self.interestView];
    [self.interestView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lineView.mas_bottom).offset = 20;
        make.left.right.bottom.equalTo(self.view);
    }];
    
    //顶部按钮控件
    self.topButtonsView.layer.masksToBounds = YES;
    self.topButtonsView.layer.cornerRadius = self.topButtonsView.bounds.size.height/2;
    self.topButtonsView.layer.borderWidth= 0.5f;
    self.topButtonsView.layer.borderColor = Color(186, 209, 231, 1).CGColor;
    
    [self.segmentRightBtn.titleLabel setFont:[UIFont fontWithName:@"ArialMT" size:14]];
    [self.segmentRightBtn setTitleColor:[UIColor colorWithRed:56/255.0 green:56/255.0 blue:56/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.segmentRightBtn setTitleColor:[UIColor colorWithRed:56/255.0 green:56/255.0 blue:56/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.segmentRightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    
    [self.segmentLeftBtn.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:14]];
    [self.segmentLeftBtn setTitleColor:[UIColor colorWithRed:56/255.0 green:56/255.0 blue:56/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.segmentLeftBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
}


- (void)setupTableView {
    // 初始化下拉
    [self.listTableView setupPullRefresh:self pullDown:YES pullUp:YES];
    
    self.listTableView.backgroundView = nil;
    self.listTableView.showsVerticalScrollIndicator = NO;
    self.listTableView.showsHorizontalScrollIndicator = NO;
    self.listTableView.tableViewDelegate = self;
    //self.collectionHeight.constant = collectionViewHeight;
    //self.collectionView.recommendDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (@available(iOS 11, *)) {
        self.listTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    if (self.items.count == 0) {
        [self.listTableView startLSPullDown:YES];
    }
}

-(void)showNoDataView:(BOOL)show
{
    if (show) {
        [self.tipLabel setHidden:NO];
        [self.richLabel setHidden:NO];
        [self.lineView setHidden:NO];
        [self.nodataImgView setHidden:NO];
        if (self.interestItems.count == 0) {
            [self getInterestList];
        }else{
            [self.interestView setHidden:NO];
        }
    }else{
        [self.tipLabel setHidden:YES];
        [self.richLabel setHidden:YES];
        [self.lineView setHidden:YES];
        [self.nodataImgView setHidden:YES];
        [self.interestView setHidden:YES];
    }
}

- (void)reloadInterestData{
    if (self.items.count == 0 && self.interestItems.count > 0) {
        [self.interestView setHidden:NO];
        [self.interestView setItemsArray:self.interestItems];
    }else{
        [self.interestView setHidden:YES];
    }
    [self.interestView reloadData];
}
- (void)reloadData:(BOOL)isReload {
    //[self.items removeAllObjects];//测试空数据
    if (self.items.count == 0) {
        [self showNoDataView:YES];
    }else {
        [self showNoDataView:NO];
    }

    self.listTableView.items = self.items;
    self.listTableView.type = self.type;
    if (isReload) {
        [self.listTableView reloadData];
    }
    
    if (self.items.count == 0) {
        [self getInterestList];
    }
}

-(void)richLabelTap:(UITapGestureRecognizer *)tap
{
    NSLog(@"richLabelTap------------");
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)gotoMailDetail:(LSPremiumVideoAccessKeyItemObject *)item
{
    LSMailDetailViewController *vc = [[LSMailDetailViewController alloc] initWithNibName:nil bundle:nil];
    vc.mailIndex = (int)[self.items indexOfObject:item];
    LSHttpLetterListItemObject *letterItem = [[LSHttpLetterListItemObject alloc] init];
    letterItem.anchorAvatar = item.premiumVideoInfo.anchorAvatarImg;
    letterItem.anchorId = item.premiumVideoInfo.anchorId;
    letterItem.anchorNickName = item.premiumVideoInfo.anchorNickname;
    letterItem.onlineStatus = item.premiumVideoInfo.onlineStatus;
    letterItem.letterId = item.emfId;
    letterItem.hasKey = YES;
    letterItem.letterSendTime = item.lastSendTime;
    vc.letterItem = letterItem;
    vc.mailDetailDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 顶部导航tab 回调 (QNSementViewDelegate)
-(IBAction)segmentBtnOnClicked:(UIButton *)sender
{
    sender.selected = YES;
    if (sender.tag == 1) {
        [self.segmentRightBtn setSelected:NO];
        self.type = LSACCESSKEYTYPES_REPLY;
        
        [self.segmentRightBtn.titleLabel setFont:[UIFont fontWithName:@"ArialMT" size:14]];
        [self.segmentLeftBtn.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:14]];
    }else{
        [self.segmentLeftBtn setSelected:NO];
        self.type = LSACCESSKEYTYPE_UNREPLY;
        
        [self.segmentLeftBtn.titleLabel setFont:[UIFont fontWithName:@"ArialMT" size:14]];
        [self.segmentRightBtn.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:14]];
    }
    [self.listTableView startLSPullDown:YES];
}

- (void)addItemIfNotExist:(LSSayHiResponseListItemObject *_Nonnull)itemNew {
    bool bFlag = NO;
    
    for (LSSayHiResponseListItemObject *item in self.items) {
        if ([item.responseId isEqualToString:itemNew.responseId]) {
            // 已经存在
            bFlag = true;
            break;
        }
    }
    
    if (!bFlag) {
        // 不存在
        [self.items addObject:itemNew];
    }
}

#pragma mark 数据加载
-(BOOL)getInterestList
{
    LSRecommendPremiumVideoListRequest *request = [[LSRecommendPremiumVideoListRequest alloc] init];
    request.num = 2;
    self.interestView.userInteractionEnabled = NO;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int num, NSArray<LSPremiumVideoinfoItemObject *> *array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@::getInterestList (请求 LSGetPremiumVideoListRequest 列表 success : %@, errnum : %d, errmsg : %@)",[self  class],BOOL2SUCCESS(success), errnum, errmsg);
            self.interestView.userInteractionEnabled = YES;
            if (success) {
                // 清空列表
                [self.interestItems removeAllObjects];
                
                for (LSPremiumVideoinfoItemObject *itemObj in array) {
                    //[self addItemIfNotExist:itemObj];
                    [self.interestItems addObject:itemObj];
                }
                
                if (self.interestItems.count > 0) {
                    //有数据
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        //显示感兴趣的页面
                        [self reloadInterestData];
                    });
                }
            }else {
                [self.interestItems removeAllObjects];
                [self reloadInterestData];
            }
        });
    };
    BOOL bFlag = [self.sessionRequestManager sendRequest:request];
    return bFlag;
}

- (void)getListRequest:(BOOL)refresh {
    NSLog(@"%@::getListRequest( refresh : %@ )", [self class],BOOL2YES(refresh));
    int start = 0;
    if (refresh) {
        // 刷最新
        start = 0;
        self.page = 0;
    } else {
        // 刷更多
        start = self.page * PageSize;
    }
        
    LSGetPremiumVideoKeyRequestListRequest *request = [[LSGetPremiumVideoKeyRequestListRequest alloc] init];
    request.type = self.type;
    request.start = start;
    request.step = PageSize;
    
    self.view.userInteractionEnabled = NO;
    
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, int totalCount, NSArray<LSPremiumVideoAccessKeyItemObject *> *array){
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@::getListRequest (请求 LSGetPremiumVideoKeyRequestListRequest 列表 success : %@, errnum : %d, errmsg : %@)",[self  class],BOOL2SUCCESS(success), errnum, errmsg);

            if (success) {
                if (refresh) {
                    // 停止头部
                    [self.listTableView finishLSPullDown:YES];
                    // 清空列表
                    [self.items removeAllObjects];
                    self.page = 1;
                } else {
                    // 停止底部
                    [self.listTableView finishLSPullUp:YES];
                    self.page++;
                }
                
                for (LSPremiumVideoAccessKeyItemObject *itemObj in array) {
                    [self.items addObject:itemObj];
                }
                [self reloadData:YES];
                
                if (refresh) {
                    if (self.items.count > 0) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            // 拉到最顶
                            [self.listTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        });
                    }
                }
                
            }else {
                //加载失败
                if (refresh) {
                    // 停止头部
                    [self.listTableView finishLSPullDown:NO];
                    [self.items removeAllObjects];
                    [self showNoDataView:YES];
                } else {
                    // 停止底部
                    [self.listTableView finishLSPullUp:YES];
                }
                
                [self reloadData:YES];
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.view.userInteractionEnabled = YES;
            });
        });
    };
    [self.sessionRequestManager sendRequest:request];
}

- (void)addInterestedRequest:(LSPremiumVideoinfoItemObject *)item{
    NSLog(@"%@::addInterestedRequest:%@", [self class],item.videoId);
    
    self.interestView.userInteractionEnabled = NO;
    
    LSAddInterestedPremiumVideoRequest *request = [[LSAddInterestedPremiumVideoRequest alloc] init];
    request.videoId = item.videoId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *videoId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@::(请求 AddInterestedPremiumVideoRequest success : %@, errnum : %d, errmsg : %@)",[self  class],BOOL2SUCCESS(success), errnum, errmsg);

            if (success) {
                for (LSPremiumVideoAccessKeyItemObject *itemObj in self.items) {
                    if ([itemObj.premiumVideoInfo.videoId isEqual:item.videoId]) {
                        itemObj.premiumVideoInfo.isInterested = YES;
                    }
                }
                [self reloadData:YES];
            }else {
                //加载失败
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                self.interestView.userInteractionEnabled = YES;
            });
        });
    };
    [self.sessionRequestManager sendRequest:request];
}

- (void)lsMailDetailViewController:(LSMailDetailViewController *)vc haveReadMailDetailMail:(LSHttpLetterListItemObject *)model index:(int)index
{
    //已读邮件后更新状态
    NSLog(@"%@ haveReadMailDetailMail model:%@,index=%d", [self class],model,index);
    //letterItem.letterId = item.emfId;
    NSInteger rowNumber = NSNotFound;
    for (LSPremiumVideoAccessKeyItemObject *item in self.items) {
        if ([item.emfId isEqualToString:model.letterId]) {
            rowNumber = [self.items indexOfObject:item];
            item.emfReadStatus = YES;
            break;
        }
    }
    [self.listTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:rowNumber inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
//    [self.listTableView reloadData];
    //通知更新顶部未读标识
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kUpdateUnreadCountNotification" object:nil];
}
#pragma mark - LSPremiumRequestTableViewDelegate
- (void)tableView:(LSPremiumRequestTableView *)tableView didSelectPremiumRequestDetail:(LSPremiumVideoinfoItemObject *)item
{
    //点击列表
    //LSPremiumVideoinfoItemObject * obj = [self.items objectAtIndex:row];
    if (item == nil) {
        //点击了提示语
    }else{
        LSPremiumVideoDetailViewController * vc = [[LSPremiumVideoDetailViewController alloc]initWithNibName:nil bundle:nil];
        vc.womanId = item.anchorId;
        vc.videoId = item.videoId;
        vc.videoTitle = item.title;
        vc.videoSubTitle = item.describe;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)tableView:(LSPremiumRequestTableView *)tableView didCollectPremiumRequestDetail:(NSInteger)index
{
    LSPremiumVideoAccessKeyItemObject *item = [self.items objectAtIndex:index];
    if (item.premiumVideoInfo.isInterested) {
        //取消收藏
        LSDeleteInterestedPremiumVideoRequest *request = [[LSDeleteInterestedPremiumVideoRequest alloc] init];
        request.videoId = item.premiumVideoInfo.videoId;
        [self showLoading];
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *videoId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@::(请求 LSDeleteInterestedPremiumVideoRequest success : %@, errnum : %d, errmsg : %@)",[self  class],BOOL2SUCCESS(success), errnum, errmsg);

                [self hideLoading];
                if (success) {
                    for (LSPremiumVideoAccessKeyItemObject *itemObj in self.items) {
                        if ([itemObj.premiumVideoInfo.videoId isEqual:item.premiumVideoInfo.videoId]) {
                            itemObj.premiumVideoInfo.isInterested = NO;
                        }
                    }
                    //[self reloadData:YES];
                    [self.listTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }else{
                    [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
                }
            });
        };
        [self.sessionRequestManager sendRequest:request];
    }else{
        //添加收藏
        LSAddInterestedPremiumVideoRequest *request = [[LSAddInterestedPremiumVideoRequest alloc] init];
        request.videoId = item.premiumVideoInfo.videoId;
        [self showLoading];
        request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *videoId) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@::(请求 LSAddInterestedPremiumVideoRequest success : %@, errnum : %d, errmsg : %@)",[self  class],BOOL2SUCCESS(success), errnum, errmsg);

                [self hideLoading];
                if (success) {
                    for (LSPremiumVideoAccessKeyItemObject *itemObj in self.items) {
                        if ([itemObj.premiumVideoInfo.videoId isEqual:item.premiumVideoInfo.videoId]) {
                            itemObj.premiumVideoInfo.isInterested = YES;
                        }
                    }
//                    [self reloadData:YES];
                    [self.listTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }else{
                    [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
                }
            });
        };
        [self.sessionRequestManager sendRequest:request];
    }
}

- (void)tableView:(LSPremiumRequestTableView *)tableView didViewAllPremiumRequestDetail:(NSInteger)index
{
    if (self.type == LSACCESSKEYTYPES_REPLY) {
        //已回复
        LSPremiumVideoAccessKeyItemObject *item = [self.items objectAtIndex:index];
        if (!item.emfReadStatus) {
            //未读
            NSString *creditTips = [[NSUserDefaults standardUserDefaults] objectForKey:@"Mail_CreditTips"];
            if (creditTips != nil) {
                [self gotoMailDetail:item];
            }else {
                NSString *msg = [NSString stringWithFormat:@"%.0f stamp (or %.1f credits) will be deducted from your account to open this mail, do you wish to continue?",[LSConfigManager manager].item.mailTariff.mailReadBase.stampPrice,[LSConfigManager manager].item.mailTariff.mailReadBase.creditPrice];
                UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Continue" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self gotoMailDetail:item];
                }];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Later" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alertVc addAction:cancelAction];
                [alertVc addAction:okAction];
                [self presentViewController:alertVc animated:YES completion:nil];
            }
        }else {
            [self gotoMailDetail:item];
        }
    }else if (self.type == LSACCESSKEYTYPE_UNREPLY){
        //未回复
        LSPremiumVideoAccessKeyItemObject * item = [self.items objectAtIndex:index];
        NSInteger currentTime = [[NSDate date] timeIntervalSince1970];
        currentTime = item.currentTime>currentTime?item.currentTime:currentTime;
        if (currentTime-item.lastSendTime>24*60*60) {
            //已超过24小时，可再次请求
            LSRemindeSendPremiumVideoKeyRequest *request = [[LSRemindeSendPremiumVideoKeyRequest alloc] init];
            request.requestId = item.requestId;
//            self.view.userInteractionEnabled = NO;
            [self showLoading];
            request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *requestId, NSInteger currentTime, int limitSeconds){
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@::(请求 LSRemindeSendPremiumVideoKeyRequest success : %@, errnum : %d, errmsg : %@)",[self  class],BOOL2SUCCESS(success), errnum, errmsg);

                    if (success || 17615 == errnum) {
                        //17615 表示在其他断已提醒，也以成功提醒为结果
                        NSInteger index = NSNotFound;
                        for (LSPremiumVideoAccessKeyItemObject *itemObj in self.items) {
                            if ([itemObj.requestId isEqual:requestId]) {
                                itemObj.currentTime = currentTime;
                                itemObj.lastSendTime = currentTime;
                                index = [self.items indexOfObject:itemObj];
                                break;
                            }
                        }
                        [self.listTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                            self.view.userInteractionEnabled = YES;
                            [self hideLoading];
                            [[LSTipsDialogView tipsDialogView] showDialogTip:self.view tipText:@"Reminder sent!"];
                        });
                        
                    }else{
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self hideLoading];
                            [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
                        });
                    }
                });
            };
            [self.sessionRequestManager sendRequest:request];
        }else{
            NSInteger seconds =  (24*60*60) - (currentTime-item.lastSendTime);
            NSString *msg = @"";
            if (seconds < 60 * 60 * 2) {
                //小于2小时
                msg = [NSString stringWithFormat:@"You can send a reminder %ld minutes later.",(long)(seconds/60)];
            }else{
                msg = [NSString stringWithFormat:@"You can send a reminder %ld hours later.",(long)(seconds/3600)];
            }
            [[DialogTip dialogTip] showDialogTip:self.view tipText:msg];
        }
    }
}

- (void)tableView:(LSPremiumRequestTableView *)tableView didUserHeadPremiumRequestDetail:(NSInteger)index
{
    LSPremiumVideoAccessKeyItemObject * item = [self.items objectAtIndex:index];
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = item.premiumVideoInfo.anchorId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
}
-(void)didSelectInterestItemWithIndex:(NSInteger)row
{
    //进入视频详情
    LSPremiumVideoinfoItemObject * obj = [self.interestItems objectAtIndex:row];
    LSPremiumVideoDetailViewController * vc = [[LSPremiumVideoDetailViewController alloc]initWithNibName:nil bundle:nil];
    vc.womanId = obj.anchorId;
    vc.videoId = obj.videoId;
    vc.videoTitle = obj.title;
    vc.videoSubTitle = obj.describe;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)didSelectInterestHeadViewItemWithIndex:(NSInteger)row
{
    LSPremiumVideoinfoItemObject * item = [self.interestItems objectAtIndex:row];
    AnchorPersonalViewController *listViewController = [[AnchorPersonalViewController alloc] initWithNibName:nil bundle:nil];
    listViewController.anchorId = item.anchorId;
    listViewController.enterRoom = 1;
    [self.navigationController pushViewController:listViewController animated:YES];
}

-(void)didTapTipLabel{
    //点击前往公告介绍页面
    NSLog(@"点击前往公告介绍页面");
    NSString *url = [LSConfigManager manager].item.howItWorkUrl;
    LSWKWebViewController *webViewController = [[LSWKWebViewController alloc] initWithNibName:nil bundle:nil];
    UILabel * titleLab = [[UILabel alloc] init];
    titleLab.textColor = COLOR_WITH_16BAND_RGB(0x383838);
    titleLab.text = @"How Premium Videos works";
    titleLab.font = [UIFont systemFontOfSize:17.0];
    webViewController.navigationItem.titleView = titleLab;
    webViewController.requestUrl = url;
    webViewController.isShowTaBar = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - 上下拉
- (void)pullDownRefresh {
    self.view.userInteractionEnabled = NO;
    [self getListRequest:YES];
}

- (void)pullUpRefresh {
    self.view.userInteractionEnabled = NO;
    [self getListRequest:NO];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
