//
//  IntentionletterListViewController.m
//  livestream
//
//  Created by Calvin on 2018/6/20.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "IntentionletterListViewController.h"
#import "LSEMFBoxTableViewCell.h"
@interface IntentionletterListViewController ()

@property (weak, nonatomic) IBOutlet LSTableView *tableView;
@end

@implementation IntentionletterListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationTitle = @"Letter of Interest";
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
