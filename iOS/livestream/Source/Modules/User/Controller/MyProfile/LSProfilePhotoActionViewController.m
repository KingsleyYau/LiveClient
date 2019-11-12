//
//  LSProfilePhotoActionViewController.m
//  livestream
//
//  Created by test on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSProfilePhotoActionViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LSPhotoClipViewController.h"
#import "LSUploadUserPhotoRequest.h"
#import "LSFileCacheManager.h"
#import "DialogTip.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface LSProfilePhotoActionViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,LSPhotoClipViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
/** 相册控制器 */
@property (nonatomic, strong) UIImagePickerController *picker;
// 接口管理器
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (nonatomic, assign) BOOL navBarHidden;
@end

@implementation LSProfilePhotoActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.contentView.layer.cornerRadius = 5;
    self.contentView.layer.masksToBounds = YES;
    
    self.bgView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToDismiss:)];
    [self.bgView addGestureRecognizer:tap];
    
    self.sessionManager = [LSSessionRequestManager manager];
        
}

- (void)initCustomParam {
    [super initCustomParam];
    self.isShowNavBar = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self dismissView];
    self.navigationController.navigationBar.hidden = self.navBarHidden;
    
}

- (void)tapToDismiss:(UITapGestureRecognizer *)gesture {
    [self dismissView];
}

- (void)dismissView {
    [self didMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}


- (void)showPhotoAction:(UIViewController *)vc {
    [vc addChildViewController:self];
    [vc.view addSubview:self.view];
    [self didMoveToParentViewController:vc];
    
    self.navBarHidden = vc.navigationController.navigationBar.hidden;

    [self.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.equalTo(vc.view);
    }];
    
}

- (IBAction)takePhotoAction:(id)sender {
    [self photoViewSelectIsCamera:YES];
}

- (IBAction)chooseAlbum:(id)sender {
    [self photoViewSelectIsCamera:NO];
}
- (IBAction)cancelAction:(id)sender {
    [self dismissView];
}


- (void)photoViewSelectIsCamera:(BOOL)isCamera {
    // 手机能否打开相机/相册
    if ([UIImagePickerController isSourceTypeAvailable:isCamera ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        // 是否给相机设置了可以访问权限
        if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
            NSString *photoLibrarymessageTips = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"Tips_Allow", nil), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"], NSLocalizedString(@"Tips_PhotoLibrary_Allow", nil)];
            NSString *cameraMessageTips = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"Tips_Allow", nil), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"], NSLocalizedString(@"Tips_PhotoLibrary_Allow", nil)];
            // 无权限
            NSString *cameraAllow = isCamera ? photoLibrarymessageTips : cameraMessageTips;
            [self showOKAlertControllerMsg:cameraAllow];
            return;
        } else {
            // 点击打开相机/相册
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.allowsEditing = NO;
            imagePicker.delegate = self;
            imagePicker.sourceType = isCamera ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
    } else {
        NSString *photoLibrarymessageTips = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"Allow", nil), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"], NSLocalizedString(@"Tips_PhotoLibrary_Allow", nil)];
        NSString *cameraMessageTips = [NSString stringWithFormat:@"%@ %@ %@", NSLocalizedString(@"Allow", nil), [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"], NSLocalizedString(@"Tips_PhotoLibrary_Allow", nil)];
        NSString *disableCamera = isCamera ? cameraMessageTips : photoLibrarymessageTips;
        [self showOKAlertControllerMsg:disableCamera];
     
    }
}


#pragma 判断文件格式
// 是否符合上传格式png/jpeg/jpg
- (BOOL)typeForImage:(NSString *)type {
    BOOL result = YES;
    
    if ([type hasSuffix:@"png"] || [type hasSuffix:@"PNG"] ) {
        result = YES;
    }else if ([type hasSuffix:@"jpeg"] || [type hasSuffix:@"JPEG"]) {
        result = YES;
    }else if([type hasSuffix:@"jpg"] || [type hasSuffix:@"JPG"]) {
        result = YES;
    }else {
        result = NO;
    }
    return result;
    
}

#pragma mark - 拍摄和相册回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {

    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        NSString *assetString = [[info objectForKey:UIImagePickerControllerReferenceURL] absoluteString];
        BOOL result = NO;
        result = [self typeForImage:assetString];
        if (result) {
            LSPhotoClipViewController *photoClip = [[LSPhotoClipViewController alloc] init];
            photoClip.targetImage = info[UIImagePickerControllerOriginalImage];
            photoClip.delegate = self;
            [picker pushViewController:photoClip animated:NO];
            self.picker = picker;
        }else {
            [picker dismissViewControllerAnimated:YES completion:^{
                 [[DialogTip dialogTip] showDialogTip:self.view tipText:@"Upload failed. Your photo should be in JPEG format."];
            }];
            
        }
    }else if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        LSPhotoClipViewController *photoClip = [[LSPhotoClipViewController alloc] init];
        photoClip.targetImage = info[UIImagePickerControllerOriginalImage];
        photoClip.delegate = self;
        [picker pushViewController:photoClip animated:NO];
        self.picker = picker;
    }

}

/**
 *  结束操作
 *
 *  @param picker 相机控制
 */
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)showOKAlertControllerMsg:(NSString *)msg {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)lsPhotoClipViewController:(LSPhotoClipViewController *)vc didChoosePhoto:(UIImage *)image withLoadingView:(UIView *)loadingView{
    LSFileCacheManager *manager = [LSFileCacheManager manager];
    UIImage *scaleImage = nil;
    scaleImage = image;
    if (image.size.height > 750 || image.size.width > 750) {
        scaleImage = [image scaleImageWithSize:CGSizeMake(750, 750)];

    }
    NSString *headPhotoPath = [manager imageUploadCachePath:scaleImage fileName:@"headPhoto.jpg"];
    LSUploadUserPhotoRequest *request = [[LSUploadUserPhotoRequest alloc] init];
    request.file = headPhotoPath;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSProfilePhotoActionViewController  UploadUserPhoto  %@ %@", BOOL2SUCCESS(success),errmsg);
            loadingView.hidden = YES;
            vc.view.userInteractionEnabled = YES;
            if (success) {
                [self.picker dismissViewControllerAnimated:YES completion:nil];
                [self dismissView];
                if ([self.actionDelegate respondsToSelector:@selector(lsProfilePhotoActionViewControllerDidFinishPhotoAction:)]) {
                    [self.actionDelegate lsProfilePhotoActionViewControllerDidFinishPhotoAction:self];
                }
            }else {
                [[DialogTip dialogTip] showDialogTip:vc.view tipText:errmsg];
            
            }
          
        });
    };
    [self.sessionManager sendRequest:request];
    

    
}

- (void)lsPhotoClipViewControllerDidcancelChoosePhoto:(LSPhotoClipViewController *)vc {
    [self.picker dismissViewControllerAnimated:YES completion:nil];
    [self dismissView];
}

@end
