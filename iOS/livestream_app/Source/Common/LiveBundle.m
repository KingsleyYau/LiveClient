//
//  LiveBundle.m
//  livestream
//
//  Created by Max on 2017/10/13.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LiveBundle.h"

@implementation LiveBundle
+ (void)gobalInit {
    NSLog(@"LiveBundle::gobalInit( Product Bundle Identifier : %@ )", DEF_PRODUCT_BUNDLE_IDENTIFIER);
    [LSUIWidgetBundle setBundle:[LiveBundle mainBundle]];
}

+ (NSBundle *)mainBundle {
    NSBundle *bundle = [NSBundle bundleWithIdentifier:DEF_PRODUCT_BUNDLE_IDENTIFIER];
    if( !bundle ) {
        bundle = [super mainBundle];
    }
    return bundle;
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName {
    return [[LiveBundle mainBundle] localizedStringForKey:key value:value table:tableName];
}

@end
