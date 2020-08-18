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
    return (screenSize.width - 40) * 1.5;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    HangoutListCell *cell = (HangoutListCell *)[tableView dequeueReusableCellWithIdentifier:[HangoutListCell cellIdentifier]];
    if (nil == cell) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"HangoutListCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.animationArray = [NSMutableArray array];
        cell.imageViewLoader = [LSImageViewLoader loader];
        cell.imageViewHeader.image = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UINib *friendViewNib = [UINib nibWithNibName:@"HangoutListFriendCollectionViewCell" bundle:[LiveBundle mainBundle]];
        [cell.collectionView registerNib:friendViewNib forCellWithReuseIdentifier:[HangoutListFriendCollectionViewCell cellIdentifier]];
        cell.collectionView.delaysContentTouches = NO;
        cell.collectionView.dataSource = cell;
        cell.collectionView.delegate = cell;
        cell.friendArray = [NSMutableArray array];

        // 多人互动邀请按钮阴影
        cell.hangoutContentView.layer.cornerRadius = 10.0f;
        cell.hangoutContentView.layer.masksToBounds = YES;

        LSShadowView *shadow = [[LSShadowView alloc] init];
        [shadow showShadowAddView:cell.hangoutButton];

        // 头像底部阴影
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[ (__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0xD4000000).CGColor, (__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x25000000).CGColor, (__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x00252525).CGColor ];
        gradientLayer.locations = @[ @0, @0.75, @1.0 ];
        gradientLayer.startPoint = CGPointMake(0, 1.0);
        gradientLayer.endPoint = CGPointMake(0, 0.0);
        gradientLayer.frame = CGRectMake(0, 0, screenSize.width, cell.bottomView.bounds.size.height);
        [cell.bottomView.layer addSublayer:gradientLayer];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
        self.hangoutButton.layer.cornerRadius = self.hangoutButton.frame.size.height / 2.0f;
        self.hangoutButton.layer.masksToBounds = YES;

        // 添加头部点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhoto:)];
        self.imageViewHeader.userInteractionEnabled = YES;
        self.bottomView.userInteractionEnabled = YES;
        [self.imageViewHeader addGestureRecognizer:tap];
        [self.bottomView addGestureRecognizer:tap];
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

    self.hangoutButton.layer.cornerRadius = self.hangoutButton.frame.size.height / 2.0f;
    self.hangoutButton.layer.masksToBounds = YES;

    // 添加头部点击事件
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhoto:)];
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPhoto:)];
    self.imageViewHeader.userInteractionEnabled = YES;
    self.bottomView.userInteractionEnabled = YES;
    [self.imageViewHeader addGestureRecognizer:imageTap];
    [self.bottomView addGestureRecognizer:tap];
}

- (void)tapPhoto:(UITapGestureRecognizer *)gesture {
    if (self.hangoutDelegate && [self.hangoutDelegate respondsToSelector:@selector(hangoutListCellDidAchorPhoto:)]) {
        NSInteger row = self.tag - 888;
        [self.hangoutDelegate hangoutListCellDidAchorPhoto:row];
    }
}

- (void)loadInviteMsg:(NSString *)msg {
    if (msg.length > 0) {
        self.inviteMsg.text = [NSString stringWithFormat:@"\"%@\"", msg];
        self.inviteMsgHeight.constant = 34;

    } else {
        self.inviteMsgHeight.constant = 0;
        self.inviteMsg.text = @"";
    }
}

- (void)loadFriendData:(NSArray *)items {
    NSInteger friendViewWidth = 0;
    NSInteger num = 0;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    // 设置不同尺寸机型好友的大小
    NSInteger itemWidth = ((screenSize.width - 40 - 4 * 12 - 22)) / 5;
    //    // 调整5s机型上左右的间距
    //    if (screenSize.width == 320) {
    //        itemWidth = ((screenSize.width - 40 - 5 * 12 - 10)) / 5;
    //    }
    // 最大显示为5个好友
    if (items.count >= 5) {
        num = 5;
    } else {
        num = items.count;
    }
    // 好友列表的宽度, 好友列表数量的总大小以及间距
    friendViewWidth = itemWidth * num + (num - 1) * 12;
    self.friendWidth.constant = friendViewWidth;

    // 先移除当前好友列表里的数组,防止重用数据出问题
    [self.friendArray removeAllObjects];
    // 添加对应的view
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i = 0; i < num; i++) {

        LSFriendsInfoItemObject *item = items[i];
        [tempArray addObject:item];
    }
    [self.friendArray addObjectsFromArray:tempArray];
    [self.collectionView reloadData];
}

