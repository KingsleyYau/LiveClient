//
//  LSLCLiveChatItem2OCObj.m
//  dating
//
//  Created by  Samson on 5/16/16.
//  Copyright © 2016 qpidnetwork. All rights reserved.
//

#import "LSLCLiveChatItem2OCObj.h"

@interface LSLCLiveChatItem2OCObj ()

#pragma mark - message object
+ (LSLCLiveChatTextItemObject* _Nullable)getLiveChatTextItemObject:(const LSLCTextItem*)textItem;
+ (LSLCLiveChatWarningItemObject* _Nullable)getLiveChatWarningItemObject:(const LSLCWarningItem*)warningItem;
+ (LSLCLiveChatSystemItemObject* _Nullable)getLiveChatSystemItemObject:(const LSLCSystemItem*)systemItem;
+ (LSLCLiveChatCustomItemObject* _Nullable)getLiveChatCustomItemObject:(const LSLCCustomItem*)customItem;
+ (LSLCLiveChatMsgPhotoItem* _Nullable)getLiveChatPhotoItemObject:(const LSLCPhotoItem*)photoItem;
+ (LSLCLiveChatMsgVoiceItem* _Nullable)getLiveChatVoiceItemObject:(const LSLCVoiceItem*)voiceItem;
+ (LSLCLiveChatMsgVideoItem* _Nullable)getLiveChatVideoItemObject:(const lcmm::LSLCVideoItem*_Nullable)videoItem;
+ (LSLCLiveChatScheduleMsgItemObject* _Nullable)getLiveChatScheduleInviteItemObject:(const LSLCScheduleInviteItem*)ScheduleInviteItem;
+ (LSLCLiveChatScheduleReplyItemObject* _Nullable)getLiveChatScheduleReplyItemObject:(const LSLCScheduleInviteReplyItem*)ScheduleReplyItem;

+ (NSArray<LSLCEmotionTypeItemObject*>* _Nullable)getEmotionTypeItemObject:(const LSLCOtherEmotionConfigItem::TypeList&)typeList;
+ (NSArray<LSLCEmotionTagItemObject*>* _Nullable)getEmotionTagItemObject:(const LSLCOtherEmotionConfigItem::TagList&)tagList;
+ (NSArray<LSLCEmotionItemObject*>* _Nullable)getEmotionItemObject:(const LSLCOtherEmotionConfigItem::EmotionList&)EmotionList;
+ (NSArray<LSLCMagicIconTypeItemObject*>* _Nullable)getMagicIconTypeItemObject:(const LSLCMagicIconConfig::MagicTypeList&)typeList;
+ (NSArray<LSLCMagicIconItemObject*>* _Nullable)getMagicIconItemObject:(const LSLCMagicIconConfig::MagicIconList&)magicIconList;

#pragma mark - message item
+ (LSLCTextItem* _Nullable)getLiveChatTextItem:(LSLCLiveChatTextItemObject* _Nonnull)text;
+ (LSLCWarningItem* _Nullable)getLiveChatWarningItem:(LSLCLiveChatWarningItemObject* _Nonnull)warning;
+ (LSLCSystemItem* _Nullable)getLiveChatSystemItem:(LSLCLiveChatSystemItemObject* _Nonnull)system;
+ (LSLCCustomItem* _Nullable)getLiveChatCustomItem:(LSLCLiveChatCustomItemObject* _Nonnull)custom;
+ (LSLCPhotoItem* _Nullable)getLiveChatPhotoItem:(LSLCLiveChatMsgPhotoItem* _Nonnull)photo;
+ (LSLCEmotionItem* _Nullable)getLiveChatEmotionItem:(LSLCLiveChatEmotionItemObject* _Nonnull)emotion;
+ (LSLCMagicIconItem* _Nullable)getLiveChatMagicIconItem:(LSLCLiveChatMagicIconItemObject* _Nonnull)magicIcon;
+ (LSLCVoiceItem* _Nullable)getLiveChatVoiceItem:(LSLCLiveChatMsgVoiceItem*_Nonnull)voiceItem;
+ (lcmm::LSLCVideoItem* _Nullable)getLiveChatVideoItem:(LSLCLiveChatMsgVideoItem*_Nonnull)videoItem;
//+ (LSLCScheduleInviteItem* _Nullable)getLiveChatScheduleInviteItem:(LSLCLiveChatScheduleMsgItemObject*_Nonnull)scheduleItem;
@end

