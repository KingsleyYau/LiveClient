//
//  LSTypeSegment.h
//  livestream
//
//  Created by test on 2020/4/3.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSegmentItem.h"

NS_ASSUME_NONNULL_BEGIN
@protocol LSTypeSegmentDelegate <NSObject>

- (void)segmentControlSelectedTag:(NSInteger)tag;

@end

@interface LSTypeSegment : UIView

@property (nonatomic, weak) id<LSTypeSegmentDelegate> delegate;

- (void)selectButtonTag:(NSInteger)tag;

- (instancetype)initWithNumberOfTitles:(NSArray *)titles andFrame:(CGRect)frame andSetting:(LSSegmentItem *)item delegate:(id<LSTypeSegmentDelegate>)delegate isSymmetry:(BOOL)isSymmetry ;
@end

NS_ASSUME_NONNULL_END
