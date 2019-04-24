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

+ (NSInteger)cellHeight:(NSString *)str isUnfold:(BOOL)unfold {
    CGFloat h = 0;
    if (unfold) {
        h = 445;
    }
    else{
        h =  130;
    }
    return h;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSSayHiReadReplyCell *cell = (LSSayHiReadReplyCell *)[tableView dequeueReusableCellWithIdentifier:[LSSayHiReadReplyCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSSayHiReadReplyCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
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

- (IBAction)arrowBtnDid:(UIButton *)sender {
    if ([self.cellDelegate respondsToSelector:@selector(sayHiReadReplyCellArrowBtnDid)]) {
        [self.cellDelegate sayHiReadReplyCellArrowBtnDid];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
