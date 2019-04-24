//
//  RecentWatchCollectionViewCell.h
//  livestream
//
//  Created by Randy_Fan on 2019/3/21.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSLiveChatRequestManager.h"

@interface RecentWatchCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@property (weak, nonatomic) IBOutlet UILabel *representLabel;

+ (NSString *)cellIdentifier;

+ (id)getUICollectionViewCell:(UICollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

- (void)setupCellContent:(LSLCRecentVideoItemObject *)item;

@end
