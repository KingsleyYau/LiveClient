//
//  EditProFileViewController.m
//  livestream
//
//  Created by Calvin on 2018/1/3.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "EditProFileViewController.h"
#import "LSLoginManager.h"
#import "UserInfoManager.h"
#import "DialogTip.h"
#import "LSAnalyticsManager.h"
#define MAXNUM 20

@interface EditProFileViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@end

@implementation EditProFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.title = @"NickName";
    
    self.textField.delegate = self;
    
    self.textField.text = [LSLoginManager manager].loginItem.nickName;
    self.numLabel.text = [NSString stringWithFormat:@"%d/%d",(int)self.textField.text.length,MAXNUM];
    
    UIBarButtonItem * button = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveName)];
    self.navigationItem.rightBarButtonItem = button;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    if (self.textField.text.length >= 2) {
          self.navigationItem.rightBarButtonItem.enabled = YES;
    }else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)saveName
{
    [[LSAnalyticsManager manager] reportActionEvent:SaveNickname eventCategory:EventCategoryPersonalCenter];
    [self.view endEditing:YES];
    if ([self.textField.text containsString:@" "] || [self.textField.text containsString:@"\t"]) {
        [[DialogTip dialogTip] showDialogTip:self.view tipText:NSLocalizedStringFromSelf(@"Name_Error_tip3")];
        return ;
    }
     if (self.textField.text.length >= 2) {
         if (![self.textField.text isEqualToString:[LSLoginManager manager].loginItem.nickName]) {
             [self showLoading];
             [[UserInfoManager manager] setUserInfo:self.textField.text FinishHandler:^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self hideLoading];
                     if (success) {
                         [self.navigationController popViewControllerAnimated:YES];
                     }
                     else
                     {
                         [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
                     }
                 });
             }];
         }
         else
         {
             [self.navigationController popViewControllerAnimated:YES];
         }
     }
}

- (void)textDidChange:(NSNotification *)notifi
{
      self.numLabel.text = [NSString stringWithFormat:@"%d/%d",(int)self.textField.text.length,MAXNUM];
    if (self.textField.text.length > 0) {
        self.numLabel.textColor = COLOR_WITH_16BAND_RGB(0x3c3c3c);
        if (self.textField.text.length >= 2) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
     }
    else
    {
        self.numLabel.textColor = COLOR_WITH_16BAND_RGB(0xbfbfbf);
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0) return YES;
    if ([string isEqualToString:@"\n"]) {
        [self saveName];
    }
    NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    if (existedLength - selectedLength + replaceLength > MAXNUM) {
        return NO;
    }
    return YES;
}
@end
