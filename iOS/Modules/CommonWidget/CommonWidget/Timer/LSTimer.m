//
//  LSTimer.m
//  CommonWidget
//
//  Created by Max on 2017/11/24.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "LSTimer.h"
@interface LSTimer()
@property (strong) dispatch_source_t timer;
@end

@implementation LSTimer
- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)startTimer:(dispatch_queue_t)queue timeInterval:(uint64_t)timeInterval starNow:(BOOL)starNow action:(dispatch_block_t)action {
    [self stopTimer];
    
    dispatch_queue_t timerQueue = queue;
    if( !timerQueue ) {
        timerQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timerQueue);
    dispatch_time_t startTime = starNow?DISPATCH_TIME_NOW:dispatch_time(DISPATCH_TIME_NOW, timeInterval);
    dispatch_source_set_timer(self.timer, startTime, timeInterval, NSEC_PER_MSEC);
    dispatch_source_set_event_handler(self.timer, action);
    dispatch_resume(self.timer);
}

- (void)stopTimer {
    if( self.timer ) {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
    }
}

@end
