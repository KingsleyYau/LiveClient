//
//  LSSayHiDetailAddCreditsCell.m
//  livestream
//
//  Created by Calvin on 2019/5/5.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiDetailAddCreditsCell.h"
#import "LSShadowView.h"
@implementation LSSayHiDetailAddCreditsCell

+ (NSString *)cellIdentifier {
    return @"LSSayHiDetailAddCreditsCell";
}

+ (NSInteger)cellHeight {
    return 275;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSSayHiDetailAddCreditsCell *cell = (LSSayHiDetailAddCreditsCell *)[tableView dequeueReusableCellWithIdentifier:[LSSayHiDetailAddCreditsCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSSayHiDetailAddCreditsCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.addBtn.layer.cornerRadius = 5;
        cell.addBtn.layer.masksToBounds = YES;
        
        LSShadowView * btnView = [[LSShadowView alloc]init];
        [btnView showShadowAddView:cell.addBtn];
        
        cell.bgView.layer.cornerRadius = 8;
        cell.bgView.layer.masksToBounds = YES;
    }
    return cell;
}

- (void)setLadyName:(NSString *)name {
    self.nameLbael.text = name;
    self.titleLabel.text = [NSString stringWithFormat:@"Want to know what %@ says?",name];
}

- (IBAction)addBtnDid:(UIButton *)sender {
    if ([self.cellDelegate respondsToSelector:@selector(sayHiDetailAddCreditsCellBtnDid)]) {
        [self.cellDelegate sayHiDetailAddCreditsCellBtnDid];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
