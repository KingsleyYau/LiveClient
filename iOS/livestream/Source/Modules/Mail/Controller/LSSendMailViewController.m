//
//  LSSendMailViewController.m
//  livestream
//
//  Created by test on 2018/12/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSSendMailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "LSImageViewLoader.h"
#import "LSMailFileItem.h"
#import "QNChatTextView.h"
#import "LSFileCacheManager.h"
#import "LSMailAttachmentModel.h"
#import "LSMailAttachmentViewController.h"
#import "LSUploadLetterPhotoRequest.h"
#import "LiveRoomCreditRebateManager.h"
#import "DialogTip.h"
#import "LSAddCreditsViewController.h"
#import "LSSendEmfRequest.h"
#import "LSGetSendMailPriceRequest.h"
#import "LSOutOfCreditsView.h"
#import "LSOutOfPoststampView.h"
#import "LiveModule.h"
#import "LSSendMailDraftManager.h"
#import "LSUserInfoManager.h"
#import "LSShadowView.h"
#import <YYText.h>
#define TEXTMAX 6000
#define TAP_HERE_URL @"TAP_HERE_URL"

typedef enum : NSUInteger {
    AlertViewTypeDefault = 0,      //默认无操作
    AlertViewTypeBack,             //返回草稿
    AlertViewTypeUploading,        //图片上传中
    AlertViewTypeSendTip,          //发送二次确认提示
    AlertViewTypeSendSuccessfully, //发送成功
    AlertViewTypeNoSendPermissions //没有发信权限
} AlertViewType;

@interface LSSendMailViewController () <LSSendMailPhotoViewDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, ChatTextViewDelegate, LSOutOfPoststampViewDelegate, LSOutOfCreditsViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backBtnTop;
@property (weak, nonatomic) IBOutlet UIView *onlineView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
// 文本提示
@property (weak, nonatomic) IBOutlet YYLabel *infoTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet QNChatTextView *textView;
@property (strong, nonatomic) IBOutlet LSSendMailPhotoView *photoView;
@property (nonatomic, strong) NSMutableArray *fileArray;
@property (nonatomic, strong) NSMutableArray *previewArray; //预览数组
@property (nonatomic, strong) NSMutableArray *md5Array;
@property (nonatomic, assign) BOOL isUploading;
@property (weak, nonatomic) IBOutlet UIView *doneView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fileViewH;
@property (nonatomic, assign) BOOL isStamps; //是否用邮票发送
@property (nonatomic, copy) NSString *infoStr;
@property (nonatomic, assign) NSInteger uploadMaxNum; //图片上传最大数量
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (weak, nonatomic) IBOutlet UIView *noCreditsView;
@property (weak, nonatomic) IBOutlet UILabel *addCreditsLabel;
@property (nonatomic, assign) CGFloat credit;                      //发信需要的信用点
@property (nonatomic, assign) CGFloat stamps;                      //发信需要的邮票
@property (nonatomic, strong) LSOutOfCreditsView *creditsView;     //买点弹窗
@property (nonatomic, strong) LSOutOfPoststampView *poststampView; //邮票弹窗
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doneViewY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewH;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (nonatomic, assign) CGFloat keyboardH; //键盘高度
@property (nonatomic, assign) CGFloat textH;     //文本高度
@property (nonatomic, assign) NSInteger fileRow; //附件点击row
@property (weak, nonatomic) IBOutlet UIButton *addCreditsBtn;
@property (weak, nonatomic) IBOutlet UIView *noPermisionView;
@property (weak, nonatomic) IBOutlet UILabel *noPermisionLabel;
@property (weak, nonatomic) IBOutlet UIView *noPermisionContentView;
@property (nonatomic, assign) BOOL isLoadCredit;
@property (nonatomic, strong) LSUserInfoManager *userInfoManager;
@end

@implementation LSSendMailViewController
- (void)initCustomParam {
    [super initCustomParam];
    
    // 隐藏导航栏
    self.isShowNavBar = NO;
    // 禁止导航栏后退手势
    self.canPopWithGesture = NO;
}

