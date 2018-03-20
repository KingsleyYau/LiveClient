//
//  LSSettingViewController.m
//  livestream
//
//  Created by test on 2017/12/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSSettingViewController.h"
#import "LSFeedBackViewController.h"
#import "LSAboutUsViewController.h"
#import "LSLoginManager.h"
#import "LSAnalyticsManager.h"
@interface LSSettingViewController ()

@end

@implementation LSSettingViewController

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
    self.title = @"Settings";
    self.logoutBtn.layer.cornerRadius = 4.0f;
    self.logoutBtn.layer.masksToBounds = YES;
  
}

- (void)setupTableView {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *vc =  [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0.5)];
    vc.backgroundColor = COLOR_WITH_16BAND_RGB(0xF1D7FF);
    self.tableView.tableFooterView = vc;
}


- (void)reloadData:(BOOL)isReload {
    self.titleArray = @[NSLocalizedString(@"Feedback", nil),NSLocalizedString(@"About us", nil)];
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
        LSFeedBackViewController *vc = [[LSFeedBackViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (indexPath.row == 1) {
        LSAboutUsViewController *vc = [[LSAboutUsViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
- (IBAction)logoutActionClick:(id)sender {
    [[LSAnalyticsManager manager] reportActionEvent:ClickLogout eventCategory:EventCategoryPersonalCenter];
    [[LSLoginManager manager]logout:YES msg:@""];
}

@end
