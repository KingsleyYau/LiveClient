//
//  LiveFinshViewController.m
//  livestream
//
//  Created by randy on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveFinshViewController.h"
#import "RecommandCollectionViewCell.h"
#import "GetPromoAnchorListRequest.h"

@interface LiveFinshViewController ()

#pragma mark - 推荐逻辑

@property (atomic, strong) NSArray *recommandItems;

@property (nonatomic, strong) SessionRequestManager *sessionManager;

@end

@implementation LiveFinshViewController
- (void)initCustomParam {

}


- (void)dealloc {
    NSLog(@"LiveFinshViewController::dealloc");
}


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)setupContainView {
    
    // 初始化模糊背景
    [self setupBgImageView];
    
    // 初始化推荐控件
    [self setupRecommandView];
    
    // 请求推荐列表
    [self getAdvisementList];
}

- (void)updateControlDataSource {
    
    self.headImageView.layer.cornerRadius = 49;
    self.headImageView.layer.masksToBounds = YES;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:self.liveRoom.httpLiveRoom.photoUrl] placeholderImage:[UIImage imageNamed:@"Live_PreLive_Img_Head_Default"] options:0];
    
    [self.backgroundImageView sd_setImageWithURL:[NSURL URLWithString:self.liveRoom.httpLiveRoom.roomPhotoUrl] placeholderImage:[UIImage imageNamed:@"Live_PreLive_Img_Bg"] options:0];
    
    self.nameLabel.text = self.liveRoom.httpLiveRoom.nickName;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateControlDataSource];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setupBgImageView {
    // 设置模糊
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualView.frame = CGRectMake(0, 0, self.backgroundImageView.width, self.backgroundImageView.height);
    [self.backgroundImageView addSubview:visualView];
}

- (void)setupRecommandView {
    UINib *nib = [UINib nibWithNibName:@"RecommandCollectionViewCell" bundle:nil];
    [self.recommandCollectionView registerNib:nib forCellWithReuseIdentifier:[RecommandCollectionViewCell cellIdentifier]];
    self.recommandView.hidden = YES;
}

- (void)getAdvisementList {
    // TODO:获取推荐列表
    GetPromoAnchorListRequest *request = [[GetPromoAnchorListRequest alloc] init];
    request.number = 2;
    request.userId = @"";
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString *_Nonnull errmsg, NSArray<LiveRoomInfoItemObject *> *_Nullable array) {
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 刷新推荐列表
                self.recommandItems = array;
                [self reloadRecommandView];
            });
        }
    };
    [self.sessionManager sendRequest:request];
}

- (void)reloadRecommandView {
    // TODO:刷新推荐列表
    self.recommandView.hidden = NO;
    [self.recommandCollectionView reloadData];
}

#pragma mark - 推荐逻辑
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recommandItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    RecommandCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[RecommandCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    LiveRoomInfoItemObject *item = [self.recommandItems objectAtIndex:indexPath.row];
    
    cell.imageView.image = nil;
    [cell.imageViewLoader stop];
    [cell.imageViewLoader loadImageWithImageView:cell.imageView
                                         options:0 imageUrl:item.photoUrl
                                placeholderImage:[UIImage imageNamed:@"Test_Lady_Head"]];
    
    cell.nameLabel.text = item.nickName;
    
    return cell;
}

- (IBAction)cancleAction:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}



- (IBAction)bookPrivateAction:(id)sender {
    
}

@end
