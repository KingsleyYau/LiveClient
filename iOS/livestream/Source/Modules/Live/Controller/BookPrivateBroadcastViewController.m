//
//  BookPrivateBroadcastViewController.m
//  livestream
//
//  Created by Calvin on 17/9/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "BookPrivateBroadcastViewController.h"
#import "AddVirtualGiftsCell.h"
#import "AddPhoneNumCell.h"
#import "GetCreateBookingInfoRequest.h"
#import "SendBookingRequest.h"
#import "BookPrivateBroadcastSucceedViewController.h"
#import "DialogTip.h"
#import "DialogOK.h"
#import "AddMobileNumberViewController.h"
#import "LiveModule.h"
#import "LSAddCreditsViewController.h"
@interface BookPrivateBroadcastViewController () <UITableViewDelegate, UITableViewDataSource, AddVirtualGiftsCellDelegate, UIPickerViewDelegate, UIPickerViewDataSource, AddPhoneNumCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSInteger tableRow;
@property (nonatomic, copy) NSString *noteStr;
@property (nonatomic, assign) BOOL isShowVG;
@property (nonatomic, strong) UIActivityIndicatorView *buttonLoading;
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@property (nonatomic, strong) NSMutableArray *dayTimeArray;
@property (nonatomic, strong) NSArray<LSGiftItemObject *> *bookGift;
@property (nonatomic, strong) BookPhoneItemObject *bookPhoneItem;

@property (nonatomic, strong) UIButton *bookNowBtn;
@property (nonatomic, strong) DialogTip *dialogTipView;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *pickerBGView;
@property (nonatomic, assign) BOOL isDayPicker;

@property (nonatomic, assign) NSInteger selectRow;
@property (nonatomic, copy) NSString *dayStr;
@property (nonatomic, copy) NSString *timeStr;

//发送预约需要的数据
@property (nonatomic, copy) NSString *timeId;
@property (nonatomic, assign) NSInteger bookTime;
@property (nonatomic, copy) NSString *giftId;
@property (nonatomic, assign) int giftNum;
@property (nonatomic, assign) BOOL needSms;

@property (nonatomic, assign) NSInteger selectDayRow;  //选择日期
@property (nonatomic, assign) NSInteger selectTimeRow; //选择时间

@property (strong) DialogOK *dialogBookAddCredit;

@property (nonatomic, assign) CGFloat bookDeposit;
@end

@implementation BookPrivateBroadcastViewController

- (void)initCustomParam {
    [super initCustomParam];
}

- (void)dealloc {
    if (self.dialogBookAddCredit) {
        [self.dialogBookAddCredit removeFromSuperview];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedStringFromSelf(@"Book_Private_Broadcast");

    self.tableView.dataSource = self;
    self.tableView.delegate = self;

    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;

    self.tableView.backgroundColor = COLOR_WITH_16BAND_RGB(0xECEDF1);

    self.isShowVG = NO;

    self.sessionManager = [LSSessionRequestManager manager];

    self.bookDeposit = 0.5;
    self.noteStr = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Credits_Iofo"), self.bookDeposit];

    self.bookGift = [NSArray array];

    self.dayTimeArray = [NSMutableArray array];

    self.dialogTipView = [DialogTip dialogTip];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.dayTimeArray removeAllObjects];
    [self getBookPrivateBroadcastData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
}

- (IBAction)backBtnDid:(UIButton *)sender {

    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark 设置FooterView
- (void)setTableFooterView {

    self.noteStr = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Credits_Iofo"), self.bookDeposit];

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 81 + [self noteMessageH])];

    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.noteStr];
    NSString *credits = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"credits"), self.bookDeposit];
    NSRange range = [self.noteStr rangeOfString:credits];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:11] range:range];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, SCREEN_WIDTH - 40, [self noteMessageH])];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:11];
    label.textColor = COLOR_WITH_16BAND_RGB(0x999999);
    label.attributedText = attrStr;
    [footerView addSubview:label];

    self.bookNowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.bookNowBtn.frame = CGRectMake(20, [self noteMessageH] + 20, SCREEN_WIDTH - 40, 35);
    self.bookNowBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.bookNowBtn setTitle:NSLocalizedStringFromSelf(@"BOOK_NOW") forState:UIControlStateNormal];
    self.bookNowBtn.layer.cornerRadius = self.bookNowBtn.frame.size.height / 2;
    self.bookNowBtn.layer.masksToBounds = NO;
    self.bookNowBtn.layer.shadowOffset = CGSizeMake(3, 3);
    self.bookNowBtn.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.bookNowBtn.layer.shadowRadius = 2;
    self.bookNowBtn.layer.shadowOpacity = 0.8;
    //若主播没有可预约时间，则发送按钮变灰，不可用
    if (self.dayTimeArray.count > 0) {
        self.bookNowBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x297AF3); //蓝色
        self.bookNowBtn.userInteractionEnabled = YES;
    } else {
        self.bookNowBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0xb5b5b5); //灰色
        self.bookNowBtn.userInteractionEnabled = NO;
    }

    [self.bookNowBtn addTarget:self action:@selector(bookNowBtnDid:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:self.bookNowBtn];

    [self.tableView setTableFooterView:footerView];

    self.buttonLoading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.buttonLoading.frame = CGRectMake(self.bookNowBtn.frame.size.width / 2 - 15, self.bookNowBtn.frame.size.height / 2 - 15, 30, 30);
    [self.bookNowBtn addSubview:self.buttonLoading];
}

