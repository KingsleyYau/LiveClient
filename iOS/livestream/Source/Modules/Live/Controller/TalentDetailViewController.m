//
//  TalentDetailViewController.m
//  livestream
//
//  Created by Calvin on 2018/5/28.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "TalentDetailViewController.h"
#import "TalentMsgInfoManager.h"
#import "LSGiftManager.h"
#import "LSImageViewLoader.h"
@interface TalentDetailViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *talentShowBtn;
@property (weak, nonatomic) IBOutlet UILabel *talentInfoLabel;
@end

@implementation TalentDetailViewController

- (void)initCustomParam {
    [super initCustomParam];

    NSLog(@"TalentDetailViewController::initCustomParam()");
}

- (void)dealloc {
    NSLog(@"TalentDetailViewController::dealloc()");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    lineView.backgroundColor = COLOR_WITH_16BAND_RGB(0x535353);
    lineView.alpha = 0.6;
    [self.view addSubview:lineView];

    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"TalentBackIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnDid)];
    self.navigationItem.leftBarButtonItem = backButtonItem;

    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height);
    [self.view addSubview:effectView];
    [self.view sendSubviewToBack:effectView];

    self.talentInfoLabel.attributedText = [TalentMsgInfoManager showTitleString:self.talentInfoLabel.text Andunderline:NSLocalizedStringFromSelf(@"Details")];

    UIFont *font = [UIFont systemFontOfSize:12];

    UIImageView *headImage = [[UIImageView alloc] initWithFrame:CGRectMake(13, 13, 44, 44)];
    headImage.layer.cornerRadius = headImage.frame.size.height / 2;
    headImage.layer.masksToBounds = YES;
    [self.scrollView addSubview:headImage];
    [[LSImageViewLoader loader] loadImageWithImageView:headImage options:0 imageUrl:self.liveRoom.photoUrl placeholderImage:LADYDEFAULTIMG finishHandler:nil];

    CGFloat headW = headImage.frame.size.width + headImage.frame.origin.x;

    CGSize size = [self.item.decription boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - (headW + 40), 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName : font } context:nil].size;

    UIImageView *bgImage = [[UIImageView alloc] initWithFrame:CGRectMake(headW + 10, 10, SCREEN_WIDTH - headW - 20, ceil(size.height) + 40)];
    bgImage.image = [UIImage imageNamed:@"TalentDetialsBG"];
    [self.scrollView addSubview:bgImage];

    UIImageView *waringIcon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 13, 13)];
    waringIcon.image = [UIImage imageNamed:@"Talent_Waring_Icon"];
    [bgImage addSubview:waringIcon];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(waringIcon.frame.origin.x + waringIcon.frame.size.width + 5, 8, 200, 18)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:12];
    titleLabel.text = NSLocalizedStringFromSelf(@"Show description");
    [bgImage addSubview:titleLabel];

    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, bgImage.frame.size.width - 30, ceil(size.height))];
    contentLabel.text = self.item.decription;
    contentLabel.font = font;
    contentLabel.numberOfLines = 0;
    contentLabel.textColor = [UIColor lightGrayColor];
    [bgImage addSubview:contentLabel];

    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, size.height + 98);

    UILabel *bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(bgImage.frame.origin.x + 20, self.scrollView.contentSize.height - 40, bgImage.frame.size.width - 40, 18)];
    bottomLabel.textColor = [UIColor lightGrayColor];
    bottomLabel.font = [UIFont systemFontOfSize:12];
    [self.scrollView addSubview:bottomLabel];

    NSString *strs = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Talent_SubTitle"), self.item.giftName];
    LSGiftManagerItem *gift = [[LSGiftManager manager] getGiftItemWithId:self.item.giftId];
    bottomLabel.attributedText = [TalentMsgInfoManager showImageString:self.item.giftName AndTitle:strs andTitleFont:bottomLabel.font inMaxWidth:SCREEN_WIDTH - headW - 60 giftImage:gift.infoItem.smallImgUrl isShowGift:self.item.giftId.length > 0 ? YES : NO];
    //[bottomLabel sizeToFit];

    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(bottomLabel.frame.origin.x, bottomLabel.frame.origin.y + bottomLabel.frame.size.height, bgImage.frame.size.width - 20, 30)];
    priceLabel.textColor = [UIColor lightGrayColor];
    priceLabel.font = [UIFont systemFontOfSize:12];
    priceLabel.text = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"Price_label"), self.item.credit];
    priceLabel.numberOfLines = 0;
    [self.scrollView addSubview:priceLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.navigationController.navigationBar setTitleTextAttributes:
                                                 @{NSFontAttributeName : [UIFont boldSystemFontOfSize:15],
                                                   NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = self.item.name;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)detailTap:(UITapGestureRecognizer *)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromSelf(@"Note") message:NSLocalizedStringFromSelf(@"Talent_Detail_Msg") preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *canaelAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", nil) style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:canaelAC];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)backBtnDid {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)talentShowRequest:(UIButton *)sender {

    [self.navigationController popViewControllerAnimated:NO];
    if ([self.delegates respondsToSelector:@selector(talentDetailVCButtonDid:)]) {
        [self.delegates talentDetailVCButtonDid:self.item];
    }
}

@end
