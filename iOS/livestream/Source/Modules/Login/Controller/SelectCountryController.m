//
//  SelectCountryController.m
//  livestream
//
//  Created by randy on 17/5/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "SelectCountryController.h"
#import "CountryTableView.h"
#import "Country.h"
@interface SelectCountryController ()<CountryTableViewDelegate>

@end

@implementation SelectCountryController

- (void)initCustomParam {
    [super initCustomParam];
    
    self.navigationTitle = NSLocalizedString(@"Select Country or region", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    // 显示导航栏
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // 设置导航栏返回按钮
    [self setBackleftBarButtonItemOffset:30];
}

- (void)setupContainView {
    [super setupContainView];
    [self setupInputView];
}

- (void)setupInputView{
    
    CountryTableView *countryView = [[CountryTableView alloc] init];
    countryView.tableViewDelegate = self;
    [self.view addSubview:countryView];
    
    [countryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)tableView:(CountryTableView *)tableView didSelectCountry:(Country *)item {
    
    if([self.delegate respondsToSelector:@selector(sendCounty:)]) {
        [self.delegate sendCounty:item];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}



@end