#pragma mark 预约按钮事件
- (void)bookNowBtnDid:(UIButton *)button {
    [self.buttonLoading startAnimating];
    [button setTitle:@"" forState:UIControlStateNormal];
    button.userInteractionEnabled = NO;
    [self sendBookPrivateBroadcast];
}

#pragma mark 返回按钮事件
- (IBAction)back:(UIButton *)sender {

    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 显示浮窗提示
- (void)showDialog:(NSString *)message {
    [self.dialogTipView showDialogTip:self.view tipText:message];
}

#pragma mark 获取预约信息
- (void)getBookPrivateBroadcastData {
    if (!self.userId) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self showLoading];
    GetCreateBookingInfoRequest *request = [[GetCreateBookingInfoRequest alloc] init];
    request.userId = self.userId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, GetCreateBookingInfoItemObject *_Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                self.bookDeposit = item.bookDeposit;

                if (item.bookTime.count > 0) {

                    NSArray *result = [item.bookTime sortedArrayUsingComparator:^NSComparisonResult(BookTimeItemObject *_Nonnull obj1, BookTimeItemObject *_Nonnull obj2) {

                        NSString *time1 = [NSString stringWithFormat:@"%ld", obj1.time];
                        NSString *time2 = [NSString stringWithFormat:@"%ld", obj2.time];
                        return [time1 compare:time2]; //升序
                    }];

                    [self getBookTimeData:result];
                }

                self.bookGift = item.bookGift;

                if (self.bookGift.count > 0) {
                    self.tableRow = 3;
                } else {
                    self.tableRow = 2;
                }

                self.bookPhoneItem = item.bookPhone;

                if (item.bookPhone) {
                    self.needSms = item.bookPhone.phoneNo.length > 0 ? YES : NO;
                }

                [self setTableFooterView];

                [self.tableView reloadData];
            } else {
                [self showDialog:errmsg];
            }
        });
    };

    [self.sessionManager sendRequest:request];
}

