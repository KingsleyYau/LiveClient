//
//  GiftItemCollectionViewCell.m
//  UIWidget
//
//  Created by test on 2017/6/12.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "GiftItemCollectionViewCell.h"

@implementation GiftItemCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectCell = NO;


//    self.selectCell = NO;
}


- (void)reloadStyle {
    if (self.selectCell) {
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor yellowColor].CGColor;
        self.countImage.hidden = NO;
    }else {
        self.layer.borderWidth = 0;
        self.layer.borderColor = [UIColor yellowColor].CGColor;
        self.countImage.hidden = YES;
    }
    
}

+ (NSString *)cellIdentifier {
    return @"GiftItemCollectionViewCell";
}
@end
