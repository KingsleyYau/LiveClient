//
//  LSHangoutFriendCollectionViewCell.m
//  livestream
//
//  Created by test on 2019/1/21.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSHangoutFriendCollectionViewCell.h"

@implementation LSHangoutFriendCollectionViewCell

+ (NSString *)cellIdentifier {
    return @"LSHangoutFriendCollectionViewCell";
}

+ (NSInteger)cellWidth {
    return 60;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.imageViewLoader = [LSImageViewLoader loader];
        self.imageView.layer.cornerRadius = 5;
        self.imageView.layer.masksToBounds = YES;
        self.onlineView.layer.cornerRadius = self.onlineView.frame.size.width / 2.0;
        self.onlineView.layer.masksToBounds = YES;
    }
    
    return self;
}

- (void)layoutSubviews {
    
    self.imageView.layer.cornerRadius = 5;
    self.imageView.layer.masksToBounds = YES;
    self.onlineView.layer.cornerRadius = self.onlineView.frame.size.width / 2.0;
    self.onlineView.layer.masksToBounds = YES;
}

@end
