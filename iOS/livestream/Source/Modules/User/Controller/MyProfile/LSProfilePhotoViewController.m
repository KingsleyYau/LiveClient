//
//  LSProfilePhotoViewController.m
//  livestream
//
//  Created by test on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSProfilePhotoViewController.h"
#import "LSProfilePhotoActionViewController.h"

@interface LSProfilePhotoViewController ()<LSProfilePhotoActionViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *reviewTips;
@property (weak, nonatomic) IBOutlet UIButton *changePhotoBtn;
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;

@end

@implementation LSProfilePhotoViewController


- (void)initCustomParam {
    [super initCustomParam];
    self.isShowNavBar = NO;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.reviewTips.hidden = !self.isInReview;
    self.changePhotoBtn.hidden = self.isInReview;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.profilePhoto.image = self.headImage.image;

}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (IBAction)changeAction:(id)sender {
    LSProfilePhotoActionViewController *vc = [[LSProfilePhotoActionViewController alloc] initWithNibName:nil bundle:nil];
    vc.actionDelegate = self;
    [vc showPhotoAction:self];
}

- (void)lsProfilePhotoActionViewControllerDidFinishPhotoAction:(LSProfilePhotoActionViewController *)vc {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
