//
//  LSSeclectSendScheduleViewController.m
//  livestream
//
//  Created by test on 2020/4/2.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSSeclectSendScheduleViewController.h"
#import "GetContactListRequest.h"
#import "LSSessionRequestManager.h"
#import "GetFollowListRequest.h"
#import "LSTypeSegment.h"
#import "LSRecipientCell.h"
#import "LSRecepientItem.h"
#import "LSGetUserInfoRequest.h"
#import "LSConfigManager.h"
#import "LSSendScheduleViewController.h"
#import "LiveModule.h"
#import "LSPrepaidInfoView.h"
#import "LSShadowView.h"
#import "LiveUrlHandler.h"
#define PageSize 20
typedef enum : NSUInteger {
    SegmentTypeContact = 0,
    SegmentTypeFollow,
} SegmentType;

@interface LSSeclectSendScheduleViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITextFieldDelegate,LSTypeSegmentDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITextField *anchorTextField;
@property (weak, nonatomic) IBOutlet UILabel *wrongTipsNote;
@property (nonatomic, copy) NSArray *items;
@property (weak, nonatomic) IBOutlet UIView *recipientView;
@property (nonatomic, strong) LSTypeSegment *segment;
@property (weak, nonatomic) IBOutlet UIView *topSegmentView;
@property (nonatomic, strong) NSMutableArray *recepientItems;
@property (weak, nonatomic) IBOutlet UILabel *emptyTips;
/** 主播id */
@property (nonatomic, copy) NSString *anchorId;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet UILabel *dicountTips;
@property (weak, nonatomic) IBOutlet UIButton *howItWorkBtn;
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;
@property (nonatomic, assign) SegmentType type;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerDistance;
@property (weak, nonatomic) IBOutlet UILabel *requestTips;
@property (weak, nonatomic) IBOutlet UILabel *cardTitle;
/** 刷新中 */
@property (nonatomic, assign) BOOL isRefresh;
@property (nonatomic, strong) LSPrepaidInfoView * perpaidInfoView;
/** 选中的索引 */
@property (nonatomic, assign) int selectIndex;
@end

@implementation LSSeclectSendScheduleViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initCustomParam {
    [super initCustomParam];
    self.isShowNavBar = NO;
    self.isRefresh = YES;
    self.selectIndex = -99;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
    
    self.anchorTextField.layer.borderColor = COLOR_WITH_16BAND_RGB(0xDCDCDC).CGColor;
    self.anchorTextField.layer.borderWidth = 1;
    self.anchorTextField.delegate = self;
    UINib *nib = [UINib nibWithNibName:@"LSRecipientCell" bundle:[LiveBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[LSRecipientCell cellIdentifier]];
    self.recepientItems = [NSMutableArray array];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.recipientView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xD8D8D8).CGColor;
    self.recipientView.layer.borderWidth = 1;
    self.recipientView.layer.masksToBounds = YES;
    self.recipientView.layer.cornerRadius = 4.0f;
    
    self.cardTitle.layer.shadowColor = [UIColor blackColor].CGColor;
    self.cardTitle.layer.shadowOffset = CGSizeMake(0, 1);
    self.cardTitle.layer.shadowOpacity = 0.5;
    
    self.continueBtn.layer.cornerRadius = self.continueBtn.frame.size.height * 0.5f;
    self.continueBtn.layer.masksToBounds = YES;
    
    LSShadowView *shadow = [[LSShadowView alloc] init];
    [shadow showShadowAddView:self.continueBtn];
    
    self.contentView.layer.cornerRadius = 8;
    self.contentView.layer.masksToBounds = YES;
    
    UIFont *font = [UIFont systemFontOfSize:14];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:14];
    if (screenSize.width == 320) {
        font = [UIFont systemFontOfSize:12];
        boldFont = [UIFont boldSystemFontOfSize:12];
    }
    NSString *title = [NSString stringWithFormat:@"Send a Schedule One-on-One request, have your One-on-One organized and save up to %d%% of credits!",[LSConfigManager manager].item.scheduleSaveUp];
    NSMutableAttributedString *atts = [[NSMutableAttributedString alloc] initWithString:title attributes:@{
        NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x383838),
        NSFontAttributeName : font,
        
    }];
    NSRange timeRange = [title rangeOfString:[NSString stringWithFormat:@"save up to %d%%",[LSConfigManager manager].item.scheduleSaveUp]];
    [atts addAttributes:@{
        NSForegroundColorAttributeName : [UIColor redColor],
        NSFontAttributeName : boldFont,
    } range:timeRange];
    self.dicountTips.attributedText = atts;
    self.requestTips.font = font;
    
    NSString *howItWorkTitle = @"Learn how Schedule One-on-One works";
    NSMutableAttributedString *howItWorkTitleAtts = [[NSMutableAttributedString alloc] initWithString:howItWorkTitle attributes:@{
        NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle],
        NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x999999)
    }];
    [self.howItWorkBtn setAttributedTitle:howItWorkTitleAtts forState:UIControlStateNormal];
    
    self.retryBtn.hidden = YES;
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)setupSegmentView {
    // 创建分栏控件
    NSArray *title = @[NSLocalizedStringFromSelf(@"My Contact List"), NSLocalizedStringFromSelf(@"My Follows")];
    self.segment = [[LSTypeSegment alloc] initWithNumberOfTitles:title andFrame:CGRectMake(0, 0, self.topSegmentView.frame.size.width, 28) andSetting:[[LSSegmentItem alloc] init] delegate:self isSymmetry:YES];
    
    [self.topSegmentView addSubview:self.segment];
    
}


