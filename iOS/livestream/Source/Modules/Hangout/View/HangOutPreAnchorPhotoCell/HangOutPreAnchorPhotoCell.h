//
//  HangOutPreAnchorPhotoCell.h
//  livestream
//
//  Created by Randy_Fan on 2019/1/18.
//  Copyright © 2019年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImManager.h"

@interface HangOutPreAnchorPhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

- (void)setupCellDate:(IMLivingAnchorItemObject *)item;

+ (NSString *)cellIdentifier;

@end
