//
//  LSAboutUsViewController.m
//  livestream
//
//  Created by test on 2017/12/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSAboutUsViewController.h"
#import "LSAboutUsHeaderView.h"
#import "UserAgreementViewController.h"

@interface LSAboutUsViewController ()<UITableViewDataSource,UITableViewDelegate>


/** 头部 */
@property (nonatomic, strong) LSAboutUsHeaderView *headerView;
@end

@implementation LSAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    // 禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [self reloadData:YES];
}

- (void)initCustomParam {
    [super initCustomParam];
}


- (void)setupContainView {
    [super setupContainView];
    [self setupTableView];
    self.title = NSLocalizedStringFromSelf(@"About Us");
}


- (void)setupTableView {
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.headerView = [[LSAboutUsHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 180)];
    self.tableView.tableHeaderView = self.headerView;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *vc =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0.5)];
    vc.backgroundColor = COLOR_WITH_16BAND_RGB(0xF1D7FF);
    self.tableView.tableFooterView = vc;
    
    self.tableView.separatorColor = COLOR_WITH_16BAND_RGB(0xF1D7FF);
}

- (void)reloadData:(BOOL)isReload {
    self.titleArray = @[NSLocalizedStringFromSelf(@"Terms and Conditions"),NSLocalizedStringFromSelf(@"Privacy Policy")];
    if (isReload) {
        [self.tableView reloadData];
    }
}

#pragma mark - dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString * cellName = @"cellName";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellName];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.textColor = COLOR_WITH_16BAND_RGB(0x3c3c3c);
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        
        UIView * lineView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, screenSize.width - 20, 0.5)];
        lineView.backgroundColor = COLOR_WITH_16BAND_RGB(0xF1D7FF);
        [cell addSubview:lineView];
        
        cell.textLabel.text = [self.titleArray objectAtIndex:indexPath.row];
        

    }
    return cell;
}


#pragma mark - delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSLog(@"UserAgreementViewController termsOfUse ");
        UserAgreementViewController *vc = [[UserAgreementViewController alloc] initWithNibName:nil bundle:nil];
        vc.isTermsOfUse = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1){
           NSLog(@"UserAgreementViewController userProtocol");
        UserAgreementViewController *vc = [[UserAgreementViewController alloc] initWithNibName:nil bundle:nil];
        vc.isTermsOfUse = NO;
        [self.navigationController pushViewController:vc animated:YES];
        
    }

}

@end
