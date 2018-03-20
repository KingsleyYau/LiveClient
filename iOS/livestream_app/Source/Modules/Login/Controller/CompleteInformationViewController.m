//
//  CompleteInformationViewController.m
//  livestream
//
//  Created by test on 2017/12/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "CompleteInformationViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "DialogOK.h"
#import "DialogTip.h"
#import "LSUploadPhotoRequest.h"
#import "LSFileCacheManager.h"
#import "MailLoginHandler.h"
#import "FacebookLoginHandler.h"
#import "LSLoginManager.h"
#import "LSImageViewLoader.h"
#import "LSAnalyticsManager.h"
#import "LSPhotoClipViewController.h"
@interface CompleteInformationViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UIActionSheetDelegate,LSPhotoClipViewControllerDelegate>{
    CGRect _orgFrame;
    CGRect _newFrame;
}

@property (weak, nonatomic) IBOutlet UIImageView *headIcon;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *femaleBtn;
@property (weak, nonatomic) IBOutlet UIButton *maleBtn;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UITextField *inviteTextField;
/** 日期选择器 */
@property (nonatomic,strong) UIDatePicker *datePicker;
/** actionSheet */
@property (nonatomic,strong) UIActionSheet *actionSheet;
/** info */
@property (nonatomic, strong) DialogOK* infoDialog;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *camBtn;
/** 蒙层图 */
@property (nonatomic, strong) UIView* backgroundView;
@property (strong, nonatomic) LSSessionRequestManager *sessionManager;
/** 上传图片 */
@property (nonatomic,strong) UIImage *uploadingPhoto;

/** 上传图片路径 */
@property (nonatomic, copy) NSString* uploadHeadPath;

/** 是否男士 */
@property (nonatomic, assign , getter=isMale) BOOL male;

/** 相册控制器 */
@property (nonatomic, strong) UIImagePickerController *picker;

@end

@implementation CompleteInformationViewController

- (void)initCustomParam {
    [super initCustomParam];
}

- (void)dealloc {
    NSLog(@"FackBookLoginViewController:dealloc()");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sessionManager = [LSSessionRequestManager manager];
    
    [self setupHeadIcon];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 记录inputview原始大小
    if( CGRectIsEmpty(_orgFrame) ) {
        _orgFrame = self.view.frame;
        
    }
    // 是否用新frame
    if( !CGRectIsEmpty(_newFrame) ) {
        self.view.frame = _newFrame;
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
      [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    self.navigationController.navigationBar.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    // 如果出现标记为已经出现
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:@"completeInformationShow"];
    [userDefaults synchronize];
    
}

- (void)setupContainView {
    [super setupContainView];
    
    [self setupDatePick];
    
    [self setupSexSelect];
    
    [self setupNextBtn];
    
    [self setupTextField];
}

- (void)setupSexSelect {
    
    self.maleBtn.adjustsImageWhenHighlighted = NO;
    self.femaleBtn.adjustsImageWhenHighlighted = NO;
    
    [self.maleBtn setImage:[UIImage imageNamed:@"Person_Information_MaleSelect"] forState:UIControlStateNormal];
    [self.femaleBtn setImage:[UIImage imageNamed:@"Person_Information_Female"] forState:UIControlStateNormal];
    self.male = YES;
    
    if (self.loginInfo.gender == GENDERTYPE_LADY) {
        [self.maleBtn setImage:[UIImage imageNamed:@"Person_Information_Male"] forState:UIControlStateNormal];
        [self.femaleBtn setImage:[UIImage imageNamed:@"Person_Information_FemaleSelect"] forState:UIControlStateNormal];
        self.male = NO;
    } else {
        [self.maleBtn setImage:[UIImage imageNamed:@"Person_Information_MaleSelect"] forState:UIControlStateNormal];
        [self.femaleBtn setImage:[UIImage imageNamed:@"Person_Information_Female"] forState:UIControlStateNormal];
        self.male = YES;
    }
}

- (void)setupTextField {
    self.nameTextField.delegate = self;
    self.inviteTextField.delegate = self;
    if (self.loginInfo.nickName.length > 0) {
        if (self.loginInfo.nickName.length > 14) {
            self.nameTextField.text = [self.loginInfo.nickName substringToIndex:14];
        }else {
            self.nameTextField.text = self.loginInfo.nickName;
        }
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firstInviteCode"]) {
        self.inviteTextField.userInteractionEnabled = YES;
    }else {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        self.inviteTextField.text = [userDefaults stringForKey:@"inviteCode"];
        if (self.inviteTextField.text.length > 0) {
            self.inviteTextField.userInteractionEnabled = NO;
        }else {
            self.inviteTextField.userInteractionEnabled = YES;
        }
    }
}

- (void)setupNextBtn {
    self.nextBtn.layer.cornerRadius = 18.0f;
    self.nextBtn.layer.masksToBounds = YES;
    [self reloadNextBtn];
}

- (void)setupDatePick {
    
    UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 130, [UIScreen mainScreen].bounds.size.width, 130)];
    picker.datePickerMode = UIDatePickerModeDate;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *currentDate = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:-99];
    NSDate *maxDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    [comps setYear:-18];
    NSDate *minDate = [calendar dateByAddingComponents:comps toDate:currentDate options:0];
    NSLocale *usLoacal = [[NSLocale alloc] initWithLocaleIdentifier:@"en-gb"];
    picker.locale = usLoacal;
    
    [picker setMaximumDate:minDate];
    [picker setMinimumDate:maxDate];
    self.backgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundView.backgroundColor = COLOR_WITH_16BAND_RGB_ALPHA(0x66000000);
    self.backgroundView.hidden = YES;
    
    self.dateTextField.delegate = self;
    [self.view addSubview:self.backgroundView];
    [self.view addSubview:picker];
    
    picker.hidden = YES;
    picker.backgroundColor = [UIColor whiteColor];
    [picker addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventValueChanged];
    self.dateTextField.userInteractionEnabled = YES;
    self.datePicker = picker;
}


