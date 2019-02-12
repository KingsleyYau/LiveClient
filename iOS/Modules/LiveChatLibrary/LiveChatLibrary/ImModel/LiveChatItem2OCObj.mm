//
//  LiveChatItem2OCObj.m
//  dating
//
//  Created by  Samson on 5/16/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import "LiveChatItem2OCObj.h"

@interface LiveChatItem2OCObj ()

#pragma mark - message object
+ (LiveChatTextItemObject* _Nullable)getLiveChatTextItemObject:(const LCTextItem*)textItem;
+ (LiveChatWarningItemObject* _Nullable)getLiveChatWarningItemObject:(const LCWarningItem*)warningItem;
+ (LiveChatSystemItemObject* _Nullable)getLiveChatSystemItemObject:(const LCSystemItem*)systemItem;
+ (LiveChatCustomItemObject* _Nullable)getLiveChatCustomItemObject:(const LCCustomItem*)customItem;
+ (LiveChatMsgPhotoItem* _Nullable)getLiveChatPhotoItemObject:(const LCPhotoItem*)photoItem;
+ (LiveChatMsgVoiceItem* _Nullable)getLiveChatVoiceItemObject:(const LCVoiceItem*)voiceItem;

+ (NSArray<EmotionTypeItemObject*>* _Nullable)getEmotionTypeItemObject:(const OtherEmotionConfigItem::TypeList&)typeList;
+ (NSArray<EmotionTagItemObject*>* _Nullable)getEmotionTagItemObject:(const OtherEmotionConfigItem::TagList&)tagList;
+ (NSArray<EmotionItemObject*>* _Nullable)getEmotionItemObject:(const OtherEmotionConfigItem::EmotionList&)EmotionList;
+ (NSArray<MagicIconTypeItemObject*>* _Nullable)getMagicIconTypeItemObject:(const MagicIconConfig::MagicTypeList&)typeList;
+ (NSArray<MagicIconItemObject*>* _Nullable)getMagicIconItemObject:(const MagicIconConfig::MagicIconList&)magicIconList;

#pragma mark - message item
+ (LCTextItem* _Nullable)getLiveChatTextItem:(LiveChatTextItemObject* _Nonnull)text;
+ (LCWarningItem* _Nullable)getLiveChatWarningItem:(LiveChatWarningItemObject* _Nonnull)warning;
+ (LCSystemItem* _Nullable)getLiveChatSystemItem:(LiveChatSystemItemObject* _Nonnull)system;
+ (LCCustomItem* _Nullable)getLiveChatCustomItem:(LiveChatCustomItemObject* _Nonnull)custom;
+ (LCPhotoItem* _Nullable)getLiveChatPhotoItem:(LiveChatMsgPhotoItem* _Nonnull)photo;
+ (LCEmotionItem* _Nullable)getLiveChatEmotionItem:(LiveChatEmotionItemObject* _Nonnull)emotion;
+ (LCMagicIconItem* _Nullable)getLiveChatMagicIconItem:(LiveChatMagicIconItemObject* _Nonnull)magicIcon;
+ (LCVoiceItem* _Nullable)getLiveChatVoiceItem:(LiveChatMsgVoiceItem*_Nonnull)voiceItem;
@end

@implementation LiveChatItem2OCObj
#pragma mark - 公共处理
/**
 *  list<string>转NSArray
 *
 *  @param strList list<string>
 *
 *  @return NSString的NSArray
 */
+ (NSArray<NSString*>* _Nonnull)getStringArray:(const list<string>&)strList
{
    NSMutableArray* strArray = [NSMutableArray array];
    for (list<string>::const_iterator iter = strList.begin();
         iter != strList.end();
         iter++)
    {
        NSString* str = [NSString stringWithUTF8String:(*iter).c_str()];
        if (nil != str) {
            [strArray addObject:str];
        }
    }
    return strArray;
}

/**
 *  NSArray转list<string>
 *
 *  @param strArray NSString的NSArray
 *
 *  @return list<string>
 */
+ (list<string>)getStringList:(NSArray<NSString*>* _Nonnull)strArray
{
    list<string> strList;
    for (NSString* str in strArray)
    {
        const char* pStr = str != nil ? [str UTF8String] : "";
        strList.push_back(pStr);
    }
    return strList;
}

#pragma mark - user object
/**
 *  获取用户object
 *
 *  @param userItem 用户item
 *
 *  @return 用户object
 */
