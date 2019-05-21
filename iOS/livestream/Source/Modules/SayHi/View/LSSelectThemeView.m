//
//  LSSelectThemeView.m
//  livestream
//
//  Created by Randy_Fan on 2019/4/26.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSelectThemeView.h"

#import "LSSayHiThemeListCollectionViewCell.h"

@interface LSSelectThemeView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray <LSSayHiThemeItemObject *>*themeList;

@property (nonatomic, assign) NSInteger selectIndex;
@end

@implementation LSSelectThemeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        self.frame = frame;
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        UINib *nib = [UINib nibWithNibName:[LSSayHiThemeListCollectionViewCell cellIdentifier] bundle:[LiveBundle mainBundle]];
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:[LSSayHiThemeListCollectionViewCell cellIdentifier]];
        
        self.themeList = [[NSMutableArray alloc] init];
        
        self.selectIndex = -1;
    }
    return self;
}

- (void)loadThemeCollection:(NSMutableArray <LSSayHiThemeItemObject *>*)themes selectIndex:(NSInteger)selectIndex {
    self.selectIndex = selectIndex;
    self.themeList = themes;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate/UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.themeList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LSSayHiThemeListCollectionViewCell *cell = [LSSayHiThemeListCollectionViewCell getUICollectionViewCell:collectionView indexPath:indexPath];
    
    LSSayHiThemeItemObject *item = self.themeList[indexPath.row];
    [cell setupTheme:item.smallImg];
    if (self.selectIndex == indexPath.row) {
        cell.selected = YES;
    } else {
        cell.selected = NO;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row != self.selectIndex) {
        LSSayHiThemeItemObject *item = self.themeList[indexPath.row];
        if ([self.delegate respondsToSelector:@selector(didSelectItemAtIndexPath:)]) {
            [self.delegate didSelectItemAtIndexPath:item];
        }
        
        self.selectIndex = indexPath.row;
        
        [self.collectionView reloadData];
        [UIView setAnimationsEnabled:NO];
        [collectionView performBatchUpdates:^{
            
        } completion:^(BOOL finished) {
             [UIView setAnimationsEnabled:YES];
         }];
    }
}


@end
