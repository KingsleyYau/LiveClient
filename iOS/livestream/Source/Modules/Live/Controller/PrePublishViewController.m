//
//  PrePublishViewController.m
//  livestream
//
//  Created by Max on 2017/5/17.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PrePublishViewController.h"

#import "PublishViewController.h"

#import "GPUImage.h"

#import "CreateLiveRoomRequest.h"

#import "ImageViewLoader.h"

@interface PrePublishViewController ()

/**
 图片加载器
 */
@property (nonatomic, strong) ImageViewLoader* imageViewHeaderLoader;

/**
 *  接口管理器
 */
@property (nonatomic, strong) SessionRequestManager* sessionManager;

@end

@implementation PrePublishViewController
#pragma mark - 界面初始化
- (void)initCustomParam {
    [super initCustomParam];
    
    self.sessionManager = [SessionRequestManager manager];
}

- (void)dealloc {
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self addSingleTap];
    
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self removeSingleTap];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self closeAllInputView];
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goLiveAction:(id)sender {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ( authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied ) {
        // 获取摄像头失败
        NSLog(@"LiveStreamPublisher::checkDevice( 获取摄像头失败 )");
        dispatch_async(dispatch_get_main_queue(), ^{
            // 错误提示
        });
        
    } else {
        // 获取摄像头成功
        NSLog(@"LiveStreamPublisher::checkDevice( 获取摄像头成功 )");
        
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (!granted) {
                // 获取麦克风失败
                NSLog(@"LiveStreamPublisher::checkDevice( 获取麦克风失败 )");
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 错误提示
                });
                
            } else {
                // 获取麦克风成功
                NSLog(@"LiveStreamPublisher::checkDevice( 获取麦克风成功 )");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if( self.textFieldTitle.text.length == 0 ) {
                        // 弹出错误提示
                        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil
                                                                                           message:@"Please Input room name."
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *action = nil;
                        action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil];
                        [alertView addAction:action];
                        
                        [self presentViewController:alertView animated:YES completion:nil];
                    }
                    
                    // 发送开播请求
                    [self createLiveRoomRequest];
                });
            }
        }];
    }
}

#pragma mark - 文本输入控件管理
- (void)addSingleTap {
    if( self.singleTap == nil ) {
        self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAllInputView)];
        [self.view addGestureRecognizer:self.singleTap];
    }
}

- (void)removeSingleTap {
    if( self.singleTap ) {
        [self.view removeGestureRecognizer:self.singleTap];
        self.singleTap = nil;
    }
}

- (void)closeAllInputView {
    [self.textFieldTitle resignFirstResponder];
}

#pragma mark - 文本输入回调
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if( textField.text.length > 0 ) {
        self.btnGoLive.enabled = YES;
    } else {
        self.btnGoLive.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    bool bFlag = NO;
    
    if( textField.text.length > 0 ) {
        [self createLiveRoomRequest];
    }
    
    return bFlag;
}

#pragma mark 数据逻辑
- (void)createLiveRoomRequest {
    // 检查参数
    if ( [self checkInput] ) {
        // 开始菊花
        [self showLoading];
        
        CreateLiveRoomRequest* request = [[CreateLiveRoomRequest alloc] init];
        request.roomName = self.textFieldTitle.text;
        request.roomPhotoId = @"12";
        
        request.finishHandler = ^(BOOL success, NSInteger errnum, NSString * _Nonnull errmsg, NSString * _Nonnull roomId, NSString * _Nonnull roomurl) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // 隐藏菊花
                [self hideLoading];
                
                if( success ) {
                    // 跳进主播界面
                    PublishViewController* vc = [[PublishViewController alloc] initWithNibName:nil bundle:nil];
                    vc.url = @"rtmp://172.25.32.17/live/livestream";//roomurl;//
                    vc.roomId = roomId;
                    
                    [self.navigationController pushViewController:vc animated:YES];
                    
                } else {
                    // 弹出错误提示
                    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil
                                                                                       message:errmsg
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action = nil;
                    action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil];
                    [alertView addAction:action];
                    
                    [self presentViewController:alertView animated:YES completion:nil];
                }
            });
        };
        
        [self.sessionManager sendRequest:request];
    }
}

- (BOOL)checkInput {
    BOOL bFlag = YES;
    
    if ( self.textFieldTitle.text.length > 40 ) {
        // 弹出错误提示
        UIAlertController *alertView = [UIAlertController alertControllerWithTitle:nil
                                                                           message:NSLocalizedStringFromSelf(@"ERROR_INPUT_TOO_MORE")
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = nil;
        action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil];
        [alertView addAction:action];
        
        [self presentViewController:alertView animated:YES completion:nil];
        
        bFlag = NO;
    }
    
    return bFlag;
}

@end
