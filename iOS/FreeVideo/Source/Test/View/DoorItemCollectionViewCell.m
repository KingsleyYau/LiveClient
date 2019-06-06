//
//  GiftItemCollectionViewCell.m
//  UIWidget
//
//  Created by test on 2017/6/12.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "DoorItemCollectionViewCell.h"
#import "LSImageViewLoader.h"

@interface DoorItemCollectionViewCell ()
@end

@implementation DoorItemCollectionViewCell
+ (NSString *)cellIdentifier {
    return @"DoorItemCollectionViewCell";
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {

    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    self.imageViewLoader = [LSImageViewLoader loader];
    self.imageViewHeader.image = nil;
    self.labelRoomTitle.text = @"";
    
    self.onlineImageView.layer.cornerRadius = self.onlineImageView.frame.size.height * 0.5f;
    self.onlineImageView.layer.masksToBounds = YES;
}

- (void)reset {
    self.imageViewHeader.image = nil;
    self.labelRoomTitle.text = @"";
    self.onlineImageView.hidden = YES;
}

@end
