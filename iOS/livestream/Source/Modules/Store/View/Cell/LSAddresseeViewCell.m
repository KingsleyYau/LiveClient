//
//  LSAddresseeViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2019/10/12.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSAddresseeViewCell.h"
#import "LSImageViewLoader.h"

@interface LSAddresseeViewCell ()
@property (strong, nonatomic) LSImageViewLoader *imageLoader;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@end

@implementation LSAddresseeViewCell

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.imageLoader = [LSImageViewLoader loader];
    }
    return self;
}

+ (id)getUICollectionViewCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    LSAddresseeViewCell *cell = (LSAddresseeViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[LSAddresseeViewCell cellIdentifier] forIndexPath:indexPath];
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSAddresseeViewCell cellIdentifier] owner:collectionView options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0xD4000000).CGColor,(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x25000000).CGColor, (__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x00000000).CGColor];
    gradientLayer.locations = @[@0,@0.75,@1.0];
    gradientLayer.startPoint = CGPointMake(0, 1.0);
    gradientLayer.endPoint = CGPointMake(0, 0.0);
    gradientLayer.frame = CGRectMake(0, 0, screenSize.width, self.bottomView.tx_height);
    [self.bottomView.layer addSublayer:gradientLayer];
}

- (void)setupContent:(LSAddresseeItem *)model {
    self.nameLabel.text = model.anchorName;
    
    [self.imageLoader loadImageFromCache:self.headImageView options:SDWebImageRefreshCached imageUrl:model.anchorCoverUrl placeholderImage:nil finishHandler:^(UIImage *image) {

    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.imageLoader stop];
    [self.headImageView sd_cancelCurrentImageLoad];
    self.headImageView.image = nil;
}

@end