+ (LiveChatUserItemObject* _Nullable)getLiveChatUserItemObject:(const LCUserItem* _Nullable)userItem
{
    LiveChatUserItemObject* obj = nil;
    if (NULL != userItem)
    {
        obj = [[LiveChatUserItemObject alloc] init];
        obj.userId = [NSString stringWithUTF8String:userItem->m_userId.c_str()];
        obj.userName = [NSString stringWithUTF8String:userItem->m_userName.c_str()];
        obj.imageUrl = [NSString stringWithUTF8String:userItem->m_imageUrl.c_str()];
        obj.sexType = userItem->m_sexType;
        obj.clientType = userItem->m_clientType;
        obj.statusType = userItem->m_statusType;
        obj.chatType = userItem->m_chatType;
        obj.inviteId = [NSString stringWithUTF8String:userItem->m_inviteId.c_str()];
        obj.tryingSend = userItem->m_tryingSend ? YES : NO;
        obj.order = userItem->m_order;
    }
    return obj;
}

/**
 *  获取用户object数组
 *
 *  @param userList 用户item list
 *
 *  @return 用户object数组
 */
+ (NSArray<LiveChatUserItemObject*>* _Nonnull)getLiveChatUserArray:(const LCUserList&)userList
{
    NSMutableArray* users = [NSMutableArray array];
    for (LCUserList::const_iterator iter = userList.begin();
         iter != userList.end();
         iter++)
    {
        const LCUserItem* userItem = (*iter);
        LiveChatUserItemObject* userObj = [self getLiveChatUserItemObject:userItem];
        if (nil != userObj) {
            [users addObject:userObj];
        }
    }
    return users;
}

/**
 *  获取用户ID数组
 *
 *  @param userList 用户item list
 *
 *  @return 用户ID数组
 */
+ (NSArray<NSString*>* _Nonnull)getLiveChatUserIdArray:(const LCUserList&)userList
{
    NSMutableArray* userIds = [NSMutableArray array];
    for (LCUserList::const_iterator iter = userList.begin();
         iter != userList.end();
         iter++)
    {
        const LCUserItem* userItem = (*iter);
        NSString* userId = [NSString stringWithUTF8String:userItem->m_userId.c_str()];
        [userIds addObject:userId];
    }
    return userIds;
}

#pragma mark - message object
/**
 *  获取消息object
 *
 *  @param msgItem 消息item
 *
 *  @return 消息object
 */
+ (LiveChatMsgItemObject* _Nullable)getLiveChatMsgItemObject:(const LCMessageItem* _Nullable)msgItem
{
    LiveChatMsgItemObject* obj = nil;
    if (NULL != msgItem)
    {
        obj = [[LiveChatMsgItemObject alloc] init];
        obj.msgId  = msgItem->m_msgId;
        obj.sendType = msgItem->m_sendType;
        obj.fromId = [NSString stringWithUTF8String:msgItem->m_fromId.c_str()];
        obj.toId = [NSString stringWithUTF8String:msgItem->m_toId.c_str()];
        obj.inviteId = [NSString stringWithUTF8String:msgItem->m_inviteId.c_str()];
        obj.createTime = msgItem->m_createTime;
        obj.statusType = msgItem->m_statusType;
        obj.msgType = msgItem->m_msgType;
        obj.inviteType = (IniviteType)msgItem->m_inviteType;
        obj.procResult.errType = msgItem->m_procResult.m_errType;
        obj.procResult.errNum = [NSString stringWithUTF8String:msgItem->m_procResult.m_errNum.c_str()];
        obj.procResult.errMsg = [NSString stringWithUTF8String:msgItem->m_procResult.m_errMsg.c_str()];
        
        if (MT_Text == msgItem->m_msgType) {
            obj.textMsg = [self getLiveChatTextItemObject:msgItem->GetTextItem()];
        }
        else if (MT_Warning == msgItem->m_msgType) {
            obj.warningMsg = [self getLiveChatWarningItemObject:msgItem->GetWarningItem()];
        }
        else if (MT_System == msgItem->m_msgType) {
            obj.systemMsg = [self getLiveChatSystemItemObject:msgItem->GetSystemItem()];
        }
        else if (MT_Custom == msgItem->m_msgType) {
            obj.customMsg = [self getLiveChatCustomItemObject:msgItem->GetCustomItem()];
        }else if (MT_Photo == msgItem->m_msgType) {
            obj.secretPhoto = [self getLiveChatPhotoItemObject:msgItem->GetPhotoItem()];
        }
        else if (MT_Emotion == msgItem->m_msgType) {
            obj.emotionMsg = [self getLiveChatEmotionItemObject:msgItem->GetEmotionItem()];
        }
        else if (MT_MagicIcon == msgItem->m_msgType) {
            // new 一个新的高级表情item，防止getLiveChatMagicIconItemObject时,其它线程对MagicIconItem操作
            LCMagicIconItem* newMagicIconItem = new LCMagicIconItem(msgItem->GetMagicIconItem());
            obj.magicIconMsg = [self getLiveChatMagicIconItemObject:newMagicIconItem];
            if (newMagicIconItem != NULL) {
                delete newMagicIconItem;
            }
        }
        else if (MT_Voice == msgItem->m_msgType){
            obj.voiceMsg = [self getLiveChatVoiceItemObject:msgItem->GetVoiceItem()];
        }
    }
    return obj;
}

