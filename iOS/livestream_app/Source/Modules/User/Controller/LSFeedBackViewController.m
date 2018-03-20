//
//  LSFeedBackViewController.m
//  livestream
//
//  Created by test on 2017/12/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSFeedBackViewController.h"
#import "DialogTip.h"
#import "LSSubmitFeedBackRequest.h"
#import "LSAnalyticsManager.h"

@interface LSFeedBackViewController ()<LSFeedTextViewDelegate>

@end

@implementation LSFeedBackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initCustomParam {
    [super initCustomParam];
}

- (void)setupContainView {
    [super setupContainView];
    self.feedTextView.placeholder = NSLocalizedStringFromSelf(@"TextView_Tip");
    self.emailTextView.placeholder = NSLocalizedStringFromSelf(@"Address_Tip");
    self.feedTextView.layer.cornerRadius = 4.0f;
    self.emailTextView.layer.cornerRadius = 4.0f;
    self.submitBtn.layer.cornerRadius = 4.0f;
    self.textCount.textColor = COLOR_WITH_16BAND_RGB_ALPHA(0x995d0e86);
    self.textCount.text = @"0 / 300";
    self.feedTextView.layer.masksToBounds = YES;
    self.emailTextView.layer.masksToBounds = YES;
    self.submitBtn.layer.masksToBounds = YES;
    self.feedTextView.chatTextViewDelegate = self;
    self.emailTextView.chatTextViewDelegate = self;
    self.title = NSLocalizedStringFromSelf(@"Feedback");

    if (self.emailTextView.text.length > 0 && self.feedTextView.text.length > 0) {
        self.submitBtn.enabled = YES;
        self.submitBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x5D0E86);
    }else {
        self.submitBtn.enabled = NO;
        self.submitBtn.backgroundColor = [UIColor lightGrayColor];
    }
    
}



#pragma mark - 输入栏高度改变回调
- (void)textViewChangeHeight:(LSFeedTextView * _Nonnull)textView height:(CGFloat)height {

}

- (void)textViewChangeWord:(LSFeedTextView *)textView {
    
    if (self.feedTextView == textView) {
        self.textCount.text = [NSString stringWithFormat:@"%lu / 300",(unsigned long)textView.text.length];
        
        if (textView.text.length >= 300) {
            self.textCount.text = @"300 / 300";
              textView.text = [textView.text substringToIndex:300];
        }
    }

    if (self.emailTextView.text.length > 0 && self.feedTextView.text.length > 0) {
        self.submitBtn.enabled = YES;
        self.submitBtn.backgroundColor = COLOR_WITH_16BAND_RGB(0x5D0E86);
    }else {
        self.submitBtn.enabled = NO;
        self.submitBtn.backgroundColor = [UIColor lightGrayColor];
    }
}


//邮箱
- (BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}



- (IBAction)submitBtnClickAction:(id)sender {
    [[LSAnalyticsManager manager] reportActionEvent:SubmitFeedback eventCategory:EventCategoryPersonalCenter];
    [self.view endEditing:YES];
    BOOL isMail = NO;
    if ([self isValidateEmail:self.emailTextView.text]) {
        isMail = YES;
    }
    else{
        [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"EMAIL_FORMAT_ERROR")];
    }
    
    if (isMail) {
        [self submitFeedback];
    }

}


- (BOOL)submitFeedback {
    LSSessionRequestManager *sessionManaer = [LSSessionRequestManager manager];
    LSSubmitFeedBackRequest *request = [[LSSubmitFeedBackRequest alloc] init];
    request.mail = self.emailTextView.text;
    request.msg = self.feedTextView.text;
    [self showLoading];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"LSFeedBackViewController submitFeedback suucces %d",success);
            [self hideLoading];
            if (success) {
             
                self.successView.hidden = NO;

            }else {
                [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"SUBMIT_FAIL")];
                
            }
        });

    };
    
    return [sessionManaer sendRequest:request];
}
@end
