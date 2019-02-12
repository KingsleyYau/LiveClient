//
//  LSChatTimeTableViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/9/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSChatTimeTableViewCell.h"

@implementation LSChatTimeTableViewCell

+ (NSString *)cellIdentifier {
    return @"LSChatTimeTableViewCell";
}

+ (NSInteger)cellHeight {
    return 47;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSChatTimeTableViewCell *cell = (LSChatTimeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSChatTimeTableViewCell cellIdentifier]];
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSChatTimeTableViewCell cellIdentifier] owner:nil options:nil];
        self = [nib objectAtIndex:0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end
