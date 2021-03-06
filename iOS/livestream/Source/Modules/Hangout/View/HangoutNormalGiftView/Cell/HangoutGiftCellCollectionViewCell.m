//
//  HangoutGiftCellCollectionViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/21.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HangoutGiftCellCollectionViewCell.h"
#import "LSImageViewLoader.h"
#import "HangoutGiftHighlightButton.h"

@interface HangoutGiftCellCollectionViewCell () <HangoutGiftHighlightButtonDelegate>

@property (nonatomic, strong) LSGiftManager *loadManager;
@property (nonatomic, strong) LSImageViewLoader *imageLoader;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadView;
@property (nonatomic, strong) HangoutGiftHighlightButton *highlightButton;
@end

@implementation HangoutGiftCellCollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.loadManager = [LSGiftManager manager];
        self.imageLoader = [LSImageViewLoader loader];

        self.highlightButton = [[HangoutGiftHighlightButton alloc] init];
        self.highlightButton.delegate = self;
        [self.highlightButton addTarget:self action:@selector(didClickHighlightButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.signImageView.hidden = YES;

    self.layer.borderWidth = 1;
    self.layer.borderColor = COLOR_WITH_16BAND_RGB(0x666666).CGColor;

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
    self.layer.borderWidth = 1;
    self.layer.borderColor = COLOR_WITH_16BAND_RGB(0xff7100).CGColor;
}

- (void)HangoutGiftHighlightButtonCancleHighlight {
    self.layer.borderWidth = 1;
    self.layer.borderColor = COLOR_WITH_16BAND_RGB(0x666666).CGColor;
}

- (void)setHighlightButtonTag:(NSInteger)tag {
    self.highlightButton.tag = tag;
}

- (void)updataCellViewItem:(LSGiftManagerItem *)item {
    LSGiftManagerItem *dicItem = [self.loadManager getGiftItemWithId:item.infoItem.giftId];
    if (dicItem.isDownloading) {
        [self.loadView startAnimating];
        self.loadView.hidden = NO;
    } else {
        [self.loadView stopAnimating];
        self.loadView.hidden = YES;
    }

    [self.imageLoader loadImageWithImageView:self.giftImageView
                                     options:0
                                    imageUrl:item.infoItem.smallImgUrl
                            placeholderImage:[UIImage imageNamed:@"Live_Publish_Btn_Gift"]
                               finishHandler:nil];

    NSNumber *credit = @(item.infoItem.credit);
    self.creditLabel.text = [NSString stringWithFormat:@"%@ credits", credit];

    if (item.infoItem.type == GIFTTYPE_Heigh) {
        self.signImageView.hidden = NO;
    } else {
        self.signImageView.hidden = YES;
    }
}

+ (NSString *)cellIdentifier {
    return @"HangoutGiftCellCollectionViewCellIdentifier";
}

// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageLoader stop];
    [self.giftImageView sd_cancelCurrentImageLoad];
    self.giftImageView.image = nil;
}

@end
