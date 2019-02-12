//
//  ChatContactListTableViewCell.m
//  dating
//
//  Created by test on 2017/2/24.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "QNContactListTableViewCell.h"
#import "Masonry.h"


@interface QNContactListTableViewCell()

@end

@implementation QNContactListTableViewCell


+ (NSString *)cellIdentifier {
    return @"QNContactListTableViewCell";
}

+ (NSInteger)cellHeight {
    return 73;
}


+ (id)getUITableViewCell:(UITableView*)tableView {
    QNContactListTableViewCell *cell = (QNContactListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[QNContactListTableViewCell cellIdentifier]];
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[QNContactListTableViewCell cellIdentifier] owner:tableView options:nil];
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
    
    self.unreadCountIcon.layer.cornerRadius = self.unreadCountIcon.frame.size.height / 2.0f;
    self.unreadCountIcon.layer.masksToBounds = YES;
}

- (void)updateUI:(LSLadyRecentContactObject *)item {
    // 在聊icon
    self.inchatIcon.hidden = item.isOnline ? !item.isInChat : YES;
    // 在线icon
    self.onlineImage.hidden = !item.isOnline;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.onlineImage.backgroundColor = COLOR_WITH_16BAND_RGB(0x1BCD05);
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    self.onlineImage.backgroundColor = COLOR_WITH_16BAND_RGB(0x1BCD05);
}

@end
