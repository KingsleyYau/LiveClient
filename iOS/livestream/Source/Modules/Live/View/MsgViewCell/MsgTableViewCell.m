//
//  MsgTableViewCell.m
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "MsgTableViewCell.h"

@implementation MsgTableViewCell
+ (NSString *)cellIdentifier {
    return @"MsgTableViewCell";
}

+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSAttributedString *)detailString {
    NSInteger height = 3;
    
    if( detailString.length > 0 ) {
        // 设置换行模式
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineBreakMode:NSLineBreakByCharWrapping];
        NSMutableAttributedString* labelAttributeString = [[NSMutableAttributedString alloc] initWithAttributedString:detailString];
        [labelAttributeString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, labelAttributeString.length)];
        
        // 计算高度
        CGRect rect = [labelAttributeString boundingRectWithSize:CGSizeMake(width - 20, MAXFLOAT)
                                                 options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
        height += ceil(rect.size.height);
    }
    height += 3;
    
    return height;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    MsgTableViewCell *cell = (MsgTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[MsgTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[MsgTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.label.text = @"";
    cell.viewLevelBackground.layer.masksToBounds = YES;
    
    return cell;
}

+ (NSString *)textPreDetail {
    return @"          ";
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
    
    self.viewLevelBackground.layer.cornerRadius = 10;
}

@end
