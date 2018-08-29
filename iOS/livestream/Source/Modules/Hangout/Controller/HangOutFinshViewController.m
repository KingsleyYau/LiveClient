//
//  HangOutFinshViewController.m
//  livestream
//
//  Created by Randy_Fan on 2018/6/4.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HangOutFinshViewController.h"
#import "LSLoginManager.h"
#import "LSImageViewLoader.h"
#import "LiveModule.h"
#import "HangOutPreViewController.h"
#import "LiveModule.h"
#import "LiveUrlHandler.h"
#import "LiveMutexService.h"

@interface HangOutFinshViewController ()

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *startAgainBtn;
@property (weak, nonatomic) IBOutlet UIButton *addCreditBtn;

@end

@implementation HangOutFinshViewController

- (void)dealloc {
    NSLog(@"HangOutFinshViewController::dealloc()");
}

- (void)initCustomParam {
    [super initCustomParam];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    self.headImageView.layer.masksToBounds = YES;
    
    self.startAgainBtn.layer.cornerRadius = self.startAgainBtn.frame.size.height / 2;
    self.startAgainBtn.layer.masksToBounds = YES;
    self.startAgainBtn.hidden = YES;
    
    self.addCreditBtn.layer.cornerRadius = self.addCreditBtn.frame.size.height / 2;
    self.addCreditBtn.layer.masksToBounds = YES;
    self.addCreditBtn.hidden = YES;
    
    [[LSImageViewLoader loader] refreshCachedImage:self.headImageView options:SDWebImageRefreshCached imageUrl:[LSLoginManager manager].loginItem.photoUrl placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]];
}

- (void)showErrorCredieBtn:(BOOL)hiddenCredit starAgain:(BOOL)hiddenStart errmsg:(NSString *)errmsg {
    self.startAgainBtn.hidden = hiddenStart;
    self.addCreditBtn.hidden = hiddenCredit;
    self.tipLabel.text = errmsg;
}

- (void)showError:(HANGOUTERROR)error errMsg:(NSString *)errMsg {
    switch (error) {
        case HANGOUTERROR_BACKSTAGE:{
            [self showErrorCredieBtn:YES starAgain:NO errmsg:NSLocalizedStringFromSelf(@"BACKSTAGE_FOR_OVER")];
        }break;
            
        case HANGOUTERROR_NOCREDIT:{
            [self showErrorCredieBtn:NO starAgain:YES errmsg:errMsg];
        }break;
            
        default:{
            [self showErrorCredieBtn:YES starAgain:NO errmsg:errMsg];
        }break;
    }
}

- (IBAction)startAgainAction:(id)sender {
    [LiveUrlHandler shareInstance].url = [[LiveUrlHandler shareInstance] createUrlToHangoutByRoomId:@"" anchorId:@"" nickName:@""];

//    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismiss:nvc.flag animated:NO completion:nil];
    [[LiveModule module].moduleVC.navigationController popToViewController:[LiveModule module].moduleVC animated:NO];
}

- (IBAction)addCreditAciton:(id)sender {
    [self.navigationController pushViewController:[LiveModule module].addCreditVc animated:YES];
}

- (IBAction)closeAciton:(id)sender {
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismiss:nvc.flag animated:YES completion:nil];
}

@end