- (void)dealloc {
    for (LSMailFileItem *item in self.fileArray) {
        if (item.filePath.length > 0) {
            [[LSFileCacheManager manager] removeDirectory:item.filePath];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.sessionManager = [LSSessionRequestManager manager];

    self.userInfoManager = [LSUserInfoManager manager];

    self.headImage.layer.cornerRadius = self.headImage.frame.size.height / 2;
    self.headImage.layer.masksToBounds = YES;

    self.sendBtn.layer.cornerRadius = 8;
    self.sendBtn.layer.masksToBounds = YES;

    self.addCreditsBtn.layer.cornerRadius = 8;
    self.addCreditsBtn.layer.masksToBounds = YES;

    self.noPermisionContentView.layer.cornerRadius = 6.0f;
    self.noPermisionContentView.layer.masksToBounds = YES;

    LSShadowView *shadowView = [[LSShadowView alloc] init];
    [shadowView showShadowAddView:self.addCreditsBtn];

    LSShadowView *shadowView1 = [[LSShadowView alloc] init];
    [shadowView1 showShadowAddView:self.sendBtn];

    LSShadowView *shadowView2 = [[LSShadowView alloc] init];
    shadowView2.shadowColor = Color(0, 0, 0, 38);
    [shadowView2 showShadowAddView:self.noPermisionContentView];

    self.onlineView.layer.cornerRadius = self.onlineView.frame.size.height / 2;
    self.onlineView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.onlineView.layer.borderWidth = 2.0f;

    self.textView.height = 163;
    self.textView.chatTextViewDelegate = self;

    if ([LSDevice iPhoneXStyle]) {
        self.backBtnTop.constant = 50;
    } else {
        self.backBtnTop.constant = 28;
    }

    //初始化草稿箱
    [[LSSendMailDraftManager manager] initMailDraftLadyId:self.anchorId name:self.anchorName];

    if (self.quickReplyStr.length > 0) {
        self.textView.text = self.quickReplyStr;
        if (![self.quickReplyStr isEqualToString:[[LSSendMailDraftManager manager] getDraftContent:self.anchorId]]) {
            [LSSendMailDraftManager manager].isEdit = YES;
        }
    } else {
        self.textView.text = [[LSSendMailDraftManager manager] getDraftContent:self.anchorId];
    }

    self.nameLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SEND_MAIL_NAME"), self.anchorName];

    // 获取用户信息
    __weak typeof(self) weakSelf = self;
    [self.userInfoManager getUserInfo:self.anchorId
                        finishHandler:^(LSUserInfoModel *_Nonnull item) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                NSLog(@"LSSendMailViewController::getUserInfo( 获取用户信息回调 userId : %@, photoUrl : %@ nickName: %@)", item.userId, item.photoUrl, item.nickName);
                                if (item.photoUrl.length > 0) {
                                    weakSelf.photoUrl = item.photoUrl;
                                    [[LSImageViewLoader loader] loadImageFromCache:weakSelf.headImage
                                                                           options:0
                                                                          imageUrl:weakSelf.photoUrl
                                                                  placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]
                                                                     finishHandler:^(UIImage *image){
                                                                     }];
                                }
                                self.onlineView.hidden = !item.isOnline;
                            });
                        }];

    self.photoView.delegate = self;

    self.previewArray = [NSMutableArray array];
    self.md5Array = [NSMutableArray array];

    [self ShowMailPermissionsTip];

    // 邮票提示
    [self setupInfoTip];
    [self setupInfoTipLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:nil];
    BOOL userSendMailPriv = [LSLoginManager manager].loginItem.userPriv.mailPriv.userSendMailPriv;
    if (userSendMailPriv) {
        if (!self.isLoadCredit) {
            [self showLoading];
            [[LiveRoomCreditRebateManager creditRebateManager] getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideLoading];
                    self.isLoadCredit = YES;
                    if (success) {
                        //没点没邮票
                        if (postStamp < 1 && credit < 0.8) {
                            self.noCreditsView.hidden = NO;
                            self.addCreditsLabel.text = NSLocalizedStringFromSelf(@"NO_CREDITS");
                        } else {
                            self.noCreditsView.hidden = YES;
                        }
                    }
                });
            }];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark - 权限判断
