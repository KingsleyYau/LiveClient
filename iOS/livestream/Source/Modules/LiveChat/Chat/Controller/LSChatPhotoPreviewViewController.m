//
//  ChatPhotoPreviewViewController.m
//  dating
//
//  Created by Calvin on 2018/12/21.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSChatPhotoPreviewViewController.h"
#import "LSChatPhotoDataManager.h"
#import "LSChatPhoneAlbumPhoto.h"
#import "LSChatPhotoCollectionViewCell.h"
@interface LSChatPhotoPreviewViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet LSCollectionView *collectionView;
@end

@implementation LSChatPhotoPreviewViewController
- (void)initCustomParam {
    [super initCustomParam];
    self.isShowNavBar = NO;
}

- (void)dealloc {
    NSLog(@"LSChatPhotoPreviewViewController::dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sendBtn.layer.cornerRadius = self.sendBtn.frame.size.height / 2;
    self.sendBtn.layer.masksToBounds = YES;

    self.collectionView.pagingEnabled = YES;
    // 设置布局样式
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    flowlayout.minimumLineSpacing = 0;
    flowlayout.minimumInteritemSpacing = 0;
    flowlayout.itemSize = CGSizeMake(screenSize.width, screenSize.height);
    flowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.collectionView.collectionViewLayout = flowlayout;

    UINib *nib = [UINib nibWithNibName:@"LSChatPhotoCollectionViewCell" bundle:[LiveBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[LSChatPhotoCollectionViewCell cellIdentifier]];
    self.collectionView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    
    //监听进入后台
    __weak typeof(self) weakSelf = self;
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                      object:app
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      [weakSelf backBtnDid:nil];
                                                  }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.photoIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (IBAction)sendBtnDid:(id)sender {
    self.sendBtn.userInteractionEnabled = NO;
    LSChatPhoneAlbumPhoto *albumPhoto = [[LSChatPhotoDataManager manager].photoPathArray objectAtIndex:self.photoIndex];
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.resizeMode = PHImageRequestOptionsResizeModeNone;//控制照片尺寸
    option.synchronous = YES;//主要是这个设为YES这样才会只走一次
    option.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestImageForAsset:albumPhoto.asset
                                               targetSize:PHImageManagerMaximumSize
                                              contentMode:PHImageContentModeAspectFill
                                                  options:option
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                                                if (result) {
                                                    result = [result imageCropForSize:1280];
                                                    NSString *path = [[LSChatPhotoDataManager manager] getOriginalPhotoPath:result andImageName:albumPhoto.fileName];
                                                    albumPhoto.originalPath = path;
                                                    [[LSChatPhotoDataManager manager] choosePhotoURL:path];
                                                }
                                            }];
}

- (IBAction)backBtnDid:(id)sender {
    if (self.isFormChatVC) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [LSChatPhotoDataManager manager].photoPathArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSChatPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LSChatPhotoCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    cell.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
    LSChatPhoneAlbumPhoto *albumPhoto = [[LSChatPhotoDataManager manager].photoPathArray objectAtIndex:indexPath.row];

    [[PHImageManager defaultManager] requestImageForAsset:albumPhoto.asset
                                               targetSize:PHImageManagerMaximumSize
                                              contentMode:PHImageContentModeAspectFill
                                                  options:nil
                                            resultHandler:^(UIImage *result, NSDictionary *info) {
                                                if (result) {
                                                    [cell.photoImageView setImage:result];
                                                }
                                            }];
    cell.photoEditView.hidden = YES;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    self.photoIndex = indexPath.row;
}

@end
