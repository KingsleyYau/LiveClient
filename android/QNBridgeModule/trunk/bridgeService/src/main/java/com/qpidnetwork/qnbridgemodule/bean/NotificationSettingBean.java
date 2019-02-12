package com.qpidnetwork.qnbridgemodule.bean;

import java.io.Serializable;

public class NotificationSettingBean implements Serializable{

    public enum NotificationSettingType{
        SoundWithVibrate,
        Vibrate,
        Silent,
        NotPush,
    }

    public NotificationSettingBean() {
        mChatNotification = NotificationSettingType.Vibrate;
        mMailNotification = NotificationSettingType.Vibrate;
        mNormalNotification = NotificationSettingType.Vibrate;
    }

    public NotificationSettingType mChatNotification;
    public NotificationSettingType mMailNotification;
    public NotificationSettingType mNormalNotification;
}
