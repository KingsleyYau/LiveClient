//
//  LiveChannelContentView.m
//  livestream
//
//  Created by test on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveChannelContentView.h"
#import "FileCacheManager.h"
#import "LiveChannelCollectionViewCell.h"
#import "LiveChannelTopCollectionReusableView.h"
#import "LiveChannelBottomCollectionReusableView.h"

#define defaultHeight 44
#define doubleHeight (defaultHeight * 2)
static NSString *headerViewIdentifier = @"headerView";
static NSString *footerViewIdentifier = @"footerView";
@interface LiveChannelContentView()<LiveChannelTopCollectionReusableViewDelegate,LiveChannelBottomCollectionReusableViewDelegate>

@property (nonatomic,strong) UIImageView *placeholderImageView;

@end

@implementation LiveChannelContentView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        [self initialize];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    self.delegate = self;
    self.dataSource = self;
    
    self.alwaysBounceVertical = YES;
    //注册cell
    [self registerNib:[UINib nibWithNibName:@"LiveChannelCollectionViewCell" bundle:[NSBundle mainBundle]]  forCellWithReuseIdentifier:[LiveChannelCollectionViewCell cellIdentifier]];
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.minimumLineSpacing = 5.0f;
    flow.minimumInteritemSpacing = 5.0f;
    flow.sectionInset = UIEdgeInsetsMake(10, 5, 10, 5);
//    [self registerClass:[LiveChannelTopCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerViewIdentifier];
//    [self registerClass:[LiveChannelBottomCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerViewIdentifier];
     UINib *nib = nil;
    nib = [UINib nibWithNibName:@"LiveChannelTopCollectionReusableView" bundle:nil];
    [self registerNib:nib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerViewIdentifier];
    nib = [UINib nibWithNibName:@"LiveChannelBottomCollectionReusableView" bundle:nil];
    [self registerNib:nib forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerViewIdentifier];
    UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LiveChannel_DownBackground"]];
    self.backgroundView = imageV;
    self.backgroundColor = [UIColor whiteColor];
    self.collectionViewLayout = flow;
    self.scrollEnabled = NO;
    self.spreadOut = YES;


    
    
}

#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
        return self.items.count;
//    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LiveChannelCollectionViewCell *cell = (LiveChannelCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[LiveChannelCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    
    // 数据填充
    // 数据填充
        LiveRoomInfoItemObject *item = [self.items objectAtIndex:indexPath.item];
    
    
    // 房间名
    cell.nameLabel.text = item.userId;
    //    cell.labelRoomTitle.text = item.nickName;
    
    // 国家
    //    cell.labelCountry.text = item.country;
    
    if (item.onlineStatus != ONLINE_STATUS_LIVE) {
        cell.onlineImageView.backgroundColor = [UIColor colorWithHexString:@"b5b5b5"];
    } else {
        cell.onlineImageView.backgroundColor = [UIColor colorWithHexString:@"8edb2b"];
    }
    
    switch (item.roomType) {
            // 没有直播间
        case HTTPROOMTYPE_NOLIVEROOM: {
            cell.roomTpyePublic.hidden = YES;
            cell.roomTypeImageView.hidden = YES;

        } break;
            // 免费公开直播间
        case HTTPROOMTYPE_FREEPUBLICLIVEROOM: {
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                cell.roomTpyePublic.hidden = YES;
                cell.roomTypeImageView.hidden = YES;

            } else {
                cell.roomTpyePublic.hidden = NO;
                cell.roomTypeImageView.hidden = YES;

            }

        } break;
            // 付费公开直播间
        case HTTPROOMTYPE_CHARGEPUBLICLIVEROOM: {
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                [cell.roomTypeImageView setImage:nil];
                cell.roomTpyePublic.hidden = YES;
                cell.roomTypeImageView.hidden = YES;

            } else {
                cell.roomTpyePublic.hidden = NO;
                cell.roomTypeImageView.hidden = YES;
            }

        } break;
            // 普通私密直播间
        case HTTPROOMTYPE_COMMONPRIVATELIVEROOM: {
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                cell.roomTpyePublic.hidden = YES;
                cell.roomTypeImageView.hidden = YES;

            } else {
                cell.roomTpyePublic.hidden = YES;
                cell.roomTypeImageView.hidden = NO;
            
        } break;
            // 豪华私密直播间
        case HTTPROOMTYPE_LUXURYPRIVATELIVEROOM: {
            if (item.onlineStatus != ONLINE_STATUS_LIVE) {
                cell.roomTpyePublic.hidden = YES;
                cell.roomTypeImageView.hidden = YES;

            } else {
                cell.roomTpyePublic.hidden = YES;
                cell.roomTypeImageView.hidden = NO;
            }
            
        } break;
            
        default:
            break;
        }
    }
    
    
    // 头像


    cell.coverImageView.image = nil;
    [cell.imageViewLoader stop];
    [cell.imageViewLoader loadImageWithImageView:cell.coverImageView
                                         options:0
                                        imageUrl:item.roomPhotoUrl
                                placeholderImage:[UIImage imageNamed:@"Home_HotAndFollow_ImageView_Placeholder"]];

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s",__func__);
    
    if ([self.liveChannelDelegate respondsToSelector:@selector(liveChannelContentView:didSelecRoom:)]) {
        [self.liveChannelDelegate liveChannelContentView:self didSelecRoom:indexPath];
    }
}



- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemSize = (self.frame.size.width - 15)/2.0f;
    return CGSizeMake(itemSize, itemSize);
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
       UICollectionReusableView *reusableView = nil;

    //如果是头视图
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        LiveChannelTopCollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerViewIdentifier forIndexPath:indexPath];

        header.topReuableViewDelegate = self;
        reusableView = header;
    }
    //如果底部视图
    if([kind isEqualToString:UICollectionElementKindSectionFooter]){
       
        LiveChannelBottomCollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:footerViewIdentifier forIndexPath:indexPath];
        footer.bottomResuableViewDelegate = self;
        if (self.items.count == 0) {
            if (!self.placeholderImageView) {
                self.backgroundView.userInteractionEnabled = YES;
                self.userInteractionEnabled = YES;
                UIImageView *placeholderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, defaultHeight, self.frame.size.width, self.frame.size.height - doubleHeight)];
                placeholderImageView.image = [UIImage imageNamed:@"Home_HotAndFollow_ImageView_Placeholder"];
                [self.backgroundView addSubview:placeholderImageView];
                placeholderImageView.userInteractionEnabled = YES;
                self.placeholderImageView = placeholderImageView;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(placeholderBackImageViewDidTap:)];
                [placeholderImageView addGestureRecognizer:tap];
            }
        }else {
            if (self.placeholderImageView) {
                [self.placeholderImageView removeFromSuperview];
            }
        }



        reusableView = footer;
    }
    return reusableView;
}

//执行的 headerView 代理 返回 headerView 的高度
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return CGSizeMake(screenSize.width, defaultHeight);
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    return CGSizeMake(screenSize.width, defaultHeight);
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.items.count > 0) {
        return UIEdgeInsetsMake(5, 5,5, 5);
    }else {


        return UIEdgeInsetsMake(self.backgroundView.frame.size.height - doubleHeight, 0,0, 0);
    }
    return UIEdgeInsetsMake(0, 0,0, 0);
}




- (void)liveChannelBottomCollectionReusableView:(LiveChannelBottomCollectionReusableView *)bottomResuableView didClickBtn:(UIButton *)sender{
    NSLog(@"%s",__func__);
    if ([self.liveChannelDelegate respondsToSelector:@selector(liveChannelContentView:didClickGoWatch:)]) {
        [self.liveChannelDelegate liveChannelContentView:self didClickGoWatch:sender];
    }
}

- (void)liveChannelTopCollectionReusableView:(LiveChannelTopCollectionReusableView *)reusableView didClickBtn:(UIButton *)sender {
        NSLog(@"%s",__func__);
    if ([self.liveChannelDelegate respondsToSelector:@selector(liveChannelContentView:didClickTop:)]) {
        [self.liveChannelDelegate liveChannelContentView:self didClickTop:sender];
    }
}


- (void)placeholderBackImageViewDidTap:(UITapGestureRecognizer *)gesture {
    NSLog(@"%s",__func__);
}
@end
