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
    return 150;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSSayHiUnreadReplyCell *cell = (LSSayHiUnreadReplyCell *)[tableView dequeueReusableCellWithIdentifier:[LSSayHiUnreadReplyCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSSayHiUnreadReplyCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.readBtn.layer.cornerRadius = cell.readBtn.tx_height/2;
        cell.readBtn.layer.masksToBounds = YES;
        
        LSShadowView * btnView = [[LSShadowView alloc]init];
        [btnView showShadowAddView:cell.readBtn];
        
        cell.bgView.layer.cornerRadius = 5;
        cell.bgView.layer.masksToBounds = YES;
        
        LSShadowView * view = [[LSShadowView alloc]init];
        [view showShadowAddView:cell.bgView];
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)readBtnDid:(id)sender {
    if ([self.cellDelegate respondsToSelector:@selector(sayHiUnreadReplyCellReadNowBtnDid)]) {
        [self.cellDelegate sayHiUnreadReplyCellReadNowBtnDid];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
