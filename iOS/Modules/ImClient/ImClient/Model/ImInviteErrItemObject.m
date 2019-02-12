//
//  ImInviteErrItemObject.m
//  livestream
//
//  Created by Max on 2017/9/4.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ImInviteErrItemObject.h"

@implementation ImInviteErrItemObject

- (id)init {
    if( self = [super init] ) {

        self.status = IMCHATONLINESTATUS_OFF;;
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        self.status = [coder decodeIntForKey:@"status"];
        self.priv = [coder decodeObjectForKey:@"priv"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.status forKey:@"status"];
    [coder encodeObject:self.priv forKey:@"priv"];
}


@end
