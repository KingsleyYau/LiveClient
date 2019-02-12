//
//  CommonDetailAndAccessoryTableViewCell.h
//  dating
//
//  Created by lance on 16/3/8.
//   cell包含标题和辅助视图
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSCreditDetailTableViewCell.h"

@implementation LSCreditDetailTableViewCell
//标识符
+ (NSString *)cellIdentifier{
    return @"LSCreditDetailTableViewCell";
}
//高度
+ (NSInteger)cellHeight{
    return 106;
}


//根据标识符生成
+ (id)getUITableViewCell:(UITableView *)tableView {
    LSCreditDetailTableViewCell *cell = (LSCreditDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSCreditDetailTableViewCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSCreditDetailTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }

    cell.titleBtn.layer.masksToBounds = YES;
    cell.bgView.layer.cornerRadius = 8.0f;
    cell.bgView.layer.masksToBounds = YES;
    cell.detailLabel.text = @"";
    cell.accessoryLabel.text = @"";
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.titleBtn layoutIfNeeded];
    self.titleBtn.layer.cornerRadius = self.titleBtn.frame.size.height * 0.5;
    
}

@end
