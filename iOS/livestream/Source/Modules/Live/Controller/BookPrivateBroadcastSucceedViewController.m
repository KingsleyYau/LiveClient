//
//  BookPrivateBroadcastSucceedViewController.m
//  testDemo
//
//  Created by Calvin on 17/9/27.
//  Copyright © 2017年 dating. All rights reserved.
//

#import "BookPrivateBroadcastSucceedViewController.h"
#import "BookPrivateBroadcastSucceedHeadView.h"
#import "LiveGiftDownloadManager.h"
#import "LSImageViewLoader.h"
#import "LSMyReservationsViewController.h"
#import "LiveModule.h"
#import "LiveGobalManager.h"
@interface BookPrivateBroadcastSucceedViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray * titleArray;
@property (nonatomic, strong) LiveGiftDownloadManager *giftDownloadManager;
@end

@implementation BookPrivateBroadcastSucceedViewController

- (void)initCustomParam {
    [super initCustomParam];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
        
    self.giftDownloadManager = [LiveGiftDownloadManager manager];
    
    self.titleArray = @[NSLocalizedStringFromSelf(@"BROAD_CASTER"),NSLocalizedStringFromSelf(@"RESER_TIME"),NSLocalizedStringFromSelf(@"VIRTUAL_GIFT")];
    
    [self setTableHeadView];
    [self setTableFooterView];
    [self.tableView reloadData];
}

- (void)backBtnDid:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setTableHeadView
{
    BookPrivateBroadcastSucceedHeadView * headView = [[BookPrivateBroadcastSucceedHeadView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 129)];
    [self.tableView setTableHeaderView:headView];
}

- (void)setTableFooterView
{
    UIView * footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
    footerView.backgroundColor = [UIColor clearColor];
    UIButton * okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    okBtn.frame = CGRectMake(20, 24, SCREEN_WIDTH - 40, 35);
    okBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [okBtn setTitle:NSLocalizedString(@"OK", @"OK") forState:UIControlStateNormal];
    okBtn.layer.cornerRadius = okBtn.frame.size.height/2;
    okBtn.layer.masksToBounds = NO;
    okBtn.layer.shadowOffset = CGSizeMake(3, 3);
    okBtn.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    okBtn.layer.shadowRadius = 2;
    okBtn.layer.shadowOpacity = 0.8;
    okBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x297AF3);
    [okBtn addTarget:self action:@selector(backBtnDid:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:okBtn];
    
    // 需求已改，不显示
    UIButton * myBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat bottom = okBtn.frame.origin.y + okBtn.frame.size.height;
    myBtn.frame = CGRectMake(footerView.frame.size.width/2 - 201/2, bottom + 13, 201, 35);
    [myBtn setTitle:NSLocalizedStringFromSelf(@"MY_RESER") forState:UIControlStateNormal];
    myBtn.layer.cornerRadius = 5;
    myBtn.layer.masksToBounds = YES;
    myBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x5d0e86);
    [myBtn addTarget:self action:@selector(myBtnDid:) forControlEvents:UIControlEventTouchUpInside];
    myBtn.hidden = YES;
    [footerView addSubview:myBtn];
    
    [self.tableView setTableFooterView:footerView];
}


- (void)myBtnDid:(UIButton *)btn
{
    LSMyReservationsViewController * vc = [[LSMyReservationsViewController alloc]initWithNibName:nil bundle:nil];
    [[[LiveModule module] moduleVC].navigationController pushViewController:vc animated:YES];
}

- (void)setupContainView {
    
    [super setupContainView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.giftId.length > 0) {
        return self.titleArray.count;
    }
    return self.titleArray.count - 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellName = @"cellName";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = COLOR_WITH_16BAND_RGB(0x3c3c3c);
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textColor = COLOR_WITH_16BAND_RGB(0x666666);
        
//        UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, screenSize.width - 20, 0.5)];
//        lineView.backgroundColor = COLOR_WITH_16BAND_RGB(0xdb96ff);
//        [cell addSubview:lineView];
        
        cell.textLabel.text = [self.titleArray objectAtIndex:indexPath.row];
        
        if (indexPath.row == 0) {
            cell.detailTextLabel.text = self.userName;
        }
        else if (indexPath.row == 1)
        {
            cell.detailTextLabel.text = self.time;
        }
        else
        {
            NSString * giftUrl = [self.giftDownloadManager backMiddleImgUrlWithGiftID:self.giftId];
            
            UIImageView * icon = [[UIImageView alloc]initWithFrame:CGRectMake(self.tableView.frame.size.width - 80, 10, 30, 30)];
            icon.layer.cornerRadius = 4;
            icon.layer.masksToBounds = YES;
            [cell addSubview:icon];
            LSImageViewLoader *imageViewLoader = [LSImageViewLoader loader];
            [imageViewLoader loadImageWithImageView:icon options:0 imageUrl:giftUrl placeholderImage:nil];
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"X%ld",(long)self.giftNum];
        }
    }

    return cell;
}

@end
