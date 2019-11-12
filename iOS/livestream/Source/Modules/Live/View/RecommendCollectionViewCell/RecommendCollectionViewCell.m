//
//  RecommendCollectionViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2019/6/11.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "RecommendCollectionViewCell.h"
#import "LSImageViewLoader.h"

@interface RecommendCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UIButton *followBtn;

@property (weak, nonatomic) IBOutlet UIButton *sayHiBtn;

@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIImageView *onlineView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) LSImageViewLoader *imageLoader;

@property (strong, nonatomic) LSRecommendAnchorItemObject *anchorItem;

@end

@implementation RecommendCollectionViewCell

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self class]);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.imageLoader = [LSImageViewLoader loader];
        self.anchorItem = [[LSRecommendAnchorItemObject alloc] init];
    }
    return self;
}

+ (id)getUICollectionViewCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath {
    RecommendCollectionViewCell *cell = (RecommendCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[RecommendCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[RecommendCollectionViewCell cellIdentifier] owner:collectionView options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.layer.cornerRadius = 5;
    self.contentView.layer.masksToBounds = YES;
    
    self.onlineView.layer.cornerRadius = self.onlineView.tx_height / 2;
    self.onlineView.layer.masksToBounds = YES;
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0xD4000000).CGColor,(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x25000000).CGColor, (__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x00000000).CGColor];
    gradientLayer.locations = @[@0,@0.75,@1.0];
    gradientLayer.startPoint = CGPointMake(0, 1.0);
    gradientLayer.endPoint = CGPointMake(0, 0.0);
    gradientLayer.frame = CGRectMake(0, 0, screenSize.width, self.bottomView.tx_height);
    [self.bottomView.layer addSublayer:gradientLayer];
}

- (void)updataReommendCell:(LSRecommendAnchorItemObject *)item {
    if (item.anchorId.length > 0) {
        
        self.followBtn.hidden = NO;
        self.sayHiBtn.hidden = NO;
        self.headImageView.hidden = NO;
        self.bottomView.hidden = NO;
        
        self.anchorItem = item;
        
        self.nameLabel.text = item.anchorNickName;
        [self.imageLoader loadImageWithImageView:self.headImageView options:0 imageUrl:item.anchorCover placeholderImage:[self imageWithColor:COLOR_WITH_16BAND_RGB(0xd8d8d8)] finishHandler:^(UIImage *image) {
            
        }];
        if (item.isFollow) {
            self.followBtn.userInteractionEnabled = NO;
            [self.followBtn setImage:[UIImage imageNamed:@"Home_HotAndFollow_Follow"] forState:UIControlStateNormal];
        } else {
            self.followBtn.userInteractionEnabled = YES;
            [self.followBtn setImage:[UIImage imageNamed:@"Home_HotAndFollow_UnFollow"] forState:UIControlStateNormal];
        }
        
        if (!item.onlineStatus) {
            [self.onlineView setBackgroundColor:COLOR_WITH_16BAND_RGB(0xc2c2c2)];
        } else {
            [self.onlineView setBackgroundColor:COLOR_WITH_16BAND_RGB(0x20a726)];
        }
    }
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (IBAction)followAction:(id)sender {
    self.followBtn.userInteractionEnabled = NO;
    [self.followBtn setImage:[UIImage imageNamed:@"Home_HotAndFollow_Follow"] forState:UIControlStateNormal];
    if ([self.delegate respondsToSelector:@selector(recommendViewCellFollowToAnchor:)]) {
        [self.delegate recommendViewCellFollowToAnchor:self.anchorItem];
    }
}

- (IBAction)sayHiAction:(id)sender {
    if ([self.delegate respondsToSelector:@selector(recommendViewCellSayHiToAnchor:)]) {
        [self.delegate recommendViewCellSayHiToAnchor:self.anchorItem];
    }
}

// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageLoader stop];
    [self.headImageView sd_cancelCurrentImageLoad];
    self.headImageView.image = nil;
    
    self.followBtn.hidden = YES;
    self.sayHiBtn.hidden = YES;
    self.headImageView.hidden = YES;
    self.bottomView.hidden = YES;
}

@end
