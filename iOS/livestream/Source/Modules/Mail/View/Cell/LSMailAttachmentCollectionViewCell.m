//
//  LSMailAttachmentCollectionViewCell.m
//  livestream
//
//  Created by test on 2018/12/26.
//  Copyright © 2018 net.qdating. All rights reserved.
//

#import "LSMailAttachmentCollectionViewCell.h"

@implementation LSMailAttachmentCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    // 创建新的
    self.imageViewLoader = [LSImageViewLoader loader];

}

+ (NSString *)cellIdentifier {
    return @"LSMailAttachmentCollectionViewCell";
}



@end
