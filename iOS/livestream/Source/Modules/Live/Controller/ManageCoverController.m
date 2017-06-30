//
//  ManageCoverController.m
//  livestream
//
//  Created by randy on 17/6/19.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ManageCoverController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#import "SelectCoverViewCell.h"
#import "LxGridViewFlowLayout.h"
#import "DeleteTipView.h"

#import "TZImagePickerController.h"
#import "TZImageManager.h"
#import "TZVideoPlayerController.h"
#import "TZPhotoPreviewController.h"
#import "TZGifPhotoPreviewController.h"
#import "TZLocationManager.h"

#import "UploadLiveRoomImgRequest.h"
#import "AddLiveRoomPhotoRequest.h"
#import "DelLiveRoomPhotoRequest.h"
#import "GetLiveRoomPhotoListRequest.h"
#import "SetUsingLiveRoomPhotoRequest.h"

#import "FileCacheManager.h"

@interface ManageCoverController ()<TZImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,DeleteTipViewDelegate>{
    
    NSMutableArray *_selectedImageId;
    BOOL _isSelectOriginalPhoto;
    
    CGFloat _itemWH;
    CGFloat _margin;
}

@property (strong, nonatomic) UICollectionView *coverCollectionView;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic, strong) DeleteTipView *tipView;

/**
 *  接口管理器
 */
@property (nonatomic, strong) SessionRequestManager* sessionManager;

@end

@implementation ManageCoverController
- (void)initCustomParam {
    [super initCustomParam];
    
    self.navigationTitle = NSLocalizedString(@"Manage Cover", nil);
    
    self.sessionManager = [SessionRequestManager manager];
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
    
}

- (void)setupContainView {
    [super setupContainView];
}

- (void)setupInputView {

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _margin = 14;
    _itemWH = (SCREEN_WIDTH - 4*_margin) / 3;
    layout.itemSize = CGSizeMake(_itemWH, _itemWH + DESGIN_TRANSFORM_3X(30));
    layout.minimumInteritemSpacing = _margin;
    layout.minimumLineSpacing = _margin;
    
    CGFloat collectionHeight = (SCREEN_HEIGHT - DESGIN_TRANSFORM_3X(350))*0.5;
    
    _coverCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, collectionHeight) collectionViewLayout:layout];
    _coverCollectionView.alwaysBounceVertical = NO;
    _coverCollectionView.backgroundColor = [UIColor whiteColor];
    _coverCollectionView.contentInset = UIEdgeInsetsMake(2, 14, 2, 14);
    _coverCollectionView.dataSource = self;
    _coverCollectionView.delegate = self;
    _coverCollectionView.scrollEnabled = NO;
    _coverCollectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_coverCollectionView];
    [_coverCollectionView registerClass:[SelectCoverViewCell class] forCellWithReuseIdentifier:[SelectCoverViewCell cellIdentifier]];
    
    
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(14)];
    label.textColor = COLOR_WITH_16BAND_RGB(0xbfbfbf);
    label.numberOfLines = 2;
    label.text = @"Broadcaster has at most 3 covers \nNot through the cover will be removed directly";
    [self.view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@14);
        make.top.equalTo(@(collectionHeight + DESGIN_TRANSFORM_3X(20)));
    }];
    
    
    _tipView = [[DeleteTipView alloc]initWithFrame:CGRectMake(0, -SCREEN_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _tipView.deleteDelegate = self;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (iOS9Later) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupInputView];
    
    _isSelectOriginalPhoto = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 显示导航栏
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // 设置导航栏返回按钮
    [self setBackleftBarButtonItemOffset:30];
}

#pragma mark UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.coverList.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectCoverViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[SelectCoverViewCell cellIdentifier] forIndexPath:indexPath];
    if (indexPath.row == self.coverList.count) {
        cell.imageView.image = [UIImage imageNamed:@"Live_Select_btn"];
        cell.deleteBtn.hidden = YES;
        cell.userButton.hidden = YES;
        cell.maskView.hidden = YES;
        cell.label.hidden = YES;
        
    } else {
        
        [cell setCellCoverImage:self.coverList[indexPath.row]];
    }
    cell.deleteBtn.tag = indexPath.row;
    cell.userButton.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    [cell.userButton addTarget:self action:@selector(setLiverUseNomalCover:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.coverList.count) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"去相册选择", nil];
        [sheet showInView:self.view];
        
    } else {
        // 图片预览器
//        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:_selectedAssets selectedPhotos:_selectedPhotos index:indexPath.row];
//        imagePickerVc.maxImagesCount = 3;
//        imagePickerVc.allowPickingOriginalPhoto = NO;
//        imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
//        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
//            _selectedPhotos = [NSMutableArray arrayWithArray:photos];
//            _selectedAssets = [NSMutableArray arrayWithArray:assets];
//            _isSelectOriginalPhoto = isSelectOriginalPhoto;
//            [_coverCollectionView reloadData];
//            _coverCollectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
//        }];
//        [self presentViewController:imagePickerVc animated:YES completion:nil];
    }
}

