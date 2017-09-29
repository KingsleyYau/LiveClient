//
//  BookPrivateBroadcastViewController.m
//  livestream
//
//  Created by Calvin on 17/9/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "BookPrivateBroadcastViewController.h"
#import "UIView+YYAdd.h"
#import "AddVirtualGiftsCell.h"
#import "AddPhoneNumCell.h"
#import "GetCreateBookingInfoRequest.h"
#import "SendBookingRequest.h"
#import "BookPrivateBroadcastSucceedViewController.h"
#import "Dialog.h"
#import "DialogOK.h"
#import "AddMobileNumberViewController.h"
@interface BookPrivateBroadcastViewController ()<UITableViewDelegate,UITableViewDataSource,AddVirtualGiftsCellDelegate,UIPickerViewDelegate,UIPickerViewDataSource,AddPhoneNumCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray * titleArray;
@property (nonatomic, copy) NSString * noteStr;
@property (nonatomic, assign) BOOL isShowVG;
@property (nonatomic, strong) UIActivityIndicatorView * buttonLoading;
@property (nonatomic, strong) SessionRequestManager* sessionManager;

@property (nonatomic, strong) NSMutableArray * dayTimeArray;
@property (nonatomic, strong) NSArray<GiftItemObject*>* bookGift;
@property (nonatomic, strong) BookPhoneItemObject * bookPhoneItem;

@property (nonatomic, strong) UIButton * bookNowBtn;
@property (nonatomic, strong) Dialog * dialog;

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UIView *pickerBGView;
@property (nonatomic, assign) BOOL isDayPicker;

@property (nonatomic, assign) NSInteger selectRow;
@property (nonatomic, copy) NSString * dayStr;
@property (nonatomic, copy) NSString * timeStr;

//发送预约需要的数据
@property (nonatomic, copy) NSString * timeId;
@property (nonatomic, copy) NSString * giftId;
@property (nonatomic, assign) int giftNum;
@property (nonatomic, assign) BOOL needSms;
@end

@implementation BookPrivateBroadcastViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    
    self.isShowVG = YES;
    
    self.sessionManager = [SessionRequestManager manager];

    self.noteStr = [NSString stringWithFormat:@"%0.5%@",NSLocalizedStringFromSelf(@"Credits_Iofo")];
    
    self.bookGift = [NSArray array];
    
    self.dayTimeArray = [NSMutableArray array];
    
    [self getBookPrivateBroadcastData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:NO];
}

#pragma mark 设置FooterView
- (void)setTableFooterView
{
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 81)];
    
    self.bookNowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.bookNowBtn.frame = CGRectMake(footerView.frame.size.width/2 - 201/2, 24, 201, 35);
    [self.bookNowBtn setTitle:@"BOOK NOW" forState:UIControlStateNormal];
    self.bookNowBtn.layer.cornerRadius = 5;
    self.bookNowBtn.layer.masksToBounds = YES;
    //若主播没有可预约时间，则发送按钮变灰，不可用
    if (self.dayTimeArray.count > 0) {
        self.bookNowBtn.backgroundColor = [UIColor colorWithHexString:@"f94ceb"];//粉红
        self.bookNowBtn.userInteractionEnabled = YES;
    }
    else
    {
        self.bookNowBtn.backgroundColor = [UIColor colorWithHexString:@"b5b5b5"];//灰色
        self.bookNowBtn.userInteractionEnabled = NO;
    }
    
    [self.bookNowBtn addTarget:self action:@selector(bookNowBtnDid:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:self.bookNowBtn];
    
    [self.tableView setTableFooterView:footerView];
    
    self.buttonLoading = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.buttonLoading.frame = CGRectMake(self.bookNowBtn.width/2 - 15, self.bookNowBtn.height/2 - 15, 30, 30);
    [self.bookNowBtn addSubview:self.buttonLoading];
}

#pragma mark 预约按钮事件
- (void)bookNowBtnDid:(UIButton *)button
{
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
- (void)showDialog:(NSString *)message
{
    self.dialog = [Dialog dialog];
    self.dialog.tipsLabel.text = message;
    [self.dialog showDialog:self.view actionBlock:nil];
    [self performSelector:@selector(hideDialog) withObject:self afterDelay:2];
}

- (void)hideDialog
{
    [UIView animateWithDuration:1 animations:^{
        self.dialog.alpha = 0;
    }completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        [self.dialog removeFromSuperview];
    }];
}

