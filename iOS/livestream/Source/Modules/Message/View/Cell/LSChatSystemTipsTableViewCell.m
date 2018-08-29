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
    self.bgView.layer.cornerRadius = 19.0f;
    self.bgView.layer.masksToBounds = YES;
}

+ (NSString *)cellIdentifier {
    return @"LSChatSystemTipsTableViewCell";
}

+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSAttributedString *)detailString {
    NSInteger height = 7;
    
    if(detailString.length > 0) {
        CGRect rect = [detailString boundingRectWithSize:CGSizeMake(width - 30 - 8 - 22 - 8 - 8 -30, MAXFLOAT)
                                                 options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        height += ceil(rect.size.height);
    }
    height += 7;
    
    if (height < 44) {
        return 44;
    }
    return height;
}
+ (id)getUITableViewCell:(UITableView*)tableView {
    LSChatSystemTipsTableViewCell *cell = (LSChatSystemTipsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSChatSystemTipsTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[LSChatSystemTipsTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
