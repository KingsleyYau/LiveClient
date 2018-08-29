//
//  SelectForGiftView.h
//  livestream
//
//  Created by Randy_Fan on 2018/5/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelecterModel : NSObject
@property (nonatomic, strong) NSString *anchorId;
@property (nonatomic, strong) NSString *anchorName;
@property (strong, nonatomic) NSMutableArray *urls;
@end

@class SelectForGiftView;
@protocol SelectForGiftViewDelegate <NSObject>
- (void)selectTheSender:(SelecterModel *)model;
@end

@interface SelectForGiftView : UIView

@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@property (weak, nonatomic) IBOutlet UIImageView *anchorImageView;

@property (weak, nonatomic) IBOutlet UIImageView *allImageViewOne;

@property (weak, nonatomic) IBOutlet UIImageView *allImageViewTwo;

@property (weak, nonatomic) IBOutlet UIImageView *allImageViewThree;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headViewTwoY;
@property (weak, nonatomic) id<SelectForGiftViewDelegate> delegate;

- (void)showViewUpdate:(SelecterModel *)model;

@end
