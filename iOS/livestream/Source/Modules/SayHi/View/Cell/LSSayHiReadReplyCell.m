//
//  LSSayHiReadReplyCell.m
//  livestream
//
//  Created by Calvin on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiReadReplyCell.h"
#import "LSShadowView.h"
@implementation LSSayHiReadReplyCell

+ (NSString *)cellIdentifier {
    return @"LSSayHiReadReplyCell";
}

+ (NSInteger)cellHeight:(LSSayHiDetailResponseListItemObject *)obj {
    CGFloat contentH = 0;
    CGFloat topH = 50;
    CGFloat bottomH = 50;
    CGFloat imageH = obj.hasImg?200:0;
    CGFloat btnH = 40;
    CGFloat spacing =obj.hasImg?30:10;
    if (obj.imageH > 0) {
        imageH = obj.imageH;
    }
    contentH = obj.contentH + imageH + topH + bottomH + btnH + spacing;
    return contentH;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSSayHiReadReplyCell *cell = (LSSayHiReadReplyCell *)[tableView dequeueReusableCellWithIdentifier:[LSSayHiReadReplyCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSSayHiReadReplyCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.replyBtn.layer.cornerRadius = cell.replyBtn.tx_height/2;
        cell.replyBtn.layer.masksToBounds =YES;
        
        cell.replyMiniBtn.layer.cornerRadius = cell.replyMiniBtn.tx_height/2;
        cell.replyMiniBtn.layer.masksToBounds =YES;
        
        cell.freeIcon.layer.cornerRadius = 4;
        cell.freeIcon.layer.masksToBounds = YES;
        
        LSShadowView * btnView = [[LSShadowView alloc]init];
        [btnView showShadowAddView:cell.replyBtn];
        
        LSShadowView * miniBtnView = [[LSShadowView alloc]init];
        [miniBtnView showShadowAddView:cell.replyMiniBtn];
        
        cell.imageLoader =  [LSImageViewLoader loader];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)contentImageTap:(UITapGestureRecognizer *)sender {
    if ([self.cellDelegate respondsToSelector:@selector(sayHiReadReplyCellContentImageTap)]) {
        [self.cellDelegate sayHiReadReplyCellContentImageTap];
    }
}

- (IBAction)replyBtnDid:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(sayHiReadReplyCellReplyBtnDid)]) {
        [self.cellDelegate sayHiReadReplyCellReplyBtnDid];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