- (void)setupHeadIcon {
    if (self.loginInfo.photoUrl) {
        [[LSImageViewLoader loader] loadImageWithImageView:self.headIcon options:0 imageUrl:self.loginInfo.photoUrl placeholderImage:[UIImage imageNamed:@"Person_Information_DefailtHead"]];
    }
    self.headIcon.layer.cornerRadius = self.headIcon.frame.size.height * 0.5f;
    self.headIcon.layer.masksToBounds = YES;
    self.headIcon.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headIconDidClick:)];
    [self.headIcon addGestureRecognizer:tap];
}

- (void)headIconDidClick:(UIGestureRecognizer *)gesture {
    [self callSheet];
}

- (void)reloadNextBtn {
    if (self.nameTextField.text.length > 0 && self.dateTextField.text.length > 0 ) {
        self.nextBtn.enabled = YES;
        self.nextBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x5D0E86);
    }else {
        self.nextBtn.enabled = NO;
        self.nextBtn.backgroundColor = [UIColor lightGrayColor];
    }
}


#pragma mark - 按钮操作
- (void)selectDate:(UIDatePicker *)picker {
    NSDate *selectDate = [picker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *birthday = [dateFormatter stringFromDate:selectDate];
    self.dateTextField.text = birthday;
}

- (IBAction)camBtnClickAction:(id)sender {
    [self callSheet];
}

- (IBAction)dateSelectAction:(id)sender {
    [self.view endEditing:YES];
    self.backgroundView.hidden = NO;
    self.datePicker.hidden = NO;
}

- (IBAction)backBtnClickAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)maleBtnClickAction:(id)sender {
    
    [self.maleBtn setImage:[UIImage imageNamed:@"Person_Information_MaleSelect"] forState:UIControlStateNormal];
    [self.femaleBtn setImage:[UIImage imageNamed:@"Person_Information_Female"] forState:UIControlStateNormal];
    self.male = YES;
}

