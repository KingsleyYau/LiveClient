//
//  LSBaseTableViewCell.m
//  UIWidget
//
//  Created by test on 2020/3/13.
//  Copyright © 2020 drcom. All rights reserved.
//

#import "LSBaseTableViewCell.h"


@implementation LSBaseTableViewCell


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self setBarkModelBackgroundColor];
    

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier  {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setBarkModelBackgroundColor];
    }
    return self;
}


- (void)setBarkModelBackgroundColor {
    if (@available(iOS 13.0, *)) {
        self.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
