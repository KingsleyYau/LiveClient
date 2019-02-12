//
//  MotifyAboutYouViewController.m
//  dating
//
//  Created by test on 2018/9/18.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSMotifyAboutYouViewController.h"
#import "LSMotifyPersonalProfileManager.h"
#import "DialogTip.h"
#import "DialogIconTips.h"

#define Minimum 100
#define Maximum 2000
@interface LSMotifyAboutYouViewController ()<UITextViewDelegate,LSMotifyPersonalProfileManagerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomDistance;
/** 修改个人描述 */
@property (nonatomic,strong) LSMotifyPersonalProfileManager *motifyManager;
@end

@implementation LSMotifyAboutYouViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedStringFromSelf(@"About_You");
    UIBarButtonItem *item = [UIBarButtonItem itemWithTarget:self action:@selector(saveAction:) title:NSLocalizedStringFromSelf(@"Save")];
    UIBarButtonItem *itemPlaceholder = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    self.navigationItem.rightBarButtonItems = @[itemPlaceholder,item];
    self.aboutYouTextView.layer.cornerRadius = 6;
    self.aboutYouTextView.layer.masksToBounds = YES;
    self.motifyManager = [LSMotifyPersonalProfileManager manager];
    self.motifyManager.delegate = self;
    
    // 添加键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Do any additional setup after loading the view from its nib.
    [self.aboutYouTextView becomeFirstResponder];
    self.aboutYouTextView.text = self.aboutYouContent;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.aboutYouPlaceholderLabel.hidden = NO;
    }else {
        self.aboutYouPlaceholderLabel.hidden = YES;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length == 0) {
        self.aboutYouPlaceholderLabel.hidden = NO;
    }else {
        self.aboutYouPlaceholderLabel.hidden = YES;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {

    
    return YES;
}


- (void)saveAction:(UIButton *)btn {
    NSString *content = [self.aboutYouTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (content.length < Minimum) {
        NSString *tipsMessage = NSLocalizedStringFromSelf(@"Tips_About_Min");
        [[DialogTip dialogTip] showDialogTip:self.view tipText:tipsMessage];
    
    }else if (content.length > Maximum){
        NSString *tipsMessage = NSLocalizedStringFromSelf(@"Tips_About_Max");
        [[DialogTip dialogTip] showDialogTip:self.view tipText:tipsMessage];
    }else {
        // 添加二次确认是否修改提交
       UIAlertController *confirmAlert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromSelf(@"Tips_About_Confirm") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showLoading];
            [self.view endEditing:YES];
            [self.motifyManager motifyPersonalResume:content];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
        [confirmAlert addAction:okAction];
        [confirmAlert addAction:cancelAction];
        [self presentViewController:confirmAlert animated:YES completion:nil];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)lsMotifyPersonalProfileResult:(LSMotifyPersonalProfileManager *)manager result:(BOOL)success {
    [self hideLoading];
    if (success) {
        [[DialogIconTips dialogIconTips] showDialogIconTips:self.view tipText:@"Done" tipIcon:nil];
        if ([self.motifyDelegate respondsToSelector:@selector(lsMotifyAboutYouViewControllerDidMotifyResume:)]) {
            [self.motifyDelegate lsMotifyAboutYouViewControllerDidMotifyResume:self];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }else {
        NSString *tipsMessage = NSLocalizedStringFromSelf(@"Tips_Update_Fail");
        [[DialogTip dialogTip] showDialogTip:self.view tipText:tipsMessage];
    }
}


#pragma mark - 处理键盘回调
- (void)moveInputBarWithKeyboardHeight:(CGFloat)height withDuration:(NSTimeInterval)duration {
    if (height != 0) {
        // 弹出键盘
        self.bottomDistance.constant = height + 45;
    } else {
        // 收起键盘
        self.bottomDistance.constant = 45;
    }
    [UIView animateWithDuration:duration
                     animations:^{
                         [self.view layoutIfNeeded];
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];

    [self moveInputBarWithKeyboardHeight:keyboardRect.size.height withDuration:animationDuration];

}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self moveInputBarWithKeyboardHeight:0.0 withDuration:animationDuration];
}


- (void)keyboardDidShow:(NSNotification *)notification {
    self.view.userInteractionEnabled = YES;
}

@end
