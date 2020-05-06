//
//  LSScheduleFootCell.m
//  livestream
//
//  Created by test on 2020/4/14.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleFootCell.h"
#import "LSChatTextAttachment.h"
#import "TTTAttributedLabel.h"

@interface LSScheduleFootCell()<TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *scheduleTips;

@property (weak, nonatomic) IBOutlet UIButton *howItWorkBtn;

@end

@implementation LSScheduleFootCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    

}

+ (CGFloat)cellHeight {
    return 120;
}


+ (id)getUITableViewCell:(UITableView *)tableView {
    LSScheduleFootCell *cell = (LSScheduleFootCell *)[tableView dequeueReusableCellWithIdentifier:[LSScheduleFootCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSScheduleFootCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
    }
    [cell setupUI];
    return cell;
}

+ (NSString *)cellIdentifier {
    return @"LSScheduleFootCell";
}


- (void)setupUI {
    NSString *howItWorkTitle = @"Learn how Schedule One-on-One works";
    NSMutableAttributedString *howItWorkTitleAtts = [[NSMutableAttributedString alloc] initWithString:howItWorkTitle attributes:@{
        NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle],
        NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x999999)
    }];
    [self.howItWorkBtn setAttributedTitle:howItWorkTitleAtts forState:UIControlStateNormal];
    
    
    // 设置超链接属性
     NSDictionary *dic = @{
                           NSFontAttributeName : [UIFont systemFontOfSize:11],
                           NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x1E9EFB),
                           NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle),
                           NSUnderlineColorAttributeName : COLOR_WITH_16BAND_RGB(0x1E9EFB),
                           };
     self.scheduleTips.linkAttributes = dic;
     self.scheduleTips.activeLinkAttributes = dic;
     self.scheduleTips.delegate = self;
     
     // 设置文本属性
     NSMutableAttributedString *attrbuteStr = [[NSMutableAttributedString alloc] initWithString:self.scheduleTips.text];
     
     
     // 设置超链接内容
     LSChatTextAttachment *attachment = [[LSChatTextAttachment alloc] init];
     attachment.text = @"Schedule One-on-One";
    attachment.url = [NSURL URLWithString:@"schedule"];
     attachment.bounds = CGRectMake(0, 0, [UIFont systemFontOfSize:14].lineHeight, [UIFont systemFontOfSize:14].lineHeight);
     NSRange tapRange = [self.scheduleTips.text rangeOfString:@"Schedule One-on-One"];
     [attrbuteStr addAttributes:@{
                                  NSFontAttributeName : [UIFont systemFontOfSize:14],
                                  NSAttachmentAttributeName : attachment,
                                  } range:tapRange];
     
     self.scheduleTips.attributedText = attrbuteStr;
     
     [attrbuteStr enumerateAttributesInRange:NSMakeRange(0, attrbuteStr.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
         LSChatTextAttachment *attachment = attrs[NSAttachmentAttributeName];
         if( attachment && attachment.url != nil ) {
             [self.scheduleTips addLinkToURL:attachment.url withRange:range];
         }
     }];
}


- (IBAction)howItWorkAction:(UIButton *)sender {
    if ([self.footCellDelegate respondsToSelector:@selector(lsScheduleFootCell:didClickHowWork:)]) {
        [self.footCellDelegate lsScheduleFootCell:self didClickHowWork:sender];
    }
}


- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if ([[url absoluteString] isEqualToString:@"schedule"]) {
        if ([self.footCellDelegate respondsToSelector:@selector(lsScheduleFootCellDidClickLink:)]) {
            [self.footCellDelegate lsScheduleFootCellDidClickLink:self];
        }
    }
}
@end
