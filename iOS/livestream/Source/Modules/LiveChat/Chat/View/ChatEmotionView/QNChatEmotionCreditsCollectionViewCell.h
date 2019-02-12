//
//  ChatEmotionCreditsCollectionViewCell.h
//  dating
//
//  Created by test on 16/9/9.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QNChatEmotionCreditsCollectionViewCell;
@protocol ChatEmotionCreditsCollectionViewCellDelegate <NSObject>
@optional
- (void)ChatEmotionCreditsCollectionViewCellDidLongPress:(QNChatEmotionCreditsCollectionViewCell *)cell gesture:(UILongPressGestureRecognizer *)gesture;
@end



@interface QNChatEmotionCreditsCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *creditPrice;
@property (weak, nonatomic) IBOutlet UIImageView *largeEmotionImageView;

/** 代理 */
@property (nonatomic,weak) id<ChatEmotionCreditsCollectionViewCellDelegate> delegate;

+ (NSString *)cellIdentifier;

@end
