//
//  ChatEmotionManager.m
//  livestream
//
//  Created by randy on 2017/8/14.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "ChatEmotionManager.h"

@implementation ChatEmotionManager

+ (instancetype)emotionManager {
    
    static ChatEmotionManager *chatEmotionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        chatEmotionManager = [[ChatEmotionManager alloc] init];
        chatEmotionManager.emotionDict = [[NSDictionary alloc] init];
        chatEmotionManager.emotionArray = [[NSArray alloc] init];
        chatEmotionManager.imageNameArray = [[NSArray alloc] init];
    });
    
    return chatEmotionManager;
}


- (void)sendRequestEmotionList{
    
    
}

- (void)downLoadListEmotionWithUrl:(NSString *)url{
    
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    
    [manager loadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
        
    } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        
        if (image) {
            
            
            NSLog(@"ChatEmotionManager::downLoadListEmotionWithUrl( emotionURL : %@ )", imageURL);
        }
        
    }];
}

- (void)getTheEmotionListWithUserID:(NSString *)userID {
    
    
}

- (void)againDownloadTheEmotion {
    
    
}

- (void)sendTheEmotionMessage:(NSString *)userID iconID:(NSString *)iconID {
    
    
}


#pragma mark - 表情逻辑
/** 加载普通表情 */
- (void)reloadEmotion {
    // 读取表情配置文件
    NSString *emotionPlistPath = [[NSBundle mainBundle] pathForResource:@"EmotionList" ofType:@"plist"];
    NSArray* emotionFileArray = [[NSArray alloc] initWithContentsOfFile:emotionPlistPath];
    
    // 初始化普通表情文件名字
    NSMutableArray* emotionArray = [NSMutableArray array];
    NSMutableDictionary* emotionDict = [NSMutableDictionary dictionary];
    NSMutableArray *imageNameArray = [NSMutableArray array];
    
    ChatEmotion* emotion = nil;
    UIImage* image = nil;
    NSString* imageFileName = nil;
    NSString* imageName = nil;
    
    for(NSDictionary* dict in emotionFileArray) {
        imageFileName = [dict objectForKey:@"name"];
        image = [UIImage imageNamed:imageFileName];
        if( image != nil ) {
            imageName = [self parseEmotionTextByImageName:imageFileName];
            emotion = [[ChatEmotion alloc] initWithTextImage:imageName image:image];
            
            [emotionDict setObject:emotion forKey:imageName];
            [emotionArray addObject:emotion];
            [imageNameArray addObject:imageName];
        }
    }
    
    self.emotionDict = emotionDict;
    self.emotionArray = emotionArray;
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

/**
 *  解析消息表情和文本消息
 *
 *  @param text 普通文本消息
 *  @param font        字体
 *  @return 表情富文本消息
 */
- (NSAttributedString *)parseMessageTextEmotion:(NSString *)text font:(UIFont *)font {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSRange strRange;
    NSAttributedString* emotionAttString = nil;
    ChatTextAttachment *attachment = nil;
    
    // 替换img
    for (int i = 0; i < self.imageNameArray.count; i++) {
        
        NSString *str = self.imageNameArray[i];
        while ([text containsString:str]) {
            
            strRange = [text rangeOfString:str];
            // 增加表情文本
            attachment = [[ChatTextAttachment alloc] init];
            attachment.bounds = CGRectMake(0, -4, font.lineHeight, font.lineHeight);
            ChatEmotion* emotion = [self.emotionDict objectForKey:str];
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


- (NSAttributedString *)parseMessageAttributedTextEmotion:(NSMutableAttributedString *)text font:(UIFont *)font {
    
    NSRange strRange;

    /** 遍历字典查询是否有表情文本标记 有则替换为表情文本 */
    //        for (ChatEmotionItem *emotionItem in self.stanListItem.chatList) {
    //
    //            if ([emotionItem.emo_sign isEqualToString:emotionOriginalString]) {
    //
    //                // 生成表情富文本
    //                NSMutableAttributedString *imageString = [NSMutableAttributedString yy_attachmentStringWithContent:emotion.image contentMode:UIViewContentModeCenter attachmentSize:emotion.image.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    //
    //                // 替换普通文本为表情富文本
    //                replaceRange = NSMakeRange(range.location, NSMaxRange(endRange) - range.location);
    //                [text replaceCharactersInRange:replaceRange withAttributedString:imageString];
    //                // 替换查找文本
    //                findString = text.string;
    //
    //            }
    //        }
    //
    
    //        for (ChatEmotionItem *emotionItem in self.advanListItem.chatList) {
    //
    //            if ([emotionItem.emo_sign isEqualToString:emotionOriginalString]) {
    //
    //                // 生成表情富文本
    //                NSMutableAttributedString *imageString = [NSMutableAttributedString yy_attachmentStringWithContent:emotion.image contentMode:UIViewContentModeCenter attachmentSize:emotion.image.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
    //
    //                // 替换普通文本为表情富文本
    //                replaceRange = NSMakeRange(range.location, NSMaxRange(endRange) - range.location);
    //                [text replaceCharactersInRange:replaceRange withAttributedString:imageString];
    //                // 替换查找文本
    //                findString = text.string;
    //                
    //            }
    //        }
    
    // 替换img
    for (int i = 0; i < self.imageNameArray.count; i++) {
        
        NSString *str = self.imageNameArray[i];
        while ([text.string containsString:str]) {
            
            strRange = [text.string rangeOfString:str];
            ChatEmotion* emotion = [self.emotionDict objectForKey:str];
            // 生成表情富文本
            NSMutableAttributedString *imageString = [NSMutableAttributedString yy_attachmentStringWithContent:emotion.image contentMode:UIViewContentModeCenter attachmentSize:emotion.image.size alignToFont:font alignment:YYTextVerticalAlignmentCenter];
            // 生成表情富文本
            [text replaceCharactersInRange:strRange withAttributedString:imageString];
        }
    }
//    [text addAttributes:@{NSFontAttributeName : font} range:NSMakeRange(0, text.length)];
    
    return text;
}


@end
