//
//  LSPrivatePhotoCollectionViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/12/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSPrivatePhotoCollectionViewCell.h"
#import "LSImageViewLoader.h"

@interface LSPrivatePhotoCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *privateImageView;
@property (weak, nonatomic) IBOutlet UIImageView *unlockImageView;
@property (weak, nonatomic) IBOutlet UIView *tipView;
@property (weak, nonatomic) IBOutlet UIImageView *tipImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UILabel *desLabel;

@property (nonatomic, strong) LSImageViewLoader *imageLoader;

@end

@implementation LSPrivatePhotoCollectionViewCell

+ (NSString *)cellIdentifier {
    return @"LSPrivatePhotoCollectionViewCell";
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.imageLoader = [LSImageViewLoader loader];
    }
    return self;
}

- (void)setupImageDetail:(LSMailAttachmentModel *)model {
    
    self.desLabel.text = model.photoDesc;
    UIImage *placeholderImage = [self createImageWithColor:COLOR_WITH_16BAND_RGB(0xd8d8d8)];
    switch (model.expenseType) {
        case ExpenseTypeNo:{
            self.unlockImageView.hidden = YES;
            self.tipView.hidden = NO;
            [self.tipImageView setImage:[UIImage imageNamed:@"EMF_Private_Lock"]];
            self.tipLabel.text = NSLocalizedStringFromSelf(@"axA-EL-g1h.text");
            [self.imageLoader loadImageWithImageView:self.privateImageView options:0 imageUrl:model.blurImgUrl placeholderImage:placeholderImage finishHandler:nil];
        }break;
        
        case ExpenseTypeYes:{
            self.unlockImageView.hidden = NO;
            self.tipView.hidden = YES;
            [self.imageLoader loadImageWithImageView:self.privateImageView options:0 imageUrl:model.smallImgUrl placeholderImage:placeholderImage finishHandler:nil];
        }break;
            
        default:{
            self.unlockImageView.hidden = YES;
            self.tipView.hidden = NO;
            [self.tipImageView setImage:[UIImage imageNamed:@"Mail_Private_Photo_Expired"]];
            self.tipLabel.text = NSLocalizedStringFromSelf(@"EXPIRED");
            [self.imageLoader loadImageWithImageView:self.privateImageView options:0 imageUrl:model.blurImgUrl placeholderImage:placeholderImage finishHandler:nil];
        }break;
    }
}


- (UIImage*)createImageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageLoader stop];
    [self.privateImageView sd_cancelCurrentImageLoad];
    self.privateImageView.image = nil;
}

@end