#pragma mark 获取预约信息
- (void)getBookPrivateBroadcastData
{
    [self showLoading];
    GetCreateBookingInfoRequest * request = [[GetCreateBookingInfoRequest alloc]init];
    request.userId = self.userId;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, GetCreateBookingInfoItemObject * _Nonnull item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                self.noteStr = [NSString stringWithFormat:@"%0.1f%@",item.bookDeposit,NSLocalizedStringFromSelf(@"Credits_Iofo")];
               
                if (item.bookTime.count > 0) {
                  [self getBookTimeData:item.bookTime];
                }
                
                self.bookGift = item.bookGift;
                
                if (self.bookGift.count > 0) {
                    self.titleArray = @[@"When do you want to start the private live?",@"",@"",@"Note:"];
                }
                else
                {
                    self.titleArray = @[@"When do you want to start the private live?",@"",@"Note:"];
                }
                
                self.bookPhoneItem = item.bookPhone;
                
                self.needSms = item.bookPhone.phoneNo.length > 0?YES:NO;
                
                [self setTableFooterView];
                
                [self.tableView reloadData];
            }
            else{
                [self showDialog:errmsg];
            }
        });
    };
    
    [self.sessionManager sendRequest:request];
}

#pragma mark 发送预约
- (void)sendBookPrivateBroadcast
{
    SendBookingRequest * request = [[SendBookingRequest alloc]init];
    request.userId = self.userId;
    if (self.isShowVG) {
        request.giftId = self.giftId;
        request.giftNum = self.giftNum;
    }
    request.timeId = self.timeId;
    request.needSms = self.needSms;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.bookNowBtn.userInteractionEnabled = YES;
            [self.buttonLoading stopAnimating];
            [self.bookNowBtn setTitle:@"BOOK NOW" forState:UIControlStateNormal];
            if (success) {
                NSLog(@"预约成功");
                [self.navigationController popViewControllerAnimated:NO];
                BookPrivateBroadcastSucceedViewController * vc = [[BookPrivateBroadcastSucceedViewController alloc]initWithNibName:nil bundle:nil];
                vc.userName = self.userName;
                vc.time = [NSString stringWithFormat:@"%@.%@",self.dayStr,self.timeStr];
                if (self.bookGift.count > 0 && self.isShowVG) {
                    vc.giftId = self.giftId;
                    vc.giftNum = self.giftNum;
                }
                [AppDelegate().window.rootViewController presentViewController:vc animated:YES completion:nil];
            }
            else
            {
                if (errnum == 10027) {
                    NSString * message = @"Oops! Your don't have enough credits to book a private live.";
                    DialogOK * dialogOK = [DialogOK dialog];
                    dialogOK.tipsLabel.text = message;
                    [dialogOK showDialog:self.view actionBlock:^{
                        NSLog(@"跳转到充值界面");
                    }];
                }
                else
                {
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    BOOL isShowGiftData = self.bookGift.count > 0?YES:NO;
    if (section == 1) {
        return 5;
    }
    if (section == 2) {
      return isShowGiftData?5:30;
    }
    if (section == 3) {
        return 30;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isShowGiftData = self.bookGift.count > 0?YES:NO;
    if (indexPath.section == 1) {
        if (isShowGiftData) {
          return self.isShowVG?[AddVirtualGiftsCell cellHeight]:50;
        }
        else{
             return [AddPhoneNumCell cellHeight];
        }
    }
    if (indexPath.section == 2)
    {
        return isShowGiftData?[AddPhoneNumCell cellHeight]:[self noteMessageH];
    }
    if (indexPath.section == 3) {
        return [self noteMessageH];
    }
    return 50;
}

- (CGFloat)noteMessageH
{
    NSAttributedString *string = [[NSAttributedString alloc]initWithString:self.noteStr attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14.0]}];
    CGRect rect = [string boundingRectWithSize:CGSizeMake(self.tableView.frame.size.width, MAXFLOAT)
                                       options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    return ceil(rect.size.height) + 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.titleArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 1) {
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, section == 0?40:30)];
        UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, tableView.frame.size.width, view.frame.size.height)];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = [UIColor colorWithHexString:@"3c3c3c"];
        titleLabel.text = [self.titleArray objectAtIndex:section];
        [view addSubview:titleLabel];
         return view;
    }
    return nil;
}

