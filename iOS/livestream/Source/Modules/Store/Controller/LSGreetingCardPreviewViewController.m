//
//  LSGreetingCardPreviewViewController.m
//  livestream
//
//  Created by test on 2019/10/16.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSGreetingCardPreviewViewController.h"
#import "LSLoginManager.h"

@interface LSGreetingCardPreviewViewController ()
@property (weak, nonatomic) IBOutlet UILabel *greetingCardDetail;
@property (weak, nonatomic) IBOutlet UILabel *greetingCardOwner;
@end

@implementation LSGreetingCardPreviewViewController


- (void)initCustomParam {
    [super initCustomParam];
    self.isShowNavBar = NO;
    
}



- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.greetingCardOwner.text = [NSString stringWithFormat:@"From %@",[LSLoginManager manager].loginItem.nickName];
    self.greetingCardDetail.text = self.greetingCardMsg;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
