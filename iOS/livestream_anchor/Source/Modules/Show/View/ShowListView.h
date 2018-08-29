//
//  ShowListView.h
//  livestream
//
//  Created by Calvin on 2018/4/23.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
#import "LSUIImageViewTopFit.h"
#import "LSAnchorProgramItemObject.h"
@protocol ShowListViewDelegate <NSObject>
 
- (void)showListViewBtnDidFromItem:(LSAnchorProgramItemObject *)item;

@end

@interface ShowListView : UIView 

@property (weak, nonatomic) id<ShowListViewDelegate> delegates;

@property (weak, nonatomic) IBOutlet UIView *onGingView;
@property (weak, nonatomic) IBOutlet UILabel *onGingLabel;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *showBGView;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UILabel *dataLabel;
@property (weak, nonatomic) IBOutlet UILabel *minLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *onGingIcon;
@property (nonatomic, strong) LSImageViewLoader * imageViewLoader;
@property (nonatomic, strong) LSImageViewLoader * bgImageViewLoader;
- (void)updateUI:(LSAnchorProgramItemObject *)item;
- (void)updateHistoryUI:(LSAnchorProgramItemObject *)item;
@end
