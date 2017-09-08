//
//  YMAudienceCell.m
//  YueMao
//
//  Created by 范明玮 on 16/5/20.
//
//

#import "YMAudienceCell.h"


@interface YMAudienceCell ()

@property(nonatomic,strong) UIImageView *headImageView;
@property(nonatomic,strong) UIImageView *rankImageView;
@property(nonatomic,strong) UIImageView *roundImage;
@property(nonatomic,strong) UIImageView *crownImage;
/**认证标识*/
@property (nonatomic,strong)UIImageView *certificationImageView;


@end

@implementation YMAudienceCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.headImageView = [[UIImageView alloc] init];
        self.headImageView.layer.masksToBounds = YES;
        self.headImageView.layer.cornerRadius = DESGIN_TRANSFORM_3X(34)*0.5;
        self.headImageView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xffcc00).CGColor;
        self.headImageView.layer.borderWidth = 1;
        [self.contentView addSubview:self.headImageView];
        
        // 认证标识
        self.certificationImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"mine_star"]];
        self.certificationImageView.hidden = YES;
        [self.contentView addSubview:self.certificationImageView];
        
        self.roundImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"userface_Round"]];
        self.roundImage.hidden = YES;
        [self.contentView addSubview:self.roundImage];
        
        self.crownImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"userface_Crown"]];
        self.crownImage.hidden = YES;
        [self.contentView addSubview:self.crownImage];
        
        [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.width.height.equalTo(@DESGIN_TRANSFORM_3X(34));
        }];
        
        [self.certificationImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@(DESGIN_TRANSFORM_3X(11)));
            make.right.bottom.equalTo(self.headImageView);
        }];
        
        [self.roundImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.height.equalTo(@DESGIN_TRANSFORM_3X(35));
        }];
        
        [self.crownImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@DESGIN_TRANSFORM_3X(36));
            make.height.equalTo(@DESGIN_TRANSFORM_3X(17));
            make.centerX.equalTo(self.roundImage);
            make.bottom.equalTo(self.roundImage.mas_bottom).offset(1);
        }];
        
    }
    return self;
}

//- (void)updateCellWithObject:(Cs_13111List *)update{
//    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[UiUtils appendHttpHeadImage:update.a_Avatar]] placeholderImage:[UIImage imageNamed:@"mine_default_avatar_icon"] options:0];
//    if (update.privilege >= 2) {
//        self.roundImage.hidden = NO;
//        self.crownImage.hidden = NO;
//    }else{
//        self.roundImage.hidden = YES;
//        self.crownImage.hidden = YES;
//    }
//    
//    if (update.certificationState == 4) {
//        self.certificationImageView.hidden = NO;
//    }else{
////        self.certificationImageView.hidden = NO;
//        self.certificationImageView.hidden = YES;
//    }
//}

@end