- (AddVirtualGiftsCell *)showAddVirtualGiftsCell:(UITableView *)tableView
{
    AddVirtualGiftsCell *result = nil;
    AddVirtualGiftsCell * cell = [AddVirtualGiftsCell getUITableViewCell:tableView isShowVG:self.isShowVG];
    cell.delegate = self;
    result = cell;
    
    if (self.bookGift.count > 0) {
        [cell getVirtualGiftList:self.bookGift];
    }
    
    return result;
}

- (AddPhoneNumCell *)showAddPhoneNumCell:(UITableView *)tableView
{
    AddPhoneNumCell  *result = nil;
    AddPhoneNumCell * cell = [AddPhoneNumCell getUITableViewCell:tableView isOpen:self.needSms];
    cell.delegate = self;
    result = cell;
    
    if (self.bookPhoneItem.phoneNo.length > 0) {
        cell.phoneNumLabel.text = [NSString stringWithFormat:@"+%@-%@",self.bookPhoneItem.areaCode,self.bookPhoneItem.phoneNo];
        cell.addBtn.hidden = YES;
        cell.changeBtn.hidden = NO;
        cell.switchBGView.userInteractionEnabled = YES;
    }
    else
    {
        cell.phoneNumLabel.text = @"";
        cell.addBtn.hidden = NO;
        cell.changeBtn.hidden = YES;
        cell.switchBGView.userInteractionEnabled = NO;
    }
    
    return result;
}

- (UITableViewCell *)addTitleCell:(UITableView *)tableView ForRow:(NSInteger)row isDayTime:(BOOL)isDayTime
{
    
    static NSString * cellName = @"cellName";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor colorWithHexString:@"3c3c3c"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"5d0e86"];
    }
    if (isDayTime) {
        cell.textLabel.text = row == 0?@"Date":@"Time";
        
        if (self.dayTimeArray.count > 0) {
            cell.detailTextLabel.text = row == 0?self.dayStr:self.timeStr;
        }
    }
    else
    {
        cell.textLabel.text = self.noteStr;
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BOOL isShowGiftData = self.bookGift.count > 0?YES:NO;
    
    if (indexPath.section == 0)
    {
        return [self addTitleCell:tableView ForRow:indexPath.row isDayTime:YES];
    }
    else if (indexPath.section == 1)
    {
        
        return isShowGiftData?[self showAddVirtualGiftsCell:tableView]:
                              [self showAddPhoneNumCell:tableView];
       
    }
    else if (indexPath.section == 2)
    {
        return isShowGiftData?[self showAddPhoneNumCell:tableView]:
        [self addTitleCell:tableView ForRow:indexPath.row isDayTime:NO];
    }
    else
    {
        return [self addTitleCell:tableView ForRow:indexPath.row isDayTime:NO];
    }

    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        
        if (self.dayTimeArray.count > 0) {
            self.isDayPicker = indexPath.row == 0?YES:NO;
            self.pickerBGView.hidden = NO;
            self.pickerView.hidden = NO;
            [self.pickerView reloadAllComponents];
        }
        else
        {
            NSString * message = @"Sorry, this broadcaster does not offer a booking schedule at the moment.";
            [self showDialog:message];
        }
    }
}

- (IBAction)pickerBGTap:(UITapGestureRecognizer *)sender {
    
    self.pickerBGView.hidden = YES;
    self.pickerView.hidden = YES;
}