- (IBAction)continueAction:(id)sender {
    // 如果输入了内容则优先检测是否存在
    if (self.anchorTextField.text.length > 0) {
        self.anchorId = self.anchorTextField.text;
        [self checkAnchorExist:self.anchorId];
    }else {
        // 没输入内容,选择了指定主播则直接跳转
        if (self.anchorId.length > 0) {
            self.continueBtn.userInteractionEnabled = NO;
            NSURL * url = [[LiveUrlHandler shareInstance] createUrlToSendScheduleMail:self.anchorId];
            [[LiveModule module].serviceManager handleOpenURL:url];
        }else {
            // 否则显示未输入内容错误提示
            self.wrongTipsNote.hidden = NO;
        }
    }
}

- (IBAction)workNoteAction:(id)sender {
    self.perpaidInfoView = nil;
    [self.perpaidInfoView removeFromSuperview];
    self.perpaidInfoView = [[LSPrepaidInfoView alloc]init];
    [self.navigationController.view addSubview:self.perpaidInfoView];
}

- (IBAction)retryAction:(id)sender {
    switch (self.type) {
        case SegmentTypeContact:{
            self.retryBtn.hidden = YES;
            [self getContactListData];
        }break;
        case SegmentTypeFollow:{
            self.retryBtn.hidden = YES;
            [self getListRequest:NO];
        }break;
        default:
            break;
    }
}

- (void)showScheduleView:(UIViewController *)vc {
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [vc addChildViewController:self];
    [vc.view addSubview:self.view];
    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(vc.view);
    }];
    [self.view layoutIfNeeded];
    [self setupSegmentView];
    [self segmentControlSelectedTag:0];
}

- (void)segmentControlSelectedTag:(NSInteger)tag {
    self.selectIndex = -99;
    self.emptyTips.hidden = YES;
    self.retryBtn.hidden = YES;
    if (tag == 0) {
        self.type = SegmentTypeContact;
        [self getContactListData];
    }else {
        self.type = SegmentTypeFollow;
        [self getListRequest:NO];
    }
}

- (void)reloadCollectionViewData {
    

    [self.collectionView reloadData];
    
}

#pragma mark - 接口
- (void)checkAnchorExist:(NSString *)anchorId {
    [self showLoading];
    LSGetUserInfoRequest *request = [[LSGetUserInfoRequest alloc] init];
    request.userId = anchorId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, LSUserInfoItemObject *userInfoItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                NSLog(@"LSSeclectSendScheduleViewController::getUserInfoWithRequest( userId : %@, nickName : %@, photoUrl : %@ )", userInfoItem.userId, userInfoItem.nickName, userInfoItem.photoUrl);
                NSURL * url = [[LiveUrlHandler shareInstance] createUrlToSendScheduleMail:self.anchorId];
                [[LiveModule module].serviceManager handleOpenURL:url];
            }else {
                self.wrongTipsNote.hidden = NO;
            }
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}


- (void)getContactListData {
    GetContactListRequest * request = [[GetContactListRequest alloc]init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSArray<LSRecommendAnchorItemObject *> *array, int totalCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSeclectSendScheduleViewController::getContactListData %@,%ld", BOOL2SUCCESS(success), (long)array.count);
            if (success) {
                NSMutableArray *recepientArray = [NSMutableArray array];
                
                for (LSRecommendAnchorItemObject *item in array) {
                    LSRecepientItem *recepientItem = [[LSRecepientItem alloc] init];
                    recepientItem.anchorPhoto = item.anchorAvatar;
                    recepientItem.anchorName = item.anchorNickName;
                    recepientItem.anchorId = item.anchorId;
                    [recepientArray addObject:recepientItem];
                }
                self.items = recepientArray;
                if (self.items.count > 0) {
                    self.emptyTips.hidden = YES;
                }else {
                    self.emptyTips.hidden = NO;
                    self.emptyTips.text = @"Your contact list is empty.";
                }
 
            }
            else {
                // 失败清除数据
                self.items = [NSArray array];
                self.retryBtn.hidden = NO;
          
            }
            [self reloadCollectionViewData];
        });
    };
    [[LSSessionRequestManager manager] sendRequest:request];
}


