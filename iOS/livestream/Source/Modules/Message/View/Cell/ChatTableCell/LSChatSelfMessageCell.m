//
//  LSChatSelfMessageCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/9/28.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSChatSelfMessageCell.h"

@interface LSChatSelfMessageCell ()

@property (nonatomic, strong) YYTextLinePositionSimpleModifier *modifier;
@property (nonatomic, strong) YYTextContainer *container;
@end

@implementation LSChatSelfMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Chat_Self_Rectangle"]];
        [self addSubview:self.backgroundImageView];
        
        self.messageLabel = [YYLabel new];
        self.messageLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH - 160, 0);
        self.messageLabel.displaysAsynchronously = NO;
        [self addSubview:self.messageLabel];
        
        self.retryButton = [[UIButton alloc] init];
        [self.retryButton setImage:[UIImage imageNamed:@"ChatWarningIcon"] forState:UIControlStateNormal];
        self.retryButton.hidden = YES;
        [self.retryButton addTarget:self action:@selector(retryBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.retryButton];
        
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] init];
        [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicatorView.hidden = YES;
        [self addSubview:self.activityIndicatorView];
        
        [self.backgroundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.messageLabel.mas_left).offset(-10);
            make.right.equalTo(self.messageLabel.mas_right).offset(10);
            make.top.equalTo(@5);
            make.bottom.equalTo(@(-5));
        }];
        
        [self.retryButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self.backgroundImageView.mas_left).offset(-10);
        }];
        
        [self.activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self.backgroundImageView.mas_left).offset(-10);
        }];
        
        self.modifier = [[YYTextLinePositionSimpleModifier alloc] init];
        self.modifier.fixedLineHeight = 19;
        
        // 创建文本容器
        self.container = [[YYTextContainer alloc] init];
        self.container.linePositionModifier = self.modifier;
        self.container.size = CGSizeMake(SCREEN_WIDTH - 160, CGFLOAT_MAX);
        self.container.maximumNumberOfRows = 0;
    }
    return self;
}

+ (NSString *)cellIdentifier {
    return @"LSChatSelfMessageCell";
}

+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSAttributedString *)detailString {
    NSInteger height = 30;
    
    if(detailString.length > 0) {
        YYTextLayout *layout = [[self new] getLabelContainerLayout:width detailString:detailString];
        height += ceil(layout.textBoundingSize.height);
    }
    return height;
}

- (void)updataChatMessage:(CGFloat)subWidth detailString:(NSAttributedString *)detailString {
    
    YYTextLayout *yylayout = [self getLabelContainerLayout:subWidth detailString:detailString];
    
    CGFloat width = yylayout.textBoundingSize.width;
    CGFloat height = yylayout.textBoundingSize.height;
    CGFloat x = subWidth - width - 20;
    
    CGRect giftFrame = CGRectMake(x, 15, width, height);
    self.messageLabel.frame = giftFrame;
    self.messageLabel.textLayout = yylayout;
}

- (YYTextLayout *)getLabelContainerLayout:(CGFloat)width detailString:(NSAttributedString *)detailString {
    NSMutableAttributedString *mutableStr = [[NSMutableAttributedString alloc] initWithAttributedString:detailString];
    NSRange range = NSMakeRange(0, mutableStr.length);
    [mutableStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15] range:range];
    [mutableStr addAttribute:NSForegroundColorAttributeName value:Color(255, 255, 255, 1) range:range];
    
    YYTextContainer *container = [[YYTextContainer alloc] init];
    container.size = CGSizeMake(width - 160, MAXFLOAT);
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:mutableStr];
    return layout;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSChatSelfMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:[LSChatSelfMessageCell cellIdentifier]];
    return cell;
}

- (void)retryBtnClick:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if ( self.delegate && [self.delegate respondsToSelector:@selector(chatTextSelfRetryButtonClick:sendErr:)] ) {
        [self.delegate chatTextSelfRetryButtonClick:self sendErr:btn.tag];
    }
}

@end
