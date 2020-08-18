//
//  LSAllVideoListTableView.m
//  livestream
//
//  Created by logan on 2020/7/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSVideoCollectionView.h"
#import "LSVideoItemCollectionViewCell.h"

@interface LSVideoCollectionView ()

@end

@implementation LSVideoCollectionView
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {

    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

- (void)dealloc{
    NSLog(@"dealloc -");
}

@end
