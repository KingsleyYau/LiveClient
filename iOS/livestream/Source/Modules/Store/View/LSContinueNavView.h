//
//  LSContinueNavView.h
//  livestream
//
//  Created by Calvin on 2019/10/12.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSContinueNavViewDelegate <NSObject>

- (void)continueNavViewCheckoutBtnDid;

@end


@interface LSContinueNavView : UIView

@property (weak, nonatomic) IBOutlet LSBadgeButton *checkoutBtn;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) id<LSContinueNavViewDelegate> delegate;

- (void)setName:(NSString *)name andHeadImage:(NSString *)imageUrl;
@end
 
