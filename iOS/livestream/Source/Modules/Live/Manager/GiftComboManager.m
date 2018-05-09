//
//  GiftComboManager.m
//  livestream
//
//  Created by Max on 2017/6/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "GiftComboManager.h"

@interface GiftComboManager ()
@property (strong) NSMutableDictionary* dictionary;
@property (strong) NSMutableArray *itemIdArray;
@end

@implementation GiftComboManager
- (id)init {
    if( self = [super init] ) {
        self.dictionary = [NSMutableDictionary dictionary];
        self.itemIdArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self.dictionary removeAllObjects];
    [self.itemIdArray removeAllObjects];
}

- (void)removeManager{
    [self.itemIdArray removeAllObjects];
    [self.dictionary removeAllObjects];
    self.dictionary = nil;
    self.itemIdArray = nil;
}

- (GiftItem *)popGift:(NSString * _Nullable)itemId {
    GiftItem* findItem = nil;
    
    @synchronized (self) {
        if( [self.dictionary count] > 0 ) {
            if( itemId.length > 0 ) {
                findItem = [self.dictionary objectForKey:itemId];
                if( findItem ) {
                    [self.dictionary removeObjectForKey:itemId];
                }
            }
            
            if( !findItem ) {
                NSString *itemId = nil;
                if (self.itemIdArray.count) {
                    itemId = self.itemIdArray.firstObject;
                    [self.itemIdArray removeObjectAtIndex:0];
                }
                
                NSString* key = [[self.dictionary allKeys] firstObject];
                if (itemId) {
                    key = itemId;
                }
                findItem = [self.dictionary objectForKey:key];
                [self.dictionary removeObjectForKey:key];
            }
        }
    }
    
    return findItem;
}

- (void)pushGift:(GiftItem *_Nonnull)item {
    if( item.itemId.length > 0 ) {
        @synchronized (self) {
            NSLog(@"item.itemid%@",item.itemId);
            GiftItem* findItem = [self.dictionary objectForKey:item.itemId];
            if( findItem ) {
                if( item.multi_click_end > findItem.multi_click_end ) {
                    findItem.multi_click_end = item.multi_click_end;
                }
            } else {
                [self.itemIdArray addObject:item.itemId];
                [self.dictionary setObject:item forKey:item.itemId];
            }
        }
    }
}

@end

