//
//  EMFBoxTableViewCell.m
//  dating
//
//  Created by alex shum on 17/6/14.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSEMFBoxTableViewCell.h"

@implementation LSEMFBoxTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.headImg layoutIfNeeded];
    self.headImg.layer.cornerRadius = self.headImg.frame.size.width * 0.5;
    self.stateImg.layer.cornerRadius = 5;
    self.stateImg.layer.masksToBounds = YES;
    self.stateImg.backgroundColor = [UIColor redColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (NSString *)cellIdentifier {
    return @"LSEMFBoxTableViewCell";
}

+ (NSInteger)cellHeight {
    return 72;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSEMFBoxTableViewCell *cell = (LSEMFBoxTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSEMFBoxTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSEMFBoxTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    return cell;
}

+ (UIEdgeInsets)defaultInsets {
    return UIEdgeInsetsMake(0, 64, 0, 0);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)updateNameFrame:(NSString *)name {
    CGFloat w = [name sizeWithAttributes:@{NSFontAttributeName:self.nameLabel.font}].width;
    CGRect nameRect = self.nameLabel.frame;
    nameRect.size.width = w;
    self.nameFrame = nameRect;
    self.nameLabel.frame = nameRect;
    
    CGRect iconRect = self.attachImg.frame;
    iconRect.origin.x = nameRect.origin.x + w + 10;
    self.attachImg.frame = iconRect;
    
    CGRect secondIconRect = self.secondAttachImg.frame;
    secondIconRect.origin.x = CGRectGetMaxX(iconRect) + 10;
    self.secondAttachImg.frame = secondIconRect;
}

@end
