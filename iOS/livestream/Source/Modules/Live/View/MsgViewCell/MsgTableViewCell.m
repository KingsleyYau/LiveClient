//
//  MsgTableViewCell.m
//  dating
//
//  Created by Max on 16/2/14.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "MsgTableViewCell.h"
#import "NSAttributedString+YYText.h"

@interface MsgTableViewCell ()

@property (nonatomic, strong) YYTextLinePositionSimpleModifier *modifier;
@property (nonatomic, strong) YYTextContainer *container;
@property (nonatomic, strong) YYTextLayout *layout;
@property (nonatomic, strong) UIButton *tapBtn;
@property (nonatomic, copy) NSString *linkUrl;

@end


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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.messageLabel = [YYLabel new];
        self.messageLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH - 165, 0);
        self.messageLabel.displaysAsynchronously = YES;
        [self addSubview:self.messageLabel];
        
        self.tapBtn = [[UIButton alloc] init];
        self.tapBtn.backgroundColor = [UIColor clearColor];
        [self.tapBtn addTarget:self action:@selector(pushGoAction) forControlEvents:UIControlEventTouchUpInside];
        self.tapBtn.hidden = YES;
        [self addSubview:self.tapBtn];
        
        self.backgroundColor = [UIColor clearColor];
        
        self.modifier = [[YYTextLinePositionSimpleModifier alloc] init];
        self.modifier.fixedLineHeight = 19;
        
        // 创建文本容器
        self.container = [[YYTextContainer alloc] init];
        self.container.linePositionModifier = self.modifier;
        self.container.size = CGSizeMake(SCREEN_WIDTH - 165, CGFLOAT_MAX);
        self.container.maximumNumberOfRows = 0;
    }
    return self;
}

- (void)changeMessageLabelWidth:(CGFloat)width {
    
    self.tableViewWidth = width;
    CGRect frame = self.messageLabel.frame;
    frame.size.width = width;
    self.messageLabel.frame = frame;
    self.container.size = CGSizeMake(width, CGFLOAT_MAX);
}

- (void)updataChatMessage:(MsgItem *)item{
    // 生成排版结果
    self.tapBtn.hidden = YES;
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:self.container text:item.attText];
    CGRect frame = self.messageLabel.frame;
    frame.size = layout.textBoundingSize;
    self.messageLabel.frame = frame;
    self.messageLabel.textLayout = layout;
    self.messageLabel.shadowColor = Color(0, 0, 0, 0.7);
    self.messageLabel.shadowOffset = CGSizeMake(0, 0.5);
    self.messageLabel.shadowBlurRadius = 1.0f;
    self.messageLabelWidth = self.messageLabel.frame.size.width;
    self.messageLabelHeight = self.messageLabel.frame.size.height;
    
    if (item.type == MsgType_Link) {
        self.tapBtn.hidden = NO;
        [self.tapBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(self.messageLabelWidth));
            make.left.top.height.equalTo(self);
        }];
        self.linkUrl = item.linkStr;
    }
}

- (void)pushGoAction {
    
    if ([self.msgDelegate respondsToSelector:@selector(msgCellRequestHttp:)]) {
        [self.msgDelegate msgCellRequestHttp:self.linkUrl];
    }
}

+ (NSString *)textPreDetail {
    return @"          ";
}

- (void)setMessageLabelHeight:(CGFloat)messageLabelHeight {
    
    
}

- (CGSize)sizeThatFits:(CGSize)size{
    
    CGFloat giftLabelHight = 1;
    giftLabelHight += self.messageLabel.frame.size.height;
    return CGSizeMake(self.tableViewWidth , giftLabelHight);
}

- (void)layoutSubviews {
    [super layoutSubviews];
}



@end
