//
//  LSScheduleListTopTypeView.m
//  livestream
//
//  Created by Calvin on 2020/4/15.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleListTopTypeView.h"

@interface LSScheduleListTopTypeView ()

@end

@implementation LSScheduleListTopTypeView

- (instancetype)init {
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSScheduleListTopTypeView" owner:self options:0].firstObject;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}
 

@end
