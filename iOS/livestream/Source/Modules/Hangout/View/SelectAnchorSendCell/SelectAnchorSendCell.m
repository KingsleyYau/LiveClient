//
//  SelectAnchorSendCell.m
//  livestream
//
//  Created by Randy_Fan on 2019/2/13.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "SelectAnchorSendCell.h"
#import "LSImageViewLoader.h"
#import "LSShadowView.h"

@interface SelectAnchorSendCell ()

@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;

@property (weak, nonatomic) IBOutlet UIImageView *firstImageView;

@property (strong, nonatomic) LSImageViewLoader *imageLoader;

@property (assign, nonatomic) BOOL isSelect;

@end

@implementation SelectAnchorSendCell

+ (NSString *)cellIdentifier {
    return @"SelectAnchorSendCell";
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.imageLoader = [LSImageViewLoader loader];
        self.isSelect = YES;
    }
    return self;
}

- (void)setupDate:(NSString *)url index:(NSInteger)index {
    if (!index) {
        self.firstImageView.hidden = NO;
    } else {
        self.firstImageView.hidden = YES;
    }
    [self.imageLoader loadImageFromCache:self.headImageView options:SDWebImageRefreshCached imageUrl:url placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:^(UIImage *image) {
    }];
}

- (void)foreverAnimation:(CABasicAnimation *)animation {
    for (UIView *view in self.contentView.subviews) {
        if ([view isKindOfClass:[LSShadowView class]]) {
             [view.layer addAnimation:animation forKey:nil];
        }
    }
}

- (void)changeSelect:(BOOL)isSelect {
    self.isSelect = isSelect;
    if (isSelect) {
        self.selectImageView.hidden = NO;
        self.headImageView.layer.borderColor = COLOR_WITH_16BAND_RGB(0x55c02a).CGColor;
        self.shadowView.hidden = NO;
    } else {
        self.headImageView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xffffff).CGColor;
        self.shadowView.hidden = YES;
        self.selectImageView.hidden = YES;
    }
}

- (BOOL)getIsSelect {
    return self.isSelect;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectImageView.hidden = NO;
    
    self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height / 2;
    self.headImageView.layer.borderWidth = 1;
    self.headImageView.layer.borderColor = COLOR_WITH_16BAND_RGB(0x55c02a).CGColor;
    self.headImageView.layer.masksToBounds = YES;
    
    self.shadowView.layer.cornerRadius = self.shadowView.frame.size.height / 2;
    self.shadowView.layer.masksToBounds = YES;
    
    LSShadowView *shadowView = [[LSShadowView alloc] init];
    shadowView.shadowColor = COLOR_WITH_16BAND_RGB(0xffffff);
    shadowView.shadowOpacity = 1;
    shadowView.shadowRadius = 2;
    [shadowView showShadowAddView:self.shadowView];
    
    self.firstImageView.hidden = YES;
}

// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageLoader stop];
    [self.headImageView sd_cancelCurrentImageLoad];
    self.headImageView.image = nil;
}

@end