- (void)showNoPermisionContent {
    self.noPermisionView.hidden = NO;
}

- (void)ShowMailPermissionsTip {

    //没有发信权限
    if (![LSLoginManager manager].loginItem.userPriv.mailPriv.userSendMailPriv) {

        self.noPermisionLabel.text = NSLocalizedStringFromSelf(@"SEND_MAIL_PERMISSOINS_TIP");
        [self showNoPermisionContent];
        //        [self showAlertViewMsg:NSLocalizedStringFromSelf(@"SEND_MAIL_PERMISSOINS_TIP") cancelBtnMsg:NSLocalizedStringFromSelf(@"OK") otherBtnMsg:nil alertViewType:AlertViewTypeNoSendPermissions];
    }

    //判断是否用邮票还是信用点发送
    if ([LiveRoomCreditRebateManager creditRebateManager].mPostStamp >= 1) {
        self.isStamps = YES;
        self.infoStr = [LSLoginManager manager].loginItem.userPriv.mailPriv.userSendMailImgPriv.postStampMsg;
    } else {
        self.isStamps = NO;
        self.infoStr = [LSLoginManager manager].loginItem.userPriv.mailPriv.userSendMailImgPriv.coinMsg;
    }

    self.fileArray = [NSMutableArray array];
    //图片上传数量
    self.uploadMaxNum = [LSLoginManager manager].loginItem.userPriv.mailPriv.userSendMailImgPriv.maxImg;

    //没有发照片权限，隐藏控件
    if ([LSLoginManager manager].loginItem.userPriv.mailPriv.userSendMailImgPriv.mailSendPriv == LSSENDIMGRISKTYPE_NOSEND || self.uploadMaxNum == 0) {
        self.fileViewH.constant = 0;
    }

    for (int i = 0; i < self.uploadMaxNum; i++) {
        LSMailFileItem *item = [[LSMailFileItem alloc] init];
        item.type = FileType_Add;
        [self.fileArray addObject:item];
        if (self.fileArray.count == 3) {
            break;
        }
    }

    self.photoView.photoArray = self.fileArray;
}
- (IBAction)closePermisionView:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 返回按钮点击事件
- (IBAction)backBtnDid:(id)sender {
    if ([[LSSendMailDraftManager manager] isShowDraftDialogLadyId:self.anchorId name:self.anchorName content:self.textView.text]) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedStringFromSelf(@"Back_Tip") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *saveAC = [UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"Save Draft") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self alertView:AlertViewTypeBack clickCancleOrOther:0];
        }];
        UIAlertAction *deleAC = [UIAlertAction actionWithTitle:NSLocalizedStringFromSelf(@"Delete Draft") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self alertView:AlertViewTypeBack clickCancleOrOther:1];
        }];
        UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:saveAC];
        [alertVC addAction:deleAC];
        [alertVC addAction:cancelAC];
        [self presentViewController:alertVC animated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 买点按钮点击事件
- (IBAction)addCreditsBtnDid:(id)sender {
    self.isLoadCredit = NO;
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 发送按钮点击事件
- (IBAction)sendBtnDid:(id)sender {
    [[LiveModule module].analyticsManager reportActionEvent:ReplyMailClickSendMail eventCategory:EventCategoryMail];

    if ([self.textView.text isEqualToString:[NSString stringWithFormat:@"Dear %@,\n", self.anchorName]] || self.textView.text.length == 0 || [self isEmpty:self.textView.text]) {
        [self showAlertViewMsg:NSLocalizedStringFromSelf(@"NO_MAIL_TEXT") cancelBtnMsg:nil otherBtnMsg:NSLocalizedString(@"OK", nil) alertViewType:AlertViewTypeDefault];
        return;
    }

    BOOL isUploadError = NO;
    for (LSMailFileItem *model in self.fileArray) {
        if (model.uploadStatus == UploadStatus_error) {
            isUploadError = YES;
            break;
        }
    }
    if (self.isUploading || isUploadError) {
        [self showAlertViewMsg:NSLocalizedStringFromSelf(@"SEND_MAIL_UPLOADING") cancelBtnMsg:NSLocalizedString(@"OK", nil) otherBtnMsg:nil alertViewType:AlertViewTypeDefault];
        return;
    }

    [self showLoading];
    LSGetSendMailPriceRequest *request = [[LSGetSendMailPriceRequest alloc] init];
    int photoNum = 0;
    for (LSMailFileItem *item in self.fileArray) {
        if (item.url.length > 0) {
            photoNum++;
        }
    }
    request.imgNumber = photoNum;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, double creditPrice, double stampPrice) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSendMailViewController::LSGetSendMailPriceRequest %@ errmsg: %@ errnum: %d creditPrice: %f stampPrice : %f", BOOL2SUCCESS(success), errmsg, errnum, creditPrice, stampPrice);
            [self hideLoading];
            if (success) {
                self.credit = creditPrice;
                self.stamps = stampPrice;
                NSString *str = @"";
                if (self.isStamps) {
                    str = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SENDMAIL_STAMPS_TIP"), self.stamps];
                } else {
                    str = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"SENDMAIL_CREDIT_TIP"), self.credit];
                }
                [self showAlertViewMsg:str cancelBtnMsg:NSLocalizedString(@"Cancel", nil) otherBtnMsg:NSLocalizedString(@"OK", nil) alertViewType:AlertViewTypeSendTip];
            } else {
                [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

- (void)sendMail {
    [self showLoading];
    WeakObject(self, weakSelf);
    LSSendEmfRequest *request = [[LSSendEmfRequest alloc] init];
    request.anchorId = self.anchorId;
    if (self.loiId) {
        request.loiId = self.loiId;
    }
    if (self.emfId) {
        request.emfId = self.emfId;
    }
    request.content = self.textView.text;
    NSMutableArray *uploadedArray = [NSMutableArray array];
    for (LSMailFileItem *item in self.fileArray) {
        if (item.url.length > 0) {
            [uploadedArray addObject:item.url];
        }
    }
    request.imgList = uploadedArray;
    request.comsumeType = self.isStamps == YES ? LSLETTERCOMSUMETYPE_STAMP : LSLETTERCOMSUMETYPE_CREDIT;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSendMailViewController::sendBtnDid %@ errmsg: %@ errnum: %d", BOOL2SUCCESS(success), errmsg, errnum);
            [weakSelf hideLoading];
            if (success) {
                if ([weakSelf.sendDelegate respondsToSelector:@selector(sendMailIsSuccess:)]) {
                    [weakSelf.sendDelegate sendMailIsSuccess:weakSelf];
                }

                [weakSelf showAlertViewMsg:NSLocalizedStringFromSelf(@"SEND_MAIL_SUCCESSFULLY") cancelBtnMsg:NSLocalizedString(@"OK", nil) otherBtnMsg:nil alertViewType:AlertViewTypeSendSuccessfully];
                [[LiveRoomCreditRebateManager creditRebateManager] getLeftCreditRequest:^(BOOL success, double credit, int coupon, double postStamp, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg){

                }];
                [[LSSendMailDraftManager manager] deleteMailDraft:self.anchorId];
            } else {
                if (errnum == HTTP_LCC_ERR_LETTER_NO_CREDIT_OR_NO_STAMP) {
                    if (weakSelf.isStamps) {
                        //显示邮票弹窗
                        [weakSelf showStampsView];
                    } else {
                        //显示余额弹窗
                        [weakSelf showCreditsView];
                    }
                } else {
                    [weakSelf showAlertViewMsg:errmsg cancelBtnMsg:nil otherBtnMsg:NSLocalizedString(@"OK", nil) alertViewType:AlertViewTypeDefault];
                }
            }
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - 邮票/余额 弹窗
- (void)showStampsView {
    [self.creditsView removeFromSuperview];
    self.creditsView = nil;
    [self.poststampView removeFromSuperview];
    self.poststampView = nil;
    self.poststampView = [LSOutOfPoststampView initWithActionViewDelegate:self];
    [self.poststampView outOfPoststampShowCreditView:self.view balanceCount:[NSString stringWithFormat:@"%0.1f", self.credit]];
}

- (void)lsOutOfPoststampView:(LSOutOfPoststampView *)addView didSelectAddCredit:(UIButton *)creditBtn {
    [self.poststampView removeFromSuperview];
    self.poststampView = nil;
    self.isStamps = NO;
    [self setupInfoTipLabel];
    [self sendMail];
}

- (void)showCreditsView {
    [self.creditsView removeFromSuperview];
    self.creditsView = nil;
    [self.poststampView removeFromSuperview];
    self.poststampView = nil;
    self.creditsView = [LSOutOfCreditsView initWithActionViewDelegate:self];
    [self.creditsView outOfCreditShowPoststampAndAddCreditView:self.view poststampCount:[NSString stringWithFormat:@"%0.0f", self.stamps]];
}

- (void)lsOutOfCreditsView:(LSOutOfCreditsView *)addView didSelectAddCredit:(UIButton *)creditBtn {
    [self.creditsView removeFromSuperview];
    self.creditsView = nil;
    LSAddCreditsViewController *vc = [[LSAddCreditsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)lsOutOfCreditsView:(LSOutOfCreditsView *)addView didSelectSendPoststamp:(UIButton *)SendPoststampBtn {
    [self.creditsView removeFromSuperview];
    self.creditsView = nil;
    self.isStamps = YES;
    [self setupInfoTipLabel];
    [self sendMail];
}

#pragma mark - file回调
- (void)sendMailPhotoViewDidRow:(NSInteger)row {
    [[LiveModule module].analyticsManager reportActionEvent:ReplyMailUploadPhoto eventCategory:EventCategoryMail];
    self.fileRow = row;
    [self.view endEditing:YES];
    LSMailFileItem *item = self.fileArray[row];
    if (item.type == FileType_Add) {
        if ([self uploadToMaxTip]) {
            return;
        }
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedStringFromSelf(@"Camera"), NSLocalizedStringFromSelf(@"Album"), nil];
        [actionSheet showInView:self.view];
    } else {
        if (item.uploadStatus == UploadStatus_succeed) {
            //点击查看原图
            LSMailAttachmentViewController *vc = [[LSMailAttachmentViewController alloc] initWithNibName:nil bundle:nil];
            vc.attachmentsArray = self.previewArray;
            vc.photoIndex = row;
            UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
            [nvc.navigationBar setTranslucent:self.navigationController.navigationBar.translucent];
            [nvc.navigationBar setTintColor:self.navigationController.navigationBar.tintColor];
            [nvc.navigationBar setBarTintColor:self.navigationController.navigationBar.barTintColor];
            [self presentViewController:nvc
                               animated:NO
                             completion:nil];
        } else if (item.uploadStatus == UploadStatus_error) {

            item.uploadStatus = UploadStatus_uploading;
            self.photoView.photoArray = self.fileArray;
            [self uploadPhotoFromimageName:item.fileName imagePath:item.filePath];
        } else {
        }
    }
}

- (void)sendMailPhotoViewRemoveRow:(NSInteger)row {
    if (!self.isUploading) {
        [self.fileArray removeObjectAtIndex:row];
        [self.md5Array removeObjectAtIndex:row];
        if (self.fileArray.count <= 3) {
            self.fileViewH.constant = 100;
        }

        if (self.uploadMaxNum > 3) {
            if (row == self.uploadMaxNum - 1 || self.fileArray.count < 3) {
                LSMailFileItem *item = [[LSMailFileItem alloc] init];
                item.type = FileType_Add;
                [self.fileArray addObject:item];
            } else if (self.fileArray.count == 5) {
                LSMailFileItem *item = [[LSMailFileItem alloc] init];
                item.type = FileType_Add;
                BOOL result = YES;
                for (LSMailFileItem *item in self.fileArray) {
                    if (item.type == FileType_Add) {
                        result = NO;
                    }
                }
                if (result) {
                    [self.fileArray addObject:item];
                }
            }
        } else {
            LSMailFileItem *item = [[LSMailFileItem alloc] init];
            item.type = FileType_Add;
            [self.fileArray addObject:item];
        }

        self.photoView.photoArray = self.fileArray;
        [self.previewArray removeObjectAtIndex:row];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (actionSheet.cancelButtonIndex != buttonIndex) {
        if (buttonIndex == 0) {
            [self emfAddPhotoViewSelectIsCamera:YES];
        } else {
            [self emfAddPhotoViewSelectIsCamera:NO];
        }
    }
}
#pragma mark - 图片按钮点击回调
- (void)emfAddPhotoViewSelectIsCamera:(BOOL)isCamera {

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
            [self showAlertViewMsg:cameraAllow cancelBtnMsg:NSLocalizedString(@"Close", nil) otherBtnMsg:nil alertViewType:AlertViewTypeDefault];
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
        [self showAlertViewMsg:disableCamera cancelBtnMsg:NSLocalizedString(@"Close", nil) otherBtnMsg:nil alertViewType:AlertViewTypeDefault];
    }
}

#pragma mark - 拍摄和相册回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *, id> *)info {
    LSFileCacheManager *fileCacheManager = [LSFileCacheManager manager];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    UIImage *fixOrientationImage = [image fixOrientation];

    if (fixOrientationImage.size.width > fixOrientationImage.size.height) {
        //横图
        if (fixOrientationImage.size.width > 1280) {
            fixOrientationImage = [fixOrientationImage scaleWithFixedWidth:1280];
        }
    } else {
        //竖图
        if (fixOrientationImage.size.height > 1280) {
            fixOrientationImage = [fixOrientationImage scaleWithFixedHeight:1280];
        }
    }

    NSString *imageName = [NSString stringWithFormat:@"EMF%ld", time(NULL) * 1000];
    NSString *path = [fileCacheManager imageUploadCachePath:fixOrientationImage fileName:[NSString stringWithFormat:@"%@.jpg", imageName]];
    //上传图片
    [self uploadPhotoFromimageName:imageName imagePath:path];

    LSMailFileItem *item = [[LSMailFileItem alloc] init];
    item.fileName = imageName;
    item.image = image;
    item.uploadStatus = UploadStatus_uploading;
    item.type = FileType_Photo;
    item.msg = @"Uploading";
    item.filePath = path;

    [self.fileArray replaceObjectAtIndex:self.fileRow withObject:item];

    BOOL isADD = YES;
    for (int i = 0; i < self.fileArray.count; i++) {
        LSMailFileItem *item = self.fileArray[i];
        if (item.type == FileType_Add) {
            isADD = NO;
            break;
        }
    }

    if (isADD && self.fileArray.count < self.uploadMaxNum) {
        LSMailFileItem *item = [[LSMailFileItem alloc] init];
        item.type = FileType_Add;
        [self.fileArray addObject:item];
    }

    LSMailAttachmentModel *model = [[LSMailAttachmentModel alloc] init];
    model.attachType = AttachmentTypeSendPhoto;
    model.originImgUrl = path;
    [self.previewArray addObject:model];

    if (self.fileArray.count > 3) {
        self.fileViewH.constant = 200;
    }
    self.photoView.photoArray = self.fileArray;
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (BOOL)uploadToMaxTip {
    BOOL isMax = NO;
    if (self.fileArray.count >= self.uploadMaxNum + 1) {
        [self showAlertViewMsg:NSLocalizedStringFromSelf(@"Upload_maxNum_error") cancelBtnMsg:NSLocalizedString(@"OK", nil) otherBtnMsg:nil alertViewType:AlertViewTypeDefault];
        isMax = YES;
    }
    return isMax;
}

#pragma mark 上传图片
- (void)uploadPhotoFromimageName:(NSString *)name imagePath:(NSString *)path {
    self.isUploading = YES;
    LSUploadLetterPhotoRequest *request = [[LSUploadLetterPhotoRequest alloc] init];
    request.file = path;
    request.fileName = name;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *errmsg, NSString *url, NSString *md5, NSString *fileName) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSSendMailViewController:uploadPhotoFromimageName 上传图片: %@  fileName : %@, errmsg : %@ url:%@", BOOL2SUCCESS(success), fileName, errmsg, url);
            self.isUploading = NO;

            for (LSMailFileItem *model in self.fileArray) {
                if ([model.fileName isEqualToString:fileName] && model.type == FileType_Photo) {
                    if (success) {
                        model.msg = @"Uploaded";
                        model.uploadStatus = UploadStatus_succeed;
                        model.url = url;

                        for (NSString *str in self.md5Array) {
                            if ([md5 isEqualToString:str]) {
                                model.uploadStatus = UploadStatus_error;
                                [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"UPLOAD_ERROR_MSG")];
                            }
                        }
                    } else {
                        model.msg = errmsg;
                        model.uploadStatus = UploadStatus_error;
                        [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
                    }
                    break;
                }
            }
            self.photoView.photoArray = self.fileArray;
            [self.md5Array addObject:md5];
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - AlertView回调
- (void)showAlertViewMsg:(NSString *)titleMsg cancelBtnMsg:(NSString *)cancelMsg otherBtnMsg:(NSString *)otherMsg alertViewType:(AlertViewType)type {
    [self.view endEditing:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.56 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:titleMsg preferredStyle:UIAlertControllerStyleAlert];
        if (cancelMsg.length > 0) {
            UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:cancelMsg style:UIAlertActionStyleCancel handler:nil];
            [alertVC addAction:cancelAC];
        }
        if (otherMsg.length > 0) {
            UIAlertAction *otherAC = [UIAlertAction actionWithTitle:otherMsg style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self alertView:type clickCancleOrOther:1];
            }];
            [alertVC addAction:otherAC];
        }
        [self presentViewController:alertVC animated:YES completion:nil];
    });
}