#pragma mark 发送预约
- (void)sendBookPrivateBroadcast {
    if (!self.userId) {
        return;
    }
    SendBookingRequest *request = [[SendBookingRequest alloc] init];
    request.userId = self.userId;
    if (self.isShowVG) {
        request.giftId = self.giftId;
        request.giftNum = self.giftNum;
    }
    request.bookTime = self.bookTime;
    request.timeId = self.timeId;
    request.needSms = self.needSms;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.bookNowBtn.userInteractionEnabled = YES;
            [self.buttonLoading stopAnimating];
            [self.bookNowBtn setTitle:NSLocalizedStringFromSelf(@"BOOK_NOW") forState:UIControlStateNormal];
            if (success) {
                NSLog(@"预约成功");
                BookPrivateBroadcastSucceedViewController *vc = [[BookPrivateBroadcastSucceedViewController alloc] initWithNibName:nil bundle:nil];
                vc.userName = self.userName;
                vc.time = [NSString stringWithFormat:@"%@.%@", self.dayStr, self.timeStr];
                if (self.bookGift.count > 0 && self.isShowVG) {
                    vc.giftId = self.giftId;
                    vc.giftNum = self.giftNum;
                }
                vc.view.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT);
                [self addChildViewController:vc];
                [self.view addSubview:vc.view];

                [UIView animateWithDuration:0.2
                                 animations:^{
                                     vc.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                                 }];
            } else {
                if (errnum == HTTP_LCC_ERR_NO_CREDIT) {
                    if (self.dialogBookAddCredit) {
                        [self.dialogBookAddCredit removeFromSuperview];
                    }
                    self.dialogBookAddCredit = [DialogOK dialog];
                    self.dialogBookAddCredit.tipsLabel.text = NSLocalizedStringFromSelf(@"BOOKPRIVATE_ERR_ADD_CREDIT");
                    [self.dialogBookAddCredit showDialog:self.view
                                             actionBlock:^{
                                                 NSLog(@"跳转到充值界面");
                                                 [[LiveModule module].analyticsManager reportActionEvent:BuyCredit eventCategory:EventCategoryGobal];
                                                 LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
                                                 [self.navigationController pushViewController:vc animated:YES];
                                             }];
                } else {
                    [self showDialog:errmsg];
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    BOOL isShowGiftData = self.bookGift.count > 0 ? YES : NO;
    if (section == 1) {
        return 10;
    }
    if (section == 2) {
        return isShowGiftData ? 10 : 20;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isShowGiftData = self.bookGift.count > 0 ? YES : NO;
    if (indexPath.section == 1) {
        if (isShowGiftData) {
            return self.isShowVG ? [AddVirtualGiftsCell cellHeight] : 50;
        } else {
            return [AddPhoneNumCell cellHeight];
        }
    }
    if (indexPath.section == 2) {
        return isShowGiftData ? [AddPhoneNumCell cellHeight] : [self noteMessageH];
    }
    return 50;
}

- (CGFloat)noteMessageH {
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:self.noteStr attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:11.0]}];
    CGRect rect = [string boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, MAXFLOAT)
                                       options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                       context:nil];
    return ceil(rect.size.height) + 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tableRow;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, section == 0 ? 40 : 30)];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, tableView.frame.size.width - 15, view.frame.size.height)];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = COLOR_WITH_16BAND_RGB(0x999999);
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.text = SCREEN_WIDTH == 320 ? NSLocalizedStringFromSelf(@"WHEN_STAR_PRIVATE_IPHONE5") : NSLocalizedStringFromSelf(@"WHEN_STAR_PRIVATE");
        [view addSubview:titleLabel];
        return view;
    }
    return nil;
}

- (AddVirtualGiftsCell *)showAddVirtualGiftsCell:(UITableView *)tableView {
    AddVirtualGiftsCell *result = nil;
    AddVirtualGiftsCell *cell = [AddVirtualGiftsCell getUITableViewCell:tableView isShowVG:self.isShowVG];
    cell.delegate = self;
    result = cell;

    if (self.bookGift.count > 0) {
        [cell getVirtualGiftList:self.bookGift];
    }

    return result;
}

- (AddPhoneNumCell *)showAddPhoneNumCell:(UITableView *)tableView {
    AddPhoneNumCell *result = nil;
    // isHaveNumber是否有增加过电话
    AddPhoneNumCell *cell = [AddPhoneNumCell getUITableViewCell:tableView isOpen:self.needSms isHaveNumber:self.bookPhoneItem.phoneNo.length > 0 ? YES : NO];
    cell.delegate = self;
    result = cell;

    if (self.bookPhoneItem.phoneNo.length > 0) {
        cell.phoneNumLabel.text = [NSString stringWithFormat:@"+%@-%@", self.bookPhoneItem.areaCode, self.bookPhoneItem.phoneNo];
        cell.addBtn.hidden = YES;
        cell.changeBtn.hidden = NO;
        //cell.switchBGView.userInteractionEnabled = YES;
    } else {
        cell.phoneNumLabel.text = @"";
        cell.addBtn.hidden = NO;
        cell.changeBtn.hidden = YES;
        //cell.switchBGView.userInteractionEnabled = NO;
    }

    return result;
}

