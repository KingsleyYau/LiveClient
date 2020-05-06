//
//  LSScheduleNoteCell.m
//  livestream
//
//  Created by test on 2020/4/14.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleNoteCell.h"

@implementation LSScheduleNoteCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    

}

+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSString *)detailString {
    NSInteger height = 19;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;  //设置行间距
    paragraphStyle.alignment = NSTextAlignmentLeft;
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont italicSystemFontOfSize:13], NSParagraphStyleAttributeName : paragraphStyle };;
    if(detailString.length > 0) {

        CGRect rect = [detailString boundingRectWithSize:CGSizeMake(width - 40, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
        height += ceil(rect.size.height);
    }
    
    height += 19;
    

    return height;
}


+ (id)getUITableViewCell:(UITableView *)tableView {
    LSScheduleNoteCell *cell = (LSScheduleNoteCell *)[tableView dequeueReusableCellWithIdentifier:[LSScheduleNoteCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSScheduleNoteCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
    }

    return cell;
}

+ (NSString *)cellIdentifier {
    return @"LSScheduleNoteCell";
}
@end
