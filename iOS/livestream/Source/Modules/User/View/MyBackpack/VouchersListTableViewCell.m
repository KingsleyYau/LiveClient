//
//  VouChersListTableViewCell.m
//  livestream
//
//  Created by test on 2019/6/14.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "VouchersListTableViewCell.h"
#import "LSChatTextAttachment.h"

@implementation VouchersListTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier{
    return @"VouchersListTableViewCell";
}


+ (NSInteger)cellHeight{
    return 100;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    VouchersListTableViewCell *cell = (VouchersListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[VouchersListTableViewCell cellIdentifier]];
    
    if( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[VouchersListTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.expiringNote.hidden = YES;
        cell.expiringNote.layer.cornerRadius = 8.0f;
        cell.expiringNote.layer.masksToBounds = YES;
    }
    
    return cell;
}


- (void)updatelimitedVoucherType:(NSString *)voucherType withAchor:(NSString *)anchorId {
    // 设置超链接属性
    NSDictionary *dic = @{
                          NSFontAttributeName : [UIFont systemFontOfSize:13],
                          NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x297AF3),
                          NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle),
                          NSUnderlineColorAttributeName : COLOR_WITH_16BAND_RGB(0x297AF3),
                          };
    self.voucherCondition.linkAttributes = dic;
    self.voucherCondition.activeLinkAttributes = dic;
    NSString *appointAnchor = [NSString stringWithFormat:@"%@ %@",voucherType,anchorId];
    self.voucherCondition.text = appointAnchor;
    
    
    // 设置文本属性
    NSMutableAttributedString *attrbuteStr = [[NSMutableAttributedString alloc] initWithString:appointAnchor];
    
    // 设置超链接内容
    LSChatTextAttachment *attachment = [[LSChatTextAttachment alloc] init];
    attachment.text = anchorId;
    attachment.url = [NSURL URLWithString:[NSString stringWithFormat:@"%d",(int)self.voucherCondition.tag]];
    attachment.bounds = CGRectMake(0, 0, [UIFont systemFontOfSize:13].lineHeight, [UIFont systemFontOfSize:13].lineHeight);
    NSRange tapRange = [self.voucherCondition.text rangeOfString:anchorId];
    [attrbuteStr addAttributes:@{
                                 NSFontAttributeName : [UIFont systemFontOfSize:13],
                                 NSAttachmentAttributeName : attachment,
                                 } range:tapRange];
    
    self.voucherCondition.attributedText = attrbuteStr;
    
    // 添加链接属性
    [attrbuteStr enumerateAttributesInRange:NSMakeRange(0, attrbuteStr.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        LSChatTextAttachment *attachment = attrs[NSAttachmentAttributeName];
        if( attachment && attachment.url != nil ) {
            [self.voucherCondition addLinkToURL:attachment.url withRange:range];
        }
    }];
}


- (void)updateValidTime:(NSInteger)startTime expTime:(NSInteger)expTime {
    // 获取当前时间
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSInteger nowTime = [date timeIntervalSince1970];
    
    // 到期提醒时间
    NSInteger  ExpiringTime = 60 * 60 * 48;
    
    // 没到可使用时间显示可使用时间段
    if (nowTime < startTime) {
        self.voucherValidty.textColor = [UIColor lightGrayColor];
        self.voucherValidty.text = [NSString stringWithFormat:@"Valid:%@ to %@",[self getTime:startTime],[self getTime:expTime]];
        // 未生效临近到期时间显示
        self.expiringNote.hidden =  YES;
    }else {
        //  可使用显示结束时间
        self.voucherValidty.text = [NSString stringWithFormat:@"Exp: %@",[self getTime:expTime]];
        // 临近到期时间显示
        self.expiringNote.hidden = expTime - nowTime <= ExpiringTime ? NO : YES;
    }

    
}


- (NSString *)getTime:(NSInteger)time {
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"MMM dd,yyyy"];
    NSDate *timeDate = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *timeStr = [stampFormatter stringFromDate:timeDate];
    
    return timeStr;
}
@end
