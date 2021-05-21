//
//  OCTimer.h
//  Cartoon
//
//  Created by Max on 2021/5/7.
//

#import <Foundation/Foundation.h>

@interface OCTimer : NSObject
- (void)startTimer:(dispatch_queue_t)queue timeInterval:(uint64_t)timeInterval starNow:(BOOL)starNow action:(dispatch_block_t)action;
- (void)stopTimer;
@end