- (IBAction)femaleBtnClickAction:(id)sender {
    
    [self.maleBtn setImage:[UIImage imageNamed:@"Person_Information_Male"] forState:UIControlStateNormal];
    [self.femaleBtn setImage:[UIImage imageNamed:@"Person_Information_FemaleSelect"] forState:UIControlStateNormal];
    self.male = NO;
}

- (BOOL)inputShouldLetter:(NSString *)inputString {
    if (inputString.length == 0) return NO;
    NSString *regex =@"[a-zA-Z]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [pred evaluateWithObject:inputString];
}

- (IBAction)nextBtnClickAction:(id)sender {
    
    [self.view endEditing:YES];
    if (self.nameTextField.text.length < 2) {
        DialogTip *tips = [DialogTip dialogTip];
        [tips showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"Name_Error_tip1")];
        return;
    }
    
    if (![self inputShouldLetter:self.nameTextField.text]) {
        DialogTip *tips = [DialogTip dialogTip];
        [tips showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"Name_Error_tip2")];
        return;
    }
    
    if ([self.nameTextField.text containsString:@" "] || [self.nameTextField.text containsString:@"\t"]) {
        [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"Name_Error_tip3")];
        return ;
    }
    
    self.loginInfo.nickName = self.nameTextField.text;
    self.loginInfo.birthday = self.dateTextField.text;
    self.loginInfo.gender = self.male?GENDERTYPE_MAN:GENDERTYPE_LADY;
    self.loginInfo.inviteCode = self.inviteTextField.text;
    
    [self showLoading];
    
    ILoginHandler * loginHandler = [LSLoginManager manager].loginHandler;
    loginHandler.loginInfo = self.loginInfo;
    [loginHandler registerHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull userSid) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                [[LSLoginManager manager] login:loginHandler];
                
                if (self.uploadHeadPath.length > 0) {
                    [self uploadPhoto:self.uploadHeadPath];
                }
            }
            else
            {
                [[DialogTip dialogTip]showDialogTip:self.view tipText:errmsg];
            }
        });
    }];
    
}

- (IBAction)inviteInfoAction:(id)sender {
    if (!self.infoDialog) {
        self.infoDialog = [DialogOK dialog];
    }
    
    self.infoDialog.tipsLabel.text = NSLocalizedStringFromSelf(@"TIPS_INVITE_CODE");
    [self.infoDialog.okButton setTitle:@"OK" forState:UIControlStateNormal];
    [self.infoDialog.okButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.infoDialog.okButton.backgroundColor = COLOR_WITH_16BAND_RGB(0x5D0E86);
    [self.infoDialog showDialog:self.view
                    actionBlock:^{
                        
                    }];
}

/**
 *  推出选择日期
 */
- (void)cancelDatePicker {
    NSDate *selectDate = [self.datePicker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *birthday =  [dateFormatter stringFromDate:selectDate];
    self.dateTextField.text = birthday;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.backgroundView.hidden == NO) {
        if (self.dateTextField.text.length == 0) {
            [self cancelDatePicker];
        }
    }
    self.backgroundView.hidden = YES;
    self.datePicker.hidden = YES;
    [self.view endEditing:YES];
    [self reloadNextBtn];
}

#pragma mark - 相册逻辑
- (void)callSheet{
    [[LSAnalyticsManager manager] reportActionEvent:UploadAvatar eventCategory:EventCategoryPersonalCenter];
    NSString *photoTypeLibrary = NSLocalizedString(@"PHOTO_LIBRARY", nil);
    NSString *photoTypeTakePhoto = NSLocalizedString(@"PHOTO_TAKING", nil);
    NSString *photoCancel = NSLocalizedString(@"Cancel", nil);
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:photoCancel destructiveButtonTitle:nil otherButtonTitles:photoTypeTakePhoto,photoTypeLibrary, nil,nil];
    }else{
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:photoCancel destructiveButtonTitle:nil otherButtonTitles:photoTypeLibrary, nil,nil];
    }
    self.actionSheet.tag = 1001;
    [self.actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 1001) {
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        NSString *tips = @"";
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            switch (buttonIndex) {
                case 0:
                    //相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    tips = NSLocalizedString(@"Tips_Camera_Allow", nil);
                    break;
                case 1:
                    //相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    tips = NSLocalizedString(@"Tips_PhotoLibrary_Allow", nil);
                    break;
                case 2:
                    return;
                    break;
                default:
                    break;
            }
        }else{
            if (buttonIndex == 0){
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }else{
                return;
            }
        }
        
        //点击打开相册
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = sourceType;
        imagePicker.allowsEditing = NO;
        imagePicker.delegate = self;
        
        NSString *mediaType = AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
        // 是否给相机设置了可以访问权限
        if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
            // 无权限
            UIAlertView *cameraAlert = [[UIAlertView alloc] initWithTitle:nil message:tips delegate:self cancelButtonTitle:NSLocalizedString(@"Close", nil) otherButtonTitles:nil];
            [cameraAlert show];
            return;
        } else {
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
 
    }
}

