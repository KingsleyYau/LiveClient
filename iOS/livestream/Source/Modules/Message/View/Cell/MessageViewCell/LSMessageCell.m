//
//  LSMessageCell.m
//  livestream
//
//  Created by Calvin on 2018/6/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSMessageCell.h"
#import "LSImageViewLoader.h"
#import "LSDateTool.h"
#import "LSChatEmotionManager.h"

@interface LSMessageCell()

@property (nonatomic, strong) LSImageViewLoader *imageLoader;
@property (nonatomic, strong) LSDateTool *dateTool;
@end

@implementation LSMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSMessageCell cellIdentifier] owner:nil options:nil];
        self = [nib objectAtIndex:0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.onlineImage.hidden = YES;
    
    self.headView.layer.cornerRadius = self.headView.frame.size.height/2;
    self.headView.layer.masksToBounds = YES;
    
    self.unreadView.layer.cornerRadius = self.unreadView.frame.size.height / 2;
    self.unreadView.layer.masksToBounds = YES;
    
    self.onlineImage.layer.cornerRadius = self.onlineImage.frame.size.height / 2;
    self.onlineImage.layer.masksToBounds = YES;
    
    self.imageLoader = [LSImageViewLoader loader];
    self.dateTool = [[LSDateTool alloc] init];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.unreadView.backgroundColor = Color(255, 53, 0, 1);
    self.unreadLabel.backgroundColor = Color(255, 53, 0, 1);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.unreadView.backgroundColor = Color(255, 53, 0, 1);
    self.unreadLabel.backgroundColor = Color(255, 53, 0, 1);
}

+ (NSString *)cellIdentifier {
    return @"LSMessageCell";
}

+ (NSInteger)cellHeight {
    return 65;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSMessageCell *cell = (LSMessageCell *)[tableView dequeueReusableCellWithIdentifier:[LSMessageCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSMessageCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)setCellPattern:(LMPrivateMsgContactObject *)model {
    [self.imageLoader refreshCachedImage:self.headView options:SDWebImageRefreshCached imageUrl:model.avatarImg placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    self.nameLbael.text = model.nickName;
    self.msgLabel.attributedText = [[LSChatEmotionManager emotionManager] parseMessageTextEmotion:model.lastMsg
                                                                            font:[UIFont systemFontOfSize:13]];
    if (model.unreadNum) {
        self.unreadView.hidden = NO;
        self.unreadLabel.text = [NSString stringWithFormat:@"%d",model.unreadNum];
    } else {
        self.unreadView.hidden = YES;
    }
    
    if (model.onlineStatus) {
        self.onlineImage.hidden = NO;
    } else {
        self.onlineImage.hidden = YES;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:model.updateTime];
    self.timeLabel.text = [self.dateTool showMessageListTimeTextOfDate:date];
}

// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageLoader stop];
    [self.headView sd_cancelCurrentImageLoad];
    self.headView.image = nil;
}

@end
