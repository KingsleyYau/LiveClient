//
//  ChatContactListTableViewCell.m
//  dating
//
//  Created by test on 2017/2/24.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSContactListTableViewCell.h"
#import "Masonry.h"


@interface LSContactListTableViewCell()

@end

@implementation LSContactListTableViewCell


+ (NSString *)cellIdentifier {
    return @"LSContactListTableViewCell";
}

+ (NSInteger)cellHeight {
    return 72;
}



+ (id)getUITableViewCell:(UITableView*)tableView {
    LSContactListTableViewCell *cell = (LSContactListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSContactListTableViewCell cellIdentifier]];
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSContactListTableViewCell cellIdentifier] owner:tableView options:nil];
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
    
    self.unreadCountIcon.layer.cornerRadius = 8;
    self.unreadCountIcon.layer.masksToBounds = YES;
}

- (void)updateUI:(LSLCLadyRecentContactObject *)item {
    // 在聊icon
    self.inchatIcon.hidden = item.isOnline ? !item.isInChat : YES;
    // 在线icon
    self.onlineImage.hidden = !item.isOnline;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.onlineImage.backgroundColor = COLOR_WITH_16BAND_RGB(0x4B7F04);
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    self.onlineImage.backgroundColor = COLOR_WITH_16BAND_RGB(0x4B7F04);
}

@end
