package com.qpidnetwork.qnbridgemodule.fcm;

import android.content.Context;
import android.text.TextUtils;

import com.google.firebase.iid.FirebaseInstanceId;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * Created by Hardy on 2019/1/22.
 */
public class InstanceIDUtil {

    private InstanceIDUtil() {
    }

    /**
     * 获取 gcm 返回的 register token ，发送给 app 服务器
     *
     * @param context
     * @param senderId
     * @return
     */
    public static String getGcmToken(Context context, String senderId) {
        if (TextUtils.isEmpty(senderId)) {
            senderId = "";
        }

//        InstanceID instanceID = InstanceID.getInstance(context);
        String token = "";
//        try {
//            token = instanceID.getToken(senderId, GoogleCloudMessaging.INSTANCE_ID_SCOPE, null);
//        } catch (IOException e) {
//            e.printStackTrace();
//        }

        return token;
    }

    public static String getFCMToken() {
        String refreshedToken = FirebaseInstanceId.getInstance().getToken();
        Log.i("info", "------------getFCMToken--------refreshedToken: " + refreshedToken);
        return refreshedToken;
    }
}
