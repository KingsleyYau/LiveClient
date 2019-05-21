package com.qpidnetwork.qnbridgemodule.util;

import android.content.Context;
import android.text.TextUtils;

import com.qpidnetwork.qnbridgemodule.datacache.LocalCorePreferenceManager;

import java.util.UUID;

/**
 * UUID工具类
 */
public class UUIDUtil {
    private static String KEY_SP_INSTALL_UUID = "KeyInstallUUID";

    public static synchronized void create(Context context){
        getUUID(context);
    }

    /**
     * 2019/2/20 Hardy
     * 获取安装唯一标记 uuid
     * @param context
     * @return
     */
    public static synchronized String getUUID(Context context){
        context = context.getApplicationContext();
        LocalCorePreferenceManager localCorePreferenceManager = new LocalCorePreferenceManager(context);

        String uuid = localCorePreferenceManager.getString(KEY_SP_INSTALL_UUID);

        if (TextUtils.isEmpty(uuid)) {
            uuid = UUID.randomUUID().toString();
            localCorePreferenceManager.save(KEY_SP_INSTALL_UUID, uuid);
        }

        return uuid;
    }
}
