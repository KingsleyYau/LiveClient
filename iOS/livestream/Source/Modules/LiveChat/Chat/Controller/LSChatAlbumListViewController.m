//
//  ChatAlbumListViewController.m
//  dating
//
//  Created by Calvin on 2018/12/21.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSChatAlbumListViewController.h"
#import "LSChatPhotoDataManager.h"
#import "LSChatPhoneAlbumPhoto.h"
#import "LSChatPhotoCollectionViewCell.h"
#import "QNChatTitleView.h"
#import "LSImageViewLoader.h"
#import "Masonry.h"
#import "LSChatPhotoPreviewViewController.h"
@interface LSChatAlbumListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource,ChatPhotoDataManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) QNChatTitleView *titleView;
@property (nonatomic, strong) NSArray * array;
@end

@implementation LSChatAlbumListViewController

- (void)dealloc {
    NSLog(@"LSChatAlbumListViewController::dealloc");
    [[LSChatPhotoDataManager manager] removeDelegate:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [[LSChatPhotoDataManager manager] addDelegate:self];
    // 设置布局样式
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    flowlayout.minimumLineSpacing = 0;
    flowlayout.minimumInteritemSpacing = 0;
    flowlayout.itemSize = CGSizeMake(screenSize.width/3, screenSize.width/3);
    flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    self.collectionView.collectionViewLayout = flowlayout;
    
    UINib *nib = [UINib nibWithNibName:@"LSChatPhotoCollectionViewCell" bundle:[LiveBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[LSChatPhotoCollectionViewCell cellIdentifier]];
    
    self.array = [LSChatPhotoDataManager manager].photoPathArray;
    
    [self.collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"Navigation_Back_Button"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(0, 0, 40, 40);
    [backBtn addTarget:self action:@selector(backBtnDid:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    self.title = @"Album";
}

- (void)chatPhotoDataManagerReloadData {
    self.array = [LSChatPhotoDataManager manager].photoPathArray;
    [self.collectionView reloadData];
}

- (void)backBtnDid:(UIButton *)btn {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSChatPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LSChatPhotoCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    if (self.array.count  > 0) {
        LSChatPhoneAlbumPhoto *albumPhoto = [self.array objectAtIndex:indexPath.row];
        
        [[PHImageManager defaultManager] requestImageForAsset:albumPhoto.asset
                                                   targetSize:CGSizeMake(screenSize.width/2,screenSize.width/2)
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:nil
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    if (result) {
                                                        [cell.photoImageView setImage:result];
                                                    }
                                                }];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    LSChatPhotoPreviewViewController * vc = [[LSChatPhotoPreviewViewController alloc]initWithNibName:nil bundle:nil];
    vc.photoIndex = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
