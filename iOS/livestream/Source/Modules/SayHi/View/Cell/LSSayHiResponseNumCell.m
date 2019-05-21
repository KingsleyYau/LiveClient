//
//  LSSayHiResponseNumCell.m
//  livestream
//
//  Created by Calvin on 2019/5/5.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiResponseNumCell.h"

@implementation LSSayHiResponseNumCell


+ (NSString *)cellIdentifier {
    return @"LSSayHiResponseNumCell";
}

+ (NSInteger)cellHeight {
    return 55;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSSayHiResponseNumCell *cell = (LSSayHiResponseNumCell *)[tableView dequeueReusableCellWithIdentifier:[LSSayHiResponseNumCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSSayHiResponseNumCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell;
}

- (void)setContentText:(LSSayHiDetailItemObject *)detail {
    
    NSString * text = [NSString stringWithFormat:@"( %d / %d )",detail.unreadNum,detail.responseNum];
    NSAttributedString * name = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@'s response ",detail.nickName]];
    
    NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc]initWithString:text];
    [attributeString addAttributes:@{
                                     NSFontAttributeName : self.contentLabel.font,
                                     NSForegroundColorAttributeName:[UIColor orangeColor]
                                     }
                             range:[text rangeOfString:[NSString stringWithFormat:@"%d",detail.unreadNum]]];
    [attributeString insertAttributedString:name atIndex:0];
    self.contentLabel.attributedText = attributeString;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
