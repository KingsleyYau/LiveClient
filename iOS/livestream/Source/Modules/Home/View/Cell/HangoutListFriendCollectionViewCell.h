//
//  HangoutListFriendCollectionViewCell.h
//  livestream
//
//  Created by test on 2019/2/28.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
@class HangoutListFriendCollectionViewCell;
@protocol HangoutListFriendCollectionViewCellDelegate <NSObject>
@optional
- (void)hangoutListFriendCollectionViewCell:(HangoutListFriendCollectionViewCell *)cell didSelectIndex:(NSInteger)index;
@end

@interface HangoutListFriendCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) IBOutlet LSUIImageViewTopFit *imageView;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (weak, nonatomic) id<HangoutListFriendCollectionViewCellDelegate> friendCellDelegate;
+ (NSString *)cellIdentifier;
//- (void)setHighlightButtonTag:(NSInteger)tag;
@end
