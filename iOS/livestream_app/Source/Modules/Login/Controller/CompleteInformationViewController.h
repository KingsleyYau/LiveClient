//
//  CompleteInformationViewController.h
//  livestream
//
//  Created by test on 2017/12/18.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSViewController.h"
#import "LiveLoginInfo.h"
#import "FacebookLoginHandler.h"
@interface CompleteInformationViewController : LSGoogleAnalyticsViewController

@property (nonatomic, assign) BOOL isEmailRegister;
@property (nonatomic, strong) LiveLoginInfo * loginInfo;

@end
