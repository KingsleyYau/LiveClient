//
//  HangoutListCell.m
//  livestream
//
//  Created by Calvin on 2019/1/16.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import "HangoutListCell.h"
#import "LSShadowView.h"

@implementation HangoutListCell

+ (NSString *)cellIdentifier {
    return @"HangoutListCell";
}

+ (NSInteger)cellHeight {
    return 500;
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

        // 多人互动邀请按钮阴影
        cell.hangoutContentView.layer.cornerRadius = 10.0f;
        cell.hangoutContentView.layer.masksToBounds = YES;
        
        LSShadowView *shadow = [[LSShadowView alloc] init];
        [shadow showShadowAddView:cell.hangoutButton];
        
        // 头像底部阴影
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
    
    self.hangoutButton.layer.cornerRadius = self.hangoutButton.frame.size.height /2.0f;
    self.hangoutButton.layer.masksToBounds = YES;
    
    // 添加头部点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhoto:)];
    self.imageViewHeader.userInteractionEnabled = YES;
    self.bottomView.userInteractionEnabled = YES;
    [self.imageViewHeader addGestureRecognizer:tap];
    [self.bottomView addGestureRecognizer:tap];
}

- (void)tapPhoto:(UITapGestureRecognizer *)gesture {
    if (self.hangoutDelegate && [self.hangoutDelegate respondsToSelector:@selector(hangoutListCellDidAchorPhoto:)]) {
        NSInteger row = self.tag - 888;
        [self.hangoutDelegate hangoutListCellDidAchorPhoto:row];
    }
}


- (void)loadInviteMsg:(NSString *)msg {
    NSLog(@"HangoutListCell::loadInviteMsg %@",msg);
    if (msg.length > 0) {
        NSLog(@"msg :%@",msg);
        self.inviteMsg.text = [NSString stringWithFormat:@"\"%@\"",msg];
        self.inviteMsgHeight.constant = 34;

    }else {
        self.inviteMsgHeight.constant = 0;
        self.inviteMsg.text = @"";
    }
}


- (void)loadFriendData:(NSArray *)items {
    
    CGFloat w = (screenSize.width - 25 - 20) / 5.0f;
    CGFloat spacing = 5.0f;
    CGFloat friendViewWidth = 0;
    NSInteger num = 0;
    // 最多显示5个
    if (items.count >= 5) {
        friendViewWidth = 5 * w;
        num = 5;
    } else {
        friendViewWidth = items.count * w;
        num = items.count;
    }
    
    // 超过宽度为最大宽度
    if (friendViewWidth >= screenSize.width - 20) {
        friendViewWidth = screenSize.width - 20;
    }
    self.friendWidth.constant = friendViewWidth;
    CGFloat itemSize = w - 5.0f;
    
    // 添加对应的view
    for (int i = 0; i < num; i++) {
        
        LSFriendsInfoItemObject * item = items[i];
        
        UIView * headView = [[UIView alloc]initWithFrame:CGRectMake(w * i + spacing, 0, itemSize, itemSize)];
        [self.friendView addSubview:headView];
        
        UIImageView * headImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, itemSize, itemSize)];
        headImage.layer.cornerRadius = itemSize /2.0f;
        headImage.layer.borderWidth = 2;
        headImage.layer.borderColor = [UIColor clearColor].CGColor;
        headImage.layer.masksToBounds = YES;
        headImage.contentMode = UIViewContentModeScaleAspectFill;
        headImage.backgroundColor = COLOR_WITH_16BAND_RGB(0xECEDF1);
        headImage.userInteractionEnabled = YES;
        [headView addSubview:headImage];
        headImage.tag = i;
        [headImage addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(headImageTap:)]];
        
        [[LSImageViewLoader loader] loadImageWithImageView:headImage options:0 imageUrl:item.anchorImg placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    }
    
}

- (void)headImageTap:(UITapGestureRecognizer *)gesture {
    // 添加颜色渐变动画
    [gesture.view.layer addAnimation:[self addBorderAnimation] forKey:@"borderColor"];
    if (self.hangoutDelegate && [self.hangoutDelegate respondsToSelector:@selector(hangoutListCell:didClickAchorFriendPhoto:)]) {
        NSInteger row = gesture.view.tag;
        [self.hangoutDelegate hangoutListCell:self didClickAchorFriendPhoto:row];
    }
}

- (IBAction)hangoutButtonDid:(UIButton *)sender {
    if (self.hangoutDelegate && [self.hangoutDelegate respondsToSelector:@selector(hangoutListCellDidHangout:)]) {
        NSInteger row = sender.tag - 88;
        [self.hangoutDelegate hangoutListCellDidHangout:row];
    }
}


// 添加颜色渐变动画
- (CABasicAnimation *)addBorderAnimation {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    animation.fromValue = (id)[UIColor clearColor].CGColor;
    animation.toValue = (id)COLOR_WITH_16BAND_RGB(0xFF6D00).CGColor;
    animation.autoreverses = YES;
    animation.duration = 0.3;
    animation.repeatCount = 1;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return animation;
}
@end
