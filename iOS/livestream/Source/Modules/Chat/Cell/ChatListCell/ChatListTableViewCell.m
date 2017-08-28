//
//  ChatListTableViewCell.m
//  livestream
//
//  Created by randy on 2017/8/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ChatListTableViewCell.h"

@implementation ChatListTableViewCell

- (void)awakeFromNib{
    
    [super awakeFromNib];
    
    self.unreadNumView.hidden = YES;
    
    self.unreadNumView.layer.cornerRadius = 10;
    self.unreadNumView.layer.masksToBounds = YES;
    
    self.headImageView.layer.cornerRadius = 23;
    self.headImageView.layer.masksToBounds = YES;
}


- (void)setListCellModel:(ChatListModel *)model {
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.imgUrl]
                          placeholderImage:[UIImage imageNamed:@"Live_Publish_Btn_Gift"] options:0];
    
    if (model.unreadNum) {
        
        self.unreadNumView.hidden = NO;
        
        if (model.unreadNum > 99) {
            
        }
        [self.unreadNumView setImage:[UIImage imageNamed:@""]];
        
    }else{
        
        self.unreadNumView.hidden = YES;
    }
    
    self.nameLabel.text = model.name;
    
    self.lasterMsgLabel.text = model.lasterMsg;
}


+ (NSString *)cellIdentifier {
    return @"ChatListTableViewCellIdentifier";
}

@end