/**
 *  获取消息object数组
 *
 *  @param msgList 消息item list
 *
 *  @return 消息object数组
 */
+ (NSArray<LiveChatMsgItemObject*>* _Nonnull)getLiveChatMsgArray:(const LCMessageList&)msgList
{
    NSMutableArray* msgs = [NSMutableArray array];
    for (LCMessageList::const_iterator iter = msgList.begin();
         iter != msgList.end();
         iter++)
    {
        const LCMessageItem* msgItem = (*iter);
        LiveChatMsgItemObject* msgObj = [self getLiveChatMsgItemObject:msgItem];
        if (nil != msgObj) {
            [msgs addObject:msgObj];
        }
    }
    return msgs;
}

/**
 *  获取文本消息object
 *
 *  @param textItem 文本消息item
 *
 *  @return 文本消息object
 */
+ (LiveChatTextItemObject* _Nullable)getLiveChatTextItemObject:(const LCTextItem*)textItem
{
    LiveChatTextItemObject* obj = nil;
    if (NULL != textItem)
    {
        obj = [[LiveChatTextItemObject alloc] init];
        obj.message = [NSString stringWithUTF8String:textItem->m_message.c_str()];
        obj.displayMsg = [NSString stringWithUTF8String:textItem->m_displayMsg.c_str()];
        obj.illegal = textItem->m_illegal ? YES : NO;
    }
    return obj;
}

/**
 *  获取警告消息object
 *
 *  @param warningItem 警告消息item
 *
 *  @return 警告消息object
 */
+ (LiveChatWarningItemObject* _Nullable)getLiveChatWarningItemObject:(const LCWarningItem*)warningItem
{
    LiveChatWarningItemObject* obj = nil;
    if (NULL != warningItem)
    {
        obj = [[LiveChatWarningItemObject alloc] init];
        obj.codeType = warningItem->m_codeType;
        obj.message = [NSString stringWithUTF8String:warningItem->m_message.c_str()];
        
        if (NULL != warningItem->m_linkItem)
        {
            LCWarningLinkItem* linkItem = warningItem->m_linkItem;
            LiveChatWarningLinkItemObject* linkObj = [[LiveChatWarningLinkItemObject alloc] init];
            linkObj.linkMsg = [NSString stringWithUTF8String:linkItem->m_linkMsg.c_str()];
            linkObj.linkOptType = linkItem->m_linkOptType;
            
            obj.link = linkObj;
        }
    }
    return obj;
}

/**
 *  获取系统消息object
 *
 *  @param systemItem 系统消息item
 *
 *  @return 系统消息object
 */
+ (LiveChatSystemItemObject* _Nullable)getLiveChatSystemItemObject:(const LCSystemItem*)systemItem
{
    LiveChatSystemItemObject* obj = nil;
    if (NULL != systemItem)
    {
        obj = [[LiveChatSystemItemObject alloc] init];
        obj.codeType = systemItem->m_codeType;
        obj.message = [NSString stringWithUTF8String:systemItem->m_message.c_str()];
    }
    return obj;
}

/**
 *  获取自定义消息object
 *
 *  @param customItem 自定义消息item
 *
 *  @return 自定义消息object
 */
+ (LiveChatCustomItemObject* _Nullable)getLiveChatCustomItemObject:(const LCCustomItem*)customItem
{
    LiveChatCustomItemObject* obj = nil;
    if (NULL != customItem)
    {
        obj = [[LiveChatCustomItemObject alloc] init];
        obj.param = customItem->m_param;
    }
    return obj;
}


/**
 *  获取自定义图片信息object
 *
 *  @param photoItem 自定义图片信息item
 *
 *  @return 自定义图片信息object
 */
+ (LiveChatMsgPhotoItem* _Nullable)getLiveChatPhotoItemObject:(const LCPhotoItem*)photoItem{
        LiveChatMsgPhotoItem* obj = nil;
    if (NULL != photoItem)
    {
        obj = [[LiveChatMsgPhotoItem alloc] init];
        obj.photoId = [NSString stringWithUTF8String:photoItem->m_photoId.c_str()];
        obj.photoDesc = [NSString stringWithUTF8String:photoItem->m_photoDesc.c_str()];
        obj.sendId = [NSString stringWithUTF8String:photoItem->m_sendId.c_str()];
        obj.showFuzzyFilePath = [NSString stringWithUTF8String:photoItem->m_showFuzzyFilePath.c_str()];
        obj.thumbFuzzyFilePath = [NSString stringWithUTF8String:photoItem->m_thumbFuzzyFilePath.c_str()];
        obj.srcFilePath = [NSString stringWithUTF8String:photoItem->m_srcFilePath.c_str()];
        obj.showSrcFilePath = [NSString stringWithUTF8String:photoItem->m_showSrcFilePath.c_str()];
        obj.thumbSrcFilePath = [NSString stringWithUTF8String:photoItem->m_thumbSrcFilePath.c_str()];
        obj.charge = photoItem->m_charge;
    }
    return obj;
}

