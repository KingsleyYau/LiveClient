//
//  LSIniviteListTableViewCell.m
//  livestream
//
//  Created by test on 2018/11/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "QNIniviteListTableViewCell.h"

@implementation QNIniviteListTableViewCell

+ (NSString *)cellIdentifier {
    return @"QNIniviteListTableViewCell";
}

+ (NSInteger)cellHeight {
    return 73;
}



+ (id)getUITableViewCell:(UITableView*)tableView {
    QNIniviteListTableViewCell *cell = (QNIniviteListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[QNIniviteListTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[QNIniviteListTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.imageViewLoader = nil;
    }
    
    return cell;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.ladyImage.hidden = NO;
    self.ladyImage.layer.masksToBounds = YES;
    
    self.ladyImage.layer.cornerRadius = self.ladyImage.frame.size.width * 0.5;
    self.onlineImage.layer.cornerRadius = self.onlineImage.frame.size.width * 0.5;
    self.onlineImage.layer.borderWidth = 1.0f;
    self.onlineImage.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.onlineImage.layer.masksToBounds = YES;
}

- (void)updateUI:(LSLadyRecentContactObject *)item {
    
    //在线icon
    self.onlineImage.hidden = !item.isOnline;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.onlineImage.backgroundColor = COLOR_WITH_16BAND_RGB(0x4B7F04);
}


//这个方法在用户按住Cell时被调用
-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    self.onlineImage.backgroundColor = COLOR_WITH_16BAND_RGB(0x4B7F04);
}

@end
