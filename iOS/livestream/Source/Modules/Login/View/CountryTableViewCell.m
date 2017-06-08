//
//  CountryTableViewCell.m
//  UIWidget
//
//  Created by test on 2017/5/24.
//  Copyright © 2017年 lance. All rights reserved.
//

#import "CountryTableViewCell.h"

@implementation CountryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (NSString *)cellIdentifier {
    return @"CountryTableViewCell";
}

+ (NSInteger)cellHeight{
    return 45;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    CountryTableViewCell *cell = (CountryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[CountryTableViewCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:[CountryTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if( self ) {
        // Initialization code
        
    }
    return self;
}
@end
