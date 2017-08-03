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

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
     
        self.lvView = [LevelView getLevelView];
        [self addSubview:self.lvView];
        
        self.messageLabel = [YYLabel new];
        self.messageLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH - 20, 0);
        self.messageLabel.displaysAsynchronously = YES;
        [self addSubview:self.messageLabel];
        
        [self.lvView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@37);
            make.height.equalTo(@16);
            make.left.equalTo(@0);
            make.bottom.equalTo(self.messageLabel.mas_top).offset(20);
        }];
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)updataChatMessage:(MsgItem *)item{
    
//    self.lvView.levelLabel.text = [NSString stringWithFormat:@"%lld0", (long long)item.level, nil];
    self.lvView.levelLabel.text = [NSString stringWithFormat:@"89"];
    
    YYTextLinePositionSimpleModifier *modifier = [YYTextLinePositionSimpleModifier new];
    modifier.fixedLineHeight = 16;
    
    // 创建文本容器
    YYTextContainer *container = [YYTextContainer new];
    container.linePositionModifier = modifier;
    container.size = CGSizeMake(SCREEN_WIDTH - 20, CGFLOAT_MAX);
    container.maximumNumberOfRows = 0;
    
    // 生成排版结果
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:item.attText];
    self.messageLabel.size = layout.textBoundingSize;
    self.messageLabel.textLayout = layout;
    self.messageLabel.shadowColor = Color(0, 0, 0, 0.7);
    self.messageLabel.shadowOffset = CGSizeMake(0, 0.5);
    self.messageLabel.shadowBlurRadius = 1.0f;
    
    self.messageLabelWidth = self.messageLabel.frame.size.width;
}

+ (NSString *)textPreDetail {
    return @"          ";
}

- (CGSize)sizeThatFits:(CGSize)size{
    
    CGFloat giftLabelHight = 1;
    giftLabelHight += self.messageLabel.frame.size.height;
    return CGSizeMake(SCREEN_WIDTH - 20 , giftLabelHight);
}

- (void)layoutSubviews {
    [super layoutSubviews];
}



@end
