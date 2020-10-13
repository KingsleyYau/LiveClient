//
//  StreamFileItemLayout.h
//  UIWidget
//
//  Created by max on 2017/6/13.
//  Copyright © 2017年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface StreamFileItemLayout : UICollectionViewLayout
@property (assign) NSInteger pageCount;
@property (assign) NSInteger currentPage;

- (instancetype)init;
@end
