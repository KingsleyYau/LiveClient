//
//  ChatEmotionCreditsCollectionViewLayout.h
//  dating
//
//  Created by lance on 16/9/9.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ChatEmotionCreditsCollectionViewLayout : UICollectionViewLayout
@property (assign, nonatomic) NSInteger pageCount;
@property (nonatomic,assign) NSInteger currentPage;

- (instancetype)init;
@end
