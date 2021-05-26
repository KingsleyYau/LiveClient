//
//  SettingViewController.m
//  Cartoon
//
//  Created by Max on 2021/5/12.
//

#import "SettingViewController.h"
#import "AppDelegate.h"
#import "LoadingView.h"
#import "ToastView.h"

#import <Masonry/Masonry.h>

@interface SettingViewController ()
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Setting";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 18, 18);
    [button setImage:[UIImage imageNamed:@"Nav-CloseButton"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (IBAction)closeAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
            
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Default"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Default"];
    }
    
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = @"Terms of Use";
        } break;
        case 1: {
            cell.textLabel.text = @"Privacy Policy";
        } break;
        case 2: {
            cell.textLabel.text = @"Restore In-App Purchases";
        } break;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: {
            NSURL *url = [NSURL URLWithString:@"https://m.maxzoon.cn/superlive/terms.html"];
            [[UIApplication sharedApplication] openURL:url options:nil completionHandler:nil];
        } break;
        case 1: {
            NSURL *url = [NSURL URLWithString:@"https://m.maxzoon.cn/superlive/policy.html"];
            [[UIApplication sharedApplication] openURL:url options:nil completionHandler:nil];
        } break;
        case 2: {
            [self showLoading];
            [[PaymentManager manager] restore:^(BOOL success, NSString *message) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideLoading];
                    [self toast:message];
                });
            }];
        } break;
        default:
            break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
@end