@implementation LSLCLiveChatItem2OCObj
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
+ (LSLCLiveChatUserItemObject* _Nullable)getLiveChatUserItemObject:(const LSLCUserItem* _Nullable)userItem
{
    LSLCLiveChatUserItemObject* obj = nil;
    if (NULL != userItem)
    {
        obj = [[LSLCLiveChatUserItemObject alloc] init];
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
+ (NSArray<LSLCLiveChatUserItemObject*>* _Nonnull)getLiveChatUserArray:(const LCUserList&)userList
{
    NSMutableArray* users = [NSMutableArray array];
    for (LCUserList::const_iterator iter = userList.begin();
         iter != userList.end();
         iter++)
    {
        const LSLCUserItem* userItem = (*iter);
        LSLCLiveChatUserItemObject* userObj = [self getLiveChatUserItemObject:userItem];
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
        const LSLCUserItem* userItem = (*iter);
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
+ (LSLCLiveChatMsgItemObject* _Nullable)getLiveChatMsgItemObject:(const LSLCMessageItem* _Nullable)msgItem
{
    LSLCLiveChatMsgItemObject* obj = nil;
    if (NULL != msgItem)
    {
        obj = [[LSLCLiveChatMsgItemObject alloc] init];
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
            LSLCMagicIconItem* newMagicIconItem = new LSLCMagicIconItem(msgItem->GetMagicIconItem());
            obj.magicIconMsg = [self getLiveChatMagicIconItemObject:newMagicIconItem];
            if (newMagicIconItem != NULL) {
                delete newMagicIconItem;
            }
        }
        else if (MT_Voice == msgItem->m_msgType) {
            obj.voiceMsg = [self getLiveChatVoiceItemObject:msgItem->GetVoiceItem()];
        }
        else if (MT_Video == msgItem->m_msgType) {
            obj.videoMsg = [self getLiveChatVideoItemObject:msgItem->GetVideoItem()];
        }
        else if (MT_Schedule == msgItem->m_msgType) {
            obj.scheduleMsg = [self getLiveChatScheduleInviteItemObject:msgItem->GetScheduleInviteItem()];
        }
        else if (MT_ScheduleReply == msgItem->m_msgType) {
            obj.scheduleReplyMsg = [self getLiveChatScheduleReplyItemObject:msgItem->GetScheduleInviteReplyItem()];
        }
    }
    return obj;
}

/**
 *  获取消息object
 *
 *  @param msgItem 消息item(非指针)
 *
 *  @return 消息object
 */
+ (LSLCLiveChatMsgItemObject* _Nullable)getLiveChatLastMsgItemObject:(const LSLCMessageItem&)msgItem {
    LSLCLiveChatMsgItemObject* obj = nil;
    
    obj = [[LSLCLiveChatMsgItemObject alloc] init];
    obj.msgId  = msgItem.m_msgId;
    obj.sendType = msgItem.m_sendType;
    obj.fromId = [NSString stringWithUTF8String:msgItem.m_fromId.c_str()];
    obj.toId = [NSString stringWithUTF8String:msgItem.m_toId.c_str()];
    obj.inviteId = [NSString stringWithUTF8String:msgItem.m_inviteId.c_str()];
    obj.createTime = msgItem.m_createTime;
    obj.statusType = msgItem.m_statusType;
    obj.msgType = msgItem.m_msgType;
    obj.inviteType = (IniviteType)msgItem.m_inviteType;
    obj.procResult.errType = msgItem.m_procResult.m_errType;
    obj.procResult.errNum = [NSString stringWithUTF8String:msgItem.m_procResult.m_errNum.c_str()];
    obj.procResult.errMsg = [NSString stringWithUTF8String:msgItem.m_procResult.m_errMsg.c_str()];
    
    if (MT_Text == msgItem.m_msgType) {
        obj.textMsg = [self getLiveChatTextItemObject:msgItem.GetTextItem()];
    }
    else if (MT_Warning == msgItem.m_msgType) {
        obj.warningMsg = [self getLiveChatWarningItemObject:msgItem.GetWarningItem()];
    }
    else if (MT_System == msgItem.m_msgType) {
        obj.systemMsg = [self getLiveChatSystemItemObject:msgItem.GetSystemItem()];
    }
    else if (MT_Custom == msgItem.m_msgType) {
        obj.customMsg = [self getLiveChatCustomItemObject:msgItem.GetCustomItem()];
    }else if (MT_Photo == msgItem.m_msgType) {
        obj.secretPhoto = [self getLiveChatPhotoItemObject:msgItem.GetPhotoItem()];
    }
    else if (MT_Emotion == msgItem.m_msgType) {
        obj.emotionMsg = [self getLiveChatEmotionItemObject:msgItem.GetEmotionItem()];
    }
    else if (MT_MagicIcon == msgItem.m_msgType) {
        // new 一个新的高级表情item，防止getLiveChatMagicIconItemObject时,其它线程对MagicIconItem操作
        LSLCMagicIconItem* newMagicIconItem = new LSLCMagicIconItem(msgItem.GetMagicIconItem());
        obj.magicIconMsg = [self getLiveChatMagicIconItemObject:newMagicIconItem];
        if (newMagicIconItem != NULL) {
            delete newMagicIconItem;
        }
    }
    else if (MT_Voice == msgItem.m_msgType) {
        obj.voiceMsg = [self getLiveChatVoiceItemObject:msgItem.GetVoiceItem()];
    }
    else if (MT_Video == msgItem.m_msgType) {
        obj.videoMsg = [self getLiveChatVideoItemObject:msgItem.GetVideoItem()];
    }
    else if (MT_Schedule == msgItem.m_msgType) {
        obj.scheduleMsg = [self getLiveChatScheduleInviteItemObject:msgItem.GetScheduleInviteItem()];
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
+ (NSArray<LSLCLiveChatMsgItemObject*>* _Nonnull)getLiveChatMsgArray:(const LCMessageList&)msgList
{
    NSMutableArray* msgs = [NSMutableArray array];
    for (LCMessageList::const_iterator iter = msgList.begin();
         iter != msgList.end();
         iter++)
    {
        const LSLCMessageItem* msgItem = (*iter);
        LSLCLiveChatMsgItemObject* msgObj = [self getLiveChatMsgItemObject:msgItem];
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
+ (LSLCLiveChatTextItemObject* _Nullable)getLiveChatTextItemObject:(const LSLCTextItem*)textItem
{
    LSLCLiveChatTextItemObject* obj = nil;
    if (NULL != textItem)
    {
        obj = [[LSLCLiveChatTextItemObject alloc] init];
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
+ (LSLCLiveChatWarningItemObject* _Nullable)getLiveChatWarningItemObject:(const LSLCWarningItem*)warningItem
{
    LSLCLiveChatWarningItemObject* obj = nil;
    if (NULL != warningItem)
    {
        obj = [[LSLCLiveChatWarningItemObject alloc] init];
        obj.codeType = warningItem->m_codeType;
        obj.message = [NSString stringWithUTF8String:warningItem->m_message.c_str()];
        
        if (NULL != warningItem->m_linkItem)
        {
            LSLCWarningLinkItem* linkItem = warningItem->m_linkItem;
            LSLCLiveChatWarningLinkItemObject* linkObj = [[LSLCLiveChatWarningLinkItemObject alloc] init];
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
+ (LSLCLiveChatSystemItemObject* _Nullable)getLiveChatSystemItemObject:(const LSLCSystemItem*)systemItem
{
    LSLCLiveChatSystemItemObject* obj = nil;
    if (NULL != systemItem)
    {
        obj = [[LSLCLiveChatSystemItemObject alloc] init];
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
+ (LSLCLiveChatCustomItemObject* _Nullable)getLiveChatCustomItemObject:(const LSLCCustomItem*)customItem
{
    LSLCLiveChatCustomItemObject* obj = nil;
    if (NULL != customItem)
    {
        obj = [[LSLCLiveChatCustomItemObject alloc] init];
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
+ (LSLCLiveChatMsgPhotoItem* _Nullable)getLiveChatPhotoItemObject:(const LSLCPhotoItem*)photoItem{
        LSLCLiveChatMsgPhotoItem* obj = nil;
    if (NULL != photoItem)
    {
        obj = [[LSLCLiveChatMsgPhotoItem alloc] init];
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
+ (NSArray<LSLCEmotionTypeItemObject*>* _Nullable)getEmotionTypeItemObject:(const LSLCOtherEmotionConfigItem::TypeList &)typeList
{
    NSMutableArray *object = [NSMutableArray array];
    for(LSLCOtherEmotionConfigItem::TypeList::const_iterator iter = typeList.begin(); iter != typeList.end(); iter++){
        LSLCEmotionTypeItemObject* typeItem = [[LSLCEmotionTypeItemObject alloc] init];
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
+ (NSArray<LSLCEmotionTagItemObject*>* _Nullable)getEmotionTagItemObject:(const LSLCOtherEmotionConfigItem::TagList &)tagList
{
    NSMutableArray *object = [NSMutableArray array];
    for(LSLCOtherEmotionConfigItem::TagList::const_iterator iter = tagList.begin(); iter != tagList.end(); iter++){
        LSLCEmotionTagItemObject* tagItem = [[LSLCEmotionTagItemObject alloc] init];
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
+ (NSArray<LSLCEmotionItemObject*>* _Nullable)getEmotionItemObject:(const LSLCOtherEmotionConfigItem::EmotionList &)EmotionList
{
    NSMutableArray *object = [NSMutableArray array];
    for(LSLCOtherEmotionConfigItem::EmotionList::const_iterator iter = EmotionList.begin(); iter != EmotionList.end(); iter++){
        LSLCEmotionItemObject* EmotionItem = [[LSLCEmotionItemObject alloc] init];
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
+ (NSArray<LSLCMagicIconTypeItemObject*>* _Nullable)getMagicIconTypeItemObject:(const LSLCMagicIconConfig::MagicTypeList&)typeList
{
    NSMutableArray *object = [NSMutableArray array];
    for (LSLCMagicIconConfig::MagicTypeList::const_iterator iter = typeList.begin(); iter != typeList.end(); iter++) {
        LSLCMagicIconTypeItemObject* typeItem = [[LSLCMagicIconTypeItemObject alloc] init];
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
+ (NSArray<LSLCMagicIconItemObject*>* _Nullable)getMagicIconItemObject:(const LSLCMagicIconConfig::MagicIconList&)magicIconList
{
    NSMutableArray *object = [NSMutableArray array];
    for (LSLCMagicIconConfig::MagicIconList::const_iterator iter = magicIconList.begin(); iter != magicIconList.end() ; iter++) {
        LSLCMagicIconItemObject * typeItem = [[LSLCMagicIconItemObject alloc] init];
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
+ (LSLCMessageItem* _Nullable)getLiveChatMsgItem:(LSLCLiveChatMsgItemObject* _Nonnull)msg
{
    LSLCMessageItem* msgItem = new LSLCMessageItem;
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
            LSLCTextItem* textItem = [LSLCLiveChatItem2OCObj getLiveChatTextItem:msg.textMsg];
            msgItem->SetTextItem(textItem);
        }
        else if (MT_Warning == msg.msgType)
        {
            LSLCWarningItem* warningItem = [LSLCLiveChatItem2OCObj getLiveChatWarningItem:msg.warningMsg];
            msgItem->SetWarningItem(warningItem);
        }
        else if (MT_System == msg.msgType)
        {
            LSLCSystemItem* systemItem = [LSLCLiveChatItem2OCObj getLiveChatSystemItem:msg.systemMsg];
            msgItem->SetSystemItem(systemItem);
        }
        else if (MT_Custom == msg.msgType)
        {
            LSLCCustomItem* customItem = [LSLCLiveChatItem2OCObj getLiveChatCustomItem:msg.customMsg];
            msgItem->SetCustomItem(customItem);
        }
        else if(MT_Emotion == msg.msgType)
        {
            LSLCEmotionItem* emotionItem = [LSLCLiveChatItem2OCObj getLiveChatEmotionItem:msg.emotionMsg];
            msgItem->SetEmotionItem(emotionItem);
        }
        else if(MT_MagicIcon == msg.msgType)
        {
            LSLCMagicIconItem* magicIconItem = [LSLCLiveChatItem2OCObj getLiveChatMagicIconItem:msg.magicIconMsg];
            msgItem->SetMagicIconItem(magicIconItem);
        }
        else if (MT_Voice == msg.msgType)
        {
            LSLCVoiceItem* voiceItem = [LSLCLiveChatItem2OCObj getLiveChatVoiceItem:msg.voiceMsg];
            msgItem->SetVoiceItem(voiceItem);
        }
        else if (MT_Video == msg.msgType) {
            lcmm::LSLCVideoItem* videoItem = [LSLCLiveChatItem2OCObj getLiveChatVideoItem:msg.videoMsg];
            msgItem->SetVideoItem(videoItem);
        }
        else if (MT_Schedule == msg.msgType) {
            LSLCScheduleInviteItem* scheduleItem = [LSLCLiveChatItem2OCObj getLiveChatScheduleInviteItem:msg.scheduleMsg];
            msgItem->SetScheduleInviteItem(scheduleItem);
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
+ (LSLCTextItem* _Nullable)getLiveChatTextItem:(LSLCLiveChatTextItemObject* _Nonnull)text
{
    LSLCTextItem* textItem = new LSLCTextItem;
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
+ (LSLCWarningItem* _Nullable)getLiveChatWarningItem:(LSLCLiveChatWarningItemObject* _Nonnull)warning
{
    LSLCWarningItem* warningItem = new LSLCWarningItem;
    if (NULL != warningItem && warning != nil)
    {
        warningItem->m_message = [warning.message UTF8String];
        if (nil != warning.link)
        {
            warningItem->m_linkItem = new LSLCWarningLinkItem;
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
+ (LSLCSystemItem* _Nullable)getLiveChatSystemItem:(LSLCLiveChatSystemItemObject* _Nonnull)system
{
    LSLCSystemItem* systemItem = new LSLCSystemItem;
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
+ (LSLCCustomItem* _Nullable)getLiveChatCustomItem:(LSLCLiveChatCustomItemObject* _Nonnull)custom
{
    LSLCCustomItem* customItem = new LSLCCustomItem;
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

+ (LSLCPhotoItem* _Nullable)getLiveChatPhotoItem:(LSLCLiveChatMsgPhotoItem* _Nonnull)photo
{
    LSLCPhotoItem* photoItem = new LSLCPhotoItem;
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
+ (LSLCEmotionItem* _Nullable)getLiveChatEmotionItem:(LSLCLiveChatEmotionItemObject* _Nonnull)emotion
{
    LSLCEmotionItem* emotionItem = new LSLCEmotionItem;
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
+ (LSLCMagicIconItem* _Nullable)getLiveChatMagicIconItem:(LSLCLiveChatMagicIconItemObject* _Nonnull)magicIcon
{
    LSLCMagicIconItem* magicIconItem = new LSLCMagicIconItem;
    if(NULL != magicIconItem && magicIcon != nil){
        magicIconItem->m_magicIconId = magicIcon.magicIconId != nil ? [magicIcon.magicIconId UTF8String] : "";
        magicIconItem->m_sourcePath  = magicIcon.sourcePath != nil ? [magicIcon.sourcePath UTF8String] : "";
        magicIconItem->m_thumbPath   = magicIcon.thumbPath != nil ? [magicIcon.thumbPath UTF8String] : "";
    }
    return magicIconItem;
}

+ (LSLCVoiceItem* _Nullable)getLiveChatVoiceItem:(LSLCLiveChatMsgVoiceItem* _Nonnull)voiceItem
{
    LSLCVoiceItem* lcVoiceItem = new LSLCVoiceItem;
    if(NULL != lcVoiceItem && voiceItem != nil){
        lcVoiceItem->m_voiceId = voiceItem.voiceId != nil ? [voiceItem.voiceId UTF8String] : "";
        lcVoiceItem->m_filePath  = voiceItem.filePath != nil ? [voiceItem.filePath UTF8String] : "";
        lcVoiceItem->m_fileType   = voiceItem.fileType != nil ? [voiceItem.fileType UTF8String] : "";
        lcVoiceItem->m_checkCode = voiceItem.checkCode != nil ? [voiceItem.checkCode UTF8String] : "";
        lcVoiceItem->m_timeLength = voiceItem.timeLength;
        
    }
    return lcVoiceItem;
}

+ (lcmm::LSLCVideoItem* _Nullable)getLiveChatVideoItem:(LSLCLiveChatMsgVideoItem*_Nonnull)videoItem
{
    lcmm::LSLCVideoItem* lcVideoItem = new lcmm::LSLCVideoItem;
    if(NULL != lcVideoItem && videoItem != nil){
        lcVideoItem->m_videoId = videoItem.videoId != nil ? [videoItem.videoId UTF8String] : "";
        lcVideoItem->m_sendId  = videoItem.sendId != nil ? [videoItem.sendId UTF8String] : "";
        lcVideoItem->m_videoDesc   = videoItem.videoDesc != nil ? [videoItem.videoDesc UTF8String] : "";
        lcVideoItem->m_videoUrl = videoItem.videoUrl != nil ? [videoItem.videoUrl UTF8String] : "";
        lcVideoItem->m_bigPhotoFilePath   = videoItem.bigPhotoFilePath != nil ? [videoItem.bigPhotoFilePath UTF8String] : "";
        lcVideoItem->m_videoFilePath = videoItem.videoFilePath != nil ? [videoItem.videoFilePath UTF8String] : "";
        lcVideoItem->m_charge = videoItem.charge;
        
    }
    return lcVideoItem;
}

+ (LSLCScheduleInviteItem* _Nullable)getLiveChatScheduleInviteItem:(LSLCLiveChatScheduleMsgItemObject*_Nonnull)scheduleItem
{
    LSLCScheduleInviteItem* lcScheduleItem = new LSLCScheduleInviteItem;
    if(NULL != lcScheduleItem && scheduleItem != nil){
        lcScheduleItem->m_sessionId = scheduleItem.scheduleInviteId != nil ? [scheduleItem.scheduleInviteId UTF8String] : "";
        lcScheduleItem->m_type = scheduleItem.type;
        lcScheduleItem->m_timeZone  = scheduleItem.timeZone != nil ? [scheduleItem.timeZone UTF8String] : "";
        lcScheduleItem->m_timeZoneValue   = scheduleItem.timeZoneOffSet;
        lcScheduleItem->m_sessionDuration = scheduleItem.origintduration;
        lcScheduleItem->m_durationAdjusted = scheduleItem.duration;
        lcScheduleItem->m_startGmtTime = scheduleItem.startTime;
        lcScheduleItem->m_timePeriod = scheduleItem.period != nil ? [scheduleItem.period UTF8String] : "";
        lcScheduleItem->m_actionGmtTime = scheduleItem.statusUpdateTime;
        lcScheduleItem->m_sendGmtTime = scheduleItem.sendTime;
        
    }
    return lcScheduleItem;
}


#pragma mark - userinfo item
/**
 *  获取用户信息object
 *
 *  @param userInfo 用户信息item
 *
 *  @return 用户信息object
 */
+ (LSLCLiveChatUserInfoItemObject* _Nullable)getLiveChatUserInfoItemObjecgt:(const UserInfoItem&)userInfo
{
    LSLCLiveChatUserInfoItemObject* object = [[LSLCLiveChatUserInfoItemObject alloc] init];
    if (nil != object) {
        object.userId = [NSString stringWithUTF8String:userInfo.userId.c_str()];
        object.userName = [NSString stringWithUTF8String:userInfo.userName.c_str()];
        object.server = [NSString stringWithUTF8String:userInfo.server.c_str()];
        object.imgUrl = [NSString stringWithUTF8String:userInfo.imgUrl.c_str()];
        object.avatarImg = [NSString stringWithUTF8String:userInfo.avatarImg.c_str()];
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
+ (NSArray<LSLCLiveChatUserInfoItemObject*>* _Nonnull)getLiveChatUserInfoArray:(const UserInfoList&)userInfoList
{
    NSMutableArray* userInfoArray = [NSMutableArray array];
    for (UserInfoList::const_iterator iter = userInfoList.begin();
         iter != userInfoList.end();
         iter++)
    {
        LSLCLiveChatUserInfoItemObject* object = [self getLiveChatUserInfoItemObjecgt:(*iter)];
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
+ (LSLCLiveChatEmotionItemObject*) getLiveChatEmotionItemObject:(const LSLCEmotionItem *)EmotionItem
{
    LSLCLiveChatEmotionItemObject* object = nil;
    if(NULL != EmotionItem){
        object = [[LSLCLiveChatEmotionItemObject alloc] init];
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

+ (LSLCLiveChatEmotionConfigItemObject*)getLiveChatEmotionConfigItemObject:(const LSLCOtherEmotionConfigItem &)otherEmotionItem
{
    LSLCLiveChatEmotionConfigItemObject *object = nil;
    object                 = [[LSLCLiveChatEmotionConfigItemObject alloc] init];
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
+ (LSLCLiveChatMagicIconItemObject*)getLiveChatMagicIconItemObject:(const LSLCMagicIconItem*)magicIconItem
{
    LSLCLiveChatMagicIconItemObject* object = nil;
    if (NULL != magicIconItem) {
        object                              = [[LSLCLiveChatMagicIconItemObject alloc] init];
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
+ (LSLCLiveChatMagicIconConfigItemObject*)getLiveChatMagicIconConfigItemObject:(const LSLCMagicIconConfig&)magicConfig
{
    LSLCLiveChatMagicIconConfigItemObject* object = nil;
    object                                    = [[LSLCLiveChatMagicIconConfigItemObject alloc] init];
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
+ (LSLCLiveChatMsgVoiceItem*)getLiveChatVoiceItemObject:(const LSLCVoiceItem*)voiceItem
{
    LSLCLiveChatMsgVoiceItem* obj = nil;
    if (NULL != voiceItem)
    {
        obj = [[LSLCLiveChatMsgVoiceItem alloc] init];
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

+ (LSLCLiveChatMsgVideoItem* _Nullable)getLiveChatVideoItemObject:(const lcmm::LSLCVideoItem*_Nullable)videoItem
{
    LSLCLiveChatMsgVideoItem* obj = nil;
    if (NULL != videoItem)
    {
        obj = [[LSLCLiveChatMsgVideoItem alloc] init];
        obj.videoId = [NSString stringWithUTF8String:videoItem->m_videoId.c_str()];
        obj.sendId = [NSString stringWithUTF8String:videoItem->m_sendId.c_str()];
        obj.videoDesc = [NSString stringWithUTF8String:videoItem->m_videoDesc.c_str()];
        obj.videoUrl = [NSString stringWithUTF8String:videoItem->m_videoUrl.c_str()];
        obj.charge = videoItem->m_charge;
        //        obj.thumbPhotoFilePath = [NSString stringWithUTF8String:videoItem->m_thumbPhotoFilePath.c_str()];
        obj.bigPhotoFilePath = [NSString stringWithUTF8String:videoItem->m_bigPhotoFilePath.c_str()];
        obj.videoFilePath = [NSString stringWithUTF8String:videoItem->m_videoFilePath.c_str()];
    }
    return obj;
}

+ (LSLCLiveChatScheduleMsgItemObject* _Nullable)getLiveChatScheduleInviteItemObject:(const LSLCScheduleInviteItem*)scheduleInviteItem
{
        LSLCLiveChatScheduleMsgItemObject* obj = nil;
        if (NULL != scheduleInviteItem)
        {
            obj = [[LSLCLiveChatScheduleMsgItemObject alloc] init];
            obj.scheduleInviteId = [NSString stringWithUTF8String:scheduleInviteItem->m_sessionId.c_str()];
            obj.type = scheduleInviteItem->m_type;
            obj.timeZone = [NSString stringWithUTF8String:scheduleInviteItem->m_timeZone.c_str()];
            obj.timeZoneOffSet = scheduleInviteItem->m_timeZoneValue;
            obj.origintduration = scheduleInviteItem->m_sessionDuration;
            obj.duration = scheduleInviteItem->m_durationAdjusted;
            obj.startTime = scheduleInviteItem->m_startGmtTime;
            obj.period = [NSString stringWithUTF8String:scheduleInviteItem->m_timePeriod.c_str()];
            obj.statusUpdateTime = scheduleInviteItem->m_actionGmtTime;
            obj.sendTime = scheduleInviteItem->m_sendGmtTime;
        }
        return obj;
}

+ (LSLCLiveChatScheduleReplyItemObject* _Nullable)getLiveChatScheduleReplyItemObject:(const LSLCScheduleInviteReplyItem*)ScheduleReplyItem
{
    LSLCLiveChatScheduleReplyItemObject* obj = nil;
    if (NULL != ScheduleReplyItem)
    {
        obj = [[LSLCLiveChatScheduleReplyItemObject alloc] init];
        obj.scheduleId = [NSString stringWithUTF8String:ScheduleReplyItem->m_scheduleId.c_str()];
        obj.isScheduleAccept = ScheduleReplyItem->m_isScheduleAccept;
        obj.isScheduleFromMe = ScheduleReplyItem->m_isScheduleFromMe;
    }
    return obj;
}


//+ (LSLCLiveChatScheduleInfoItemObject* _Nullable)getLiveChatScheduleInfoItemObject:(const LSLCScheduleInfoItem&)msgItem {
//    LSLCLiveChatScheduleInfoItemObject* obj = [[LSLCLiveChatScheduleInfoItemObject alloc] init];
//    obj.manId = [NSString stringWithUTF8String:msgItem.manId.c_str()];
//    obj.womanId = [NSString stringWithUTF8String:msgItem.womanId.c_str()];
//    LSLCLiveChatScheduleMsgItemObject* msgObj = [[LSLCLiveChatScheduleMsgItemObject alloc] init];
//    msgObj.scheduleInviteId = [NSString stringWithUTF8String:msgItem.msg.sessionId.c_str()];
//    msgObj.type = msgItem.msg.type;
//    msgObj.timeZone = [NSString stringWithUTF8String:msgItem.msg.timeZone.c_str()];
//    msgObj.timeZoneOffSet = msgItem.msg.timeZoneOffSet;
//    msgObj.origintduration = msgItem.msg.sessionDuration;
//    msgObj.duration = msgItem.msg.durationAdjusted;
//    msgObj.startTime = msgItem.msg.startGmtTime;
//    msgObj.period = [NSString stringWithUTF8String:msgItem.msg.timePeriod.c_str()];
//    msgObj.inviteId = [NSString stringWithUTF8String:msgItem.msg.inviteId.c_str()];
//    msgObj.statusUpdateTime = msgItem.msg.actionGmtTime;
//    obj.msg = msgObj;
//
//    return obj;
//}

@end
