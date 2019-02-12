//
//  QNChatTextLadyTableViewCell.h
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "QNChatTextLadyTableViewCell.h"

@implementation QNChatTextLadyTableViewCell
+ (NSString *)cellIdentifier {
    return @"QNChatTextLadyTableViewCell";
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
    QNChatTextLadyTableViewCell *cell = (QNChatTextLadyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[QNChatTextLadyTableViewCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[QNChatTextLadyTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.backgroundImageView.layer.cornerRadius = cell.backgroundImageView.frame.size.height/2 -1;
        cell.backgroundImageView.layer.masksToBounds = YES;
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
