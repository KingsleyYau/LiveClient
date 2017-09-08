//
//  RecommandCollectionViewCell.m
//  livestream
//
//  Created by Max on 2017/9/7.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "RecommandCollectionViewCell.h"

@implementation RecommandCollectionViewCell

+ (NSString *)cellIdentifier {
    return @"RecommandCollectionViewCell";
}

+ (NSInteger)cellWidth {
    return 80;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.imageViewLoader = [ImageViewLoader loader];
        self.imageView.layer.cornerRadius = [RecommandCollectionViewCell cellWidth] / 2;
        self.imageView.layer.masksToBounds = YES;
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

@end
