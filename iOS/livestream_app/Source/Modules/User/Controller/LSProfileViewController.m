//
//  LSProfileViewController.m
//  livestream
//
//  Created by test on 2017/12/26.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSProfileViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LSGetManBaseInfoRequest.h"
#import "LSUploadPhotoRequest.h"
#import "LSProfilePhotoTableViewCell.h"
#import "LSLoginManager.h"
#import "LSFileCacheManager.h"
#import "UserInfoManager.h"
#import "DialogTip.h"
#import "LSImageViewLoader.h"
#import "EditProFileViewController.h"
#import "LSAnalyticsManager.h"
#import "LSPhotoClipViewController.h"
@interface LSProfileViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate,LSListViewControllerDelegate,LSPhotoClipViewControllerDelegate>

@property (nonatomic,strong) NSArray *titleArray;
/** 数据 */
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) LSSessionRequestManager* sessionManager;
@property (nonatomic, strong) LSLoginManager* loginManager;
@property (nonatomic, strong) UserInfoManager * userInfoManager;
@property (nonatomic, strong) UIImagePickerController *picker;
@end

@implementation LSProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController setNavigationBarHidden:NO];
    // 禁用返回手势
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    //[self reloadData:YES];
    [self getUserInfo];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

#pragma mark - 界面逻辑
- (void)setupContainView{
    [super setupContainView];
    
    [self setupTableView];
    self.title = NSLocalizedStringFromSelf(@"Profile");
}

- (void)initCustomParam{
    // 初始化父类参数
    [super initCustomParam];
    self.sessionManager = [LSSessionRequestManager manager];
    self.loginManager = [LSLoginManager manager];
    self.userInfoManager = [UserInfoManager manager];
}

- (void)setupTableView {
    
    [self.tableView setTableFooterView:[UIView new]];
    self.tableView.separatorColor = COLOR_WITH_16BAND_RGB_ALPHA(0x61db96ff);
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
}

#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView{
    self.titleArray = @[NSLocalizedStringFromSelf(@"Avatar"),
                        NSLocalizedStringFromSelf(@"ID"),
                        NSLocalizedStringFromSelf(@"Nickname"),
                        NSLocalizedStringFromSelf(@"Gender"),
                        NSLocalizedStringFromSelf(@"Birthday")];
    
    self.dataArray = @[self.loginManager.loginItem.photoUrl,
                       self.loginManager.loginItem.userId,
                       self.loginManager.loginItem.nickName,
                       self.loginManager.loginItem.gender==GENDERTYPE_MAN?@"Male":@"Female",
                       self.loginManager.loginItem.birthday];
    
    if(isReloadView) {
        [self.tableView reloadData];
    }
}

- (void)updateNameStatus:(UILabel *)label
{
    NSString * str = @"";
    switch ([LSLoginManager manager].loginItem.nickNameStatus) {
        case NICKNAMEVERIFYSTATUS_HANDLDING:{
            // 审核中
            str = [NSString stringWithFormat:@"%@ (%@)",NSLocalizedStringFromSelf(@"Nickname"),NSLocalizedStringFromSelf(@"Pending Approval")];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
            NSRange ranges = NSMakeRange(0, str.length);
            [attributedString addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x3c3c3c) range:ranges];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:ranges];
            NSRange range = [str rangeOfString:NSLocalizedStringFromSelf(@"Pending Approval")];
            [attributedString addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x00A0E9) range:range];
            label.attributedText = attributedString;
            
        }break;
        case NICKNAMEVERIFYSTATUS_FINISH:{
            // 审核完成
            str = NSLocalizedStringFromSelf(@"Nickname");
            
            label.text = str;
        }break;
        default:
            str = NSLocalizedStringFromSelf(@"Nickname");
            
            label.text = str;
            break;
    }
}

