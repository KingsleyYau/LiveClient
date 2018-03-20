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
    
    self.selectCell = NO;
    
    self.bigGiftLogo.hidden = NO;
    
    [self updataMasonry];
}

- (void)updataMasonry{
    
    self.giftNameLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(11)];
    self.giftNameLabel.textColor = COLOR_WITH_16BAND_RGB_ALPHA(0x8cffffff);
    self.haveNumLabel.font = [UIFont systemFontOfSize:DESGIN_TRANSFORM_3X(9)];
    self.giftCountBottomOffset.constant = DESGIN_TRANSFORM_3X(4);
    self.giftNameLableBottomOffset.constant = 0;
    self.giftImageBottomOffset.constant = DESGIN_TRANSFORM_3X(3);
    self.giftImageWidth.constant = self.giftImageHeight.constant = DESGIN_TRANSFORM_3X(50);
    self.bigGiftLogoWidth.constant = self.bigGiftLogoHeight.constant = DESGIN_TRANSFORM_3X(12);
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

- (void)updataBackpackCellViewItem:(RoomBackGiftItem *)backItem {
    
    AllGiftItem *item = [[LiveGiftDownloadManager manager] backGiftItemWithGiftID:backItem.giftId];
    
    self.selectCell = NO;
    
    if (item.infoItem.type == ZBGIFTTYPE_COMMON) {
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

    self.giftNameLabel.text = item.infoItem.name;
    
    [self.imageLoader loadImageWithImageView:self.giftImageView options:0 imageUrl:item.infoItem.middleImgUrl placeholderImage:
     [UIImage imageNamed:@"Live_Gift_Nomal"]];
    
    self.haveNumLabel.text = [NSString stringWithFormat:@"x %d",backItem.giftNum];
}

+ (NSString *)cellIdentifier {
    return @"GiftItemCollectionViewIdentifier";
}
@end
