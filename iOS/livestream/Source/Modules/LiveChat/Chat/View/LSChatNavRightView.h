//
//  LSChatNavRightView.h
//  livestream
//
//  Created by Calvin on 2020/4/11.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

 
@interface LSChatNavRightView : UIView 
@property (weak, nonatomic) IBOutlet UIButton *endChatBtn;
@property (weak, nonatomic) IBOutlet UIButton *schedleBtn;
@property (weak, nonatomic) IBOutlet UIButton *recentBtn;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UILabel *chatLabel;
- (void)updateCount:(NSInteger)count;
@end
 
