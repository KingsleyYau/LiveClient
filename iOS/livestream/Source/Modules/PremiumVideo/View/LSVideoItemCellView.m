//
//  LSVideoItemCellView.m
//  livestream
//
//  Created by logan on 2020/7/30.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSVideoItemCellView.h"
#import "LSImageViewLoader.h"
#import "LSDurationLabel.h"

@interface LSVideoItemCellView ()

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *userHeadImgView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLab;
@property (weak, nonatomic) IBOutlet UILabel *ageLab;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *coverImgView;
@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;
@property (weak, nonatomic) IBOutlet LSDurationLabel *videoTimeLab;
@property (weak, nonatomic) IBOutlet UIImageView *isOnlineImg;

/** model */
@property (nonatomic, weak) id<LSVideoItemCellViewModelProtocol> model;

@end

@implementation LSVideoItemCellView

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        self = [[NSBundle mainBundle] loadNibNamed:@"LSVideoItemCellView" owner:self options:nil].firstObject;
        self.frame = frame;
        self.layer.cornerRadius = 4;
        self.layer.shadowColor = COLOR_WITH_16BAND_RGB(0x000000).CGColor;
        self.layer.shadowOpacity = 0.19;
        self.layer.shadowOffset = CGSizeMake(1, 1);
        self.bgView.layer.masksToBounds = YES;
        self.bgView.layer.cornerRadius = 4;
        
        self.userHeadImgView.layer.masksToBounds = YES;
        self.userHeadImgView.layer.cornerRadius = self.userHeadImgView.bounds.size.height/2;
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
}

- (void)dealloc{
    NSLog(@"dealloc");
}
- (IBAction)favoriteBtnCheck:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCellView:favoriteCheckModel:)]) {
        [self.delegate itemCellView:self favoriteCheckModel:self.model];
    }
}
- (IBAction)toVideoDetailCheck:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCellView:toVideoDetailCheckModel:)]) {
        [self.delegate itemCellView:self toVideoDetailCheckModel:self.model];
    }
}
- (IBAction)toUserDetailCheck:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(itemCellView:toUserDetailCheckModel:)]) {
        [self.delegate itemCellView:self toUserDetailCheckModel:self.model];
    }
}

- (void)setViewWithModel:(id<LSVideoItemCellViewModelProtocol>)model{
    _model = model;
    if ([model respondsToSelector:@selector(getVideoItemModelTitle)]) {
        _titleLab.text = [model getVideoItemModelTitle];
    }
    if ([model respondsToSelector:@selector(getVideoItemModelDetail)]) {
        _detailLab.text = [model getVideoItemModelDetail];
    }
    if ([model respondsToSelector:@selector(getVideoItemModelCoverImg)]) {
        [_coverImgView sd_setImageWithURL:[NSURL URLWithString:[model getVideoItemModelCoverImg]] placeholderImage:nil];
    }
    if ([model respondsToSelector:@selector(getVideoItemModelUsername)]) {
        _userNameLab.text = [model getVideoItemModelUsername];
    }
    if ([model respondsToSelector:@selector(getVideoItemModelUserAge)]) {
        NSString * yrStr = [[model getVideoItemModelUserAge] intValue] <= 1?@"yr":@"yrs";
        _ageLab.text = [NSString stringWithFormat:@"%@%@",[model getVideoItemModelUserAge],yrStr];
    }
    if ([model respondsToSelector:@selector(getVideoItemModelUserHeadImg)]) {
        [[LSImageViewLoader loader] loadImageFromCache:_userHeadImgView options:0 imageUrl:[model getVideoItemModelUserHeadImg] placeholderImage:nil finishHandler:nil];
    }
    if ([model respondsToSelector:@selector(getVideoItemModelIsFavorite)]) {
        _favoriteBtn.selected = [model getVideoItemModelIsFavorite];
    }
    if ([model respondsToSelector:@selector(getVideoItemModelVideoTime)]) {
        int timeInt = [[model getVideoItemModelVideoTime] intValue];
        [_videoTimeLab setDuration:timeInt];
    }
    if ([model respondsToSelector:@selector(getVideoItemModelIsOnline)]) {
        _isOnlineImg.hidden = ![model getVideoItemModelIsOnline];
    }
}

@end
