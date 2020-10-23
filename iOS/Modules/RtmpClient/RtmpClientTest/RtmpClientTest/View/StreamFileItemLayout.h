//
//  StreamFileItemLayout.h
//  RtmpClientTest
//
//  Created by Max on 2020/10/12.
//  Copyright © 2020年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface StreamFileItemLayout : UICollectionViewLayout
@property (assign) NSInteger pageCount;
@property (assign) NSInteger currentPage;

- (instancetype)init;
@end
