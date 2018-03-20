//
//  CrashLogManager.m
//  dating
//
//  Created by test on 16/6/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "CrashLogManager.h"
#import "LSLoginManager.h"
#import "LSRequestManager.h"
#import "LSFileCacheManager.h"
#import "LSUploadCrashFileRequest.h"
//#include "common/KZip.h"
#import "NSDate+ToString.h"
static CrashLogManager* gManager = nil;
@interface CrashLogManager()<LoginManagerDelegate,UIApplicationDelegate>
{
    NSUncaughtExceptionHandler *_handler;
}


/**
 *  接口管理器
 */
@property (nonatomic, strong) LSSessionRequestManager* sessionManager;
@property (nonatomic, strong) LSLoginManager* loginManager;
@property (nonatomic,strong) LSRequestManager *requestManager;
/** crashLog路径 */
@property (nonatomic,strong) NSString *crashPath;

@end
@implementation CrashLogManager


#pragma mark - 获取实例
+ (instancetype)manager{
    if (gManager == nil) {
        gManager = [[[self class] alloc] init];
    }
    return gManager;
}


- (instancetype)init
{
    if(self = [super init] ) {
        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];
        self.sessionManager = [LSSessionRequestManager manager];
        // 初始化Crash Log捕捉
        _handler = NSGetUncaughtExceptionHandler();
        NSSetUncaughtExceptionHandler(UncaughtExceptionHandler);

        
    }
    
    return self;
}

#pragma mark - 登录
/**
 *  LoginManager登录回调处理
 *
 *  @param manager   LoginManager
 *  @param success   是否成功
 *  @param loginItem 登录item
 *  @param errnum    登录结果code
 *  @param errmsg    登录结果描述
 */
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSManBaseInfoItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg{
    dispatch_async(dispatch_get_main_queue(), ^{
        if( success ) {
            if ( [self checkCrashLogFiles] ) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    //上传崩溃日志
                    [self uploadCrashLog:[[LSFileCacheManager manager] crashLogPath] tmpDirectory:[[LSFileCacheManager manager] tmpPath]];
                });
            }
        }
    });

}






#pragma mark - Crash处理
- (BOOL)logCrashToFile:(NSString *)errorString {
    BOOL bFlag = NO;
    
    // Crash Log写入到文件
    NSDate *curDate = [NSDate date];
    NSString *fileName = [NSString stringWithFormat:@"%@.crash", [curDate toStringCrashZipDate], nil];
    NSString *filePath = [[[LSFileCacheManager manager] crashLogPath] stringByAppendingPathComponent:fileName];
    bFlag = [errorString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
//    if(bFlag) {
//        NSLog(@"CrashLogManager::logCrashToFile( crash log has been save : %@ )", filePath);
//               exit(9);
//    }
//    sleep(1000);
    return bFlag;
}



void UncaughtExceptionHandler(NSException *exception) {
    // Objective-C 异常处理, BAD_ACCESS等错误不能捕捉
    NSArray *stack = [exception callStackReturnAddresses];
    NSArray *symbols = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSMutableString *reportString = [NSMutableString string];
    

    // 设备
    [reportString appendFormat:@"Name = %@\n", [[UIDevice currentDevice] name]];
    [reportString appendFormat:@"Model = %@\n", [CrashLogManager iphoneType]];
    [reportString appendFormat:@"System = %@\n", [[UIDevice currentDevice] systemName]];
    [reportString appendFormat:@"System-Version = %@\n", [[UIDevice currentDevice] systemVersion]];
    [reportString appendFormat:@"UUID = %@\n", [[UIDevice currentDevice] identifierForVendor]];

    // 程序
    [reportString appendFormat:@"CFBundleDisplayName = %@\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
    [reportString appendFormat:@"CFBundleVersion = %@\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    [reportString appendFormat:@"Version = %@\n", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Version"]];
    
    // 原因
    [reportString appendFormat:@"ExecptionName = %@\nReason = %@\n\nSymbols = %@\n\nStack = %@\n", name, reason, symbols, stack];
    
    // Crash Log写入到文件
    [[CrashLogManager manager] logCrashToFile:reportString];
   

}

/** 清除崩溃日志目录 */
- (BOOL)clearCrashLogs{
    NSString *crashPath = [[LSFileCacheManager manager] crashLogPath];
    BOOL success = YES;
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:crashPath];
    for (NSString *fileName in files) {
        
        NSError *error = nil;
        
        NSString *cachPath = [crashPath stringByAppendingPathComponent:fileName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:cachPath]) {
            
            [[NSFileManager defaultManager] removeItemAtPath:cachPath error:&error];
            
            
        }else{
            success = NO;
        }
        
    }
    
    return success;
}

/**
 *  检查是否存在crash文件
 *
 *  @return <#return value description#>
 */