- (UITableViewCell *)addTitleCell:(UITableView *)tableView ForRow:(NSInteger)row isDayTime:(BOOL)isDayTime {

    static NSString *cellName = @"cellName";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textColor = COLOR_WITH_16BAND_RGB(0x297AF3);
    }
    if (isDayTime) {
        cell.textLabel.text = row == 0 ? @"Date" : @"Time";

        if (self.dayTimeArray.count > 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.text = row == 0 ? self.dayStr : self.timeStr;
            cell.backgroundColor = [UIColor whiteColor];
        }
    } else {
        cell.textLabel.text = self.noteStr;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    BOOL isShowGiftData = self.bookGift.count > 0 ? YES : NO;

    if (indexPath.section == 0) {
        return [self addTitleCell:tableView ForRow:indexPath.row isDayTime:YES];
    } else if (indexPath.section == 1) {

        return isShowGiftData ? [self showAddVirtualGiftsCell:tableView] : [self showAddPhoneNumCell:tableView];

    } else if (indexPath.section == 2) {
        return isShowGiftData ? [self showAddPhoneNumCell:tableView] : [self addTitleCell:tableView ForRow:indexPath.row isDayTime:NO];
    } else {
        return [self addTitleCell:tableView ForRow:indexPath.row isDayTime:NO];
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {

        if (self.dayTimeArray.count > 0) {
            self.isDayPicker = indexPath.row == 0 ? YES : NO;
            self.pickerBGView.hidden = NO;
            self.pickerView.hidden = NO;
            [self.pickerView reloadAllComponents];

            [self.pickerView selectRow:indexPath.row == 0 ? self.selectDayRow : self.selectTimeRow inComponent:0 animated:NO];

        } else {
            [self showDialog:NSLocalizedStringFromSelf(@"BOOKING_SCHEDULE_ERR")];
        }
    }
}

- (IBAction)pickerBGTap:(UITapGestureRecognizer *)sender {

    self.pickerBGView.hidden = YES;
    self.pickerView.hidden = YES;
}

#pragma mark PickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.dayTimeArray.count > 0) {
        if (self.isDayPicker) {
            return self.dayTimeArray.count;
        }
        NSArray *items = [self.dayTimeArray[self.selectRow] objectForKey:@"time"];
        return items.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (self.dayTimeArray.count > 0) {
        if (self.isDayPicker) {
            return [self.dayTimeArray[row] objectForKey:@"day"];
        }

        NSArray *array = [self.dayTimeArray[self.selectRow] objectForKey:@"time"];
        NSString *times = [array objectAtIndex:row];
        times = [[times componentsSeparatedByString:@"&"] firstObject];
        return [times stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (self.isDayPicker) {

        self.selectRow = row;
        self.selectDayRow = row;
        self.selectTimeRow = 0;
        self.dayStr = [self.dayTimeArray[row] objectForKey:@"day"];

        NSString *times = [[self.dayTimeArray[row] objectForKey:@"time"] objectAtIndex:0];
        NSArray *timeData = [times componentsSeparatedByString:@"&"];
        self.timeStr = [[timeData firstObject] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
        self.timeId = [[[timeData lastObject] componentsSeparatedByString:@"-"] firstObject];
        self.bookTime = [[[[timeData lastObject] componentsSeparatedByString:@"-"] lastObject] integerValue];
    } else {
        self.selectTimeRow = row;
        NSString *times = [self.dayTimeArray[self.selectRow] objectForKey:@"time"][row];
        NSArray *timeData = [times componentsSeparatedByString:@"&"];
        self.timeStr = [[timeData firstObject] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
        self.timeId = [[[timeData lastObject] componentsSeparatedByString:@"-"] firstObject];
        self.bookTime = [[[[timeData lastObject] componentsSeparatedByString:@"-"] lastObject] integerValue];
    }

    NSIndexSet *indexSet = [[NSIndexSet alloc] initWithIndex:0];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark 获取预约时间
- (void)getBookTimeData:(NSArray *)bookTime {
    NSMutableArray *timeArray = [NSMutableArray array];

    NSMutableArray *dayArary = [NSMutableArray array];
    for (BookTimeItemObject *obj in bookTime) {

        //只有可预约的时间段才插入数组
        if (obj.status == BOOKTIMESTATUS_BOOKING) {
            NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
            stampFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [stampFormatter setDateFormat:@"MMM-dd h:mm-a"];
            NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:obj.time];
            NSString *timeStr = [stampFormatter stringFromDate:timeDate];
            //拼接时间和时间ID
            [timeArray addObject:[NSString stringWithFormat:@"%@&%@-%ld", timeStr, obj.timeId, (long)obj.time]];

            [stampFormatter setDateFormat:@"MMM dd"];
            NSDate *dayDate = [NSDate dateWithTimeIntervalSince1970:obj.time];
            NSString *dayStr = [stampFormatter stringFromDate:dayDate];
            [dayArary addObject:dayStr];
        }
    }

    if (dayArary.count == 0) {
        return;
    }

    NSMutableArray *dateArray = [NSMutableArray arrayWithArray:timeArray];

    NSMutableArray *times = [@[] mutableCopy];
    for (int i = 0; i < dateArray.count; i++) {

        NSString *string = [[dateArray[i] componentsSeparatedByString:@" "] firstObject];

        NSMutableArray *tempArray = [@[] mutableCopy];

        [tempArray addObject:[[dateArray[i] componentsSeparatedByString:@" "] lastObject]];

        for (int j = i + 1; j < dateArray.count; j++) {

            NSString *jstring = [[dateArray[j] componentsSeparatedByString:@" "] firstObject];

            if ([string isEqualToString:jstring]) {

                NSString *times = [[dateArray[j] componentsSeparatedByString:@" "] lastObject];
                [tempArray addObject:times];

                [dateArray removeObjectAtIndex:j];
                j -= 1;
            }
        }

        [times addObject:tempArray];
    }

    NSMutableArray *listAry = [[NSMutableArray alloc] init];
    for (NSString *str in dayArary) {
        if (![listAry containsObject:str]) {
            [listAry addObject:str];
        }
    }

    for (int i = 0; i < times.count; i++) {

        NSDictionary *dic = @{ @"day" : [listAry objectAtIndex:i],
                               @"time" : [times objectAtIndex:i] };
        [self.dayTimeArray addObject:dic];
    }

    NSArray *dataTimes = [self.dayTimeArray copy];
    if (self.dayTimeArray.count > 3) {
        dataTimes = [dataTimes subarrayWithRange:NSMakeRange(0, 3)];
        self.dayTimeArray = [NSMutableArray arrayWithArray:dataTimes];
    }

    if (!self.dayStr) {
        self.dayStr = [[self.dayTimeArray objectAtIndex:0] objectForKey:@"day"];

        NSArray *timesArray = [[self.dayTimeArray objectAtIndex:0] objectForKey:@"time"];
        NSArray *timeData = [[timesArray objectAtIndex:0] componentsSeparatedByString:@"&"];
        self.timeStr = [[timeData firstObject] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
        self.timeId = [[[timeData lastObject] componentsSeparatedByString:@"-"] firstObject];
        self.bookTime = [[[[timeData lastObject] componentsSeparatedByString:@"-"] lastObject] integerValue];
    }
}

#pragma mark 添加虚拟礼物回调
- (void)addVirtualGiftsCellSwitchOn:(BOOL)isOn {
    self.isShowVG = isOn;

    [self.tableView reloadData];
}

- (void)addVirtualGiftsCellSelectGiftId:(NSString *)giftId andNum:(NSInteger)num {
    self.giftId = giftId;
    self.giftNum = (int)num;
}

#pragma mark 手机是否发信息回调
- (void)addPhoneNumCellSwitchOn:(BOOL)isOn {
    self.needSms = isOn;

    if (self.bookPhoneItem.phoneNo.length > 0) {

    } else {

        [self showDialog:NSLocalizedStringFromSelf(@"Add_First_Mobile")];
    }

    [self.tableView reloadData];
}

- (void)addPhoneNumCellAddBtnDid {
    AddMobileNumberViewController *vc = [[AddMobileNumberViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addPhoneNumCellChangeBtnDid
{
    AddMobileNumberViewController * vc = [[AddMobileNumberViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