- (void)alertView:(NSInteger)tag clickCancleOrOther:(NSInteger)index {
    switch (tag) {
        case AlertViewTypeBack: { //返回弹窗
            if (index == 0) {
                //Save Draft
                [[LSSendMailDraftManager manager] saveMailDraftFromLady:self.anchorId content:self.textView.text];
                [self.navigationController popViewControllerAnimated:YES];
            } else if (index == 1) {
                //Delete Draft
                [[LSSendMailDraftManager manager] deleteMailDraft:self.anchorId];
                [self.navigationController popViewControllerAnimated:YES];
            }
        } break;
        case AlertViewTypeUploading: { //图片上传中
            
        } break;
        case AlertViewTypeSendTip: { //发送二次确认提示
            if (index != 0) {
                [[LiveModule module].analyticsManager reportActionEvent:ReplyMailConfirmSendMail eventCategory:EventCategoryMail];
                [self sendMail];
            }
        } break;
        case AlertViewTypeSendSuccessfully: { //发送成功
            [self.navigationController popViewControllerAnimated:YES];
        } break;
        case AlertViewTypeNoSendPermissions: { //没有发信权限
            [self.navigationController popViewControllerAnimated:YES];
        } break;
        default:
            break;
    }
}

#pragma mark - 键盘监听事件
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    // 设置键盘的高度
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    // 设置键盘的高度为0
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    [self.view layoutIfNeeded];
    self.keyboardH = height;
    if (height != 0) {
        // 弹出键盘
        self.doneViewY.constant = -(height + 44);
    } else {
        // 收起键盘
        self.doneViewY.constant = 0;
    }
    [UIView animateWithDuration:duration
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                     }];
}