#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    if(indexPath.row == 0) {
        height = [LSProfilePhotoTableViewCell cellHeight];
    }
    else
    {
        height = 50;
    }
    
    return height;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    if (indexPath.row == 0) {
        LSProfilePhotoTableViewCell *cell = [LSProfilePhotoTableViewCell getUITableViewCell:tableView];
        
        cell.textLabel.text = [self.titleArray objectAtIndex:indexPath.row];
        
        [[LSImageViewLoader loader] stop];
        [[LSImageViewLoader loader] refreshCachedImage:cell.profilePhoto options:SDWebImageRefreshCached imageUrl:self.loginManager.loginItem.photoUrl placeholderImage:[UIImage imageNamed:@"UserHead_bg"]];
        
        [cell updateAvatarStatus];
        return cell;
    }
    else
    {
        static NSString * cellName = @"ProFileCell";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellName];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = COLOR_WITH_16BAND_RGB(0x3c3c3c);
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = indexPath.row == 2?UITableViewCellAccessoryDisclosureIndicator: UITableViewCellSelectionStyleNone;
            if (indexPath.row == 2) {
                [self updateNameStatus:cell.textLabel];
            }
            else
            {
                cell.textLabel.text = [self.titleArray objectAtIndex:indexPath.row];
            }
        }
        
        cell.detailTextLabel.text = [self.dataArray objectAtIndex:indexPath.row];
        
        return cell;
    }
    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        if (self.loginManager.loginItem.photoStatus == PHOTOVERIFYSTATUS_HANDLDING) {
            [[DialogTip dialogTip]showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"avatar_tip")];
        }
        else
        {
            [self callSheet];
        }
    }
    else if (indexPath.row == 2)
    {
        EditProFileViewController * vc = [[EditProFileViewController alloc]initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        
    }
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
    self.actionSheet.tag = 1000;
    [self.actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (actionSheet.tag == 1000) {
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
        imagePicker.allowsEditing = NO;
        imagePicker.delegate = self;
        imagePicker.sourceType = sourceType;
        
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
    UIImage *uploadingPhoto = info[UIImagePickerControllerOriginalImage];
    LSPhotoClipViewController *photoClip = [[LSPhotoClipViewController alloc] init];
    photoClip.targetImage = uploadingPhoto;
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
    [self showLoading];
    [self uploadPhoto:headPhotoPath];
    [self.picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)lsPhotoClipViewControllerDidcancelChoosePhoto:(LSPhotoClipViewController *)vc {
    [self.picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)uploadPhoto:(NSString *)photoName {
    LSUploadPhotoRequest *request = [[LSUploadPhotoRequest alloc] init];
    request.photoName = photoName;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, NSString * _Nonnull photoUrl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            NSLog(@"LSProfileViewController::uploadPhoto ( [上传用户头像], success : %d, errnum : %ld, errmsg : %@, photoUrl : %@ )",success, (long)errnum, errmsg, photoUrl);
            if (success) {
                [self getUserInfo];
                [[DialogTip dialogTip]showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"Photo_Uploaded_Success")];
            }
            else
            {
                [[DialogTip dialogTip]showDialogTip:self.view tipText:errmsg];
            }
        });
    };
    return [self.sessionManager sendRequest:request];
}

- (void)getUserInfo
{
    [self showLoading];
    [self.userInfoManager getMyProfileInfoFinishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, LSManBaseInfoItemObject * _Nonnull infoItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                self.loginManager.loginItem = infoItem;
                [self reloadData:YES];
            }else {
                [self showFailView];
            }
        });
    }];
}


- (void)showFailView {
    self.failView.hidden = NO;
    self.failTipsText = NSLocalizedString(@"List_FailTips", @"List_FailTips");
    self.failBtnText = NSLocalizedString(@"List_Reload", @"List_Reload");
    self.delegate = self;
    [self reloadFailViewContent];
}

- (void)lsListViewController:(LSListViewController *)listView didClick:(UIButton *)sender {
    self.failView.hidden = YES;
    [self getUserInfo];
}

@end