/**
 *  获取高级表情配置的type节点object
 *
 *  @param typeList 高级表情配置的type节点item
 *
 *  @return 高级表情配置的type节点object
 */
+ (NSArray<EmotionTypeItemObject*>* _Nullable)getEmotionTypeItemObject:(const OtherEmotionConfigItem::TypeList &)typeList
{
    NSMutableArray *object = [NSMutableArray array];
    for(OtherEmotionConfigItem::TypeList::const_iterator iter = typeList.begin(); iter != typeList.end(); iter++){
        EmotionTypeItemObject* typeItem = [[EmotionTypeItemObject alloc] init];
        typeItem.toflag   = (*iter).toflag;
        typeItem.typeId   = [NSString stringWithUTF8String:(*iter).typeId.c_str()];
        typeItem.typeName = [NSString stringWithUTF8String:(*iter).typeName.c_str()];
        [object addObject:typeItem];
    }
    return object;
}

/**
 *  获取高级表情配置的tag节点object
 *
 *  @param tagList 高级表情配置的tag节点item
 *
 *  @return 高级表情配置的tag节点object
 */
+ (NSArray<EmotionTagItemObject*>* _Nullable)getEmotionTagItemObject:(const OtherEmotionConfigItem::TagList &)tagList
{
    NSMutableArray *object = [NSMutableArray array];
    for(OtherEmotionConfigItem::TagList::const_iterator iter = tagList.begin(); iter != tagList.end(); iter++){
        EmotionTagItemObject* tagItem = [[EmotionTagItemObject alloc] init];
        tagItem.toflag   = (*iter).toflag;
        tagItem.typeId   = [NSString stringWithUTF8String:(*iter).typeId.c_str()];
        tagItem.tagId    = [NSString stringWithUTF8String:(*iter).tagId.c_str()];
        tagItem.tagName = [NSString stringWithUTF8String:(*iter).tagName.c_str()];
        [object addObject:tagItem];
    }
    return object;
}

/**
 *  获取高级表情配置的男士／女士Eotion列表object
 *
 *  @param EmotionList 高级表情配置的男士／女士emotion列表
 *
 *  @return 高级表情配置的男士／女士Eotion列表object
 */
+ (NSArray<EmotionItemObject*>* _Nullable)getEmotionItemObject:(const OtherEmotionConfigItem::EmotionList &)EmotionList
{
    NSMutableArray *object = [NSMutableArray array];
    for(OtherEmotionConfigItem::EmotionList::const_iterator iter = EmotionList.begin(); iter != EmotionList.end(); iter++){
        EmotionItemObject* EmotionItem = [[EmotionItemObject alloc] init];
        EmotionItem.emotionId  = [NSString stringWithUTF8String:(*iter).fileName.c_str()];
        EmotionItem.price     = (*iter).price;
        EmotionItem.isNew     = (*iter).isNew;
        EmotionItem.isSale    = (*iter).isSale;
        EmotionItem.sortId    = (*iter).sortId;
        EmotionItem.typeId    = [NSString stringWithUTF8String:(*iter).typeId.c_str()];
        EmotionItem.tagId     = [NSString stringWithUTF8String:(*iter).tagId.c_str()];
        EmotionItem.title     = [NSString stringWithUTF8String:(*iter).title.c_str()];
        [object addObject:EmotionItem];
    }
    return object;
}

/**
 *  获取小高级表情配置的type节点object
 *
 *  @param typeList 小高级表情配置的type节点item
 *
 *  @return 小高级表情配置的type节点object
 */
+ (NSArray<MagicIconTypeItemObject*>* _Nullable)getMagicIconTypeItemObject:(const MagicIconConfig::MagicTypeList&)typeList
{
    NSMutableArray *object = [NSMutableArray array];
    for (MagicIconConfig::MagicTypeList::const_iterator iter = typeList.begin(); iter != typeList.end(); iter++) {
        MagicIconTypeItemObject* typeItem = [[MagicIconTypeItemObject alloc] init];
        typeItem.typeId                   = [NSString stringWithUTF8String:(*iter).typeId.c_str()];
        typeItem.typeTitle                = [NSString stringWithUTF8String:(*iter).typeTitle.c_str()];
        [object addObject:typeItem];
    }
    return object;
}

