//
//  ChatSystemTipsTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSChatSystemTipsTableViewCell.h"

@implementation LSChatSystemTipsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.bgView.layer.cornerRadius = 5;
    self.bgView.layer.masksToBounds = YES;
}

+ (NSString *)cellIdentifier {
    return @"LSChatSystemTipsTableViewCell";
}

+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSAttributedString *)detailString {
    NSInteger height = 7;
    
    if(detailString.length > 0) {
        CGRect rect = [detailString boundingRectWithSize:CGSizeMake(260, MAXFLOAT)
                                                 options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        height += ceil(rect.size.height);
    }
    height += 7;
    
    if (height < 60) {
        return 60;
    }
    return height;
}
+ (id)getUITableViewCell:(UITableView*)tableView {
    LSChatSystemTipsTableViewCell *cell = (LSChatSystemTipsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSChatSystemTipsTableViewCell cellIdentifier]];
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSChatSystemTipsTableViewCell cellIdentifier] owner:nil options:nil];
        self = [nib objectAtIndex:0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
