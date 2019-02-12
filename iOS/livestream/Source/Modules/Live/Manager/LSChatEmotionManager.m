//
//  LSChatEmotionManager.m
//  livestream
//
//  Created by randy on 2017/8/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSChatEmotionManager.h"
#import "LiveBundle.h"
#import "GetEmoticonListRequest.h"
#import "LSLoginManager.h"
#import <YYText.h>
@interface LSChatEmotionManager ()<LoginManagerDelegate>
/**
 *  接口管理器
 */
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;

@property (nonatomic, strong) LSLoginManager *loginManager;

@property (nonatomic, assign) BOOL isFirstLogin;

@end

@implementation LSChatEmotionManager

+ (instancetype)emotionManager {
    
    static LSChatEmotionManager *chatEmotionManager = nil;
    if (chatEmotionManager == nil) {
        chatEmotionManager = [[LSChatEmotionManager alloc] init];
    }
    return chatEmotionManager;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.loginManager = [LSLoginManager manager];
        [self.loginManager addDelegate:self];
        self.sessionManager = [LSSessionRequestManager manager];
        self.emotionDict = [[NSMutableDictionary alloc] init];
        self.stanEmotionList = [[NSMutableArray alloc] init];
        self.advanEmotionList = [[NSMutableArray alloc] init];
        self.imageNameArray = [[NSMutableArray alloc] init];
        self.stanListItem = [[ChatEmotionListItem alloc] init];
        self.advanListItem = [[ChatEmotionListItem alloc] init];
        self.isFirstLogin = YES;
    }
    return self;
}

// 监听HTTP登录
- (void)manager:(LSLoginManager *)manager onLogin:(BOOL)success loginItem:(LSLoginItemObject *)loginItem errnum:(HTTP_LCC_ERR_TYPE)errnum errmsg:(NSString *)errmsg {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            
            if (self.isFirstLogin) {
                [self requestEmotionList];
            }
        }
    });
}

// 请求聊天表情
- (void)requestEmotionList {
    GetEmoticonListRequest *request = [[GetEmoticonListRequest alloc] init];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg,
                              NSArray<EmoticonItemObject *> * _Nullable item) {
        dispatch_async(dispatch_get_main_queue(), ^{
           
            if (success) {
                
                for (int i = 0; i < item.count; i++) {
                    EmoticonItemObject *object = item[i];
                    ChatEmotionListItem *listItem = [[ChatEmotionListItem alloc] init];
                    listItem.type = object.type;
                    listItem.name = object.name;
                    listItem.errMsg = object.errMsg;
                    listItem.emoUrl = object.emoUrl;
                    
                    NSMutableArray *emoMutableList = [[NSMutableArray alloc] init];
                    for (EmoticonInfoItemObject *infoItem in object.emoList) {
                        ChatEmotionItem *emoItem = [[ChatEmotionItem alloc] init];
                        emoItem.emoId = infoItem.emoId;
                        emoItem.emoSign = infoItem.emoSign;
                        emoItem.emoUrl = infoItem.emoUrl;
                        emoItem.emoIconUrl = infoItem.emoIconUrl;
                        [emoMutableList addObject:emoItem];
                    }
                    listItem.emoList = emoMutableList;
                    
                    if (object.type == 0) {
                        self.stanListItem = listItem;
                        [self downloadStandardEmoticon];
                        
                    } else {
                        self.advanListItem = listItem;
                        [self downloadAdvancedEmoticon];
                    }
                }
                self.isFirstLogin = NO;
                
            } else {
                self.isFirstLogin = YES;
            }
            
        });
    };
    [self.sessionManager sendRequest:request];
}

