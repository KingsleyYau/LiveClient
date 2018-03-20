//
//  YMAudienceView.m
//  YueMao
//
//  Created by randy on 2017/8/30.
//
//

#import "YMAudienceView.h"
#import "AudienceCell.h"
#import "LiveBundle.h"

#define ItemSize 25

@interface YMAudienceView () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation YMAudienceView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {

    self = [super initWithCoder:aDecoder];
    if (self) {

        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(ItemSize, ItemSize);
        //        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 4;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.bounces = NO;
        NSBundle *bundle = [LiveBundle mainBundle];
        UINib *nib = [UINib nibWithNibName:@"AudienceCell" bundle:bundle];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:[AudienceCell cellIdentifier]];
        self.collectionView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.collectionView];

        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

#pragma mark - Public Method
- (void)setAudienceArray:(NSMutableArray *)audienceArray {
    _audienceArray = audienceArray;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.audienceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AudienceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[AudienceCell cellIdentifier] forIndexPath:indexPath];
    [cell updateHeadImageWith:self.audienceArray[indexPath.row] radius:ItemSize];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //    [self.delegate liveAudidenceView:self didTapHeadWithObject:self.audienceArray[indexPath.row]];
}

#pragma mark - UIScrollViewDelegate

//刷到底部
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //    CGPoint offset = scrollView.contentOffset;  // 当前滚动位移
    //    CGRect bounds = scrollView.bounds;          // UIScrollView 可视宽度
    //    CGSize size = scrollView.contentSize;         // 滚动区域
    //    UIEdgeInsets inset = scrollView.contentInset;
    //    float x = offset.x + bounds.size.width - inset.right;
    //    float w = size.width;
    //    float reload_distance = 10;
    //    if (x > w + reload_distance) {
    //        [self.delegate liveLoadingAudienceView:self];
    //    }
    //
    //    [self.delegate liveAudidenveViewDidScroll];
}

//停在第一页
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        //这里写上停止时要执行的代码
        CGPoint offset = scrollView.contentOffset; // 当前滚动位移
        if (offset.x == 0) {
            [self.delegate liveReloadAudidenceView:self];
        }
    }
}

//停在第一页
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset; // 当前滚动位移
    if (offset.x == 0) {
        [self.delegate liveReloadAudidenceView:self];
    }
    [self.delegate liveAudidenveViewDidEndScrolling];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {

    [self.delegate liveAudidenveViewDidEndScrolling];
}


@end
