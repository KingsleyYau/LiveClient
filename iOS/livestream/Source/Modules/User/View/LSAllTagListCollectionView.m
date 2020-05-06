//
//  AllTagListCollectionView.m
//  dating
//
//  Created by test on 2017/5/31.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSAllTagListCollectionView.h"
#define defaultTextWidth 35.0f
#define defaultTextHeight 10.0f

@interface LSAllTagListCollectionView()<UICollectionViewDataSource,UICollectionViewDelegate>


@end

@implementation LSAllTagListCollectionView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.collectionView.frame = self.bounds;
    
}

- (void)setup {
    LSTagListCollectionViewFlowLayout *layout = [[LSTagListCollectionViewFlowLayout alloc] init];
    self.collectionView = [[LSCollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.scrollEnabled = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    UINib *nib = [UINib nibWithNibName:@"LSTagListCollectionViewCell" bundle:[LiveBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[LSTagListCollectionViewCell cellIdentifier]];
    [self addSubview:self.collectionView];
}


#pragma mark - UICollectionViewDelegate | UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger interestsCount = 0;
    interestsCount = self.allTags.count;
    return interestsCount;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSTagListCollectionViewFlowLayout *layout = (LSTagListCollectionViewFlowLayout *)collectionView.collectionViewLayout;
    CGSize maxSize = CGSizeMake(collectionView.frame.size.width - layout.sectionInset.left - layout.sectionInset.right, layout.itemSize.height);
    
    CGSize textSize;
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14], NSFontAttributeName, nil];
    
    LSManInterestItem *interestItem = self.allTags[indexPath.item];
    textSize = [interestItem.title boundingRectWithSize:maxSize 
                                                options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                             attributes:dict
                                                context:nil].size;
    
    return CGSizeMake(textSize.width + defaultTextWidth, textSize.height + defaultTextHeight);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSTagListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LSTagListCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    
    LSManInterestItem *interestItem  = self.allTags[indexPath.item];
    [cell.interestTag setTitle:interestItem.title forState:UIControlStateNormal];
    [cell.interestTag setImage:[UIImage imageNamed:interestItem.icon] forState:UIControlStateNormal];
    //                cell.interestTag.layer.cornerRadius = cell.interestTag.frame.size.height * 0.35;
    cell.interestTag.layer.cornerRadius = 15.0f;
    cell.interestTag.backgroundColor = Color(240, 240, 240, 1);
    
    if (self.selectTags.count > 0) {
        for (LSManInterestItem *item in self.selectTags) {
            if ([item isEqual:interestItem]) {
                cell.interestTag.layer.masksToBounds = YES;
                cell.interestTag.layer.borderWidth = 1;
                cell.interestTag.layer.borderColor = Color(8, 187, 255, 1).CGColor;
                cell.interestTag.backgroundColor = [UIColor whiteColor];
                break;
            }else {
                cell.interestTag.layer.masksToBounds = YES;
                cell.interestTag.layer.borderWidth = 0;
                
            }
        }
    }else {
        cell.interestTag.layer.masksToBounds = YES;
        cell.interestTag.layer.borderWidth = 0;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.allTagDelegate && [self.allTagDelegate respondsToSelector:@selector(lsAllTagListCollectionView:didClickViewItem:)]) {
        
        LSManInterestItem *interestItem  = self.allTags[indexPath.item];
        [self.allTagDelegate lsAllTagListCollectionView:self didClickViewItem:interestItem];
    }
    
}


@end
