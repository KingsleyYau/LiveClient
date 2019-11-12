package com.qpidnetwork.livemodule.httprequest.item;


import com.qpidnetwork.livemodule.utils.UserInfoUtil;

/**
 * 直播间列表通用item数据结构
 *
 * @author Jagger 2018-5-28
 */
public class ContactItem {

    public ContactItem() {

    }

    /**
     * 热播列表item数据结构
     *
     * @param userId          主播ID
     * @param nickName        主播昵称
     * @param avatarImg       主播头像url
     * @param coverImg        直播间封面图url
     * @param onlienStatus    主播在线状态
     * @param publicRoomId    公开直播间ID（空值，表示不在公开中）
     * @param roomType        直播间类型
     * @param lastContactTime 最后联系人时间
     * @param priv            权限
     */
    public ContactItem(String userId,
                       String nickName,
                       String avatarImg,
                       String coverImg,
                       int onlienStatus,
                       String publicRoomId,
                       int roomType,
                       int lastContactTime,
                       HttpAuthorityItem priv) {
        this.anchorId = userId;
        this.nickName = nickName;
        this.avatarImg = avatarImg;
        this.coverImg = coverImg;

        if (onlienStatus < 0 || onlienStatus >= AnchorOnlineStatus.values().length) {
            this.onlineStatus = AnchorOnlineStatus.Unknown;
        } else {
            this.onlineStatus = AnchorOnlineStatus.values()[onlienStatus];
        }

        this.publicRoomId = publicRoomId;


        if (roomType < 0 || roomType >= LiveRoomType.values().length) {
            this.roomType = LiveRoomType.Unknown;
        } else {
            this.roomType = LiveRoomType.values()[roomType];
        }

        this.lastContactTime = lastContactTime;
        this.priv = priv;

        // 2019/8/9 Hardy
        this.lastContactTimeString = UserInfoUtil.getMyContactLastContactTime(this.lastContactTime);
    }

    public String anchorId;
    public String nickName;
    public String avatarImg;
    public String coverImg;
    public AnchorOnlineStatus onlineStatus;
    public String publicRoomId;
    public LiveRoomType roomType;
    public int lastContactTime;
    public HttpAuthorityItem priv;

    // 2019/8/9 Hardy 自定义字段
    public String lastContactTimeString;
}
