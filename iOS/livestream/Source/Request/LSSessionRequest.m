//
//  LSSessionRequest.m
//  dating
//
//  Created by Max on 16/3/28.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@implementation LSSessionRequest

- (id)init {
    if( self = [super init] ) {
        self.manager = [LSRequestManager manager];
        self.isHandleAlready = NO;
    }
    return self;
}

- (BOOL)sendRequest {
    return NO;
}

- (void)callRespond:(BOOL)success errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString* _Nullable)errmsg {
    [self finishRequest];
}

- (void)finishRequest {
    if( [self.delegate respondsToSelector:@selector(requestFinish:)] ) {
        [self.delegate requestFinish:self];
    }
}

@end
