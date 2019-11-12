//
//  LSChatNameView.h
//  livestream
//
//  Created by Randy_Fan on 2019/8/29.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSChatNameView : UIView

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

+ (CGFloat)viewWidth:(CGFloat)textWidth;

@end

NS_ASSUME_NONNULL_END