/**
 *  获取小高级表情配置的列表object
 *
 *  @param magicIconList 高级表情配置的列表
 *
 *  @return 小高级表情配置的列表object
 */
+ (NSArray<MagicIconItemObject*>* _Nullable)getMagicIconItemObject:(const MagicIconConfig::MagicIconList&)magicIconList
{
    NSMutableArray *object = [NSMutableArray array];
    for (MagicIconConfig::MagicIconList::const_iterator iter = magicIconList.begin(); iter != magicIconList.end() ; iter++) {
        MagicIconItemObject * typeItem = [[MagicIconItemObject alloc] init];
        typeItem.iconId                = [NSString stringWithUTF8String:(*iter).iconId.c_str()];
        typeItem.iconTitle             = [NSString stringWithUTF8String:(*iter).iconTitle.c_str()];
        typeItem.price                 = (*iter).price;
        typeItem.hotflog               = (*iter).hotflag;
        typeItem.typeId                = [NSString stringWithUTF8String:(*iter).typeId.c_str()];
        typeItem.updatetime            = (*iter).updatetime;
        [object addObject:typeItem];
    }
    return object;
}


#pragma mark - message item
/**
 *  获取消息item
 *
 *  @param msg 消息object
 *
 *  @return 消息item
 */
+ (LCMessageItem* _Nullable)getLiveChatMsgItem:(LiveChatMsgItemObject* _Nonnull)msg
{
    LCMessageItem* msgItem = new LCMessageItem;
    if (NULL != msgItem && msg != nil)
    {
        msgItem->m_fromId = [msg.fromId UTF8String];
        msgItem->m_inviteId = [msg.inviteId UTF8String];
        msgItem->m_sendType = msg.sendType;
        msgItem->m_statusType = msg.statusType;
        msgItem->m_toId = [msg.toId UTF8String];
        msgItem->m_createTime = msg.createTime;
        msgItem->m_statusType = msg.statusType;
        msgItem->m_procResult.m_errType = msg.procResult.errType;
        msgItem->m_procResult.m_errNum = [msg.procResult.errNum UTF8String];
        msgItem->m_procResult.m_errMsg = [msg.procResult.errMsg UTF8String];
        
        if (MT_Text == msg.msgType)
        {
            LCTextItem* textItem = [LiveChatItem2OCObj getLiveChatTextItem:msg.textMsg];
            msgItem->SetTextItem(textItem);
        }
        else if (MT_Warning == msg.msgType)
        {
            LCWarningItem* warningItem = [LiveChatItem2OCObj getLiveChatWarningItem:msg.warningMsg];
            msgItem->SetWarningItem(warningItem);
        }
        else if (MT_System == msg.msgType)
        {
            LCSystemItem* systemItem = [LiveChatItem2OCObj getLiveChatSystemItem:msg.systemMsg];
            msgItem->SetSystemItem(systemItem);
        }
        else if (MT_Custom == msg.msgType)
        {
            LCCustomItem* customItem = [LiveChatItem2OCObj getLiveChatCustomItem:msg.customMsg];
            msgItem->SetCustomItem(customItem);
        }
        else if(MT_Emotion == msg.msgType)
        {
            LCEmotionItem* emotionItem = [LiveChatItem2OCObj getLiveChatEmotionItem:msg.emotionMsg];
            msgItem->SetEmotionItem(emotionItem);
        }
        else if(MT_MagicIcon == msg.msgType)
        {
            LCMagicIconItem* magicIconItem = [LiveChatItem2OCObj getLiveChatMagicIconItem:msg.magicIconMsg];
            msgItem->SetMagicIconItem(magicIconItem);
        }
        else if (MT_Voice == msg.msgType)
        {
            LCVoiceItem* voiceItem = [LiveChatItem2OCObj getLiveChatVoiceItem:msg.voiceMsg];
            msgItem->SetVoiceItem(voiceItem);
        }
        else
        {
            delete msgItem;
            msgItem = NULL;
        }
    }
    return msgItem;
}

/**
 *  获取文本消息item
 *
 *  @param text 文本消息object
 *
 *  @return 文本消息item
 */
+ (LCTextItem* _Nullable)getLiveChatTextItem:(LiveChatTextItemObject* _Nonnull)text
{
    LCTextItem* textItem = new LCTextItem;
    if (NULL != textItem & text != nil)
    {
        textItem->m_message = [text.message UTF8String];
        textItem->m_illegal = text.illegal ? true : false;
    }
    return textItem;
}

/**
 *  获取警告消息item
 *
 *  @param warning 警告消息object
 *
 *  @return 警告消息item
 */