#pragma mark - 相册代理方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    self.uploadingPhoto = info[UIImagePickerControllerOriginalImage];
    LSPhotoClipViewController *photoClip = [[LSPhotoClipViewController alloc] init];
    photoClip.targetImage = self.uploadingPhoto;
    photoClip.delegate = self;
    [picker pushViewController:photoClip animated:NO];
    self.picker = picker;

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  拍摄完图片回调
 *
 */
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
}

- (void)lsPhotoClipViewController:(LSPhotoClipViewController *)vc didChoosePhoto:(UIImage *)image {
    LSFileCacheManager *manager = [LSFileCacheManager manager];
    UIImage *scaleImage = [image scaleImageWithSize:CGSizeMake(800, 1000)];
    NSString *headPhotoPath = [manager imageUploadCachePath:scaleImage fileName:@"headPhoto.jpg"];
    self.uploadHeadPath = headPhotoPath;
    self.headIcon.image = image;
    [self.picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)lsPhotoClipViewControllerDidcancelChoosePhoto:(LSPhotoClipViewController *)vc {
    [self.picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 输入回调

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if (textField == self.dateTextField) {
        [self.view endEditing:YES];
        [textField resignFirstResponder];
        self.backgroundView.hidden = NO;
        self.datePicker.hidden = NO;
        return NO;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    if (textField == self.inviteTextField) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setBool:YES forKey:@"firstInviteCode"];
        [userDefaults setObject:textField.text forKey:@"inviteCode"];
        [userDefaults synchronize];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (self.nameTextField == textField) {

        // 判断是否超过字符限制
        NSInteger strLength = textField.text.length - range.length + string.length;
        if (strLength >= 14 && string.length >= range.length) {
            // 判断是否删除字符
            if ('\000' != [string UTF8String][0] && ![string isEqualToString:@"\b"]) {
                // 非删除字符，不允许输入
                return  NO;
            }
        }
    }
    
    if (self.dateTextField == textField) {
        return NO;
    }
    return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.nameTextField) {
        [self.dateTextField becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    [UIView animateWithDuration:duration animations:^{
        if(height > 0) {
            // 弹出键盘
            CGFloat inviteTextFieldY = CGRectGetMaxY(self.inviteTextField.frame);
            //如果键盘高度遮挡住了邀请码的填写则整体上移
            if (screenSize.height - height < inviteTextFieldY && [self.inviteTextField isFirstResponder]) {
                _newFrame = CGRectMake(_orgFrame.origin.x, _orgFrame.origin.y - height, _orgFrame.size.width, _orgFrame.size.height);
                self.view.frame = _newFrame;
            }
            
        } else {
            self.view.frame = _orgFrame;
            _newFrame = CGRectZero;
            
            
        }
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *userInfo = [notification userInfo];
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. Thze bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}

- (BOOL)uploadPhoto:(NSString *)photoName {
    LSUploadPhotoRequest *request = [[LSUploadPhotoRequest alloc] init];
    request.photoName = photoName;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull photoUrl) {
        if (success) {
            
        }
    };
    return [self.sessionManager sendRequest:request];
}
@end
