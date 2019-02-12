//
//  LSChatAddCreditsTableViewCell.m
//  livestream
//
//  Created by Calvin on 2018/7/3.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSChatAddCreditsTableViewCell.h"
#import "LSChatTextAttachment.h"

#define ADD_CREDIT_URL @"ADD_CREDIT_URL"

@implementation LSChatAddCreditsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.bgView.layer.cornerRadius = 5;
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
    
    NSDictionary *dic = @{
                          NSFontAttributeName : [UIFont systemFontOfSize:13],
                          NSForegroundColorAttributeName : Color(255, 113, 0, 1),
                          NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                          };
    cell.detailLabel.linkAttributes = dic;
    cell.detailLabel.activeLinkAttributes = dic;
    cell.detailLabel.delegate = cell;
    
    NSAttributedString *attributeStr = [cell parseNoMomenyWarningMessage:[UIFont systemFontOfSize:13]];
    
    cell.detailLabel.attributedText = attributeStr;
    
    [attributeStr enumerateAttributesInRange:NSMakeRange(0, attributeStr.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        LSChatTextAttachment *attachment = attrs[NSAttachmentAttributeName];
        if( attachment && attachment.url != nil ) {
            [cell.detailLabel addLinkToURL:attachment.url withRange:range];
        }
    }];
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[LSChatAddCreditsTableViewCell cellIdentifier] owner:nil options:nil];
        self = [nib objectAtIndex:0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (NSAttributedString* )parseNoMomenyWarningMessage:(UIFont *)font {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"Out_Of_Credit")];
    
    [attributeString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:Color(102, 102, 102, 1),
                                     }
                             range:NSMakeRange(0, attributeString.length)];
    
    // 拼接超链接URL
    LSChatTextAttachment *attachment = [[LSChatTextAttachment alloc] init];
    attachment.text = NSLocalizedStringFromSelf(@"Add_Credit");
    attachment.url = [NSURL URLWithString:ADD_CREDIT_URL];
    attachment.bounds = CGRectMake(0, 0, font.lineHeight, font.lineHeight);
    // 超链接文本
    NSMutableAttributedString *attributeLinkString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"Add_Credit")];
    [attributeLinkString addAttributes:@{
                                         NSAttachmentAttributeName : attachment,
                                         } range:NSMakeRange(0, attributeLinkString.length)];
    [attributeString appendAttributedString:attributeLinkString];
    
    NSMutableAttributedString *attributeEndString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedStringFromSelf(@"To_Continue")];
    [attributeEndString addAttributes:@{
                                     NSFontAttributeName : font,
                                     NSForegroundColorAttributeName:Color(102, 102, 102, 1),
                                     }
                             range:NSMakeRange(0, attributeEndString.length)];
    [attributeString appendAttributedString:attributeEndString];
    
    return attributeString;
}

#pragma mark - 点击超链接回调
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if( [[url absoluteString] isEqualToString:ADD_CREDIT_URL] ) {
        if ([self.delegate respondsToSelector:@selector(pushToAddCredites)]) {
            [self.delegate pushToAddCredites];
        }
    }
}

@end
