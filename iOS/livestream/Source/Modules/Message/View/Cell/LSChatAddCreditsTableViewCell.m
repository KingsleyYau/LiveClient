//
//  LSChatAddCreditsTableViewCell.m
//  livestream
//
//  Created by Calvin on 2018/7/3.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSChatAddCreditsTableViewCell.h"

@implementation LSChatAddCreditsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.bgView.layer.cornerRadius = 10;
    self.bgView.layer.masksToBounds = YES;
}

+ (NSString *)cellIdentifier {
    return @"LSChatAddCreditsTableViewCell";
}

+ (NSInteger)cellHeight {
    return 50;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSChatAddCreditsTableViewCell *cell = (LSChatAddCreditsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSChatAddCreditsTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[LSChatAddCreditsTableViewCell cellIdentifier] owner:tableView options:nil];
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
