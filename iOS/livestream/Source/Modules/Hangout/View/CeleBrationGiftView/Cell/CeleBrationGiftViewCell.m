//
//  CeleBrationGiftViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/24.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "CeleBrationGiftViewCell.h"
#import "LSImageViewLoader.h"
#import "LSShadowView.h"
#import "HangoutGiftHighlightButton.h"

@interface CeleBrationGiftViewCell () <HangoutGiftHighlightButtonDelegate>
@property (nonatomic, strong) LSImageViewLoader *imageLoader;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (nonatomic, strong) HangoutGiftHighlightButton *highlightButton;
@end

@implementation CeleBrationGiftViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.imageLoader = [LSImageViewLoader loader];

        self.highlightButton = [[HangoutGiftHighlightButton alloc] init];
        self.highlightButton.delegate = self;
        [self.highlightButton addTarget:self action:@selector(didClickHighlightButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

+ (NSString *)cellIdentifier {
    return @"CeleBrationGiftViewCell";
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.giftImageView.layer.borderWidth = 1;
    self.giftImageView.layer.borderColor = COLOR_WITH_16BAND_RGB(0x535353).CGColor;
    self.giftImageView.layer.cornerRadius = ((SCREEN_WIDTH / 3) - 30) / 2;
    self.giftImageView.layer.masksToBounds = YES;
    [self.giftImageView setBackgroundColor:[UIColor clearColor]];

    self.shadowView.layer.cornerRadius = ((SCREEN_WIDTH / 3) - 30) / 2;
    self.shadowView.layer.masksToBounds = YES;

    LSShadowView *shadowView = [[LSShadowView alloc] init];
    shadowView.shadowColor = COLOR_WITH_16BAND_RGB(0xff5756);
    shadowView.shadowOpacity = 1;
    [shadowView showShadowAddView:self.shadowView];
    self.shadowView.hidden = YES;

    [self addSubview:self.highlightButton];
    [self bringSubviewToFront:self.highlightButton];
    [self.highlightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)didClickHighlightButton {
    if ([self.delegate respondsToSelector:@selector(sendGiftToAnchor:)]) {
        [self.delegate sendGiftToAnchor:self.highlightButton.tag];
    }
}

- (void)HangoutGiftHighlightButtonIsHighlight {
    self.giftImageView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xff5756).CGColor;
    [self.giftImageView setBackgroundColor:COLOR_WITH_16BAND_RGB(0xff5756)];
    self.shadowView.hidden = NO;
}

- (void)HangoutGiftHighlightButtonCancleHighlight {
    self.giftImageView.layer.borderColor = COLOR_WITH_16BAND_RGB(0x535353).CGColor;
    [self.giftImageView setBackgroundColor:[UIColor clearColor]];
    self.shadowView.hidden = YES;
}

- (void)setHighlightButtonTag:(NSInteger)tag {
    self.highlightButton.tag = tag;
}

- (void)updataCellViewItem:(LSGiftManagerItem *)item {

    [self.imageLoader loadImageWithImageView:self.giftImageView
                                     options:0
                                    imageUrl:item.infoItem.smallImgUrl
                            placeholderImage:[UIImage imageNamed:@"Hangout_CeleBration_Gift"]
                               finishHandler:nil];

    NSNumber *credit = @(item.infoItem.credit);
    self.creditsLabel.text = [NSString stringWithFormat:@"%@ Credits", credit];

    [self layoutIfNeeded];
}

// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageLoader stop];
    [self.giftImageView sd_cancelCurrentImageLoad];
    self.giftImageView.image = nil;
}

@end