+ (LCWarningItem* _Nullable)getLiveChatWarningItem:(LiveChatWarningItemObject* _Nonnull)warning
{
    LCWarningItem* warningItem = new LCWarningItem;
    if (NULL != warningItem && warning != nil)
    {
        warningItem->m_message = [warning.message UTF8String];
        if (nil != warning.link)
        {
            warningItem->m_linkItem = new LCWarningLinkItem;
            if (NULL != warningItem->m_linkItem)
            {
                warningItem->m_linkItem->m_linkMsg = warning.link.linkMsg != nil ? [warning.link.linkMsg UTF8String] : "";
                warningItem->m_linkItem->m_linkOptType = warning.link.linkOptType;
            }
        }
    }
    return warningItem;
}

/**
 *  获取系统消息item
 *
 *  @param system 系统消息object
 *
 *  @return 系统消息item
 */
+ (LCSystemItem* _Nullable)getLiveChatSystemItem:(LiveChatSystemItemObject* _Nonnull)system
{
    LCSystemItem* systemItem = new LCSystemItem;
    if (NULL != systemItem && system != nil)
    {
        systemItem->m_message = system.message != nil ? [system.message UTF8String] : "";
    }
    return systemItem;
}

/**
 *  获取自定义消息item
 *
 *  @param custom 自定义消息object
 *
 *  @return 自定义消息item
 */
+ (LCCustomItem* _Nullable)getLiveChatCustomItem:(LiveChatCustomItemObject* _Nonnull)custom
{
    LCCustomItem* customItem = new LCCustomItem;
    if (NULL != customItem && custom != nil)
    {
        customItem->m_param = custom.param;
    }
    return customItem;
}



/**
 *  获取图片信息item
 *
 *  @param photo 自定义图片信息object
 *
 *  @return 自定义图片信息item
 */

+ (LCPhotoItem* _Nullable)getLiveChatPhotoItem:(LiveChatMsgPhotoItem* _Nonnull)photo
{
    LCPhotoItem* photoItem = new LCPhotoItem;
    if (NULL != photoItem && photo != nil)
    {
        photoItem->m_photoId = photo.photoId != nil ? [photo.photoId UTF8String] : "";
        photoItem->m_photoDesc = photo.photoDesc != nil ? [photo.photoDesc UTF8String] : "";
        photoItem->m_sendId = photo.sendId != nil ? [photo.sendId UTF8String] : "";
        photoItem->m_showFuzzyFilePath = photo.showFuzzyFilePath != nil ? [photo.showFuzzyFilePath UTF8String] : "";
        photoItem->m_thumbFuzzyFilePath = photo.thumbFuzzyFilePath != nil ? [photo.thumbFuzzyFilePath UTF8String] : "";
        photoItem->m_srcFilePath = photo.srcFilePath != nil ? [photo.srcFilePath UTF8String] : "";
        photoItem->m_showSrcFilePath = photo.showSrcFilePath != nil ? [photo.showSrcFilePath UTF8String] : "";
        photoItem->m_thumbSrcFilePath = photo.thumbSrcFilePath != nil ? [photo.thumbSrcFilePath UTF8String] : "";
        photoItem->m_charge = photo.isGetCharge;
        
    }
    return photoItem;
}

/**
 *  获取高级表情信息item
 *
 *  @param emotion 自定义高级表情信息object
 *
 *  @return 高级表情信息item
 */
+ (LCEmotionItem* _Nullable)getLiveChatEmotionItem:(LiveChatEmotionItemObject* _Nonnull)emotion
{
    LCEmotionItem* emotionItem = new LCEmotionItem;
    if (NULL != emotionItem && emotion != nil) {
        emotionItem->LockEmotion();
        emotionItem->m_emotionId   = emotion.emotionId != nil ? [emotion.emotionId UTF8String] : "";
        emotionItem->m_imagePath   = emotion.imagePath != nil ? [emotion.imagePath UTF8String] : "";
        emotionItem->m_playBigPath = emotion.playBigPath != nil ? [emotion.playBigPath UTF8String] : "";
        for (int i = 0; i< [emotion.playBigImages count]; i++) {
            string strPlayBigPath = [emotion.playBigImages objectAtIndex:i] != nil ? [[emotion.playBigImages objectAtIndex:i] UTF8String] : "";
            emotionItem->m_playBigPaths.push_back(strPlayBigPath);
        }
        emotionItem->UnlockEmotion();
    }
    return emotionItem;
}

/**
 *  获取小高级表情信息item
 *
 *  @param emotion 自定义小高级表情信息object
 *
 *  @return 小高级表情信息item
 */
