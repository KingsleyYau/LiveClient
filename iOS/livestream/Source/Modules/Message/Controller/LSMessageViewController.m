//
//  LSMessageViewController.m
//  livestream
//
//  Created by Calvin on 2018/6/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSMessageViewController.h"
#import "LSMessageCell.h"
#import "LSChatViewController.h"
@interface LSMessageViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *noDataView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray * data;
@end

@implementation LSMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.data = [NSArray array];
    
    // 设置失败页属性
    self.failTipsText = NSLocalizedString(@"List_FailTips", @"List_FailTips");
    
    self.failBtnText = NSLocalizedString(@"List_Reload", @"List_Reload");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LSMessageCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LSMessageCell *result = nil;
    LSMessageCell *cell = [LSMessageCell getUITableViewCell:tableView];
    result = cell;
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LSChatViewController * vc = [[LSChatViewController alloc]initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
