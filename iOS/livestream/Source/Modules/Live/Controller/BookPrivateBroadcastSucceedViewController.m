//
//  BookPrivateBroadcastSucceedViewController.m
//  testDemo
//
//  Created by Calvin on 17/9/27.
//  Copyright © 2017年 dating. All rights reserved.
//

#import "BookPrivateBroadcastSucceedViewController.h"
#import "UIView+YYAdd.h"
#import "BookPrivateBroadcastSucceedHeadView.h"
#import "LiveGiftDownloadManager.h"
#import "ImageViewLoader.h"
@interface BookPrivateBroadcastSucceedViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray * titleArray;
@property (nonatomic, strong) LiveGiftDownloadManager *giftDownloadManager;
@end

@implementation BookPrivateBroadcastSucceedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.giftDownloadManager = [LiveGiftDownloadManager manager];
    
    self.titleArray = @[@"Broadcaster",@"Reservation Time",@"Virtual Gift"];
    
    [self setTableHeadView];
    [self setTableFooterView];
    [self.tableView reloadData];
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
    okBtn.frame = CGRectMake(footerView.frame.size.width/2 - 201/2, 24, 201, 35);
    [okBtn setTitle:@"OK" forState:UIControlStateNormal];
    okBtn.layer.cornerRadius = 5;
    okBtn.layer.masksToBounds = YES;
    okBtn.backgroundColor = [UIColor colorWithHexString:@"f94ceb"];
    [okBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:okBtn];
    
    UIButton * myBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    myBtn.frame = CGRectMake(footerView.frame.size.width/2 - 201/2, okBtn.bottom + 13, 201, 35);
    [myBtn setTitle:@"My Reservations" forState:UIControlStateNormal];
    myBtn.layer.cornerRadius = 5;
    myBtn.layer.masksToBounds = YES;
    myBtn.backgroundColor = [UIColor colorWithHexString:@"5d0e86"];
    [myBtn addTarget:self action:@selector(myBtnDid:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:myBtn];
    
    [self.tableView setTableFooterView:footerView];
}

- (IBAction)backBtn:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)myBtnDid:(UIButton *)btn
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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
        cell.textLabel.textColor = [UIColor colorWithHexString:@"3c3c3c"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"5d0e86"];
        
        cell.textLabel.text = [self.titleArray objectAtIndex:indexPath.row];
    }
    
    if (indexPath.row == 0) {
        cell.detailTextLabel.text = self.userName;
    }
    else if (indexPath.row == 1)
    {
        cell.detailTextLabel.text = self.time;
    }
    else
    {
        NSString * giftUrl = [self.giftDownloadManager backSmallImgUrlWithGiftID:self.giftId];
        
        UIImageView * icon = [[UIImageView alloc]initWithFrame:CGRectMake(self.tableView.width - 80, 10, 30, 30)];
        icon.layer.cornerRadius = 4;
        icon.layer.masksToBounds = YES;
        [cell addSubview:icon];
        ImageViewLoader * imageViewLoader = [ImageViewLoader loader];
        [imageViewLoader loadImageWithImageView:icon options:0 imageUrl:giftUrl placeholderImage:nil];
    
        cell.detailTextLabel.text = [NSString stringWithFormat:@"X%ld",self.giftNum];
    }

    return cell;
}

@end
