//
//  ShowCell.m
//  livestream
//
//  Created by Calvin on 2018/4/18.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "ShowCell.h"

@interface ShowCell ()

@end

@implementation ShowCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.shadowView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    self.shadowView.layer.shadowOpacity = 0.8;
    self.shadowView.layer.shadowOffset = CGSizeMake(1, 1);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier {
    return @"ShowCell";
}

+ (NSInteger)cellHeight {
    return 250;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    ShowCell *cell = (ShowCell *)[tableView dequeueReusableCellWithIdentifier:[ShowCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[ShowCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
        cell.showListView.delegates = cell;
    
    return cell;
}

- (void)updateUI:(LSProgramItemObject *)item
{
    [self.showListView updateUI:item];
}

- (void)updateHistoryUI:(LSProgramItemObject *)item
{
    [self.showListView updateHistoryUI:item];
}

- (void)showListViewBtnDid:(NSInteger)type fromItem:(LSProgramItemObject *)item
{
    if ([self.cellDelegate respondsToSelector:@selector(showCellBtnDid: fromItem:)]) {
        [self.cellDelegate showCellBtnDid:type fromItem:item];
    }
}

@end
