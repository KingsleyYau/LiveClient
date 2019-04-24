//
//  LSSayHiDialogViewController.m
//  livestream
//
//  Created by Randy_Fan on 2019/4/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiDialogViewController.h"
#import "LSShadowView.h"


@interface LSSayHiDialogViewController ()

@property (weak, nonatomic) IBOutlet UIView *dialogView;

@property (weak, nonatomic) IBOutlet UILabel *tiltleLabel;

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@property (weak, nonatomic) IBOutlet UIButton *pushButton;

@end

@implementation LSSayHiDialogViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dialogView.layer.cornerRadius = 5;
    self.dialogView.layer.masksToBounds = YES;
    LSShadowView *shadowView = [[LSShadowView alloc] init];
    [shadowView showShadowAddView:self.dialogView];
    
    
    
}

- (void)showDiaLogView:(BOOL)success sayHiId:(NSString *)sayHiId loiId:(NSString *)loiId {
    
    if (success) {
        
    } else {
        
    }
    
}

- (IBAction)closeAction:(id)sender {
    [self.view removeFromSuperview];
}

- (IBAction)pushAction:(id)sender {
    
}


@end
