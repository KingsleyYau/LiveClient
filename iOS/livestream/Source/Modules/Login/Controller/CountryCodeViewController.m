//
//  CountryCodeViewController.m
//  livestream
//
//  Created by Calvin on 17/9/28.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "CountryCodeViewController.h"
#import "CountryTableView.h"

@interface CountryCodeViewController ()<CountryTableViewDelegate>

@property (weak, nonatomic) IBOutlet CountryTableView *tableView;
@end

@implementation CountryCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableViewDelegate = self;
    
    [self.tableView reloadData];
}

- (IBAction)backBtnDid:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(CountryTableView *)tableView didSelectCountry:(Country *)item
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([self.delegate respondsToSelector:@selector(countryCode:)]) {
        [self.delegate countryCode:item];
    }
}
@end
