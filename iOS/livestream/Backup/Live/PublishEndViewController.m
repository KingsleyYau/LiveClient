//
//  PublishEndViewController.m
//  livestream
//
//  Created by Max on 2017/6/1.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "PublishEndViewController.h"

@interface PublishEndViewController ()

@property (weak, nonatomic) IBOutlet UILabel *endTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *diamondsLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewerLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansNewsLabel;
@property (weak, nonatomic) IBOutlet UILabel *sharesLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareTipLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *endTitleTopOffset;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelTopOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *diamondNumLabelTopOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *diamondLabelTopOffset;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fansnewNumLabelTopOffset;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *fansnewLabelTopOffset;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *shareTipLabelTopOffset;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *shareBtnTopOffset;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *homeBtnTopOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *homeBtnHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *homeBtnWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *diamondNumLabelLeftOffset;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewerNumLabelTrailOffset;


@end

@implementation PublishEndViewController
- (void)initCustomParam {
    [super initCustomParam];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    NSLog(@"%@",self.fanNewNumLabel.constraints);
}

- (void)setupContainView{
    
    [super setupContainView];
    
    UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *view = [[UIVisualEffectView alloc]initWithEffect:beffect];
    [self.liverCoverImageView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.liverCoverImageView);
    }];
    
    self.endTitleLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(24)];
    self.diamondsLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(18)];
    self.viewerLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(18)];
    self.fansNewsLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(18)];
    self.sharesLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(18)];
    self.shareTipLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(12)];
    
    self.timeLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(20)];
    self.diamondNumLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(20)];
    self.viewerNumLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(20)];
    self.fansNewsLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(20)];
    self.shareNumLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(20)];
    
    self.homeBtnWidth.constant = DESGIN_TRANSFORM_3X(163);
    self.homeBtnHeight.constant = DESGIN_TRANSFORM_3X(36);
    self.homeBtn.layer.cornerRadius = DESGIN_TRANSFORM_3X(18);
    self.homeBtn.layer.masksToBounds = YES;
    
    self.endTitleTopOffset.constant = DESGIN_TRANSFORM_3X(70);
    self.timeLabelTopOffset.constant = DESGIN_TRANSFORM_3X(15);
    self.diamondNumLabelTopOffset.constant = DESGIN_TRANSFORM_3X(46);
    self.diamondLabelTopOffset.constant = DESGIN_TRANSFORM_3X(5);
    self.fansnewNumLabelTopOffset.constant = DESGIN_TRANSFORM_3X(45);
    self.fansnewLabelTopOffset.constant = DESGIN_TRANSFORM_3X(5);
    self.shareTipLabelTopOffset.constant = DESGIN_TRANSFORM_3X(80);
    self.shareBtnTopOffset.constant = DESGIN_TRANSFORM_3X(12);
    self.homeBtnTopOffset.constant = DESGIN_TRANSFORM_3X(30);
    
    self.diamondNumLabelLeftOffset.constant = DESGIN_TRANSFORM_3X(80);
    self.viewerNumLabelTrailOffset.constant = DESGIN_TRANSFORM_3X(80);
}


#pragma mark - 界面事件
- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)twitterAction:(UIButton *)sender{
    
}

- (IBAction)faceBookAction:(UIButton *)sender {
    
}

- (IBAction)instagramAction:(UIButton *)sender{

}

@end
