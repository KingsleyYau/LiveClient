//
//  ChangePasswordViewController.h
//  dating
//
//  Created by test on 2017/7/26.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSGoogleAnalyticsViewController.h"

@interface LSChangePasswordViewController : LSGoogleAnalyticsViewController
@property (weak, nonatomic) IBOutlet UITextField *currentPassword;
@property (weak, nonatomic) IBOutlet UITextField *recentPassword;
@property (weak, nonatomic) IBOutlet UITextField *confirmPassword;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;

@end
