//
//  LSSayHiUnreadReplyCell.m
//  livestream
//
//  Created by Calvin on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiUnreadReplyCell.h"
#import "LSShadowView.h"
@implementation LSSayHiUnreadReplyCell

+ (NSString *)cellIdentifier {
    return @"LSSayHiUnreadReplyCell";
}

+ (NSInteger)cellHeight {
    return 67;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSSayHiUnreadReplyCell *cell = (LSSayHiUnreadReplyCell *)[tableView dequeueReusableCellWithIdentifier:[LSSayHiUnreadReplyCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSSayHiUnreadReplyCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.ladyHead.layer.cornerRadius = cell.ladyHead.tx_height/2;
        cell.ladyHead.layer.masksToBounds = YES;
        
        cell.freeIcon.layer.cornerRadius = 4;
        cell.freeIcon.layer.masksToBounds = YES;
        
       cell.imageLoader =  [LSImageViewLoader loader];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setIsPhoto:(BOOL)isPhoto {
    CGFloat x = self.photoIcon.tx_x;
    CGFloat w = self.contentLabel.tx_width;
    if (isPhoto) {
        self.photoIcon.hidden = NO;
        x = x + 20;
    }
    else {
        self.photoIcon.hidden = YES;
        w = w + 20;
    }
    CGRect rect = self.contentLabel.frame;
    rect.origin.x = x;
    rect.size.width = w;
    self.contentLabel.frame = rect;
}

- (void)loadUI:(LSSayHiDetailResponseListItemObject *)obj {
    self.contentLabel.text = obj.simpleContent;
    self.titleLabel.text =[NSString stringWithFormat:@"ID:%@ %@",obj.responseId,[self getTime:obj.responseTime type:@"dd MMM, yyyy"]];
    
    [self setIsPhoto:obj.hasImg];
    
    if (!obj.hasRead) {
        self.backgroundColor = COLOR_WITH_16BAND_RGB(0xFFFFC2);
        self.unreadIcon.hidden = NO;
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
        self.unreadIcon.hidden = YES;
    }
    
    if (obj.isUnfold) {
        self.selectedIcon.hidden = NO;
        self.backgroundColor = COLOR_WITH_16BAND_RGB(0xD5F2FF);
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = [UIColor blueColor].CGColor;
    }
    
    if (obj.isFree) {
        self.freeIcon.hidden = NO;
        self.unreadIcon.hidden = YES;
    }
    else {
        self.freeIcon.hidden = YES;
    }
    
    [self.imageLoader loadImageFromCache:self.ladyHead options:0 imageUrl:self.url placeholderImage:LADYDEFAULTIMG finishHandler:^(UIImage *image) {
        
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *)getTime:(NSInteger)time type:(NSString *)type {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:type];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:time];
    NSString *TimespStr = [formatter stringFromDate:confromTimesp];
    return TimespStr;
}
@end
