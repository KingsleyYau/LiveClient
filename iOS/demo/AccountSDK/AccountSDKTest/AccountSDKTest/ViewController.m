//
//  ViewController.m
//  AccountSDKTest
//
//  Created by Max on 2017/12/5.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ViewController.h"

#import <AccountSDK/AccountSDK.h>
#import <Social/Social.h>
#import "UIImageView+WebCache.h"

@interface ViewController ()
@property (strong) ACCountSDKShareItem *shareItem;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.labelToken.text = nil;
    
    srand((unsigned)time(0));
    
    self.shareItem = [[ACCountSDKShareItem alloc] init];

    // TODO:Share link
    self.shareItem.type = ACCountSDKShareItemType_Link;
    self.shareItem.url = @"http://www.baidu.com";
    // TODO:Share photos
//    self.shareItem.type = ACCountSDKShareItemType_Photo;
//    self.shareItem.imageArray = @[[UIImage imageNamed:@"1"], [UIImage imageNamed:@"2"]];
    
    BOOL bFlag = NO;
    
    bFlag = [[AccountSDKManager shareInstance] autoLogin:^(BOOL success, NSError *error) {
        NSLog(@"ViewController::viewDidLoad( [Auto login finish], success : %d, error : %@ )", success, error);
        if (success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self realoadToken];
            });
            
            [[AccountSDKManager shareInstance] getProfile:^(BOOL success, NSError *error, AccountSDKProfile *profile) {
                NSLog(@"ViewController::viewDidLoad( [Get profile finish], success : %d, error : %@, name : %@, photoUrl : %@ )", success, error, profile.name, profile.photoUrl);

                dispatch_async(dispatch_get_main_queue(), ^{
                    self.labelTips.text = [NSString stringWithFormat:@"Reload profile %@", success?@"success":@"fail"];
                    
                    self.loadingView.hidden = YES;
                    [self reloadProfile:profile];

                });
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.loadingView.hidden = YES;
            });
        }
    }];

    self.loadingView.hidden = !bFlag;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Common
- (IBAction)logoutAction:(id)sender {
    NSLog(@"ViewController::logoutAction()");
    
    [[AccountSDKManager shareInstance] logout];
    [self reloadProfile:nil];
    [self realoadToken];
}

#pragma mark - Facebook
- (IBAction)facebookLoginAction:(id)sender {
    NSLog(@"ViewController::facebookLoginAction()");

    self.loadingView.hidden = NO;

    BOOL bFlag = [[AccountSDKManager shareInstance] login:AccountSDKType_Facebook
                                                       vc:self
                                                  handler:^(BOOL success, NSError *error) {
                                                      NSLog(@"ViewController::facebookLoginAction( [Login finish], success : %d, error : %@ )", success, error);
                                                      if (success) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self realoadToken];
                                                          });
                                                          
                                                          [[AccountSDKManager shareInstance] getProfile:^(BOOL success, NSError *error, AccountSDKProfile *profile) {
                                                              NSLog(@"ViewController::facebookLoginAction( [Get profile finish], success : %d, error : %@, name : %@, photoUrl : %@ )", success, error, profile.name, profile.photoUrl);

                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  self.labelTips.text = [NSString stringWithFormat:@"Reload profile %@", success?@"success":@"fail"];
                                                                  
                                                                  self.loadingView.hidden = YES;
                                                                  [self reloadProfile:profile];
                                                              });
                                                          }];
                                                      } else {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              self.loadingView.hidden = YES;
                                                          });
                                                      }
                                                  }];

    self.loadingView.hidden = !bFlag;
}

- (IBAction)facebookShareAction:(id)sender {
    NSLog(@"ViewController::facebookShareAction()");

    self.shareItem.text = [NSString stringWithFormat:@"This is share test(%@). ", [self randomString]];
    
    __weak typeof(self) weakObj = self;
    [[AccountSDKManager shareInstance] shareItem:AccountSDKType_Facebook vc:self shareItem:self.shareItem handler:^(BOOL success, NSError *error) {
        NSLog(@"ViewController::facebookShareAction( [Finish], error : %@ )", error);
        weakObj.labelTips.text = [NSString stringWithFormat:@"Share facebook %@", success?@"success":@"fail"];
    }];
}

