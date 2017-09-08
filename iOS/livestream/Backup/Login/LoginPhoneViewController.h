//
//  LoginPhoneViewController.h
//  livestream
//
//  Created by Max on 2017/5/19.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "KKViewController.h"

@interface LoginPhoneViewController : KKViewController

@property (weak) IBOutlet BLTextField* textFieldCountry;
@property (weak) IBOutlet BLTextField* textFieldZone;
@property (weak) IBOutlet BLTextField* textFieldPhone;
@property (weak) IBOutlet BLTextField* textFieldPassword;
@property (weak) IBOutlet UIButton* btnLogin;
@property (weak, nonatomic) IBOutlet UILabel *countryNameLabel;

/**
 *  点击国家
 *
 *  @param sender 响应控件
 */
- (IBAction)selectCountryAction:(id)sender;

/**
 *  点击登陆
 *
 *  @param sender 响应控件
 */
- (IBAction)loginAction:(id)sender;

@end
