//
//  ChatPhotoCollectionViewCell.m
//  dating
//
//  Created by test on 16/7/7.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSChatPhotoCollectionViewCell.h"

@implementation LSChatPhotoCollectionViewCell

+ (NSString *)cellIdentifier{
    return @"LSChatPhotoCollectionViewCell";
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.viewBtn.layer.cornerRadius = self.viewBtn.frame.size.height/2;
    self.viewBtn.layer.masksToBounds = YES;
    
    self.sendBtn.layer.cornerRadius = self.sendBtn.frame.size.height/2;
    self.sendBtn.layer.masksToBounds = YES;
}

@end
