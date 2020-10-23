//
//  StreamFileCollectionViewCell.h
//  RtmpClientTest
//
//  Created by Max on 2020/10/12.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreamFileCollectionViewCell : UICollectionViewCell

@property (weak) IBOutlet UILabel *fileNameLabel;
@property (weak) IBOutlet UIImageView *fileImageView;

+ (NSString *)cellIdentifier;
- (void)reset;

@end
