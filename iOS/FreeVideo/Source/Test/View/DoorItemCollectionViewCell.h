//
//  DoorItemCollectionViewCell.h
//  livestream
//
//  Created by Created by Max on 16/2/15.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LSImageViewLoader.h"

@interface DoorItemCollectionViewCell : UICollectionViewCell

@property (weak) IBOutlet LSUIImageViewTopFit *imageViewHeader;
@property (strong) LSImageViewLoader *imageViewLoader;

@property (weak) IBOutlet UIImageView *onlineImageView;
@property (weak) IBOutlet UILabel *labelRoomTitle;
@property (assign) BOOL selectCell;

/**
 Cell标识

 @return Cell标识
 */
+ (NSString *)cellIdentifier;

- (void)reset;

@end
