//
//  CeleBrationGiftViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/24.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "CeleBrationGiftViewCell.h"
#import "LSImageViewLoader.h"

@interface CeleBrationGiftViewCell()
@property (nonatomic, strong) LSImageViewLoader *imageLoader;
@end

@implementation CeleBrationGiftViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.imageLoader = [LSImageViewLoader loader];
    }
    return self;
}

+ (NSString *)cellIdentifier {
    return @"CeleBrationGiftViewCell";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectCell = NO;
}

- (void)reloadStyle {
    if (self.selectCell) {
        self.giftImageView.layer.borderWidth = 1;
        self.giftImageView.layer.borderColor = Color(5, 199, 117, 1).CGColor;
    }else {
        self.giftImageView.layer.borderWidth = 0;
        self.giftImageView.layer.borderColor = Color(5, 199, 117, 1).CGColor;
    }
}

- (void)updataCellViewItem:(LSGiftManagerItem *)item {
    
    [self.imageLoader loadImageWithImageView:self.giftImageView options:0 imageUrl:item.infoItem.smallImgUrl
                                      placeholderImage:[UIImage imageNamed:@"Live_Publish_Btn_Gift"]];
    
    NSNumber *credit = @(item.infoItem.credit);
    self.creditsLabel.text = [NSString stringWithFormat:@"%@ Credits",credit];
}

// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageLoader stop];
    [self.giftImageView sd_cancelCurrentImageLoad];
    self.giftImageView.image = nil;
}

@end
