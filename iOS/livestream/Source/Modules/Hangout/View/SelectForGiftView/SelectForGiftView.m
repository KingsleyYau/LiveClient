//
//  SelectForGiftView.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "SelectForGiftView.h"
#import "LiveBundle.h"
#import "LSImageViewLoader.h"

@implementation SelecterModel
@end

@interface SelectForGiftView ()
@property (strong, nonatomic) SelecterModel *selecterModel;
@end

@implementation SelectForGiftView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self = [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        self.frame = frame;
        self.selecterModel = [[SelecterModel alloc] init];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self showNoBroadcasts];
    
    self.anchorImageView.layer.cornerRadius = self.anchorImageView.frame.size.height * 0.5;
    self.anchorImageView.layer.masksToBounds = YES;
   
    self.allImageViewOne.layer.cornerRadius = self.allImageViewOne.frame.size.height * 0.5;
    self.allImageViewOne.layer.masksToBounds = YES;
   
    self.allImageViewTwo.layer.cornerRadius = self.allImageViewTwo.frame.size.height * 0.5;
    self.allImageViewTwo.layer.masksToBounds = YES;
    
    self.allImageViewThree.layer.cornerRadius = self.allImageViewThree.frame.size.height * 0.5;
    self.allImageViewThree.layer.masksToBounds = YES;
    
    self.backgroundView.layer.shadowColor = Color(0, 0, 0, 1).CGColor;
    self.backgroundView.layer.shadowOffset = CGSizeMake(0, 0);
    self.backgroundView.layer.shadowRadius = 1;
    self.backgroundView.layer.shadowOpacity = 0.1;
    
    self.backgroundView.layer.cornerRadius = 5;
}

- (IBAction)selectAction:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(selectTheSender:)]) {
        [self.delegate selectTheSender:self.selecterModel];
    }
}

- (void)showViewUpdate:(SelecterModel *)model {
    self.selecterModel = model;
    if (model.urls.count == 0) {
        [self showNoBroadcasts];
    } else if (model.urls.count > 1) {
        [self showMoreAnchor:model.urls anchorName:model.anchorName];
    } else {
        [self showOnaAnchor:model.urls.firstObject anchorName:model.anchorName];
    }
}

- (void)showNoBroadcasts {
    self.tipLabel.hidden = NO;
    self.nameLabel.hidden = YES;
    self.anchorImageView.hidden = YES;
    self.allImageViewOne.hidden = YES;
    self.allImageViewTwo.hidden = YES;
    self.allImageViewThree.hidden = YES;
}

- (void)showOnaAnchor:(NSString *)url anchorName:(NSString *)anchorName {
    self.nameLabel.hidden = NO;
    self.anchorImageView.hidden = NO;
    
    self.tipLabel.hidden = YES;
    self.allImageViewOne.hidden = YES;
    self.allImageViewTwo.hidden = YES;
    self.allImageViewThree.hidden = YES;
    
    self.nameLabel.text = anchorName;
    [[LSImageViewLoader loader] loadImageFromCache:self.anchorImageView options:SDWebImageRefreshCached imageUrl:url placeholderImage:LADYDEFAULTIMG finishHandler:^(UIImage *image) {
    }];
}

- (void)showMoreAnchor:(NSMutableArray *)urls anchorName:(NSString *)anchorName {
    BOOL isSubter = YES;
    
    self.headViewTwoY.constant =urls.count == 2?-5:0;
    if (urls.count > 2) {
        isSubter = NO;
    }
    self.nameLabel.hidden = NO;
    self.allImageViewOne.hidden = isSubter;
    self.allImageViewTwo.hidden = NO;
    self.allImageViewThree.hidden = NO;
    
    self.tipLabel.hidden = YES;
    self.anchorImageView.hidden = YES;
    
    self.nameLabel.text = anchorName;
    [[LSImageViewLoader loader] loadImageFromCache:self.allImageViewTwo options:SDWebImageRefreshCached imageUrl:urls.firstObject placeholderImage:LADYDEFAULTIMG finishHandler:^(UIImage *image) {
    }];
    [[LSImageViewLoader loader] loadImageFromCache:self.allImageViewThree options:SDWebImageRefreshCached imageUrl:urls[1] placeholderImage:LADYDEFAULTIMG finishHandler:^(UIImage *image) {
    }];
    if (!isSubter) {
        [[LSImageViewLoader loader] loadImageFromCache:self.allImageViewOne options:SDWebImageRefreshCached imageUrl:urls[2] placeholderImage:LADYDEFAULTIMG finishHandler:^(UIImage *image) {
        }];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
