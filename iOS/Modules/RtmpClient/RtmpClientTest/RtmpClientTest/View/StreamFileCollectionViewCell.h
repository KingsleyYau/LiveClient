//
//  StreamFileCollectionViewCell.h
//  livestream
//
//  Created by Created by Max on 16/2/15.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreamFileCollectionViewCell : UICollectionViewCell

@property (weak) IBOutlet UILabel *fileNameLabel;
@property (weak) IBOutlet UIImageView *fileImageView;

+ (NSString *)cellIdentifier;
- (void)reset;

@end
