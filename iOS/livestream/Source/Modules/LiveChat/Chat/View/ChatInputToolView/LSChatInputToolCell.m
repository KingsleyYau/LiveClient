//
//  LSChatInputToolCell.m
//  livestream
//
//  Created by Calvin on 2020/3/26.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSChatInputToolCell.h"

@implementation LSChatInputToolCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.redLabel.layer.cornerRadius = self.redLabel.tx_width/2;
    self.redLabel.layer.masksToBounds = YES;
}

+ (NSString *)cellIdentifier {
    return @"LSChatInputToolCell";
}

@end
