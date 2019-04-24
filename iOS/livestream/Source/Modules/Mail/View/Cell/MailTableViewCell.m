//
//  MailTableViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/11/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "MailTableViewCell.h"
#import "LSDateTool.h"

@interface MailTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *replyImage;
@property (weak, nonatomic) IBOutlet UILabel *redLabel;
@property (weak, nonatomic) IBOutlet UILabel *anchorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *receiveImageIcon;
@property (weak, nonatomic) IBOutlet UIImageView *receiveVideoIcon;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *receiveImageIconWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *receiveVideoIconLeft;
@property (nonatomic, strong) LSImageViewLoader* imageViewLoader;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;

@property (nonatomic, strong) LSDateTool *dateTool;

@end

@implementation MailTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if( self ) {
        // Initialization code
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[MailTableViewCell cellIdentifier] owner:nil options:nil];
        self = [nib objectAtIndex:0];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.redLabel.hidden = YES;
    self.replyImage.hidden = YES;
    self.receiveImageIcon.hidden = YES;
    self.receiveVideoIcon.hidden = YES;
    self.timeLabel.text = @"";
    self.anchorNameLabel.text = @"";
    self.contentLabel.text = @"";
    
    self.redLabel.layer.cornerRadius = self.redLabel.frame.size.height / 2;
    self.redLabel.layer.masksToBounds = YES;
    
    self.headImage.layer.cornerRadius = self.headImage.frame.size.height / 2;
    self.headImage.layer.masksToBounds = YES;
    self.dateTool = [[LSDateTool alloc] init];
    self.imageViewLoader = [LSImageViewLoader loader];
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    MailTableViewCell *cell = (MailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[MailTableViewCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[MailTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)updataMailCell:(LSHttpLetterListItemObject *)obj {
    // 加载
    [self.imageViewLoader loadImageFromCache:self.headImage options:SDWebImageRefreshCached imageUrl:obj.anchorAvatar placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:^(UIImage *image) {
    }];
    self.anchorNameLabel.text = obj.anchorNickName;
    
    self.contentLabel.text = [NSString stringWithFormat:@"...%@...",obj.letterBrief];
    
    // 有未读显示文字颜色
    if (obj.hasRead) {
        self.redLabel.hidden = YES;
        self.contentLabel.textColor = COLOR_WITH_16BAND_RGB(0x999999);
        self.anchorNameLabel.textColor = COLOR_WITH_16BAND_RGB(0x8B8B8B);
    }else {
        self.redLabel.hidden = NO;
        self.contentLabel.textColor = COLOR_WITH_16BAND_RGB(0x262626);
        self.anchorNameLabel.textColor = COLOR_WITH_16BAND_RGB(0x383838);
    }
    
    self.replyImage.hidden = obj.hasReplied ? NO : YES;
    self.receiveImageIcon.hidden = obj.hasImg ? NO : YES;
    self.receiveVideoIcon.hidden = obj.hasVideo ? NO : YES;

    if (obj.hasImg) {
        self.receiveImageIconWidth.constant = 12;
        self.receiveVideoIconLeft.constant = 5;
    } else {
        self.receiveImageIconWidth.constant = 0;
        self.receiveVideoIconLeft.constant = 0;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:obj.letterSendTime];
    self.timeLabel.text = [self.dateTool showMailListTimeTextOfDate:date];
}

- (void)updataOutBoxMailCell:(LSHttpLetterListItemObject *)obj {
    // 加载
    [self.imageViewLoader loadImageFromCache:self.headImage options:SDWebImageRefreshCached imageUrl:obj.anchorAvatar placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:^(UIImage *image) {
    }];
    self.anchorNameLabel.text = obj.anchorNickName;
    
    self.contentLabel.text = [NSString stringWithFormat:@"...%@...",obj.letterBrief];
    
    // 有未读显示文字颜色
    self.redLabel.hidden = YES;
    self.contentLabel.textColor = COLOR_WITH_16BAND_RGB(0x999999);
    self.anchorNameLabel.textColor = COLOR_WITH_16BAND_RGB(0x8B8B8B);
    
    self.replyImage.hidden = YES;
    self.receiveImageIcon.hidden = obj.hasImg ? NO : YES;
    self.receiveVideoIcon.hidden = obj.hasVideo ? NO : YES;
    
    if (obj.hasImg) {
        self.receiveImageIconWidth.constant = 12;
        self.receiveVideoIconLeft.constant = 5;
    } else {
        self.receiveImageIconWidth.constant = 0;
        self.receiveVideoIconLeft.constant = 0;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:obj.letterSendTime];
    self.timeLabel.text = [self.dateTool showMailListTimeTextOfDate:date];
}


- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.redLabel.backgroundColor = Color(255, 53, 0, 1);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.redLabel.backgroundColor = Color(255, 53, 0, 1);
}

+ (NSString *)cellIdentifier {
    return @"MailTableViewCell";
}

+ (NSInteger)cellHeight {
    return 72;
}


// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.imageViewLoader stop];
    [self.headImage sd_cancelCurrentImageLoad];
    self.headImage.image = nil;
}
@end