#pragma mark PickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.dayTimeArray.count > 0) {
        if (self.isDayPicker) {
            return self.dayTimeArray.count;
        }
        NSArray *items = [self.dayTimeArray[self.selectRow] objectForKey:@"time"];
        return items.count;
    }
    return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.dayTimeArray.count > 0) {
        if (self.isDayPicker) {
            return [self.dayTimeArray[row] objectForKey:@"day"];
        }
        
        NSArray * array = [self.dayTimeArray[self.selectRow] objectForKey:@"time"];
        NSString * times = [array objectAtIndex:row];
        return [[times componentsSeparatedByString:@"&"]firstObject];
    }
   return @"";
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.isDayPicker) {
        
        self.selectRow = row;
        
        self.dayStr = [self.dayTimeArray[row] objectForKey:@"day"];
        
        NSString * times = [[self.dayTimeArray[row] objectForKey:@"time"] objectAtIndex:0];
        self.timeStr = [[times componentsSeparatedByString:@"&"]firstObject];
        self.timeId = [[times componentsSeparatedByString:@"&"]lastObject];
    }
    else
    {
        NSString * times = [self.dayTimeArray[self.selectRow] objectForKey:@"time"][row];
        self.timeStr = [[times componentsSeparatedByString:@"&"]firstObject];
        self.timeId = [[times componentsSeparatedByString:@"&"]lastObject];
    }
    
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark 获取预约时间
- (void)getBookTimeData:(NSArray *)bookTime
{
    NSMutableArray * timeArray = [NSMutableArray array];
    
    NSMutableArray * dayArary = [NSMutableArray array];
    for (BookTimeItemObject * obj in bookTime) {
        
        //只有可预约的时间段才插入数组
        if (obj.status == BOOKTIMESTATUS_BOOKING) {
            NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
            [stampFormatter setDateFormat:@"MMM-dd HH:mm"];
            NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:obj.time];
            NSString *timeStr = [stampFormatter stringFromDate:timeDate];
            //拼接时间和时间ID
            [timeArray addObject:[NSString stringWithFormat:@"%@&%@",timeStr,obj.timeId]];
            
            [stampFormatter setDateFormat:@"MMM dd"];
            NSDate *dayDate = [NSDate dateWithTimeIntervalSince1970:obj.time];
            NSString *dayStr = [stampFormatter stringFromDate:dayDate];
            [dayArary addObject:dayStr];
        }
    }
    
    NSMutableArray *dateArray = [NSMutableArray arrayWithArray:timeArray];
    
    NSMutableArray * times = [@[] mutableCopy];
    for (int i = 0; i < dateArray.count; i ++) {
        
        NSString *string = [[dateArray[i] componentsSeparatedByString:@" "] firstObject];
        
        NSMutableArray *tempArray = [@[] mutableCopy];
        
        [tempArray addObject:[[dateArray[i] componentsSeparatedByString:@" "] lastObject]];
        
        for (int j = i+1; j < dateArray.count; j ++) {
            
            NSString *jstring = [[dateArray[j] componentsSeparatedByString:@" "] firstObject];
            
            if([string isEqualToString:jstring]){
                
                [tempArray addObject:[[dateArray[j] componentsSeparatedByString:@" "] lastObject]];
                
                [dateArray removeObjectAtIndex:j];
                j -= 1;
            }
        }
        
        [times addObject:tempArray];
    }
    
    NSMutableArray *listAry = [[NSMutableArray alloc]init];
    for (NSString *str in dayArary) {
        if (![listAry containsObject:str]) {
            [listAry addObject:str];
        }
    }
    
    for (int i = 0; i < times.count; i++) {
        
        NSDictionary * dic = @{@"day":[listAry objectAtIndex:i],@"time":[times objectAtIndex:i]};
        [self.dayTimeArray addObject:dic];
    }
    
    self.dayStr = [[self.dayTimeArray objectAtIndex:0] objectForKey:@"day"];
    
    NSArray * timesArray = [[self.dayTimeArray objectAtIndex:0] objectForKey:@"time"];
    self.timeStr = [[[timesArray objectAtIndex:0] componentsSeparatedByString:@"&"] firstObject];
    self.timeId = [[[timesArray objectAtIndex:0] componentsSeparatedByString:@"&"] lastObject];
}

#pragma mark 添加虚拟礼物回调
- (void)addVirtualGiftsCellSwitchOn:(BOOL)isOn
{
    self.isShowVG = isOn;
    
    [self.tableView reloadData];
}

- (void)addVirtualGiftsCellSelectGiftId:(NSString *)giftId andNum:(NSInteger)num
{
    self.giftId = giftId;
    self.giftNum = (int)num;
}

#pragma mark 手机是否发信息回调
- (void)addPhoneNumCellSwitchOn:(BOOL)isOn
{
    self.needSms = isOn;
    
    [self.tableView reloadData];
}

- (void)addPhoneNumCellAddBtnDid
{
    AddMobileNumberViewController * vc = [[AddMobileNumberViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addPhoneNumCellChangeBtnDid
{
    AddMobileNumberViewController * vc = [[AddMobileNumberViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}
@end
