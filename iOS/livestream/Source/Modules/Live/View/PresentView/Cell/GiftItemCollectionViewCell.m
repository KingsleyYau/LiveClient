//
//  GiftItemCollectionViewCell.m
//  UIWidget
//
//  Created by test on 2017/6/12.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "GiftItemCollectionViewCell.h"
#import "LiveGiftDownloadManager.h"
#import "LSImageViewLoader.h"

@interface GiftItemCollectionViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftImageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftImageWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftImageBottomOffset;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftNameLableBottomOffset;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *giftCountBottomOffset;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bigGiftLogoHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bigGiftLogoWidth;

@property (weak, nonatomic) IBOutlet UIImageView *bigGiftLogo;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *haveNumViewWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *haveNumViewHeight;

@property (nonatomic, strong) LiveGiftDownloadManager *loadManager;

@property (nonatomic, strong) LSImageViewLoader *imageLoader;

@end

@implementation GiftItemCollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        
        [self updataMasonry];
        self.loadManager = [LiveGiftDownloadManager manager];
        self.imageLoader = [LSImageViewLoader loader];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectCell = NO;
    
    self.bigGiftLogo.hidden = NO;
    self.haveNumView.hidden = YES;
    self.notSendImageView.hidden = YES;
    
    [self updataMasonry];
}

- (void)updataMasonry{
    
    self.giftNameLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(11)];
    self.giftNameLabel.textColor = COLOR_WITH_16BAND_RGB_ALPHA(0x8cffffff);
    self.giftCountLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(9)];
    self.giftCountBottomOffset.constant = DESGIN_TRANSFORM_3X(4);
    self.giftNameLableBottomOffset.constant = 0;
    self.giftImageBottomOffset.constant = DESGIN_TRANSFORM_3X(3);
    self.giftImageWidth.constant = self.giftImageHeight.constant = DESGIN_TRANSFORM_3X(50);
    self.bigGiftLogoWidth.constant = self.bigGiftLogoHeight.constant = DESGIN_TRANSFORM_3X(12);
//    self.haveNumViewWidth.constant = DESGIN_TRANSFORM_3X(18);
//    self.haveNumViewHeight.constant = DESGIN_TRANSFORM_3X(18);
//    self.haveNumView.layer.cornerRadius = DESGIN_TRANSFORM_3X(9);
    self.haveNumView.layer.cornerRadius = self.haveNumView.frame.size.height / 2;
    self.haveNumView.layer.masksToBounds = YES;
//    self.haveNumLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(14)];
}

- (void)reloadStyle {
    if (self.selectCell) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = COLOR_WITH_16BAND_RGB(0xf7cd3a).CGColor;
    }else {
        self.layer.borderWidth = 0;
        self.layer.borderColor = COLOR_WITH_16BAND_RGB(0xf7cd3a).CGColor;
    }
}

/** 背包隐藏view */
- (void)backpackHiddenView {
    
    self.giftCountLabel.font = [UIFont systemFontOfSize:0];
    [self.giftCountLabel sizeToFit];
    self.giftCountBottomOffset.constant = DESGIN_TRANSFORM_3X(10);
    self.bigGiftLogo.hidden = YES;
    self.haveNumView.hidden = NO;
}

- (BOOL)updataCellViewItem:(AllGiftItem *)item manLV:(int)manLV loveLV:(int)loveLV{
    
    BOOL canSend = YES;
    self.selectCell = NO;
    
    if (item.infoItem.type == GIFTTYPE_COMMON) {
        self.bigGiftLogo.hidden = YES;
        self.loadingView.hidden = YES;
    }else{
        self.bigGiftLogo.hidden = NO;
        AllGiftItem *dicItem = [self.loadManager.bigGiftDownloadDic objectForKey:item.infoItem.giftId];
        if (dicItem.isDownloading) {
            [self.loadingView startAnimating];
            self.loadingView.hidden = NO;
        } else {
            [self.loadingView stopAnimating];
            self.loadingView.hidden = YES;
        }
    }
    
    if (loveLV < item.infoItem.loveLevel || manLV < item.infoItem.level) {
        self.notSendImageView.hidden = NO;
        self.bigGiftLogo.hidden = YES;
        canSend = NO;
    } else {
        self.notSendImageView.hidden = YES;
        canSend = YES;
    }
    
    self.giftNameLabel.text = item.infoItem.name;
    
    [self.imageLoader loadImageWithImageView:self.giftImageView options:0 imageUrl:item.infoItem.middleImgUrl placeholderImage:
     [UIImage imageNamed:@"Live_Gift_Nomal"]];
    
    NSNumber *credit = @(item.infoItem.credit);
    self.giftCountLabel.text = [NSString stringWithFormat:@"%@ Credits",credit];
    
    return canSend;
}

- (void)updataBackpackCellViewItem:(RoomBackGiftItem *)backItem manLV:(int)manLV loveLV:(int)loveLV canSend:(BOOL)canSend{
    
    self.selectCell = NO;
    
    self.bigGiftLogo.hidden = YES;
    
    AllGiftItem *item = [[LiveGiftDownloadManager manager] backGiftItemWithGiftID:backItem.giftId];
    
    self.giftNameLabel.text = item.infoItem.name;
    
    if ( item.infoItem.type == GIFTTYPE_COMMON ) {
        self.loadingView.hidden = YES;
    }else{
        AllGiftItem *dicItem = [self.loadManager.bigGiftDownloadDic objectForKey:item.infoItem.giftId];
        if (dicItem.isDownloading) {
            [self.loadingView startAnimating];
            self.loadingView.hidden = NO;
        } else {
            [self.loadingView stopAnimating];
            self.loadingView.hidden = YES;
        }
    }
    
    if ( loveLV < item.infoItem.loveLevel || manLV < item.infoItem.level || !canSend ) {
        self.notSendImageView.hidden = NO;
        self.haveNumView.hidden = YES;
        self.haveNumLabel.hidden = YES;
    } else {
        self.notSendImageView.hidden = YES;
        self.haveNumView.hidden = NO;
        self.haveNumLabel.hidden = NO;
    }
    
    [self.imageLoader loadImageWithImageView:self.giftImageView options:0 imageUrl:item.infoItem.middleImgUrl placeholderImage:
     [UIImage imageNamed:@"Live_Gift_Nomal"]];
    
    if ( backItem.num > 99 ) {
        self.haveNumLabel.text = [NSString stringWithFormat:@"99+"];
    } else {
        self.haveNumLabel.text = [NSString stringWithFormat:@"%d",backItem.num];
    }
}

+ (NSString *)cellIdentifier {
    return @"GiftItemCollectionViewIdentifier";
}
@end