#pragma mark - Twitter
- (IBAction)twitterLoginAction:(id)sender {
    NSLog(@"ViewController::twitterLoginAction()");
    
    self.loadingView.hidden = NO;
    
    BOOL bFlag = [[AccountSDKManager shareInstance] login:AccountSDKType_Twitter
                                                       vc:self
                                                  handler:^(BOOL success, NSError *error) {
                                                      NSLog(@"ViewController::twitterLoginAction( [Login finish], success : %d, error : %@ )", success, error);
                                                      if (success) {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              [self realoadToken];
                                                          });
                                                          
                                                          [[AccountSDKManager shareInstance] getProfile:^(BOOL success, NSError *error, AccountSDKProfile *profile) {
                                                              NSLog(@"ViewController::twitterLoginAction( [Get profile finish], success : %d, error : %@, name : %@, photoUrl : %@ )", success, error, profile.name, profile.photoUrl);

                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  self.labelTips.text = [NSString stringWithFormat:@"Reload profile %@", success?@"success":@"fail"];
                                                                  
                                                                  self.loadingView.hidden = YES;
                                                                  [self reloadProfile:profile];
                                                              });
                                                          }];
                                                      } else {
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              self.loadingView.hidden = YES;
                                                          });
                                                      }
                                                  }];

    self.loadingView.hidden = !bFlag;
}

- (IBAction)twitterShareAction:(id)sender {
    NSLog(@"ViewController::twitterShareAction()");
    
    self.shareItem.text = [NSString stringWithFormat:@"This is share test(%@). ", [self randomString]];
    
    __weak typeof(self) weakObj = self;
    [[AccountSDKManager shareInstance] shareItem:AccountSDKType_Twitter vc:self shareItem:self.shareItem handler:^(BOOL success, NSError *error) {
        NSLog(@"ViewController::twitterShareAction( [Finish], error : %@ )", error);
        weakObj.labelTips.text = [NSString stringWithFormat:@"Share twitter %@(%@)", success?@"success":@"fail", error.userInfo];
    }];
}


- (IBAction)systemsShareAction:(id)sender {
    NSLog(@"ViewController::systemsShareAction()");
    
    NSURL *url = [NSURL URLWithString:@"http://www.baidu.com"];
    NSArray *shareUrl = @[url];
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:shareUrl applicationActivities:nil];

    [self presentViewController:activity animated:YES completion:nil];
    
    [activity setCompletionWithItemsHandler:^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
        
        NSLog(@"ViewController::systemsShareAction [分享平台]:%@",activityType);
        
//        [self presentComposeView:activityType shareLink:@"http://www.baidu.com"];
//        SLComposeViewController *svc = [SLComposeViewController composeViewControllerForServiceType:@"com.apple.UIKit.activity.PostToFacebook"];
//        [svc addURL:url];
//        svc.completionHandler = ^(SLComposeViewControllerResult result) {
//            if(result == SLComposeViewControllerResultCancelled){
//                NSLog(@"cancel");
//            }else{
//                NSLog(@"done");
//            }
//        };
//        [self presentViewController:svc animated:YES completion:nil];
        
    }];
}

- (void)presentComposeView:(UIActivityType)type shareLink:(NSString *)shareLink {
    SLComposeViewController *svc;
    if (type == UIActivityTypePostToFacebook) {
        svc = [SLComposeViewController composeViewControllerForServiceType:@"com.apple.share.Facebook.post"];
    } else if (type == UIActivityTypePostToTwitter) {
        svc = [SLComposeViewController composeViewControllerForServiceType:@"com.apple.share.Twitter.post"];
    }
    [svc addURL:[NSURL URLWithString:shareLink]];
    svc.completionHandler = ^(SLComposeViewControllerResult result) {
        if(result == SLComposeViewControllerResultCancelled){
            NSLog(@"cancel");
        }else{
            NSLog(@"done");
        }
    };
    [self presentViewController:svc animated:YES completion:nil];
}

- (IBAction)copyLink:(id)sender {
    UIPasteboard *pab = [UIPasteboard generalPasteboard];
    NSString *string = @"http://www.baidu.com";
    [pab setString:string];
    if (pab == nil) {
        NSLog(@"ViewController::systemsShareAction [复制失败]");
    }else {
        NSLog(@"ViewController::systemsShareAction [复制成功]");
    }
}

#pragma mark - Reload view
- (void)reloadProfile:(AccountSDKProfile *)profile {
    if (profile) {
        self.labelName.text = profile.name;
        [self.imageViewHead sd_setImageWithURL:[NSURL URLWithString:profile.photoUrl]];
        self.generLabel.text = profile.gender;
        
    } else {
        self.labelType.text = @"";
        self.labelName.text = @"";
        self.imageViewHead.image = nil;
    }
}

- (void)realoadToken {
    NSLog(@"ViewController::realoadToken( [Current token], %@ )", [AccountSDKManager shareInstance].token);
    self.labelToken.text = [AccountSDKManager shareInstance].token;
}

- (NSString *)randomString {
    NSString *randomString = @"";
    
    int randValue = rand() % 9999999;
    randomString = [NSString stringWithFormat:@"%d", randValue];
    
    return randomString;
}

@end
