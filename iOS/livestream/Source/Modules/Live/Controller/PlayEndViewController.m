//
//  PlayEndViewController.m
//  livestream
//
//  Created by Max on 2017/5/25.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PlayEndViewController.h"

#import "FileCacheManager.h"

@interface PlayEndViewController ()

@end

@implementation PlayEndViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
}

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}

- (void)setupContainView {
    [super setupContainView];
    
    // 初始化主播信息控件
    [self setupRoomView];
}

#pragma mark - 界面事件
- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 主播信息控件管理
- (void)setupRoomView {
    self.imageViewHeader.layer.masksToBounds = YES;
    self.imageViewHeader.layer.cornerRadius = self.imageViewHeader.frame.size.height / 2;
    
    self.imageViewHeaderLoader = [ImageViewLoader loader];
    self.imageViewHeaderLoader.sdWebImageView = self.imageViewHeader;
    self.imageViewHeaderLoader.url = @"http://images3.charmdate.com/woman_photo/C841/174/C162683-d.jpg";
//    self.imageViewHeaderLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:self.imageViewHeaderLoader.url];
    [self.imageViewHeaderLoader loadImageWithOptions:SDWebImageRefreshCached placeholderImage:[UIImage imageNamed:@""]];
}
@end
