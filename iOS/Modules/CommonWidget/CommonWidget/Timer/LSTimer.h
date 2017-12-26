//
//  LSTimer.h
//  CommonWidget
//
//  Created by Max on 2017/11/24.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSTimer : NSObject
- (void)startTimer:(dispatch_queue_t)queue timeInterval:(uint64_t)timeInterval starNow:(BOOL)starNow action:(dispatch_block_t)action;
- (void)stopTimer;
@end
