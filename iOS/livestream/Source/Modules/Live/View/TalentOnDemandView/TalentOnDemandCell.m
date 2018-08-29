//
//  TalentOnDemandCell.m
//  livestream
//
//  Created by Calvin on 17/9/19.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "TalentOnDemandCell.h"
#import "LiveBundle.h"

@implementation TalentOnDemandCell
+ (NSString *)cellIdentifier {
    return @"TalentOnDemandCell";
}

+ (NSInteger)cellHeight {
    return 58;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UIImage *image = [UIImage imageNamed:@"TalentCellSelected"];
    UIImageView * imageView =  [[UIImageView alloc] initWithImage:image];
    self.selectedBackgroundView = imageView;
    
    [self.detialsBtn setBackgroundImage:[UIImage imageNamed:@"Talent_Detials_Btn_Selected"] forState:UIControlStateHighlighted];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (id)getUITableViewCell:(UITableView *)tableView  {
    TalentOnDemandCell *cell = (TalentOnDemandCell *)[tableView dequeueReusableCellWithIdentifier:[TalentOnDemandCell cellIdentifier]];

    if (nil == cell) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamed:[TalentOnDemandCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    return cell;
}


@end
