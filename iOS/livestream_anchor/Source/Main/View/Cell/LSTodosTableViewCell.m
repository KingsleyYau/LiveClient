//
//  LSTodosTableViewCell.m
//  livestream_anchor
//
//  Created by test on 2018/3/2.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSTodosTableViewCell.h"

@implementation LSTodosTableViewCell
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.redLabel.layer.cornerRadius = 15/2.0f;
    self.redLabel.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier {
    return @"LSTodosTableViewCell";
}

+ (CGFloat)cellHeight {
    return 54;
}

- (void)setFrame:(CGRect)frame {
    frame.size.height -= 4;
    [super setFrame:frame];
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSTodosTableViewCell *cell = (LSTodosTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSTodosTableViewCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:@"LSTodosTableViewCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return cell;
}

- (void)setTextW:(NSString *)text {
    CGFloat w = [text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].width;
    CGRect rect = self.titleLabel.frame;
    rect.size.width = w;
    self.titleLabel.frame = rect;
    [self setRedX:w];
}


- (void)setDetailTextW:(NSString *)text {
    CGFloat w = [text sizeWithAttributes:@{NSFontAttributeName:self.detailLabel.font}].width;
    CGRect rect = self.detailLabel.frame;
    rect.size.width = w;
    self.detailLabel.frame = rect;
}

- (void)setRedX:(CGFloat)textW {
    CGFloat textX = screenSize.width;
    CGRect rect = self.redLabel.frame;
    rect.origin.x = textX - 30;
    self.redLabel.frame = rect;
}

- (void)updateRedLabelW:(int)num {
    CGRect rect = self.redLabel.frame;
    if (num > 99) {
        rect.size.width = 30;
        self.redLabel.text = @"99+";
    } else {
        rect.size.width = 15;
        self.redLabel.text = [NSString stringWithFormat:@"%d",num];
    }
    self.redLabel.frame = rect;
}
@end
