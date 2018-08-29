//
//  LSHighlightedButton.m
//  livestream
//
//  Created by Max on 2018/5/17.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSHighlightedButton.h"

@implementation LSHighlightedButton

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.highlighted = YES;
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.highlighted = NO;
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.highlighted = NO;
    [super touchesCancelled:touches withEvent:event];
}
@end
