//
//  ManDetailTableViewCell.m
//  dating
//
//  Created by test on 2017/4/28.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSManDetailTableViewCell.h"

@interface LSManDetailTableViewCell()


@end


@implementation LSManDetailTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

//标识符
+ (NSString *)cellIdentifier{
    return @"LSManDetailTableViewCell";
}
//高度
+ (NSInteger)cellHeight{
    return 20;
}


//根据标识符生成
+ (id)getUITableViewCell:(UITableView *)tableView {
    LSManDetailTableViewCell *cell = (LSManDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSManDetailTableViewCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSManDetailTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
 
    cell.manDetail.adjustsFontSizeToFitWidth = YES;
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    return cell;
}
- (IBAction)personInformationEdit:(UIButton *)sender {
    if (self.manDetailDelegate && [self.manDetailDelegate respondsToSelector:@selector(lsManDetailTableViewCell:didClickEditBtnIndex:)]) {
        NSInteger index = sender.tag;
        [self.manDetailDelegate lsManDetailTableViewCell:self didClickEditBtnIndex:index];
    }
    
}
@end
