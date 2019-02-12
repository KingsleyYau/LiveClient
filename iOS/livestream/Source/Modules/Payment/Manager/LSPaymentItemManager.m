//
//  PaymentItemManager.m
//  dating
//
//  Created by  Samson on 31/05/2018.
//  Copyright © 2018 qpidnetwork. All rights reserved.
//  AppStore支付信息管理器，用于管理AppStore支付完成(包括成功和失败)，但提交我司接口未成功的订单，信息将在本地用文件保存

#import "LSPaymentItemManager.h"

@interface LSPaymentItemManager()
// 待提交我司的订单信息队列
@property (nonatomic, strong) NSMutableArray<LSPaymentItem*>* itemArray;

// 队列保存到文件
- (BOOL)saveToFile;
// 队列从文件读出
- (void)readFromFile;
// 获取文件路径
- (NSString*)getFilePath;

// 不保存文件插入信息
- (BOOL)insertWithoutSave:(LSPaymentItem* _Nonnull)item;
@end

@implementation LSPaymentItemManager
/**
 *  初始化
 *
 *  @return this
 */
- (id)init
{
    self = [super init];
    if (nil != self) {
        // 初始化数据
        self.itemArray = [NSMutableArray array];
        // 从文件读出数据
        [self readFromFile];
    }
    return self;
}

/**
 *  插入待提交我司订单信息
 *
 *  @param item 订单信息
 *
 *  @return 是否成功(仅当订单号已存在时失败)
 */
- (BOOL)insert:(LSPaymentItem* _Nonnull)item
{
    BOOL result = YES;
    @synchronized (self.itemArray) {
        // 判断订单信息是否已存在
        for (LSPaymentItem *theItem in self.itemArray) {
            if (theItem.orderNo == item.orderNo) {
                result = NO;
                break;
            }
        }
        
        if (result) {
            // 插入队列
            [self.itemArray addObject:item];
            // 保存文件
            [self saveToFile];
        }
    }
    return result;
}

/**
 *  不保存文件插入待提交我司订单信息
 *
 *  @param item 订单信息
 *
 *  @return 是否成功(仅当订单号已存在时失败)
 */
- (BOOL)insertWithoutSave:(LSPaymentItem* _Nonnull)item
{
    BOOL result = YES;
    @synchronized (self.itemArray) {
        // 判断订单信息是否已存在
        for (LSPaymentItem *theItem in self.itemArray) {
            if (theItem.orderNo == item.orderNo) {
                result = NO;
                break;
            }
        }
        
        if (result) {
            // 插入队列
            [self.itemArray addObject:item];
        }
    }
    return result;
}

/**
 *  移除待提交我司订单信息
 *
 *  @param orderNo  订单号
 *
 *  @return 是否成功(仅当订单号不存在时失败)
 */
- (void)remove:(NSString* _Nonnull)orderNo
{
    BOOL result = NO;
    @synchronized (self.itemArray) {
        // 移除数据
        NSUInteger index = 0;
        for (LSPaymentItem *theItem in self.itemArray) {
            if (theItem.orderNo == orderNo) {
                [self.itemArray removeObjectAtIndex:index];
                result = YES;
                break;
            }
            index++;
        }
        
        // 移除成功则保存文件
        if (result) {
            [self saveToFile];
        }
    }
}

/**
 *  移除待提交我司订单信息
 *
 *  @param orderNo  订单号
 *
 *  @return 是否成功(仅当订单号不存在时失败)
 */
- (NSArray<LSPaymentItem*>* _Nonnull)getArray
{
    return self.itemArray;
}

#pragma - 文件处理
// 队列保存到文件
- (BOOL)saveToFile
{
    BOOL result = NO;
    @synchronized (self.itemArray) {
        // 把PaymentItem解析为基础类型
        NSMutableArray *testArray = [NSMutableArray array];
        for (LSPaymentItem *item in self.itemArray) {
            NSDictionary *itemDictionary = [item getDictionary];
            if (nil != itemDictionary) {
                [testArray addObject:itemDictionary];
            }
        }
        
        // 写文件
        NSString *filePath = [self getFilePath];
        result = [testArray writeToFile:filePath atomically:YES];
    }
    
    return result;
}
// 队列从文件读出
- (void)readFromFile
{
    @synchronized (self.itemArray) {
        // 从文件读取数据
        NSString *filePath = [self getFilePath];
        NSArray *dataArray = [NSArray arrayWithContentsOfFile:filePath];
        
        // 读取成功，解析为PaymentItem
        if (nil != dataArray) {
            // 清除当前数据(以文件数据为准)
            [self.itemArray removeAllObjects];
            
            // 读取成功，解析为PaymentItem
            for (id dict in dataArray) {
                if (nil != dict && [dict isKindOfClass:[NSDictionary class]]) {
                    LSPaymentItem *item = [LSPaymentItem paymentItemWithDictionary:dict];
                    if (nil != item) {
                        [self insertWithoutSave:item];
                    }
                }
            }
        }
    }
}

// 获取文件路径
- (NSString*)getFilePath
{
    //获取路径对象
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //获取完整路径
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"tosubmit_order"];
    
    return filePath;
}
@end
