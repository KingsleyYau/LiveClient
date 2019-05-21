//
//  LSSayHiChooseView.h
//  livestream
//
//  Created by Calvin on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSSayHiChooseViewDelegate <NSObject>

- (void)sayHiChooseViewSelected:(BOOL)isUnread;

@end


@interface LSSayHiChooseView : UIView
@property (weak, nonatomic) IBOutlet UIView *chooseBGView;
@property (weak, nonatomic) IBOutlet UIButton *unreadBtn;
@property (weak, nonatomic) IBOutlet UIButton *lastBtn;
@property (nonatomic, assign) BOOL isSelectedUnread;
@property (weak, nonatomic) id<LSSayHiChooseViewDelegate> delegate;
@end

