//
//  GoProViewController.m
//  RtmpClientTest
//
//  Created by Max on 2021/5/25.
//  Copyright © 2021 net.qdating. All rights reserved.
//

#import "GoProViewController.h"
#import "AppDelegate.h"

@interface GoProViewController ()
@property (weak) IBOutlet UIButton *trialButton;
@property (weak) IBOutlet UILabel *trialTipsLabel;
@end

@implementation GoProViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"订阅专业版";
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 18, 18);
    [button setImage:[UIImage imageNamed:@"Nav-CloseButton"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.trialButton.layer.cornerRadius = self.trialButton.frame.size.height / 2;
    self.trialButton.layer.masksToBounds = YES;
    if (!self.viewDidAppearEver) {
        [self reloadData];
    }
}

- (IBAction)closeAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}

- (IBAction)trialAction:(UIButton *)sender {
    AppShareDelegate().firstTimeActive = YES;
    [self showLoading];
    if (!AppShareDelegate().subscribed) {
        [[PaymentManager manager] subscribe:^(BOOL success, NSString *message) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoading];
                if (success) {
                    [self dismissViewControllerAnimated:YES
                                             completion:^{

                                             }];
                } else {
                    [self toast:message];
                }
            });
        }];
    } else {
        [self dismissViewControllerAnimated:YES
                                 completion:^{

                                 }];
    }

}

#pragma mark - 数据逻辑
- (void)reloadData {
    if (AppShareDelegate().subscribed) {
        [self.trialButton setTitle:@"你已经成为专业版用户!" forState:UIControlStateNormal];
//        self.trialTipsLabel.text = @"";
    }
}
@end
