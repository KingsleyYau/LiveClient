//
//  LSSayHiTextListTableViewCell.m
//  livestream
//
//  Created by Randy_Fan on 2019/4/23.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiTextListTableViewCell.h"
#import "LSShadowView.h"

@interface LSSayHiTextListTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;

@property (strong, nonatomic) LSShadowView *shadow;

@end

@implementation LSSayHiTextListTableViewCell

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self class]);
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSSayHiTextListTableViewCell *cell = (LSSayHiTextListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSSayHiTextListTableViewCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSSayHiTextListTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.shadowView.layer.cornerRadius = 5;
    self.shadowView.layer.borderWidth = 2;
    self.shadowView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xff7100).CGColor;
    self.shadowView.layer.masksToBounds = YES;
    self.shadow = [[LSShadowView alloc] init];
    [self.shadow showShadowAddView:self.shadowView];
    
    self.selectImageView.hidden = YES;
}

- (void)setupTextContent:(NSString *)content {
    self.contentLabel.text = content;
    
    self.selectImageView.hidden = !self.isSelect;
    if (self.isSelect) {
        self.shadowView.layer.borderWidth = 2;
    } else {
        self.shadowView.layer.borderWidth = 0;
    }
}

@end
