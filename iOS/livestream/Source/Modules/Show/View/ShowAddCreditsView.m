//
//  ShowAddCreditsView.m
//  livestream
//
//  Created by Calvin on 2018/4/18.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "ShowAddCreditsView.h"
#import "LSImageViewLoader.h"
#import "DialogTip.h"
#import "LiveModule.h"
@interface ShowAddCreditsView ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditsLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIView *button;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (nonatomic, strong) LSImageViewLoader * imageViewLoader;

@end

@implementation ShowAddCreditsView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.bgView.layer.cornerRadius = 8;
    self.bgView.layer.masksToBounds = YES;
    
    self.button.layer.cornerRadius = 4;
    self.button.layer.masksToBounds = YES;
    
    self.headImage.layer.cornerRadius = self.headImage.frame.size.height/2;
    self.headImage.layer.masksToBounds = YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        
        self.frame = frame;
    }
    return self;
}

- (void)updateUI:(LSProgramItemObject *)item
{
    self.obj = item;
    [self.imageViewLoader stop];
    if (!self.imageViewLoader) {
        self.imageViewLoader = [LSImageViewLoader loader];
    }
    [self.imageViewLoader refreshCachedImage:self.headImage options:SDWebImageRefreshCached imageUrl:item.anchorAvatar placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:^(UIImage *image) {
    }];
    
    self.titleLabel.text = item.showTitle;
    
    self.creditsLabel.text = [NSString stringWithFormat:@"%0.1f credits",item.price];
}

- (IBAction)bgTap:(UITapGestureRecognizer *)sender {
    
    [self removeFromSuperview];
}

- (IBAction)closeBtnDid:(UIButton *)sender {
    [self removeFromSuperview];
}

- (IBAction)GetTicketBtn:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(showAddCreditsViewGetTicketBtnDid:)]) {
        [self.delegate showAddCreditsViewGetTicketBtnDid:self.obj.showLiveId];
    }
}

@end
