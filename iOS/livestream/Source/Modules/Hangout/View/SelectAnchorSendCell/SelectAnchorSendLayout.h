//
//  SelectAnchorSendLayout.h
//  UIWidget
//
//  Created by test on 2017/6/13.
//  Copyright © 2017年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectAnchorSendLayout : UICollectionViewLayout

@property (assign, nonatomic) NSInteger pageCount;
@property (nonatomic,assign) NSInteger currentPage;

- (instancetype)init;

@end
