//
//  SelectAnchorSendCell.h
//  livestream
//
//  Created by Randy_Fan on 2019/2/13.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectAnchorSendCell : UICollectionViewCell

+ (NSString *)cellIdentifier;

- (void)setupDate:(NSString *)url index:(NSInteger)index;

- (void)foreverAnimation:(CABasicAnimation *)group;

- (void)changeSelect:(BOOL)isSelect;

- (BOOL)getIsSelect;

@end
