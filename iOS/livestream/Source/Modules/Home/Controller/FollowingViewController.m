//
//  FollowingViewController.m
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "FollowingViewController.h"
#import "FollowListItemObject.h"

@interface FollowingViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *tipsImageView;
@property (weak, nonatomic) IBOutlet UIButton *tipsBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipsTitle;
@property (weak, nonatomic) IBOutlet UIButton *BrowseHot;
@property (nonatomic, strong) NSMutableArray *items;

/**
 *  接口管理器
 */
//@property (nonatomic, strong) SessionRequestManager* sessionManager;

@end

@implementation FollowingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 跳转到热门页面
    //    [self.BrowseHot addTarget:self.homePageVC action:@selector(BrowseToHotAction:) forControlEvents:UIControlEventTouchUpInside];
    // 测试用
    [self.BrowseHot addTarget:self action:@selector(BrowseToHotAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initCustomParam {
    [super initCustomParam];
    self.items = [NSMutableArray array];
}

- (void)dealloc {
    
}

- (void)setupContainView {
    [super setupContainView];
    self.BrowseHot.layer.cornerRadius = self.BrowseHot.frame.size.height * 0.5f;
    self.BrowseHot.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if( self.items.count == 0 ) {
        [self showTipsContent];
        
    } else {
        [self hideTipsContent];
        
    }
}

- (void)setupCollectionView {
    
}

- (void)showTipsContent {
    self.tipsBtn.hidden = NO;
    self.tipsImageView.hidden = NO;
    self.tipsTitle.hidden = NO;
}

- (void)hideTipsContent {
    self.tipsBtn.hidden = YES;
    self.tipsImageView.hidden = YES;
    self.tipsTitle.hidden = YES;
}

#pragma mark - 数据逻辑
- (void)initTestData {
    FollowListItemObject* item = nil;
    item = [[FollowListItemObject alloc] init];
    item.firstName = @"Angelica";
    item.imageUrl = @"http://images3.charmdate.com/woman_photo/C2248/161/C235829-f007f8438f8b56a94575f68f655e788b-1.jpg";
    [self.items addObject:item];
    
    item = [[FollowListItemObject alloc] init];
    item.firstName = @"Marry";
    item.imageUrl = @"http://images3.charmdate.com/woman_photo/C1251/132/C615703-84398ccb04629db648dfb7ee8b64b03c-4.jpg";
    [self.items addObject:item];
    
    item = [[FollowListItemObject alloc] init];
    item.firstName = @"Vera";
    item.imageUrl = @"http://images3.charmdate.com/woman_photo/C1610/150/C833381-14784b57f3f37270e79f606e80d33a0c-1.jpg";
    [self.items addObject:item];
    
    item = [[FollowListItemObject alloc] init];
    item.firstName = @"Anna";
    item.imageUrl = @"http://images3.charmdate.com/woman_photo/C3069/169/C251959-754b69462fe0ae1268256e3ba8b712cf-7.jpg";
    [self.items addObject:item];
    
}

- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    if( isReloadView ) {
        self.collectionView.items = self.items;
        [self.collectionView reloadData];
    }
}

- (void)BrowseToHotAction:(id)sender {
    [self initTestData];
    [self hideTipsContent];
    [self reloadData:YES];
}

@end
