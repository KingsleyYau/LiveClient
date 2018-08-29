//
//  HangoutGiftCellCollectionViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/5/21.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HangoutGiftCellCollectionViewCell.h"
#import "LSImageViewLoader.h"

@interface HangoutGiftCellCollectionViewCell()

@property (nonatomic, strong) LSGiftManager *loadManager;
@property (nonatomic, strong) LSImageViewLoader *imageLoader;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadView;

@end

@implementation HangoutGiftCellCollectionViewCell

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.loadManager = [LSGiftManager manager];
        self.imageLoader = [LSImageViewLoader loader];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectCell = NO;
    self.signImageView.hidden = YES;
}

- (void)reloadStyle {
    if (self.selectCell) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = Color(5, 199, 117, 1).CGColor;
    }else {
        self.layer.borderWidth = 0;
        self.layer.borderColor = Color(5, 199, 117, 1).CGColor;
    }
}

- (void)updataCellViewItem:(LSGiftManagerItem *)item {
    LSGiftManagerItem *dicItem = [self.loadManager getGiftItemWithId:item.infoItem.giftId];
    if (dicItem.isDownloading) {
        [self.loadView startAnimating];
        self.loadView.hidden = NO;
    } else {
        [self.loadView stopAnimating];
        self.loadView.hidden = YES;
    }
    
    [self.imageLoader loadImageWithImageView:self.giftImageView options:0 imageUrl:item.infoItem.smallImgUrl
      placeholderImage:[UIImage imageNamed:@"Live_Publish_Btn_Gift"]];
    
    NSNumber *credit = @(item.infoItem.credit);
    self.creditLabel.text = [NSString stringWithFormat:@"%@ credits",credit];
    
    if ( item.infoItem.type == GIFTTYPE_Heigh ) {
        self.signImageView.hidden = NO;
    } else {
        self.signImageView.hidden = YES;
    }
}

+ (NSString *)cellIdentifier {
    return @"HangoutGiftCellCollectionViewCellIdentifier";
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageLoader stop];
    [self.giftImageView sd_cancelCurrentImageLoad];
    self.giftImageView.image = nil;
}

@end
