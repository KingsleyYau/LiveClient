//
//  HotTableViewCell.m
//  livestream
//
//  Created by Max on 13-9-5.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import "HotTableViewCell.h"

@implementation HotTableViewCell
+ (NSString *)cellIdentifier {
    return @"HotTableViewCell";
}

+ (NSInteger)cellHeight {
    return 0;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    HotTableViewCell *cell = (HotTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[HotTableViewCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:@"HotTableViewCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
        cell.imageViewLoader = nil;
    }
    
    cell.imageViewHeader.image = nil;
    cell.labelViewers.text = @"";
    cell.labelCountry.text = @"";
         
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if( self ) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

@end
