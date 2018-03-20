//
//  MyRidesCell.h
//  livestream
//
//  Created by Calvin on 17/10/16.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"

@protocol MyRidesCellDelegate <NSObject>

- (void)myRidesBtnDid:(NSInteger)row;

@end

@interface MyRidesCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *ridesBtn;
@property (weak, nonatomic) IBOutlet UIView *unreadView;
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (nonatomic, weak) id<MyRidesCellDelegate> delegate;

+ (NSString *)cellIdentifier;

- (void)setRidesBtnBG:(BOOL)isRides;

- (NSString *)getTime:(NSInteger)time;
@end
