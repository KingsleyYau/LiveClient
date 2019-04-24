//
//  RecentWatchCollectionViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2019/3/21.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "RecentWatchCollectionViewCell.h"
#import "LSImageViewLoader.h"

@interface RecentWatchCollectionViewCell ()

@property (nonatomic, strong) LSImageViewLoader *imageLoader;

@property (nonatomic, assign) NSInteger row;

@end

@implementation RecentWatchCollectionViewCell

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
    RecentWatchCollectionViewCell *cell = (RecentWatchCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[RecentWatchCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    cell.row = indexPath.row;
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[RecentWatchCollectionViewCell cellIdentifier] owner:collectionView options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.coverImageView.layer.cornerRadius = 5;
    self.coverImageView.layer.masksToBounds = YES;
}

- (void)setupCellContent:(LSLCRecentVideoItemObject *)item {
 
    [self.imageLoader loadImageWithImageView:self.coverImageView options:0 imageUrl:item.videoCover placeholderImage:nil finishHandler:^(UIImage *image) {
        
    }];
    self.representLabel.text = item.title;
}

// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageLoader stop];
    [self.coverImageView sd_cancelCurrentImageLoad];
    self.coverImageView.image = nil;
}

@end