#pragma mark - 下载Standard表情图
- (void)downloadStandardEmoticon {
    // Standard icont图
    [self downLoadListEmotionWithItem:nil andUrl:self.stanListItem.emoUrl emotionType:self.stanListItem.type index:0];
    
    // Standard 表情图
    for (int i = 0; i < self.stanListItem.emoList.count; i++) {
        ChatEmotionItem *emoItem = self.stanListItem.emoList[i];
        [self downLoadListEmotionWithItem:emoItem andUrl:emoItem.emoIconUrl emotionType:self.stanListItem.type index:i];
        
        LSChatEmotion* emotion = [[LSChatEmotion alloc] init];
        emotion.text = emoItem.emoSign;
        [self.stanEmotionList addObject:emotion];
    }
}

#pragma mark - 下载Advanced表情图
- (void)downloadAdvancedEmoticon {
    // Advanced icont图
    [self downLoadListEmotionWithItem:nil andUrl:self.advanListItem.emoUrl emotionType:self.advanListItem.type index:0];
    
    // Advanced 表情图
    for (int i = 0; i < self.advanListItem.emoList.count; i++) {
        ChatEmotionItem *emoItem = self.advanListItem.emoList[i];
        [self downLoadListEmotionWithItem:emoItem andUrl:emoItem.emoIconUrl emotionType:self.advanListItem.type index:i];
        
        LSChatEmotion* emotion = [[LSChatEmotion alloc] init];
        emotion.text = emoItem.emoSign;
        [self.advanEmotionList addObject:emotion];
    }
}


- (void)downLoadListEmotionWithItem:(ChatEmotionItem *)item andUrl:(NSString *)url emotionType:(EmoticonType)type index:(NSInteger)index {
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        if ( image ) {
//            NSLog(@"LSChatEmotionManager::downLoadListEmotionWithUrl( emotionURL : %@ )", imageURL);
            
            if ( item ) {
                LSChatEmotion* emotion = [[LSChatEmotion alloc] initWithTextImage:item.emoSign image:image];
                [self.imageNameArray addObject:emotion.text];
                [self.emotionDict setObject:emotion forKey:emotion.text];
                if (type == EMOTICONTYPE_STANDARD) {
                    
                    for (LSChatEmotion *chatEmotion in self.stanEmotionList) {
                        if ([chatEmotion.text isEqualToString:emotion.text]) {
                            chatEmotion.image = emotion.image;
                            
                            if ( [self.delegate respondsToSelector:@selector(downLoadStanListFinshHandle:)] ) {
                                [self.delegate downLoadStanListFinshHandle:index];
                            }
                        }
                    }
                } else {
                    for (LSChatEmotion *chatEmotion in self.advanEmotionList) {
                        if ([chatEmotion.text isEqualToString:emotion.text]) {
                            chatEmotion.image = emotion.image;
                            
                            if ( [self.delegate respondsToSelector:@selector(downLoadAdvanListFinshHandle:)] ) {
                                [self.delegate downLoadAdvanListFinshHandle:index];
                            }
                        }
                    }
                }
            }
        }
    }];
}

/**
 *  解析消息表情和文本消息 (弹幕用)
 *
 *  @param text 普通文本消息
 *  @param font        字体
 *  @return 表情富文本消息
 */
- (NSAttributedString *)parseMessageTextEmotion:(NSString *)text font:(UIFont *)font {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSRange strRange;
    NSAttributedString* emotionAttString = nil;
    LSChatTextAttachment *attachment = nil;
    
    // 替换img
    for (int i = 0; i < self.imageNameArray.count; i++) {
        
        NSString *str = self.imageNameArray[i];
        while ([text containsString:str]) {
            
            strRange = [text rangeOfString:str];
            // 增加表情文本
            attachment = [[LSChatTextAttachment alloc] init];
            attachment.bounds = CGRectMake(0, -4, font.lineHeight, font.lineHeight);
            LSChatEmotion* emotion = [self.emotionDict objectForKey:str];
            if( emotion != nil ) {
                attachment.image = emotion.image;
            }
            attachment.text = str;
            // 生成表情富文本
            emotionAttString = [NSAttributedString attributedStringWithAttachment:attachment];
            [attributeString replaceCharactersInRange:strRange withAttributedString:emotionAttString];
            // 替换查找文本
            text = attributeString.string;
        }
        
    }
    [attributeString addAttributes:@{NSFontAttributeName : font} range:NSMakeRange(0, attributeString.length)];
    
    return attributeString;
}

