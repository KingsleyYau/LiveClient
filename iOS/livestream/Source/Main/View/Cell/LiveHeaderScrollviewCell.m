//
//  LiveHeaderScrollviewCell.m
//  ScrollviewDemo
//
//  Created by zzq on 2018/2/8.
//  Copyright © 2018年 zzq. All rights reserved.
//

#import "LiveHeaderScrollviewCell.h"

@implementation LiveHeaderScrollviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.redLabel.layer.cornerRadius = self.redLabel.frame.size.height / 2;
    self.redLabel.layer.masksToBounds = YES;
}

+ (NSString *)cellIdentifier {
    return @"ItemCollectionCellID";
}

@end
