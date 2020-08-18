//
//  LSRecipientCell.m
//  livestream
//
//  Created by test on 2020/4/7.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSRecipientCell.h"
#import "LSImageViewLoader.h"

@interface LSRecipientCell()
@property (nonatomic, strong) LSImageViewLoader *imageLoader;

@end

@implementation LSRecipientCell
+ (NSString *)cellIdentifier {
    return @"LSRecipientCell";
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.imageLoader = [LSImageViewLoader loader];
    }
    return self;
}

- (void)setupUI:(LSRecepientItem *)item {
    [self.imageLoader loadImageWithImageView:self.anchorPhoto options:0 imageUrl:item.anchorPhoto placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_HangOut"] finishHandler:^(UIImage *image) {
        
    }];
    self.anchorName.text = item.anchorName;
}


// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageLoader stop];
    [self.anchorPhoto sd_cancelCurrentImageLoad];
    self.anchorPhoto.image = nil;
    self.anchorPhoto.layer.borderWidth = 0;
    self.anchorPhoto.layer.borderColor = [UIColor clearColor].CGColor;
}


+ (NSInteger)cellWidth {
    return 70;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.imageLoader = [LSImageViewLoader loader];
}

@end
