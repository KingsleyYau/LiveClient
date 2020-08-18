//
//  LSMailVideoKeyView.m
//  livestream
//
//  Created by Albert on 2020/7/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSMailVideoKeyView.h"
#import "LSImageViewLoader.h"
#import "LSDateTool.h"
#import "LSImageViewLoader.h"

@interface LSMailVideoKeyView()
{
    
}

@property (nonatomic,strong) LSAccessKeyinfoItemObject *videoInfo;

@end

@implementation LSMailVideoKeyView
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    //[self init];
}

-(instancetype)init
{
    if (self = [super init]) {
        self = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        
        self.layer.masksToBounds = YES;
         self.layer.borderColor = [UIColor colorWithRed:255/255.f green:154/255.f blue:1/255.f alpha:1].CGColor;
         self.layer.borderWidth = 1.f;
         self.layer.cornerRadius = 4.f;
        
        self.durationLabel.layer.masksToBounds = YES;
        self.durationLabel.layer.cornerRadius = 3.f;
        
        self.coverImgView.layer.masksToBounds = YES;
        self.coverImgView.layer.cornerRadius = 3.f;
         
        self.viewButton.layer.masksToBounds = YES;
        self.viewButton.layer.cornerRadius = self.viewButton.bounds.size.height/2;
        self.viewButton.layer.borderColor = [UIColor colorWithRed:194/255.f green:215/255.f blue:234/255.f alpha:1].CGColor;
        self.viewButton.layer.borderWidth = 1.f;
         
        UIFont *font = [UIFont fontWithName:@"Arial-BoldMT" size:16];
        [self.titleBtn.titleLabel setFont:font];
        [self.titleLabel setFont:font];
         
        [self.validLabel setFont:[UIFont fontWithName:@"ArialMT" size:12]];
        [self.viewButton.titleLabel setFont: [UIFont fontWithName:@"ArialMT" size:16]];

        [self.codeLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:22]];

        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0xD4000000).CGColor,(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x25000000).CGColor, (__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x00000000).CGColor];
        gradientLayer.locations = @[@0,@0.75,@1.0];
        gradientLayer.startPoint = CGPointMake(0, 1.0);
        gradientLayer.endPoint = CGPointMake(0, 0.0);
        gradientLayer.frame = CGRectMake(0, self.coverImgView.bounds.size.height-24.f, self.coverImgView.bounds.size.width, 24.f);
        [self.coverImgView.layer addSublayer:gradientLayer];
        
        [self.coverImgView addTapGesture:self sel:@selector(tapOnClicked:)];
        [self.titleLabel addTapGesture:self sel:@selector(tapOnClicked:)];
    }
    return self;
}

-(void)setCode:(NSString *)code
{
    if (code == nil) {
        return;
    }
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:code attributes:@{NSKernAttributeName:@(3.17)}];
    
    [attStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Arial-BoldMT" size:22.f] range:NSMakeRange(0, attStr.length)];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:255/255.f green:102.f/255 blue:0 alpha:1] range:NSMakeRange(0, attStr.length)];
    
    [self.codeLabel setAttributedText:attStr];
}

-(void)setVideoItem:(LSAccessKeyinfoItemObject *)item
{
    self.videoInfo = item;
    [[LSImageViewLoader loader] loadImageWithImageView:self.coverImgView options:0 imageUrl:item.coverUrlPng placeholderImage:nil finishHandler:nil];
    [self.durationLabel setDuration:item.duration];
    
    [self.titleLabel setText:item.title];

    [self setCode:item.accessKey];
    [self.validLabel setText:[NSString stringWithFormat:@"Valid until:%@", [LSDateTool getTime:item.validTime]]];
    
    [self.usedImgView setHidden:item.accessKeyStatus != LSACCESSKEYSTATUS_USED];
}

-(void)tapOnClicked:(UITapGestureRecognizer *)tap
{
    //打开video 详情
    if (self.delegate && [self.delegate respondsToSelector:@selector(mailVideoKeyViewGotoVideoDetail)]) {
        [self.delegate performSelector:@selector(mailVideoKeyViewGotoVideoDetail)];
    }
}

-(IBAction)viewVideoBtnOnClicked:(id)sender{
    //打开video 详情
    if (self.delegate && [self.delegate respondsToSelector:@selector(mailVideoKeyViewGotoVideoDetail)]) {
        [self.delegate performSelector:@selector(mailVideoKeyViewGotoVideoDetail)];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