//- (void)headImageTap:(UITapGestureRecognizer *)gesture {
//    // 添加颜色渐变动画
//    [gesture.view.layer addAnimation:[self addBorderAnimation] forKey:@"borderColor"];
//    if (self.hangoutDelegate && [self.hangoutDelegate respondsToSelector:@selector(hangoutListCell:didClickAchorFriendPhoto:)]) {
//        NSInteger row = gesture.view.tag;
//        [self.hangoutDelegate hangoutListCell:self didClickAchorFriendPhoto:row];
//    }
//}

- (IBAction)hangoutButtonDid:(UIButton *)sender {
    if (self.hangoutDelegate && [self.hangoutDelegate respondsToSelector:@selector(hangoutListCellDidHangout:)]) {
        NSInteger row = sender.tag - 88;
        [self.hangoutDelegate hangoutListCellDidHangout:row];
    }
}

#pragma mark - 推荐逻辑
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    return self.friendArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HangoutListFriendCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HangoutListFriendCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    cell.layer.cornerRadius = cell.frame.size.width * 0.5f;
    cell.layer.masksToBounds = YES;
    LSFriendsInfoItemObject *item = [self.friendArray objectAtIndex:indexPath.row];
    cell.friendCellDelegate = self;
    //    [cell setHighlightButtonTag:indexPath.row];
    [cell.imageViewLoader stop];
    [cell.imageViewLoader loadImageFromCache:cell.imageView
                                         options:0
                                        imageUrl:item.anchorImg
                                placeholderImage:LADYDEFAULTIMG
                                   finishHandler:nil];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger itemWidth = ((screenSize.width - 40 - 4 * 12 - 22)) / 5;
    // 调整5s机型上左右的间距

    return CGSizeMake(itemWidth, itemWidth);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.hangoutDelegate && [self.hangoutDelegate respondsToSelector:@selector(hangoutListCell:didClickAchorFriendPhoto:)]) {
        [self.hangoutDelegate hangoutListCell:self didClickAchorFriendPhoto:indexPath.row];
    }
}

//- (void)hangoutListFriendCollectionViewCell:(HangoutListFriendCollectionViewCell *)cell didSelectIndex:(NSInteger)index {
//    if (self.hangoutDelegate && [self.hangoutDelegate respondsToSelector:@selector(hangoutListCell:didClickAchorFriendPhoto:)]) {
//        [self.hangoutDelegate hangoutListCell:self didClickAchorFriendPhoto:index];
//    }
//}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    HangoutListFriendCollectionViewCell *cell = (HangoutListFriendCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderColor = [UIColor clearColor].CGColor;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}
//当cell高亮时返回是否高亮
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.layer.borderColor = COLOR_WITH_16BAND_RGB(0xFF6D00).CGColor;
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    // 添加延迟操作,防止轻触点击,调用过快,没有出现
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        cell.layer.borderColor = [UIColor clearColor].CGColor;
    });
}
//
//
//
//// 添加颜色渐变动画
//- (CABasicAnimation *)addBorderAnimation {
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
//    animation.fromValue = (id)[UIColor clearColor].CGColor;
//    animation.toValue = (id)COLOR_WITH_16BAND_RGB(0xFF6D00).CGColor;
//    animation.autoreverses = YES;
//    animation.duration = 0.3;
//    animation.repeatCount = 1;
//    animation.removedOnCompletion = YES;
//    animation.fillMode = kCAFillModeForwards;
//    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//    return animation;
//}
@end
