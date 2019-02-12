//
//  ChangePasswordViewController.m
//  dating
//
//  Created by test on 2017/7/26.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSChangePasswordViewController.h"
#import "LSSessionRequestManager.h"
#import "LSChangePasswordRequest.h"
#import "DialogIconTips.h"


@interface LSChangePasswordViewController ()

/** 任务管理 */
@property (nonatomic,strong) LSDomainSessionRequestManager *sessionManager;
@end

@implementation LSChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromSelf(@"Change_Password");
    self.backTitle = @"";
    self.sessionManager = [LSDomainSessionRequestManager manager];
    
    self.changeBtn.layer.cornerRadius = 5;
    self.changeBtn.layer.masksToBounds = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - 界面事件
- (void)setupNavigationBar{
    [super setupNavigationBar];
    
}

- (void)setupContainView {
    [super setupContainView];
}


#pragma mark 初始化
- (void)initCustomParam {
    // 初始化父类参数
    [super initCustomParam];
    //    self.backTitle = NSLocalizedString(@"", nil);
    
    
}

- (void)dealloc {
    
}
- (IBAction)changeBtnClickAction:(id)sender {
    
    [self checkPassword];
    
    
}


#pragma mark - 输入回调
- (void)textViewDidChange:(UITextView *)textView {
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if ([string isEqualToString:@"\n"]){
        // 判断输入的字是否是回车，即按下return
        [textField resignFirstResponder];
        return NO;
    }
    
    return NO;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if( self.currentPassword == textField ) {
        // 完成email
        [self.currentPassword becomeFirstResponder];
        
    } else if( self.recentPassword == textField ) {
        // 完成密码
        [self.recentPassword becomeFirstResponder];
        
    } else {
        [self checkPassword];
        
    }
    return YES;
}

- (void)checkPassword{
    // 只允许英文和数字
    NSString *str =@"^[A-Za-z0-9\\u4e00-\u9fa5]+$";
    NSPredicate* password = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", str];
    
    if (self.currentPassword.text.length <= 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Tips_EnterCurrentPassword") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if (self.recentPassword.text.length <= 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Tips_EnterNewPassword") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if (self.confirmPassword.text.length <= 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Tips_ConfirmPassword") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else if (self.recentPassword.text.length < 6) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Tips_MinimumPassword") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if (self.recentPassword.text.length > 12) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Tips_MaxPassword") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if (![self.recentPassword.text isEqualToString:self.confirmPassword.text]) {
        //提示两次密码错误,重新输入密码
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Tips_ErrorPassword") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
        self.recentPassword.text = nil;
        self.confirmPassword.text = nil;
        [self.recentPassword becomeFirstResponder];
    }else if (![password evaluateWithObject:self.recentPassword.text]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedStringFromSelf(@"Tips_EndlishAndPassword") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }else {
        [self changePassword];
    }
    
}

- (BOOL)changePassword {
    LSChangePasswordRequest *request = [[LSChangePasswordRequest alloc] init];
    request.passwordOld = self.currentPassword.text;
    request.passwordNew = self.recentPassword.text;
    [self showLoading];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoading];
            if (success) {
                [[DialogIconTips dialogIconTips] showDialogIconTips:self.view tipText:NSLocalizedString(@"Done",nil) tipIcon:nil];
                [self performSelector:@selector(popVC) withObject:self afterDelay:2];
            }else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:errmsg preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                [alertController addAction:action];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        });
        
    };
    return  [self.sessionManager sendRequest:request];
}


- (void)popVC {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
