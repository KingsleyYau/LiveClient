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
#import "LiveUrlHandler.h"
#import "LiveMutexService.h"
#import "LSAddCreditsViewController.h"
#import "HangOutPreAnchorPhotoCell.h"

#define BUTTONHEIGHT 44
#define STARTBUTTONTOP 20

@interface HangOutFinshViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet LSCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewWidth;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *startAgainBtn;
@property (weak, nonatomic) IBOutlet UIButton *addCreditBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addCreditBtnHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *startHangoutBtnTop;


@property (nonatomic, strong) NSMutableArray *anchorArray;

@end

@implementation HangOutFinshViewController

- (void)dealloc {
    NSLog(@"HangOutFinshViewController::dealloc()");
}

- (void)initCustomParam {
    [super initCustomParam];
    
    self.isShowNavBar = NO;
    
    self.anchorArray = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"HangOutPreAnchorPhotoCell" bundle:[LiveBundle mainBundle]];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:[HangOutPreAnchorPhotoCell cellIdentifier]];
    
    self.collectionViewWidth.constant = self.anchorArray.count * 100;
    [self.collectionView reloadData];
    
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    self.headImageView.layer.masksToBounds = YES;
    
    self.startAgainBtn.layer.cornerRadius = self.startAgainBtn.frame.size.height / 2;
    self.startAgainBtn.layer.masksToBounds = YES;
    self.startAgainBtn.hidden = YES;
    
    self.addCreditBtn.layer.cornerRadius = self.addCreditBtn.frame.size.height / 2;
    self.addCreditBtn.layer.masksToBounds = YES;
    self.addCreditBtn.hidden = YES;
}

- (void)anchorArrayAddObject:(LSUserInfoModel *)obj {
    [self.anchorArray addObject:obj];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.anchorArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSUserInfoModel *item = self.anchorArray[indexPath.row];
    HangOutPreAnchorPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HangOutPreAnchorPhotoCell cellIdentifier] forIndexPath:indexPath];
    
    IMLivingAnchorItemObject *obj = [[IMLivingAnchorItemObject alloc] init];
    obj.anchorId = item.userId;
    obj.nickName = item.nickName;
    obj.photoUrl = item.photoUrl;
    [cell setupCellDate:obj];
    return cell;
}

#pragma mark - 界面显示
- (void)showErrorCredieBtn:(BOOL)hiddenCredit starAgain:(BOOL)hiddenStart errmsg:(NSString *)errmsg {
    self.startAgainBtn.hidden = hiddenStart;
    self.addCreditBtn.hidden = hiddenCredit;
    if (hiddenCredit) {
        self.addCreditBtnHeight.constant = 0;
        self.startHangoutBtnTop.constant = 0;
    } else {
        self.addCreditBtnHeight.constant = BUTTONHEIGHT;
        self.startHangoutBtnTop.constant = STARTBUTTONTOP;
    }
    self.tipLabel.text = errmsg;
}

- (void)showError:(HANGOUTERROR)error errMsg:(NSString *)errMsg {
    switch (error) {
        case HANGOUTERROR_BACKSTAGE:{
            [self showErrorCredieBtn:YES starAgain:NO errmsg:NSLocalizedStringFromSelf(@"BACKSTAGE_FOR_OVER")];
        }break;
            
        case HANGOUTERROR_NOCREDIT:{
            [self showErrorCredieBtn:NO starAgain:NO errmsg:errMsg];
        }break;
            
        default:{
            [self showErrorCredieBtn:YES starAgain:NO errmsg:errMsg];
        }break;
    }
}

- (IBAction)startAgainAction:(id)sender {
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:NO completion:nil];
    [[LiveModule module].moduleVC.navigationController popToViewController:[LiveModule module].moduleVC animated:NO];
    
    LSUserInfoModel *item = self.anchorArray.firstObject;
    NSURL *url = [[LiveUrlHandler shareInstance] createUrlToHangoutByRoomId:@"" inviteAnchorId:item.userId inviteAnchorName:item.nickName recommendAnchorId:@"" recommendAnchorName:@""];
    [[LiveUrlHandler shareInstance] handleOpenURL:url];
}

- (IBAction)addCreditAciton:(id)sender {
    NSURL *url = [[LiveUrlHandler shareInstance] createBuyCredit];
    [[LiveModule module].serviceManager handleOpenURL:url];
    
}

- (IBAction)closeAciton:(id)sender {
    LSNavigationController *nvc = (LSNavigationController *)self.navigationController;
    [nvc forceToDismissAnimated:YES completion:nil];
}

@end
