//
//  LSSayHiDetailHeadView.h
//  livestream
//
//  Created by Calvin on 2019/4/18.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSSayHiDetailItemObject.h"
#import "LSImageViewLoader.h"
@protocol LSSayHiDetailHeadViewDelegate <NSObject>

- (void)sayHiDetailHeadViewDidNoteBtn;

@end

@interface LSSayHiDetailHeadView : UIView 
@property (weak, nonatomic) IBOutlet UIImageView *ladyHead;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *noteBtn;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *bgImage;
@property (nonatomic, strong) LSImageViewLoader * imageLoader;
@property (nonatomic, strong) LSImageViewLoader *backgroundImageloader;
@property (weak, nonatomic) id<LSSayHiDetailHeadViewDelegate> delegate;

- (void)loadData:(LSSayHiDetailItemObject*)obj;
@end