+ (LCMagicIconItem* _Nullable)getLiveChatMagicIconItem:(LiveChatMagicIconItemObject* _Nonnull)magicIcon
{
    LCMagicIconItem* magicIconItem = new LCMagicIconItem;
    if(NULL != magicIconItem && magicIcon != nil){
        magicIconItem->m_magicIconId = magicIcon.magicIconId != nil ? [magicIcon.magicIconId UTF8String] : "";
        magicIconItem->m_sourcePath  = magicIcon.sourcePath != nil ? [magicIcon.sourcePath UTF8String] : "";
        magicIconItem->m_thumbPath   = magicIcon.thumbPath != nil ? [magicIcon.thumbPath UTF8String] : "";
    }
    return magicIconItem;
}

+ (LCVoiceItem* _Nullable)getLiveChatVoiceItem:(LiveChatMsgVoiceItem* _Nonnull)voiceItem
{
    LCVoiceItem* lcVoiceItem = new LCVoiceItem;
    if(NULL != lcVoiceItem && voiceItem != nil){
        lcVoiceItem->m_voiceId = voiceItem.voiceId != nil ? [voiceItem.voiceId UTF8String] : "";
        lcVoiceItem->m_filePath  = voiceItem.filePath != nil ? [voiceItem.filePath UTF8String] : "";
        lcVoiceItem->m_fileType   = voiceItem.fileType != nil ? [voiceItem.fileType UTF8String] : "";
        lcVoiceItem->m_checkCode = voiceItem.checkCode != nil ? [voiceItem.checkCode UTF8String] : "";
        lcVoiceItem->m_timeLength = voiceItem.timeLength;
        
    }
    return lcVoiceItem;
}


#pragma mark - userinfo item
/**
 *  获取用户信息object
 *
 *  @param userInfo 用户信息item
 *
 *  @return 用户信息object
 */
+ (LiveChatUserInfoItemObject* _Nullable)getLiveChatUserInfoItemObjecgt:(const UserInfoItem&)userInfo
{
    LiveChatUserInfoItemObject* object = [[LiveChatUserInfoItemObject alloc] init];
    if (nil != object) {
        object.userId = [NSString stringWithUTF8String:userInfo.userId.c_str()];
        object.userName = [NSString stringWithUTF8String:userInfo.userName.c_str()];
        object.server = [NSString stringWithUTF8String:userInfo.server.c_str()];
        object.imgUrl = [NSString stringWithUTF8String:userInfo.imgUrl.c_str()];
        object.sexType = userInfo.sexType;
        object.age = userInfo.age;
        object.weight = [NSString stringWithUTF8String:userInfo.weight.c_str()];
        object.height = [NSString stringWithUTF8String:userInfo.height.c_str()];
        object.country = [NSString stringWithUTF8String:userInfo.country.c_str()];
        object.province = [NSString stringWithUTF8String:userInfo.province.c_str()];
        
        object.videoChat = userInfo.videoChat ? YES : NO;
        object.videoCount = userInfo.videoCount;
        object.marryType = userInfo.marryType;
        object.childrenType = userInfo.childrenType;
        object.status = userInfo.status;
        object.userType = userInfo.userType;
        object.orderValue = userInfo.orderValue;
        
        // 设备及客户端
        object.deviceType = userInfo.deviceType;
        object.clientType = userInfo.clientType;
        object.clientVersion = [NSString stringWithUTF8String:userInfo.clientVersion.c_str()];
        
        // 翻译
        object.needTrans = userInfo.needTrans ? YES : NO;
        object.transUserId = [NSString stringWithUTF8String:userInfo.transUserId.c_str()];
        object.transUserName = [NSString stringWithUTF8String:userInfo.transUserName.c_str()];
        object.transBind = userInfo.transBind ? YES : NO;
        object.transStatus = userInfo.transStatus;
    }
    return object;
}

/**
 *  获取用户信息object数组
 *
 *  @param userInfoList 用户信息item list
 *
 *  @return 用户信息object数组
 */
+ (NSArray<LiveChatUserInfoItemObject*>* _Nonnull)getLiveChatUserInfoArray:(const UserInfoList&)userInfoList
{
    NSMutableArray* userInfoArray = [NSMutableArray array];
    for (UserInfoList::const_iterator iter = userInfoList.begin();
         iter != userInfoList.end();
         iter++)
    {
        LiveChatUserInfoItemObject* object = [self getLiveChatUserInfoItemObjecgt:(*iter)];
        if (nil != object) {
            [userInfoArray addObject:object];
        }
    }
    return userInfoArray;
}

#pragma mark - Emotion item
/**
 * 获取高级表情信息object
 *
 * @param EmotionItem
 *
 * @return 高级表情信息object
 */