- (IBAction)deonBtn:(id)sender {
    [self.view endEditing:YES];
}

- (void)textViewTextDidChange:(NSNotification *)notification {

    if (![self.textView.text isEqualToString:self.quickReplyStr]) {
        [LSSendMailDraftManager manager].isEdit = YES;
    }

    if (self.textView.text.length == 0) {
        self.sendBtn.userInteractionEnabled = NO;
        self.sendBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x8CAFF7);
    } else {
        self.sendBtn.userInteractionEnabled = YES;
        self.sendBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x97AF3);

        if (self.textView.text.length > TEXTMAX) {
            self.textView.text = [self.textView.text substringToIndex:TEXTMAX];
        }
    }
}

- (void)textViewChangeHeight:(QNChatTextView *)textView height:(CGFloat)height {

    if (height > 99) {
        self.textViewH.constant = height + 10;
    }

    if (self.keyboardH != 0 && height + 160 > screenSize.height - self.keyboardH - 44) {
        CGFloat scrollH = height - self.textH;
        [self.contentScrollView setContentOffset:CGPointMake(0, self.contentScrollView.contentOffset.y + scrollH) animated:YES];
    }
    self.textH = height;

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.textView setNeedsDisplay];
    });
}
#pragma mark - 设置底部信息UI
- (void)setupInfoTip {
    self.infoTipLabel.numberOfLines = 0;
    self.infoTipLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 40;
    self.infoTipLabel.font = [UIFont systemFontOfSize:12];
    self.infoTipLabel.displaysAsynchronously = NO;

    WeakObject(self, weakSelf);
    [self.infoTipLabel setHighlightTapAction:^(UIView *_Nonnull containerView, NSAttributedString *_Nonnull text, NSRange range, CGRect rect) {
        YYTextHighlight *highlight = [text yy_attribute:YYTextHighlightAttributeName atIndex:range.location];
        NSString *link = highlight.userInfo[@"linkUrl"];
        if ([link isEqualToString:TAP_HERE_URL]) {
            weakSelf.isStamps = !weakSelf.isStamps;
            [weakSelf setupInfoTipLabel];
        }
    }];
}

