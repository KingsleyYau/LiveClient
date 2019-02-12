//
//  LSSendMailDraftManager.m
//  livestream
//
//  Created by Calvin on 2018/12/24.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSSendMailDraftManager.h"
#import "LSLoginManager.h"
#define LSMAILDRAFTNAME @"SendMailText_"

static LSSendMailDraftManager *sendMailDraftManager = nil;

@implementation LSSendMailDraftManager


+ (instancetype)manager {
    if (sendMailDraftManager == nil) {
        sendMailDraftManager = [[[self class] alloc] init];
    }
    return sendMailDraftManager;
}

- (void)initMailDraftLadyId:(NSString *)ladyId name:(NSString *)name {
    self.isEdit = NO;
    NSString * contentKey =[NSString stringWithFormat:@"%@%@_%@",LSMAILDRAFTNAME,ladyId,[LSLoginManager manager].loginItem.userId];
    if (![[NSUserDefaults standardUserDefaults]objectForKey:contentKey]) {
        NSString * content = [NSString stringWithFormat:@"Dear %@,\n",name];
        [[NSUserDefaults standardUserDefaults]setObject:content forKey:contentKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)isShowDraftDialogLadyId:(NSString *)ladyId name:(NSString *)ladyName content:(NSString *)text {
    
    if (!self.isEdit || [text isEqualToString:[self getDraftContent:ladyId]]) {
        return NO;
    }else {
        return YES;
    }
}

- (NSString *)getDraftContent:(NSString *)ladyId {
    
    NSString * contentStr = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@_%@",LSMAILDRAFTNAME,ladyId,[LSLoginManager manager].loginItem.userId]];
    return contentStr;
}

- (void)saveMailDraftFromLady:(NSString *)ladyId content:(NSString *)text {
    
     [[NSUserDefaults standardUserDefaults] setObject:text forKey:[NSString stringWithFormat:@"%@%@_%@",LSMAILDRAFTNAME,ladyId,[LSLoginManager manager].loginItem.userId]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)deleteMailDraft:(NSString *)ladyId {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:[NSString stringWithFormat:@"%@%@_%@",LSMAILDRAFTNAME,ladyId,[LSLoginManager manager].loginItem.userId]];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end
