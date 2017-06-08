//
//  DiscoverViewController.m
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "DiscoverViewController.h"
#import "DiscoverListItemObject.h"

@interface DiscoverViewController ()
@property (nonatomic, strong) NSMutableArray *items;
@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initTestData];
    [self reloadData:YES];
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

}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    

}

#pragma mark - 数据逻辑
- (void)initTestData {
    DiscoverListItemObject* item = nil;
    item = [[DiscoverListItemObject alloc] init];
    item.firstName = @"Angelica";
    item.imageUrl = @"http://images3.charmdate.com/woman_photo/C2248/161/C235829-f007f8438f8b56a94575f68f655e788b-1.jpg";
    [self.items addObject:item];
    
    item = [[DiscoverListItemObject alloc] init];
    item.firstName = @"Marry";
    item.imageUrl = @"http://images3.charmdate.com/woman_photo/C1251/132/C615703-84398ccb04629db648dfb7ee8b64b03c-4.jpg";
    [self.items addObject:item];
    
    item = [[DiscoverListItemObject alloc] init];
    item.firstName = @"Vera";
    item.imageUrl = @"http://images3.charmdate.com/woman_photo/C1610/150/C833381-14784b57f3f37270e79f606e80d33a0c-1.jpg";
    [self.items addObject:item];
    
    item = [[DiscoverListItemObject alloc] init];
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




@end
