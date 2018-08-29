//
//  LiveHeaderScrollview.m
//  ScrollviewDemo
//
//  Created by zzq on 2018/2/8.
//  Copyright © 2018年 zzq. All rights reserved.
//

#import "LiveHeaderScrollview.h"
#import "LiveHeaderScrollviewCell.h"
#import "UnreadNumManager.h"

#define BottomLineColor [UIColor colorWithRed:41/255 green:122/255 blue:243/255 alpha:1]

@interface LiveHeaderScrollview ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

/** CollectionView **/
@property (nonatomic, strong) UICollectionView *mainCollectionView;

/** 记录当前选择下标 **/
@property (nonatomic, assign) NSInteger currentRow;

/** 第一次加载子控件 **/
@property (nonatomic, assign) BOOL isFirstLayout;

@property (nonatomic, assign) BOOL isShowUnread;

@end

@implementation LiveHeaderScrollview

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.isFirstLayout = YES;
        self.isShowUnread = NO;
    }
    return self;
}

//默认值设置为第一个
- (NSInteger)currentRow {
    if (!_currentRow) {
        _currentRow = 0;
    }
    return _currentRow;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.isFirstLayout) {
        self.isFirstLayout = NO;
        [self setUpCollectionView];
    }
}

- (void)setUpCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    _mainCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    [self addSubview:_mainCollectionView];
    _mainCollectionView.backgroundColor = [UIColor clearColor];
    _mainCollectionView.showsHorizontalScrollIndicator = NO;
    [_mainCollectionView registerNib:[UINib nibWithNibName:@"LiveHeaderScrollviewCell" bundle:[LiveBundle mainBundle]] forCellWithReuseIdentifier:[LiveHeaderScrollviewCell cellIdentifier]];

    _mainCollectionView.delegate = self;
    _mainCollectionView.dataSource = self;
    
//    UIImage *image = [UIImage imageNamed:@"Home_Head_Line"];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//    CGFloat y = (self.bounds.size.height - image.size.height) / 2;
//    imageView.frame = CGRectMake(0, y, image.size.width, image.size.height);
//    [self addSubview:imageView];
    
//    UILabel *bottomLine = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, self.frame.size.width,0.5)];
//    bottomLine.backgroundColor = BottomLineColor;
//
//    [self addSubview:bottomLine];
 
}

- (void)reloadHeaderScrollview:(BOOL)isShowUnread {
    self.isShowUnread = isShowUnread;
    [self.mainCollectionView reloadData];
}

#pragma mark -- 处理滑屏事件
- (void)scrollCollectionItemToDesWithDesIndex:(NSInteger)index {
    
    NSIndexPath *desIndexpath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.mainCollectionView  scrollToItemAtIndexPath:desIndexpath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    self.currentRow = index;
    [self.mainCollectionView reloadData];
}

#pragma mark collectionView代理方法
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LiveHeaderScrollviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LiveHeaderScrollviewCell cellIdentifier] forIndexPath:indexPath];
    cell.mainLB.text = self.dataSource[indexPath.row];
    
    if (indexPath.row == self.currentRow) {
        cell.mainLB.textColor = Color(63, 167, 255, 1);
    } else {
        cell.mainLB.textColor = [UIColor blackColor];
    }
    
    if (indexPath.row == self.dataSource.count - 1) {
        if (self.isShowUnread) {
            cell.redLabel.hidden = NO;
        } else {
            cell.redLabel.hidden = YES;
        }
    } else {
        cell.redLabel.hidden = YES;
    }
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = [self.dataSource[indexPath.row] sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15]}].width + 20;
    
    return CGSizeMake(width, self.frame.size.height);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.currentRow != indexPath.row && indexPath.row == self.dataSource.count - 1) {
        self.isShowUnread = NO;
    }
    self.currentRow = indexPath.row;
    [collectionView reloadData];
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(header_disSelectRowAtIndexPath:)]) {
        [self.delegate header_disSelectRowAtIndexPath:indexPath];
    }
}


@end
