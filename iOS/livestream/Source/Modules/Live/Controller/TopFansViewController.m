//
//  TopFansViewController.m
//  livestream
//
//  Created by Max on 2017/6/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "TopFansViewController.h"

@interface TopFansViewController () <JTSegmentControlDelegate>
@property (nonatomic, weak) JTSegmentControl* categoryControl;
@end

@implementation TopFansViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initCustomParam {
    [super initCustomParam];
}

- (void)setupContainView {
    [super setupContainView];
    
    CGRect frame = CGRectMake(0, 0, self.categoryView.frame.size.width, self.categoryView.frame.size.height);
    JTSegmentControl* categoryControl = [[JTSegmentControl alloc] initWithFrame:frame];
    
    categoryControl.delegate = self;
    categoryControl.autoScrollWhenIndexChange = YES;
    categoryControl.items = [NSArray arrayWithObjects:@"Top Fans of this live", @"Top Fans", nil];
    categoryControl.font = [UIFont systemFontOfSize:16];
    categoryControl.selectedFont = [UIFont systemFontOfSize:16];
    categoryControl.itemBackgroundColor = [UIColor clearColor];
    categoryControl.itemSelectedBackgroundColor = [UIColor clearColor];
    categoryControl.itemTextColor = COLOR_WITH_16BAND_RGB(0xDB96FF);
    categoryControl.itemSelectedTextColor = COLOR_WITH_16BAND_RGB(0xFFF600);
    categoryControl.sliderViewColor = COLOR_WITH_16BAND_RGB(0xFFF600);
    
    self.categoryControl = categoryControl;
    
    [self.categoryView addSubview:categoryControl];
}

#pragma mark - 分类选择器回调 (PZPagingScrollViewDelegate)
- (void)didSelectedWithSegement:(JTSegmentControl * _Nonnull)segement index:(NSInteger)index {

}

@end
