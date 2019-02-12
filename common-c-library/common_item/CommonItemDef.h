/*
 * author: Samson.Fan
 *   date: 2018-12-10
 *   file: CommonItemDef.h
 *   desc: IM和http的公共枚举
 */


#ifndef COMMONITEMDEF_H_
#define COMMONITEMDEF_H_

// 私信消息类型
typedef enum {
    IMCHATONLINESTATUS_UNKNOW = 0,    // 未知
    IMCHATONLINESTATUS_OFF = 1,      // 离线
    IMCHATONLINESTATUS_ONLINE = 2,   // 在线
    IMCHATONLINESTATUS_BEGIN = IMCHATONLINESTATUS_UNKNOW,
    IMCHATONLINESTATUS_END = IMCHATONLINESTATUS_ONLINE
    
}IMChatOnlineStatus;

// int 转换 IMProgramTicketStatus
inline IMChatOnlineStatus GetIntToIMChatOnlineStatus(int value) {
    return IMCHATONLINESTATUS_BEGIN < value && value <= IMCHATONLINESTATUS_END ? (IMChatOnlineStatus)value : IMCHATONLINESTATUS_UNKNOW;
}
#endif /* COMMONITEMDEF_H_ */
