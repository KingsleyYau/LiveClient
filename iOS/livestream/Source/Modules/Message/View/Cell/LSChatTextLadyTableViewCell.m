//
//  ChatTextLadyTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSChatTextLadyTableViewCell.h"

@implementation LSChatTextLadyTableViewCell
+ (NSString *)cellIdentifier {
    return @"LSChatTextLadyTableViewCell";
}

+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSAttributedString *)detailString {
    NSInteger height = 15;
    
    if(detailString.length > 0) {
        CGRect rect = [detailString boundingRectWithSize:CGSizeMake(width - 125, MAXFLOAT)
                                                 options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        height += ceil(rect.size.height);
    }
    height += 15;
    
    return height;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSChatTextLadyTableViewCell *cell = (LSChatTextLadyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSChatTextLadyTableViewCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[LSChatTextLadyTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.backgroundImageView.layer.cornerRadius = cell.backgroundImageView.frame.size.height/2 -1;
        cell.backgroundImageView.layer.masksToBounds = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.detailLabel.text = @"";


    return cell;
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

@end
