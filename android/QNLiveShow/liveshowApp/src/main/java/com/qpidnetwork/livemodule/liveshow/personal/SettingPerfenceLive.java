package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;
import android.util.Base64;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

/**
 * Created by Hardy on 2018/9/20.
 * 直播——Push 的开关标记 sp
 * 参考 QN 的类 SettingPerfence
 *
 * 2018/09/28 Hardy 暂时去掉
 */
@Deprecated
public class SettingPerfenceLive {

    // QN 是 base64，这里也保持生成在同一个 XML 文件
    private static final String FILE_NAME = "base64";
    // QN 是 NotificationItem
    private static final String NOTIFICATION_KEY = "NotificationItem_Live_";

    public enum NotificationSetting {
        SoundWithVibrate,
        Vibrate,
        Silent,
        None,
    }

    public static class NotificationItem implements Serializable {

        private static final long serialVersionUID = 3517990274449628568L;

        public NotificationItem() {
            mPrivateNotification = NotificationSetting.Vibrate;
            mMailNotification = NotificationSetting.Vibrate;
            mInvitationNotification = NotificationSetting.Vibrate;
        }

        public NotificationSetting mPrivateNotification;
        public NotificationSetting mMailNotification;
        public NotificationSetting mInvitationNotification;
    }

    /**
     * 缓存Notification配置
     *
     * @param context 上下文
     * @param item
     */
    public static void saveNotificationItem(Context context, NotificationItem item, String userId) {
        if (TextUtils.isEmpty(userId)) {
            return;
        }

        SharedPreferences mSharedPreferences = context.getSharedPreferences(FILE_NAME, Context.MODE_PRIVATE);

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ObjectOutputStream oos = null;
        try {
            oos = new ObjectOutputStream(baos);
            oos.writeObject(item);

            String personBase64 = new String(Base64.encode(baos.toByteArray(), Base64.DEFAULT));
            SharedPreferences.Editor editor = mSharedPreferences.edit();
            editor.putString(NOTIFICATION_KEY + userId, personBase64);
            editor.commit();
        } catch (IOException e) {
            e.printStackTrace();
        }
        // 2018/11/10 Hardy
        finally {
            try {
                if (baos != null) {
                    baos.close();
                }
                if (oos != null) {
                    oos.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * 获取缓存Notification
     *
     * @param context 上下文
     * @return
     */
    public static NotificationItem getNotificationItem(Context context, String userId) {
        if (TextUtils.isEmpty(userId)) {
            return null;
        }

        NotificationItem item = new NotificationItem();

        ByteArrayInputStream bais = null;
        ObjectInputStream ois = null;

        try {
            SharedPreferences mSharedPreferences = context.getSharedPreferences(FILE_NAME, Context.MODE_PRIVATE);
            String personBase64 = mSharedPreferences.getString(NOTIFICATION_KEY + userId, "");
            byte[] base64Bytes = Base64.decode(personBase64.getBytes(), Base64.DEFAULT);

            // 2018/11/10 Hardy
            if (TextUtils.isEmpty(personBase64)) {
                return null;
            }

            bais = new ByteArrayInputStream(base64Bytes);
            ois = new ObjectInputStream(bais);

            item = (NotificationItem) ois.readObject();
        } catch (Exception e) {
            e.printStackTrace();
        }
        // 2018/11/10 Hardy
        finally {
            try {
                if (bais != null) {
                    bais.close();
                }
                if (ois != null) {
                    ois.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return item;
    }


}