#pragma mark - TZImagePickerController

- (void)pushTZImagePickerController {
    
    // 相片浏览器
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    
    // 是否选择原图
    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    
    // 1.设置目前已经选中的图片数组
    imagePickerVc.selectedAssets = self.coverList; // 目前已经选中的图片数组
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    
    // 2. 在这里设置imagePickerVc的外观
// imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
// imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
// imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
// imagePickerVc.navigationBar.translucent = NO;
    
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowCrop = YES;
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}


#pragma mark - UIImagePickerController

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && iOS7Later) {
        // 无相机权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        if (iOS7Later) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self takePhoto];
                    });
                }
            }];
        } else {
            [self takePhoto];
        }
        // 拍照之前还需要检查相册权限
    } else if ([TZImageManager authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        alert.tag = 1;
        [alert show];
    } else if ([TZImageManager authorizationStatus] == 0) { // 未请求过相册权限
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            [self takePhoto];
        }];
    } else {
        [self pushImagePickerController];
    }
}

// 调用相机
- (void)pushImagePickerController {
    // 提前定位
    [[TZLocationManager manager] startLocationWithSuccessBlock:^(CLLocation *location, CLLocation *oldLocation) {
        _location = location;
    } failureBlock:^(NSError *error) {
        _location = nil;
    }];
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        self.imagePickerVc.allowsEditing = YES;
        if(iOS8Later) {
            _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
    }
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        tzImagePickerVc.sortAscendingByModificationDate = YES;
        [tzImagePickerVc showProgressHUD];
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        
        // 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image location:self.location completion:^(NSError *error){
            if (error) {
                [tzImagePickerVc hideProgressHUD];
                NSLog(@"图片保存失败 %@",error);
            } else {
                [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
                    [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
                        [tzImagePickerVc hideProgressHUD];
                        TZAssetModel *assetModel = [models firstObject];
                        if (tzImagePickerVc.sortAscendingByModificationDate) {
                            assetModel = [models lastObject];
                        }
                        [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
                    }];
                }];
            }
        }];
    }
}

- (void)refreshCollectionViewWithAddedAsset:(id)asset image:(UIImage *)image {
    
    NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
    NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
    NSString *imagePath = [[FileCacheManager manager]imageUploadCachePath:image fileName:orgFilename];
    
    [self showLoading];
    
    // 上传主播封面请求
    UploadLiveRoomImgRequest *request = [[UploadLiveRoomImgRequest alloc]init];
    request.type = IMAGETYPE_COVER;
    request.imageFileName = imagePath;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull imageId, NSString * _Nonnull imageUrl){
        
        [self hideLoading];
        if (success) {
            
            // 添加主播封面
            [self addLiveRoomPhotoRequestForImageid:imageId];
            
        }else{
            
            NSLog(@"UploadLiveRoomImgRequest : errnum%ld,errmsg%@",(long)errnum,errmsg);
        }
    };
    [self.sessionManager sendRequest:request];
    
    
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = asset;
        NSLog(@"location:%@",phAsset.location);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // take photo / 去拍照
        [self takePhoto];
    } else if (buttonIndex == 1) {
        [self pushTZImagePickerController];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
        if (iOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        } else {
            NSURL *privacyUrl;
            if (alertView.tag == 1) {
                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
            } else {
                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
            }
            if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
                [[UIApplication sharedApplication] openURL:privacyUrl];
            } else {
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"抱歉" message:@"无法跳转到隐私设置页面，请手动前往设置页面，谢谢" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
}

#pragma mark - TZImagePickerControllerDelegate

/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
   
}

#pragma mark - 选图回调
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    NSArray *resources = [PHAssetResource assetResourcesForAsset:assets.lastObject];
    NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
    UIImage *image = photos.lastObject;
    NSString *imagePath = [[FileCacheManager manager]imageUploadCachePath:image fileName:orgFilename];
    
    [self showLoading];
    
    // 上传主播封面请求
    UploadLiveRoomImgRequest *request = [[UploadLiveRoomImgRequest alloc]init];
    request.type = IMAGETYPE_COVER;
    request.imageFileName = imagePath;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull imageId, NSString * _Nonnull imageUrl){
        
        [self hideLoading];
        if (success) {
            
            // 添加主播封面
            [self addLiveRoomPhotoRequestForImageid:imageId];
            
        }else{
            
            NSLog(@"UploadLiveRoomImgRequest : errnum : %ld,errmsg : %@",(long)errnum,errmsg);
        }
    };
    [self.sessionManager sendRequest:request];
    
    
    // 1.打印图片名字
    [self printAssetsName:assets];
    
    // 2.图片位置信息
    if (iOS8Later) {
        for (PHAsset *phAsset in assets) {
            NSLog(@"location:%@",phAsset.location);
        }
    }
}

// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result {
    return YES;
}

// 决定asset显示与否
- (BOOL)isAssetCanSelect:(id)asset {
    return YES;
}

#pragma mark - Click Event(删除回调)/(设置默认封面)
// (删除回调)
- (void)deleteBtnClik:(UIButton *)sender {
    
    [self.tipView deleteTipViewShowWithTap:sender.tag];
}

// (设置默认封面)
- (void)setLiverUseNomalCover:(UIButton *)sender{
    
    CoverPhotoItemObject *object = self.coverList[sender.tag];
    [self setUsingLiveRoomPhotoRequestWithImageId:object.photoId];
}

#pragma mark - DeleteTipViewDelegate
- (void)deleteImageFromeController{
    
    CoverPhotoItemObject *object = self.coverList[self.tipView.tagNum];
    
    // 删除主播封面图
    [self delLiveRoomPhotoRequestWithImageId:object.photoId andTag:self.tipView.tagNum];
}

#pragma mark - AddLiveRoomPhotoRequest(添加主播封面请求)

- (void)addLiveRoomPhotoRequestForImageid:(NSString *)imageId{
    
    // 添加主播封面请求
    AddLiveRoomPhotoRequest *addRequest = [[AddLiveRoomPhotoRequest alloc]init];
    addRequest.photoId = imageId;
    addRequest.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg) {
        
        [self hideLoading];
        if (success) {
            
            // 请求主播封面列表
            [self getLiveRoomPhotoListRequest];
            
        }else{
            
            NSLog(@"AddLiveRoomPhotoRequest : errnum : %ld,errmsg : %@",(long)errnum,errmsg);
        }
        
    };
    [self.sessionManager sendRequest:addRequest];
}

#pragma mark - AddLiveRoomPhotoRequest(删除主播封面请求)

- (void)delLiveRoomPhotoRequestWithImageId:(NSString *)imageId andTag:(NSInteger)tag{
    
    [self showLoading];
    
    DelLiveRoomPhotoRequest *request = [[DelLiveRoomPhotoRequest alloc]init];
    request.photoId = imageId;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg) {
        
        [self hideLoading];
        if (success) {
            // 请求主播封面列表
            [self getLiveRoomPhotoListRequest];
            
        }else{
        
            NSLog(@"DelLiveRoomPhotoRequest : errnum : %ld,errmsg : %@",(long)errnum,errmsg);
        }
        [self.tipView cancelPrompt];
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - SetUsingLiveRoomPhotoRequest(设置主播默认封面)

- (void)setUsingLiveRoomPhotoRequestWithImageId:(NSString *)imageId{
    
    [self showLoading];
    SetUsingLiveRoomPhotoRequest *request = [[SetUsingLiveRoomPhotoRequest alloc]init];
    request.photoId = imageId;
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg) {
    
        [self hideLoading];
        if (success) {
            // 请求主播封面列表
            [self getLiveRoomPhotoListRequest];
            
        }else{
            
            NSLog(@"SetUsingLiveRoomPhotoRequest : errnum : %ld,errmsg : %@",(long)errnum,errmsg);
        }
        
    };
    [self.sessionManager sendRequest:request];
}


#pragma mark - GetLiveRoomPhotoListRequest(请求主播封面列表)

- (void)getLiveRoomPhotoListRequest{
    
    GetLiveRoomPhotoListRequest *request = [[GetLiveRoomPhotoListRequest alloc]init];
    request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg,
                              NSArray<CoverPhotoItemObject *> * _Nullable array) {
        
        [self hideLoading];
        
        if (success) {
            
            if (array.count) {
                
                self.coverList = [NSMutableArray arrayWithArray:array];
                [_coverCollectionView reloadData];
                
            }else{
                
                self.coverList = nil;
                [_coverCollectionView reloadData];
            }
            
        }else{
            NSLog(@"GetLiveRoomPhotoListRequest : errnum : %ld,errmsg : %@",(long)errnum,errmsg);
        }
        
    };
    [self.sessionManager sendRequest:request];
}

// 收起键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Private

/// 打印图片名字
- (void)printAssetsName:(NSArray *)assets {
    NSString *fileName;
    for (id asset in assets) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            fileName = [phAsset valueForKey:@"filename"];
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)asset;
            fileName = alAsset.defaultRepresentation.filename;;
        }
        //NSLog(@"图片名字:%@",fileName);
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
