//
//  LSHomeSchedueleCell.m
//  livestream
//
//  Created by test on 2020/3/25.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSHomeSchedueleCell.h"
#import <TTTAttributedLabel.h>
#import "LSChatTextAttachment.h"
#import "LiveModule.h"
#import "LiveUrlHandler.h"
#import "LSLoginManager.h"
@interface LSHomeSchedueleCell()<TTTAttributedLabelDelegate>
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *scheduleNote;
@property (weak, nonatomic) IBOutlet UIImageView *scheduleStatus;
@end

@implementation LSHomeSchedueleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.scheduleNote.delegate = self;
}


- (IBAction)closeAction:(id)sender {
    if ([self.schedueleDelegate respondsToSelector:@selector(lsHomeSchedueleCellDidRemove:)]) {
        [self.schedueleDelegate lsHomeSchedueleCellDidRemove:self.tag];
    }
}

- (void)updateUI:(ScheduleNoteType)type withItem:(LiveRoomInfoItemObject *)item{

    switch (type) {
        case ScheduleNoteTypeStart:{
            [self.closeBtn setImage:[UIImage imageNamed:@"Home_banner_Close"] forState:UIControlStateNormal];
            // 设置超链接属性
            NSDictionary *dic = @{
                                  NSFontAttributeName : [UIFont systemFontOfSize:14],
                                  NSForegroundColorAttributeName : [UIColor whiteColor],
                                  NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle),
                                  NSUnderlineColorAttributeName :  [UIColor whiteColor],
                                  };
            self.scheduleNote.linkAttributes = dic;
            self.scheduleNote.activeLinkAttributes = dic;
  
            self.backgroundColor = COLOR_WITH_16BAND_RGB(0xFF774B);
            self.scheduleStatus.image = [UIImage imageNamed:@"Home_BannerClockStart"];

            NSString *title = [NSString stringWithFormat:@"You have %d scheduled One-on-One need to be started.Check and start now!",item.schedule.startNum];
            NSMutableAttributedString *atts = [[NSMutableAttributedString alloc] initWithString:title attributes:@{
                  NSForegroundColorAttributeName : [UIColor whiteColor],
                  NSFontAttributeName : [UIFont systemFontOfSize:14],
            }];
            NSRange timeRange = [title rangeOfString:[NSString stringWithFormat:@"%d",item.schedule.startNum]];
            [atts addAttributes:@{
                                         NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0xFCEE02),
                                         NSUnderlineStyleAttributeName :@(NSUnderlineStyleSingle),
                                         } range:timeRange];
            
            // 设置超链接内容
            LSChatTextAttachment *attachment = [[LSChatTextAttachment alloc] init];
            attachment.text = @"Check and start now";
            attachment.url = [NSURL URLWithString:@"Start"];
            NSRange tapRange = [title rangeOfString:@"Check and start now"];
            [atts addAttributes:@{
                NSFontAttributeName : [UIFont systemFontOfSize:14],
                NSAttachmentAttributeName : attachment,
            } range:tapRange];
            
            self.scheduleNote.attributedText = atts;
            
            [atts enumerateAttributesInRange:NSMakeRange(0, atts.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                LSChatTextAttachment *attachment = attrs[NSAttachmentAttributeName];
                if( attachment && attachment.url != nil ) {
                    [self.scheduleNote addLinkToURL:attachment.url withRange:range];
                }
            }];
    
        }break;
        case ScheduleNoteTypeWillStart:{
            [self.closeBtn setImage:[UIImage imageNamed:@"SayHi_Info_Close"] forState:UIControlStateNormal];
            // 设置超链接属性
            NSDictionary *dic = @{
                                  NSFontAttributeName : [UIFont systemFontOfSize:14],
                                  NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x383838),
                                  NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle),
                                  NSUnderlineColorAttributeName :  COLOR_WITH_16BAND_RGB(0x383838),
                                  };
            self.scheduleNote.linkAttributes = dic;
            self.scheduleNote.activeLinkAttributes = dic;
            self.backgroundColor = COLOR_WITH_16BAND_RGB(0xFFEB8E);
            self.scheduleStatus.image = [UIImage imageNamed:@"Home_BannerClock"];
            int startMinutes = item.schedule.leftTime;
            
            
            NSString *title = [NSString stringWithFormat:@"You have %d scheduled One-on-One to be start within %d minutes.Check now!",item.schedule.willStartNum,startMinutes];
            NSMutableAttributedString *atts = [[NSMutableAttributedString alloc] initWithString:title attributes:@{
                NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x383838),
                NSFontAttributeName : [UIFont systemFontOfSize:14],
                
            }];
            NSRange countRange = [title rangeOfString:[NSString stringWithFormat:@"%d",item.schedule.willStartNum]];
            [atts addAttributes:@{
                NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x9C3E9E),
                NSUnderlineStyleAttributeName :@(NSUnderlineStyleSingle),
            } range:countRange];
            NSRange timeRange = [title rangeOfString:[NSString stringWithFormat:@"%d",startMinutes]];
            [atts addAttributes:@{
                NSForegroundColorAttributeName : COLOR_WITH_16BAND_RGB(0x9C3E9E),
            } range:timeRange];
            
            // 设置超链接内容
            LSChatTextAttachment *attachment = [[LSChatTextAttachment alloc] init];
            attachment.text = @"Check now";
            attachment.url = [NSURL URLWithString:@"Check"];
            NSRange tapRange = [title rangeOfString:@"Check now"];
            [atts addAttributes:@{
                NSFontAttributeName : [UIFont systemFontOfSize:14],
                NSAttachmentAttributeName : attachment,
            } range:tapRange];
            
            self.scheduleNote.attributedText = atts;
            
            [atts enumerateAttributesInRange:NSMakeRange(0, atts.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
                LSChatTextAttachment *attachment = attrs[NSAttachmentAttributeName];
                if( attachment && attachment.url != nil ) {
                    [self.scheduleNote addLinkToURL:attachment.url withRange:range];
                }
            }];

        }break;

        default:
            break;
    }
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if ([self.schedueleDelegate respondsToSelector:@selector(lsHomeSchedueleCellDidRemove:)]) {
        [self.schedueleDelegate lsHomeSchedueleCellDidRemove:self.tag];
    }
    
    if( [[url absoluteString] isEqualToString:@"Start"] ) {
        [LSLoginManager manager].loginItem.isShowStartNotice = NO;
        NSURL *scheduleUrl = [[LiveUrlHandler shareInstance] createScheduleList:LiveUrlScheduleListTypeConfirm];
        [[LiveModule module].serviceManager handleOpenURL:scheduleUrl];
    }else if( [[url absoluteString] isEqualToString:@"Check"] ) {
        [LSLoginManager manager].loginItem.isShowWillStartNotice = NO;
        NSURL *scheduleUrl = [[LiveUrlHandler shareInstance] createScheduleList:LiveUrlScheduleListTypeConfirm];
        [[LiveModule module].serviceManager handleOpenURL:scheduleUrl];
    }
}



// 防止cell重用图片显示错乱
- (void)prepareForReuse {
    [super prepareForReuse];
}


@end