/**
 输入表情替换成转义符 (聊天列表用)
 
 @param text 输入文字
 @param font 字体大小
 @return 拼接表情文字
 */
- (NSMutableAttributedString *)parseMessageAttributedTextEmotion:(NSMutableAttributedString *)text font:(UIFont *)font {
    
    NSRange strRange;
    
    // 替换img
    for (int i = 0; i < self.imageNameArray.count; i++) {
        
        NSString *str = self.imageNameArray[i];
        while ([text.string containsString:str]) {
            
            strRange = [text.string rangeOfString:str];
            LSChatEmotion* emotion = [self.emotionDict objectForKey:str];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:emotion.image];
            imageView.frame = CGRectMake(0, 0, 21, 21);
            
//            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
//            attachment.image = emotion.image;
//            attachment.bounds = CGRectMake(0, -4, font.lineHeight, font.lineHeight);
//
//            // 生成表情富文本
            NSMutableAttributedString *imageString = [NSMutableAttributedString yy_attachmentStringWithContent:imageView contentMode:UIViewContentModeCenter attachmentSize:imageView.frame.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
            
            // 生成表情富文本
//            NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:attachment];
            // 生成表情富文本
            [text replaceCharactersInRange:strRange withAttributedString:imageString];
        }
    }
    return text;
}

- (UIImage *)image:(UIImage*)image byScalingToSize:(CGSize)targetSize {
    UIImage *sourceImage = image;
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = CGPointZero;
    thumbnailRect.size.width  = targetSize.width;
    thumbnailRect.size.height = targetSize.height;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage ;
}

/*********************** 测试数据 ***************************/
#pragma mark - 表情逻辑
/** 加载普通表情 */ // 下载表情及加载
- (void)reloadEmotion {
    // 读取表情配置文件
    NSString *emotionPlistPath = [[LiveBundle mainBundle] pathForResource:@"EmotionList" ofType:@"plist"];
    NSArray* emotionFileArray = [[NSArray alloc] initWithContentsOfFile:emotionPlistPath];
    
    // 初始化普通表情文件名字
    NSMutableArray* emotionArray = [NSMutableArray array];
    NSMutableDictionary* emotionDict = [NSMutableDictionary dictionary];
    NSMutableArray *imageNameArray = [NSMutableArray array];
    
    LSChatEmotion* emotion = nil;
    UIImage* image = nil;
    NSString* imageFileName = nil;
    NSString* imageName = nil;
    
    for(NSDictionary* dict in emotionFileArray) {
        imageFileName = [dict objectForKey:@"name"];
        image = [UIImage imageNamed:imageFileName];
        if( image != nil ) {
            imageName = [self parseEmotionTextByImageName:imageFileName];
            emotion = [[LSChatEmotion alloc] initWithTextImage:imageName image:image];
            
            [emotionDict setObject:emotion forKey:imageName];
            [emotionArray addObject:emotion];
            [imageNameArray addObject:imageName];
        }
    }
    
    self.emotionDict = emotionDict;
    //    self.emotionArray = emotionArray;
    self.imageNameArray = imageNameArray;
    //    self.chatMessageObject.emotionArray  = emotionArray;
}

#pragma mark - 消息列表文本解析
/**
 *  根据表情文件名字生成表情协议名字
 *
 *  @param imageName 表情文件名字
 *
 *  @return 表情协议名字
 */
- (NSString* )parseEmotionTextByImageName:(NSString* )imageName {
    NSMutableString* resultString = [NSMutableString stringWithString:imageName];
    
    NSRange range = [resultString rangeOfString:@"img"];
    if( range.location != NSNotFound ) {
        [resultString replaceCharactersInRange:range withString:@"[img:"];
        [resultString appendString:@"]"];
    }
    
    return resultString;
}
/********************************************************/


@end
