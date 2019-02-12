//
//  TagListCollectionViewCell.m
//  dating
//
//  Created by test on 2017/5/4.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSTagListCollectionViewCell.h"

@interface LSTagListCollectionViewCell()

@end



@implementation LSTagListCollectionViewCell


+ (NSString *)cellIdentifier {
    return @"LSTagListCollectionViewCell";
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.0f;
        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

}

- (void)prepareForReuse {
    [super prepareForReuse];
    

}

@end
