//
//  HangoutListCell.m
//  livestream
//
//  Created by Calvin on 2019/1/16.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "HangoutListCell.h"

@implementation HangoutListCell

+ (NSString *)cellIdentifier {
    return @"HangoutListCell";
}

+ (NSInteger)cellHeight {
    return screenSize.width;
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    HangoutListCell *cell = (HangoutListCell *)[tableView dequeueReusableCellWithIdentifier:[HangoutListCell cellIdentifier]];
    if ( nil == cell ) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"HangoutListCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.animationArray = [NSMutableArray array];
        cell.imageViewLoader = [LSImageViewLoader loader];
        cell.imageViewHeader.image = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [cell setExclusiveTouch:YES];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0xD4000000).CGColor, (__bridge id)[UIColor clearColor].CGColor];
        gradientLayer.locations = @[@0.0, @1.0];
        gradientLayer.startPoint = CGPointMake(0, 1.0);
        gradientLayer.endPoint = CGPointMake(0, 0.0);
        gradientLayer.frame = CGRectMake(0, 0, screenSize.width, cell.bottomView.bounds.size.height);
        [cell.bottomView.layer addSublayer:gradientLayer];
        
    }
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

- (void)awakeFromNib {
    [super awakeFromNib];
    self.hangoutButton.layer.cornerRadius = self.hangoutButton.frame.size.height/2;
    self.hangoutButton.layer.masksToBounds = YES;
}

- (void)setScrollLabelViewText:(NSString *)text
{
    if (!self.scrollLabelView) {
        CGSize size = self.titleView.frame.size;
        self.scrollLabelView = [TXScrollLabelView scrollWithTitle:text type:TXScrollLabelViewTypeLeftRight velocity:1 options:UIViewAnimationOptionCurveEaseInOut];
        self.scrollLabelView.frame = CGRectMake(0, 0, size.width, 30);
        self.scrollLabelView.scrollInset = UIEdgeInsetsMake(0, 10 , 0, 10);
        self.scrollLabelView.scrollSpace = 20;
        self.scrollLabelView.textAlignment = NSTextAlignmentCenter;
        self.scrollLabelView.backgroundColor = [UIColor clearColor];
        self.scrollLabelView.font = [UIFont systemFontOfSize:18];
        [self.titleView addSubview:self.scrollLabelView];

        [self.scrollLabelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.titleView);
        }];
        
        CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]}];
        if (textSize.width > self.scrollLabelView.frame.size.width) {
          [self.scrollLabelView beginScrolling];
        }
    }
}

- (void)setHangoutHeadList:(NSArray *)list {
    
    NSArray * data = list;
    if (list.count > 3) {
        data = [list subarrayWithRange:NSMakeRange(0, 3)];
    }
    
    int unm = (int)data.count + 1;
    CGFloat x = self.titleView.frame.size.width/2 - (unm * 25)/2 + 25;
    for (int i = 0; i < unm; i++) {
        if (i == unm - 1) {
            UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(x+i*25, self.scrollLabelView.tx_bottom + 10, 40, 40)];
            label.layer.cornerRadius = 20;
            label.layer.masksToBounds = YES;
            label.layer.borderColor = [UIColor whiteColor].CGColor;
            label.layer.borderWidth = 2;
            label.backgroundColor = [UIColor lightGrayColor];
            label.text = @"...";
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:15];
            [self.titleView addSubview:label];
        }
        else {
            UIImageView * headImage = [[UIImageView alloc]initWithFrame:CGRectMake(x+i*25, self.scrollLabelView.tx_bottom + 10, 40, 40)];
            headImage.layer.cornerRadius = 20;
            headImage.layer.masksToBounds = YES;
            headImage.layer.borderColor = [UIColor whiteColor].CGColor;
            headImage.layer.borderWidth = 2;
            headImage.backgroundColor = [UIColor grayColor];
            [self.titleView addSubview:headImage];
            
            LSFriendsInfoItemObject * obj = [data objectAtIndex:i];
            [ [LSImageViewLoader loader] loadImageWithImageView:headImage
                                                        options:0
                                                       imageUrl:obj.anchorImg
                                               placeholderImage:[UIImage imageNamed:@"Home_HotAndFollow_ImageView_Placeholder"]];
        }
    }
}


- (IBAction)hangoutButtonDid:(UIButton *)sender {
    if (self.hangoutDelegate && [self.hangoutDelegate respondsToSelector:@selector(hangoutListCellDidHangout:)]) {
        NSInteger row = sender.tag - 88;
        [self.hangoutDelegate hangoutListCellDidHangout:row];
    }
}
@end
