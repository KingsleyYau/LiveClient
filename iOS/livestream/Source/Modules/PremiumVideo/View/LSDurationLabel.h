//
//  LSDurationLabel.h
//  livestream
//
//  Created by Albert on 2020/8/4.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSDurationLabel : UIView

-(void)setText:(NSString *)text;
-(void)setFont:(UIFont *)font;

-(void)setDuration:(int)duration;

@end

NS_ASSUME_NONNULL_END
