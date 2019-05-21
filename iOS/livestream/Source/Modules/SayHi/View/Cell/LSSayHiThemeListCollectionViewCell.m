//
//  LSSayHiThemeListCollectionViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2019/4/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiThemeListCollectionViewCell.h"
#import "LSImageViewLoader.h"

@interface LSSayHiThemeListCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *themeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;

@property (strong, nonatomic) LSImageViewLoader *imageLoader;

@end

@implementation LSSayHiThemeListCollectionViewCell

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
    LSSayHiThemeListCollectionViewCell *cell = (LSSayHiThemeListCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[LSSayHiThemeListCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSSayHiThemeListCollectionViewCell cellIdentifier] owner:collectionView options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.themeImageView.layer.cornerRadius = 5;
    self.themeImageView.layer.borderWidth = 2;
    self.themeImageView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xff7100).CGColor;
    self.themeImageView.layer.masksToBounds = YES;
    
    self.selectImageView.hidden = YES;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.themeImageView.layer.borderWidth = 2;
    } else {
        self.themeImageView.layer.borderWidth = 0;
    }
    self.selectImageView.hidden = !selected;
}

- (void)setupTheme:(NSString *)img {
    [self.imageLoader loadImageWithImageView:self.themeImageView options:0 imageUrl:img placeholderImage:[UIImage imageNamed:@"Select_Theme_Normal_Icon"] finishHandler:^(UIImage *image) {
        
    }];
}

// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageLoader stop];
    [self.themeImageView sd_cancelCurrentImageLoad];
    self.themeImageView.image = nil;
}


@end
