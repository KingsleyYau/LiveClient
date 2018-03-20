//
//  VerifyPhoneViewController.h
//  livestream
//
//  Created by Max on 2017/5/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "KKViewController.h"

@interface VerifyPhoneViewController : KKViewController

@property (weak) IBOutlet BLTextField* textFieldCheckcode;
@property (weak) IBOutlet BLTextField* textFieldPassword;
@property (weak) IBOutlet UIButton* btnSignup;
@property (weak, nonatomic) IBOutlet UILabel *labelPhoneNumber;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

/**
 *  点击获取验证码
 *
 *  @param sender 响应控件
 */
- (IBAction)checkCodeAction:(id)sender;

/**
 *  点击注册
 *
 *  @param sender 响应控件
 */
- (IBAction)signUpAction:(id)sender;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil phoneNumber:(NSString *)phoneNumber areno:(NSString *)areno;

@end