- (void)setupInfoTipLabel {
    //TODO: 判断是否有邮票
    if (self.isStamps) {
        self.infoStr = [LSLoginManager manager].loginItem.userPriv.mailPriv.userSendMailImgPriv.postStampMsg;
    } else {
        self.infoStr = [LSLoginManager manager].loginItem.userPriv.mailPriv.userSendMailImgPriv.coinMsg;
    }
    if (self.infoStr.length > 0) {
        //创建  NSMutableAttributedString 富文本对象
        NSMutableAttributedString *maTitleString = [[NSMutableAttributedString alloc] initWithString:self.infoStr attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x999999)}];

        UIImage *image = [UIImage imageNamed:@"Mail_Reply_Tip_Button"];
        //添加到富文本对象里
        NSMutableAttributedString *imageStr = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeCenter attachmentSize:image.size alignToFont:[UIFont systemFontOfSize:12] alignment:YYTextVerticalAlignmentCenter];
        //加入文字后面
        [maTitleString appendAttributedString:imageStr];

        YYTextHighlight *highlight = [YYTextHighlight new];
        NSRange imgRange = [maTitleString.string rangeOfString:imageStr.string];
        highlight.userInfo = @{ @"linkUrl" : TAP_HERE_URL };
        [maTitleString yy_setTextHighlight:highlight range:imgRange];
        
        YYTextContainer *container = [[YYTextContainer alloc] init];
        container.size = CGSizeMake(SCREEN_WIDTH - 40, 56);
        YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:maTitleString];
        self.infoTipLabel.textLayout = layout;
        
        //        self.infoTipLabel.attributedText = maTitleString;
    }
}

-(BOOL)isEmpty:(NSString *) str {
    NSCharacterSet*set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString*trimedString = [str stringByTrimmingCharactersInSet:set];
    if([trimedString length] ==0) {
        return YES;
    }else{
        return NO;
    }
}


@end
