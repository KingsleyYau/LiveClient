//
//  MailTableViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/11/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "MailTableViewCell.h"
#import "LSDateTool.h"
#import "LSColor.h"

@interface MailTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *replyImage;
@property (weak, nonatomic) IBOutlet UILabel *redLabel;
@property (weak, nonatomic) IBOutlet UILabel *anchorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *receiveImageIcon;
@property (weak, nonatomic) IBOutlet UIImageView *receiveVideoIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *receiveVideoIconTrailing;
@property (weak, nonatomic) IBOutlet UIImageView *receiveKeyIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *receiveKeyIconWidth;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *receiveVideoIconWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *receiveVideoIconLeft;
@property (nonatomic, strong) LSImageViewLoader* imageViewLoader;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UIImageView *followImageView;
@property (weak, nonatomic) IBOutlet UIImageView *onLineImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *onlineImageViewWidth;
@property (weak, nonatomic) IBOutlet UIImageView *scheduleIcon;

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
    self.onlineImageViewWidth.constant = 0;
    
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
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    return cell;
}

- (void)updataMailCell:(LSHttpLetterListItemObject *)obj type:(MailType)type {
    // 加载
    [self.imageViewLoader loadImageFromCache:self.headImage options:SDWebImageRefreshCached imageUrl:obj.anchorAvatar placeholderImage:LADYDEFAULTIMG finishHandler:^(UIImage *image) {
    }];
    self.anchorNameLabel.text = obj.anchorNickName;
    
    self.contentLabel.text = [NSString stringWithFormat:@"...%@...",obj.letterBrief];
    
    // 有未读显示文字颜色
    if (obj.hasRead) {
        self.redLabel.hidden = YES;
        self.anchorNameLabel.font = [UIFont systemFontOfSize:16];
        self.anchorNameLabel.textColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0x8B8B8B) orDark:COLOR_WITH_16BAND_RGB(0x8B8B8B)];
        self.contentLabel.textColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0x999999) orDark:COLOR_WITH_16BAND_RGB(0x999999)];
        self.contentView.backgroundColor = [LSColor colorWithLight:[UIColor whiteColor] orDark:[UIColor blackColor]];
    } else {
        self.redLabel.hidden = NO;
        self.anchorNameLabel.font = [UIFont boldSystemFontOfSize:16];
        self.anchorNameLabel.textColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0x383838) orDark:COLOR_WITH_16BAND_RGB(0x383838)];
        self.contentLabel.textColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0x383838) orDark:COLOR_WITH_16BAND_RGB(0x383838)];
        if (type == MAIL_GREETING) {
            self.contentView.backgroundColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0xffe5e7) orDark:COLOR_WITH_16BAND_RGB(0xffe5e7)];
        } else {
            self.contentView.backgroundColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0xdbe9fd) orDark:COLOR_WITH_16BAND_RGB(0xdbe9fd)];
        }
    }
    
    self.replyImage.hidden = obj.hasReplied ? NO : YES;
    self.receiveImageIcon.hidden = obj.hasImg ? NO : YES;
//    self.receiveVideoIcon.hidden = obj.hasVideo ? NO : YES;
    self.followImageView.hidden = obj.isFollow ? NO : YES;
    self.onlineImageViewWidth.constant = obj.onlineStatus ? 40 : 0;
    
    
    if (obj.hasVideo) {
        self.receiveVideoIcon.hidden = NO;
        self.receiveVideoIconWidth.constant = 12;
        self.receiveVideoIconLeft.constant = 5;
    } else {
        self.receiveVideoIcon.hidden = YES;
        self.receiveVideoIconWidth.constant = 0;
        self.receiveVideoIconLeft.constant = 0;
    }
    
    if (obj.hasKey) {
        self.receiveKeyIcon.hidden = NO;
        self.receiveKeyIconWidth.constant = 12;
        self.receiveVideoIconTrailing.constant = 5;
    } else {
        self.receiveKeyIcon.hidden = YES;
        self.receiveKeyIconWidth.constant = 0;
        self.receiveVideoIconTrailing.constant = 0;
    }
    
    if (obj.hasSchedule) {
        self.scheduleIcon.hidden = NO;
    }else {
        self.scheduleIcon.hidden = YES;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:obj.letterSendTime];
    self.timeLabel.text = [self.dateTool showMailListTimeTextOfDate:date];
}

- (void)updataOutBoxMailCell:(LSHttpLetterListItemObject *)obj {
    
    self.contentView.backgroundColor = [LSColor colorWithLight:[UIColor whiteColor] orDark:[UIColor blackColor]];
    // 加载
    [self.imageViewLoader loadImageFromCache:self.headImage options:SDWebImageRefreshCached imageUrl:obj.anchorAvatar placeholderImage:LADYDEFAULTIMG finishHandler:^(UIImage *image) {
    }];
    self.anchorNameLabel.text = obj.anchorNickName;
    
    self.contentLabel.text = [NSString stringWithFormat:@"...%@...",obj.letterBrief];
    
    // 有未读显示文字颜色
    self.redLabel.hidden = YES;
    self.anchorNameLabel.textColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0x8B8B8B) orDark:COLOR_WITH_16BAND_RGB(0x8B8B8B)];
    self.contentLabel.textColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0x999999) orDark:COLOR_WITH_16BAND_RGB(0x999999)];
    
    self.replyImage.hidden = YES;
    self.receiveImageIcon.hidden = obj.hasImg ? NO : YES;
    //self.receiveVideoIcon.hidden = obj.hasVideo ? NO : YES;
    self.followImageView.hidden = obj.isFollow ? NO : YES;
    self.onlineImageViewWidth.constant = obj.onlineStatus ? 40 : 0;
        
    if (obj.hasVideo) {
        self.receiveVideoIcon.hidden = NO;
        self.receiveVideoIconWidth.constant = 12;
        self.receiveVideoIconLeft.constant = 5;
    } else {
        self.receiveVideoIcon.hidden = YES;
        self.receiveVideoIconWidth.constant = 0;
        self.receiveVideoIconLeft.constant = 0;
    }
    
    //发件箱是否需要处理hasKey字段？？？
    if (obj.hasKey) {
        self.receiveKeyIcon.hidden = NO;
        self.receiveKeyIconWidth.constant = 12;
        self.receiveVideoIconTrailing.constant = 5;
    } else {
        self.receiveKeyIcon.hidden = YES;
        self.receiveKeyIconWidth.constant = 0;
        self.receiveVideoIconTrailing.constant = 0;
    }
    
    if (obj.hasSchedule) {
        self.scheduleIcon.hidden = NO;
    }else {
        self.scheduleIcon.hidden = YES;
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:obj.letterSendTime];
    self.timeLabel.text = [self.dateTool showMailListTimeTextOfDate:date];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.redLabel.backgroundColor = COLOR_WITH_16BAND_RGB(0x2A7AF3);
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    self.redLabel.backgroundColor = COLOR_WITH_16BAND_RGB(0x2A7AF3);
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