- (BOOL)getListRequest:(BOOL)loadMore {
    NSLog(@"LSSeclectSendScheduleViewController::getListRequest( loadMore : %@ )", BOOL2YES(loadMore));
    self.isRefresh = NO;
    BOOL bFlag = NO;
    
    GetFollowListRequest *request = [[GetFollowListRequest alloc] init];
    
    int start = 0;
    if (!loadMore) {
        // 刷最新
        start = 0;
        
    } else {
        // 刷更多
        start = self.items ? ((int)self.items.count) : 0;
    }
    
    // 每页最大纪录数
    request.start = start;
    request.step = PageSize;
    
    
    // 调用接口
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, NSArray<FollowItemObject *> *_Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSeclectSendScheduleViewController::getListRequest( [%@], loadMore : %@, count : %ld )", BOOL2SUCCESS(success), BOOL2YES(loadMore), (long)array.count);
            self.isRefresh = YES;
            if(success){
                for (FollowItemObject *item in array) {
                    LSRecepientItem *recepientItem = [[LSRecepientItem alloc] init];
                    recepientItem.anchorPhoto = item.photoUrl;
                    recepientItem.anchorName = item.nickName;
                    recepientItem.anchorId = item.userId;
                    [self addItemIfNotExist:recepientItem];
                }
                self.items = self.recepientItems;
                if (self.items.count > 0) {
                    self.emptyTips.hidden = YES;
                }else {
                    self.emptyTips.hidden = NO;
                    self.emptyTips.text = @"You have not followed anyone yet.";
                    
                }
            }else {
                // 失败清除数据
                self.items = [NSArray array];
                self.retryBtn.hidden = NO;
            }
            [self reloadCollectionViewData];
        });
    };
    
    
    bFlag = [[LSSessionRequestManager manager] sendRequest:request];
    
    return bFlag;
}

- (void)addItemIfNotExist:(LSRecepientItem *_Nonnull)itemNew {
    bool bFlag = NO;
    
    for (LSRecepientItem *item in self.recepientItems) {
        if ([item.anchorId isEqualToString:itemNew.anchorId]) {
            // 已经存在
            bFlag = true;
            break;
        }
    }
    
    if (!bFlag) {
        // 不存在
        [self.recepientItems addObject:itemNew];
    }
}



#pragma mark - dataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSRecipientCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LSRecipientCell cellIdentifier] forIndexPath:indexPath];
    if (indexPath.row < self.items.count) {
        LSRecepientItem *item = [self.items objectAtIndex:indexPath.row];
        if (self.selectIndex == indexPath.row) {
            cell.anchorPhoto.layer.borderWidth = 2;
            cell.anchorPhoto.layer.borderColor = COLOR_WITH_16BAND_RGB(0xE376DE).CGColor;
        }
        [cell setupUI:item];
    }
    
    return cell;
}

#pragma mark - delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.items.count) {
        // 选中则取消输入内容
        self.anchorTextField.text = @"";
        if (self.selectIndex > 0) {
            LSRecipientCell *cell = (LSRecipientCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectIndex inSection:0]];
            cell.anchorPhoto.layer.borderWidth = 0;
        }
        self.selectIndex = (int)indexPath.row;
        LSRecepientItem *item = [self.items objectAtIndex:indexPath.row];
        self.anchorId = item.anchorId;
        LSRecipientCell *cell = (LSRecipientCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        cell.anchorPhoto.layer.borderWidth = 2;
        cell.anchorPhoto.layer.borderColor = COLOR_WITH_16BAND_RGB(0xE376DE).CGColor;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.items.count) {
        LSRecipientCell *cell = (LSRecipientCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        cell.anchorPhoto.layer.borderWidth = 0;
    }
}



#pragma mark -KeyboardNSNotification
- (void)keyboardDidShow:(NSNotification *)notification {
    
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // 动画收起键盘
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
    
}

- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    if (height != 0) {
        // 弹出键盘
//        self.bottomDistance.constant = height;
        self.centerDistance.constant = -80;
        
    } else {
        // 收起键盘
        self.centerDistance.constant = 0;
    }
    
    [UIView animateWithDuration:duration
                     animations:^{
        // Make all constraint changes here, Called on parent view
        [self.view layoutIfNeeded];
        
    }completion:^(BOOL finished){
        
    }];
}



#pragma mark - touchAction

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (IBAction)closeAction:(id)sender {
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}


#pragma mark - UITextField
- (void)textFieldTextDidChange:(NSNotification *)notifi {
    self.anchorTextField.text = [self.anchorTextField.text uppercaseString];//大写
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.wrongTipsNote.hidden = YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (self.selectIndex >= 0) {
        if (string > 0) {
            LSRecipientCell *cell = (LSRecipientCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectIndex inSection:0]];
            self.selectIndex = -99;
            cell.anchorPhoto.layer.borderWidth = 0;
            self.anchorId = @"";
        }
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - scrollView
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView == self.collectionView){
        //检测左测滑动,开始加载更多
        if(scrollView.contentOffset.x + scrollView.frame.size.width - scrollView.contentSize.width > 30){
            NSLog(@"scrollview.contentOffset.x-->%f,scrollview.width-->%f,scrollview.contentsize.width--%f",scrollView.contentOffset.x,scrollView.frame.size.width,scrollView.contentSize.width);
            // 关注列表才滑动添加更多
            if (self.type == SegmentTypeFollow) {
                // 刷新完成才调用
                   if (self.isRefresh) {
                       [self getListRequest:YES];
                   }
            }
        }
    }
}





@end