- (BOOL)checkCrashLogFiles {
    NSString *crashPath = [[LSFileCacheManager manager] crashLogPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *array = [manager contentsOfDirectoryAtPath:crashPath error:nil];
    
    return (array.count > 0)?YES:NO;
}

#pragma mark - 上传日志
- (BOOL)uploadCrashLog:(NSString *)srcDirectory tmpDirectory:(NSString *)tmpDirectory {
    LSUploadCrashFileRequest *request = [[LSUploadCrashFileRequest alloc] init];

    request.file = srcDirectory;
    request.tmpDirectory = tmpDirectory;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg){
        if (success) {
            NSLog(@"CrashLogManager::uploadCrashLog( crash log has been upload : 上传崩溃日志成功");
            //上传日志成功,移除本地的崩溃日志
             [self clearCrashLogs];


        }
    };
    return [self.sessionManager sendRequest:request];
}



+ (NSString*)iphoneType {
    
    //需要导入头文件：#import <sys/utsname.h>
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if([platform isEqualToString:@"iPhone1,1"]) return@"iPhone 2G";
    
    if([platform isEqualToString:@"iPhone1,2"]) return@"iPhone 3G";
    
    if([platform isEqualToString:@"iPhone2,1"]) return@"iPhone 3GS";
    
    if([platform isEqualToString:@"iPhone3,1"]) return@"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,2"]) return@"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,3"]) return@"iPhone 4";
    
    if([platform isEqualToString:@"iPhone4,1"]) return@"iPhone 4S";
    
    if([platform isEqualToString:@"iPhone5,1"]) return@"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,2"]) return@"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,3"]) return@"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone5,4"]) return@"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone6,1"]) return@"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone6,2"]) return@"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone7,1"]) return@"iPhone 6 Plus";
    
    if([platform isEqualToString:@"iPhone7,2"]) return@"iPhone 6";
    
    if([platform isEqualToString:@"iPhone8,1"]) return@"iPhone 6s";
    
    if([platform isEqualToString:@"iPhone8,2"]) return@"iPhone 6s Plus";
    
    if([platform isEqualToString:@"iPhone8,4"]) return@"iPhone SE";
    
    if([platform isEqualToString:@"iPhone9,1"]) return@"iPhone 7";
    
    if([platform isEqualToString:@"iPhone9,2"]) return@"iPhone 7 Plus";
    
    if([platform isEqualToString:@"iPhone10,1"]) return@"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,4"]) return@"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,2"]) return@"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,5"]) return@"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,3"]) return@"iPhone X";
    
    if([platform isEqualToString:@"iPhone10,6"]) return@"iPhone X";
    
    if([platform isEqualToString:@"iPod1,1"]) return@"iPod Touch 1G";
    
    if([platform isEqualToString:@"iPod2,1"]) return@"iPod Touch 2G";
    
    if([platform isEqualToString:@"iPod3,1"]) return@"iPod Touch 3G";
    
    if([platform isEqualToString:@"iPod4,1"]) return@"iPod Touch 4G";
    
    if([platform isEqualToString:@"iPod5,1"]) return@"iPod Touch 5G";
    
    if([platform isEqualToString:@"iPad1,1"]) return@"iPad 1G";
    
    if([platform isEqualToString:@"iPad2,1"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,2"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,3"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,4"]) return@"iPad 2";
    
    if([platform isEqualToString:@"iPad2,5"]) return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,6"]) return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,7"]) return@"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad3,1"]) return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,2"]) return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,3"]) return@"iPad 3";
    
    if([platform isEqualToString:@"iPad3,4"]) return@"iPad 4";
    
    if([platform isEqualToString:@"iPad3,5"]) return@"iPad 4";
    
    if([platform isEqualToString:@"iPad3,6"]) return@"iPad 4";
    
    if([platform isEqualToString:@"iPad4,1"]) return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,2"]) return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,3"]) return@"iPad Air";
    
    if([platform isEqualToString:@"iPad4,4"]) return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,5"]) return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,6"]) return@"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,7"]) return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,8"]) return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,9"]) return@"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad5,1"]) return@"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,2"]) return@"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,3"]) return@"iPad Air 2";
    
    if([platform isEqualToString:@"iPad5,4"]) return@"iPad Air 2";
    
    if([platform isEqualToString:@"iPad6,3"]) return@"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,4"]) return@"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,7"]) return@"iPad Pro 12.9";
    
    if([platform isEqualToString:@"iPad6,8"]) return@"iPad Pro 12.9";
    
    if([platform isEqualToString:@"i386"]) return@"iPhone Simulator";
    
    if([platform isEqualToString:@"x86_64"]) return@"iPhone Simulator";
    
    return platform;
    
}


@end