+ (LiveChatEmotionItemObject*) getLiveChatEmotionItemObject:(const LCEmotionItem *)EmotionItem
{
    LiveChatEmotionItemObject* object = nil;
    if(NULL != EmotionItem){
        object = [[LiveChatEmotionItemObject alloc] init];
        if (NULL != EmotionItem->m_emotionLock) {
            EmotionItem->m_emotionLock->Lock();
        }
        object.emotionId     = [NSString stringWithUTF8String:EmotionItem->m_emotionId.c_str()];
        object.imagePath     = [NSString stringWithUTF8String:EmotionItem->m_imagePath.c_str()];
        object.playBigPath   = [NSString stringWithUTF8String:EmotionItem->m_playBigPath.c_str()];
        object.playBigImages = [NSMutableArray array];
        for(LCEmotionPathVector::const_iterator iter = EmotionItem->m_playBigPaths.begin(); iter != EmotionItem->m_playBigPaths.end(); iter++)
        {
            NSString* bigPath = [NSString stringWithUTF8String:(*iter).c_str()];
            if (bigPath != nil) {
                [object.playBigImages addObject:bigPath];
            }
            
        }
        if (NULL != EmotionItem->m_emotionLock) {
            EmotionItem->m_emotionLock->Unlock();
        }
    }
    return object;
}

/**
 *  获取高级表情配置信息object
 *
 *  @param otherEmotionItem 高级表情配置item
 *
 *  @return 高级表情配置信息object
 */

+ (LiveChatEmotionConfigItemObject*)getLiveChatEmotionConfigItemObject:(const OtherEmotionConfigItem &)otherEmotionItem
{
    LiveChatEmotionConfigItemObject *object = nil;
    object                 = [[LiveChatEmotionConfigItemObject alloc] init];
    object.version         = otherEmotionItem.version;
    object.path            = [NSString stringWithUTF8String:otherEmotionItem.path.c_str()];
    object.typeList        = [self getEmotionTypeItemObject:otherEmotionItem.typeList];
    object.tagList         = [self getEmotionTagItemObject:otherEmotionItem.tagList];
    object.manEmotionList  = [self getEmotionItemObject:otherEmotionItem.manEmotionList];
    object.ladyEmotionList = [self getEmotionItemObject:otherEmotionItem.ladyEmotionList];
    return object;
}

#pragma mark - MagicIcon item
/**
 * 获取小高级表情信息object
 *
 * @param EmotionItem 小高级表情item
 *
 * @return 小高级表情信息object
 */
+ (LiveChatMagicIconItemObject*)getLiveChatMagicIconItemObject:(const LCMagicIconItem*)magicIconItem
{
    LiveChatMagicIconItemObject* object = nil;
    if (NULL != magicIconItem) {
        object                              = [[LiveChatMagicIconItemObject alloc] init];
        object.magicIconId                  = [NSString stringWithUTF8String:magicIconItem->m_magicIconId.c_str()];
        object.thumbPath                    = [NSString stringWithUTF8String:magicIconItem->m_thumbPath.c_str()];
        object.sourcePath                   = [NSString stringWithUTF8String:magicIconItem->m_sourcePath.c_str()];
    }
    return object;
}

/**
 * 获取小高级表情配置object
 *
 * @param magicConfig 小高级表情配置item
 *
 * @return 小高级表情配置信息object
 */
+ (LiveChatMagicIconConfigItemObject*)getLiveChatMagicIconConfigItemObject:(const MagicIconConfig&)magicConfig
{
    LiveChatMagicIconConfigItemObject* object = nil;
    object                                    = [[LiveChatMagicIconConfigItemObject alloc] init];
    object.path                               = [NSString stringWithUTF8String:magicConfig.path.c_str()];
    object.maxupdatetime                      = magicConfig.maxupdatetime;
    object.typeList                           = [self getMagicIconTypeItemObject:magicConfig.typeList];
    object.magicIconList                      = [self getMagicIconItemObject:magicConfig.magicIconList];
    return object;
}

/**
 * 获取语音消息object
 *
 * @param voiceItem 语音item
 *
 * @return 语音消息object
 */
+ (LiveChatMsgVoiceItem*)getLiveChatVoiceItemObject:(const LCVoiceItem*)voiceItem
{
    LiveChatMsgVoiceItem* obj = nil;
    if (NULL != voiceItem)
    {
        obj = [[LiveChatMsgVoiceItem alloc] init];
        obj.voiceId = [NSString stringWithUTF8String:voiceItem->m_voiceId.c_str()];
        obj.filePath = [NSString stringWithUTF8String:voiceItem->m_filePath.c_str()];
        obj.fileType = [NSString stringWithUTF8String:voiceItem->m_fileType.c_str()];
        obj.checkCode = [NSString stringWithUTF8String:voiceItem->m_checkCode.c_str()];
        obj.timeLength = voiceItem->m_timeLength;
        obj.charge = voiceItem->m_charge;
        obj.processing = voiceItem->m_processing;
    }
    return obj;
}

@end
