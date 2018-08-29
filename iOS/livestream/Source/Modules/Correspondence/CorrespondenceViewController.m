//
//  CorrespondenceViewController.m
//  livestream
//
//  Created by Calvin on 2018/6/20.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "CorrespondenceViewController.h"
#import "LSEMFBoxTableViewCell.h"
@interface CorrespondenceViewController ()

@end

@implementation CorrespondenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LSEMFBoxTableViewCell cellHeight];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    LSEMFBoxTableViewCell* cell = [LSEMFBoxTableViewCell getUITableViewCell:tableView];
    result = cell;
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
