//
//  LSGiftTypeView.m
//  livestream
//
//  Created by Calvin on 2019/9/5.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSGiftTypeView.h"
#import "LSGiftTypeCell.h"
#import "LSGiftTypeItemObject.h"
@interface LSGiftTypeView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, assign) NSInteger oldRow;
@end

@implementation LSGiftTypeView
 
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        UIView *containerView = [[LiveBundle mainBundle] loadNibNamed:@"LSGiftTypeView" owner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        containerView.frame = newFrame;
        [self addSubview:containerView];
        
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialize];
    
    self.oldRow = 0;
}

- (void)initialize {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    //注册cell
    [self.collectionView registerNib:[UINib nibWithNibName:@"LSGiftTypeCell" bundle:[LiveBundle mainBundle]] forCellWithReuseIdentifier:[LSGiftTypeCell cellIdentifier]];
}

- (void)selectTypeRow:(NSInteger)row isAnimated:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.oldRow = row;
        [self.collectionView reloadData];
        if (row < self.items.count) {
                   [self.collectionView scrollToItemAtIndexPath: [NSIndexPath indexPathForRow:self.oldRow inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
        }
    });
}

#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *result = [[UICollectionViewCell alloc] init];
    LSGiftTypeCell *cell = (LSGiftTypeCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[LSGiftTypeCell cellIdentifier] forIndexPath:indexPath];
    result = cell;
    cell.layer.cornerRadius = cell.tx_height/2;
    cell.layer.masksToBounds = YES;
    
    LSGiftTypeItemObject * item = self.items[indexPath.row];
    cell.titleLabel.text = item.typeName;
    
    if ([item.typeName isEqualToString:@"Free "]) {
        cell.starIcon.hidden = NO;
    }else {
        cell.starIcon.hidden = YES;
    }
    
    if (self.oldRow == indexPath.row) {
        cell.backgroundColor = self.roomStyleItem.giftSegmentTitleColor;
        cell.titleLabel.textColor = self.roomStyleItem.giftSegmentTitleSelectColor;
    }else {
        cell.backgroundColor = [UIColor clearColor];
        cell.titleLabel.textColor = self.roomStyleItem.giftSegmentTitleColor;
    }
     
    return result;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    self.oldRow = indexPath.row;
    [collectionView reloadData];
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(giftTypeViewSelectIndexRow:)]) {
        [self.delegate giftTypeViewSelectIndexRow:self.oldRow];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSGiftTypeItemObject * item = self.items[indexPath.row];
      CGSize size = [item.typeName sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0f]}];
    CGFloat w = ceil(size.width) + 20;
    return CGSizeMake(w, 26);
}

@end
