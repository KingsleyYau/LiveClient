//
//  StreamBaseViewController.m
//  RtmpClientTest
//
//  Created by Max on 2020/10/26.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "StreamBaseViewController.h"

@interface StreamBaseViewController ()

@end

@implementation StreamBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self updateTrait];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [self updateTrait];
}

- (void)updateTrait {
    if (@available(iOS 12.0, *)) {
        BOOL isDark = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark);
        if (isDark) {
            self.view.backgroundColor = [UIColor blackColor];
        } else {
            self.view.backgroundColor = [UIColor whiteColor];
        }
    } else {
        // Fallback on earlier versions
    }
}

@end
