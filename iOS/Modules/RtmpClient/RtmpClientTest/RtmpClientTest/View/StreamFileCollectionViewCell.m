//
//  StreamFileCollectionViewCell.m
//  UIWidget
//
//  Created by test on 2017/6/12.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "StreamFileCollectionViewCell.h"

@interface StreamFileCollectionViewCell ()
@end

@implementation StreamFileCollectionViewCell
+ (NSString *)cellIdentifier {
    return NSStringFromClass([StreamFileCollectionViewCell class]);
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
    [self reset];
}

- (void)reset {
    self.fileImageView.image = nil;
    self.fileNameLabel.text = @"";
}

@end
