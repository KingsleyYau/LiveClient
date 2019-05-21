//
//  HotTopView.m
//  livestream
//
//  Created by Calvin on 2018/6/28.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "HotTopView.h"
#import "HotTopViewCell.h"
#import "LSUserUnreadCountManager.h"

@interface HotTopView ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) LSUserUnreadCountManager *unreadManager;
@end

@implementation HotTopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"HotTopView" owner:self options:0].firstObject;
        self.frame = frame;
        self.unreadManager = [LSUserUnreadCountManager shareInstance];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UINib *nib = [UINib nibWithNibName:@"HotTopViewCell" bundle:[LiveBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[HotTopViewCell cellIdentifier]];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)setIconArray:(NSArray *)iconArray {
    _iconArray = iconArray;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat width = self.frame.size.width / _iconArray.count;
    CGFloat height = self.frame.size.height;
    layout.itemSize = CGSizeMake(width , height);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.collectionView.collectionViewLayout = layout;
    
    [self.collectionView reloadData];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
    UIView *whiteView = [[UIView alloc]init];
    whiteView.backgroundColor = Color(255, 255, 255, 0.8);
    [visualView.contentView addSubview:whiteView];
    visualView.frame = self.frame;
    whiteView.frame = visualView.bounds;
    [self addSubview:visualView];
    [self sendSubviewToBack:visualView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.iconArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HotTopViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[HotTopViewCell cellIdentifier] forIndexPath:indexPath];
    cell.iconImageView.image = [UIImage imageNamed:self.iconArray[indexPath.row]];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@",self.titleArray[indexPath.row]];
    if (indexPath.row != self.iconArray.count - 1) {
        NSInteger type = 0;
        if ([LSLoginManager manager].loginItem.userPriv.isSayHiPriv) {
            type = indexPath.row;
        }else {
            type = indexPath.row + 1;
        }
        int unreadNum = [self.unreadManager getUnreadNum:(LSUnreadType)type];
        if (type == LSUnreadType_Private_Chat) {
            [cell showChatListUnreadNum:unreadNum];
        }else {
            [cell setUnreadNum:unreadNum];
        }

    } else {
        [cell setUnreadNum:0];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    [self.unreadManager setUnreadNum:(UnreadType)indexPath.row];
    [self.collectionView reloadData];
    
    if ([self.delagate respondsToSelector:@selector(didSelectTopViewItemWithIndex:)]) {
        [self.delagate didSelectTopViewItemWithIndex:indexPath.row];
    }
}

@end
