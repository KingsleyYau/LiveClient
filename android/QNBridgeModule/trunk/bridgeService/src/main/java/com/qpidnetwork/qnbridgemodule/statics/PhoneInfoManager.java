package com.qpidnetwork.qnbridgemodule.statics;

import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;
import android.util.Base64;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

/**
 * 请求收集手机硬件信息管理器
 * @author Samson Fan
 *
 */
public class PhoneInfoManager {

    /**
     * 请求收集手机硬件信息
     * @param manId
     */
    public static PhoneInfoCheckResult CheckRequestPhoneInfo(Context context, String manId)
    {
        // 是否发送请求
        boolean isRequest = false;
        // 是否新用户(非新安装)
        boolean isNewUser = false;

        // 获取缓存信息
        PhoneInfoParam param = GetPhoneInfoParam(context);
        if ((null != param) && (param.preLoginUserList != null)) {
            // 设置请求默认为true
            isRequest = true;
            // 查找用户是否已经登录过
            for (String userId : param.preLoginUserList) {
                if (userId.compareTo(manId) == 0) {
                    // 不是新用户，不发送请求
                    isRequest = false;
                    break;
                }
            }

            if (isRequest) {
                // 是新用户
                isNewUser = true;
                param.preLoginUserList.add(manId);
            }
        }
        else {
            // 从未登录过，需要发送新安装请求
            isRequest = true;
            param = new PhoneInfoParam();
            param.preLoginUserList.add(manId);
        }

        // 保存信息
        if (null != param && isRequest) {
            SavePhoneInfoParam(context, param);
        }

        return new PhoneInfoCheckResult(isNewUser, isRequest);
    }

    /**
     * 缓存PhoneInfo参数
     * @param context
     * @param item
     */
    public static void SavePhoneInfoParam(Context context, PhoneInfoParam item) {
        SharedPreferences mSharedPreferences = context.getSharedPreferences("base64", Context.MODE_PRIVATE);

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ObjectOutputStream oos= null;
        try {
            oos = new ObjectOutputStream(baos);
            if( item != null ) {
                oos.writeObject(item);
            }

            String personBase64 = new String(Base64.encode(baos.toByteArray(), Base64.DEFAULT));
            SharedPreferences.Editor editor = mSharedPreferences.edit();
            editor.putString("PhoneInfoParam", personBase64);
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
     * 获取缓存PhoneInfo参数
     * @param context
     * @return
     */
    public static PhoneInfoParam GetPhoneInfoParam(Context context) {
        PhoneInfoParam item = null;

        ByteArrayInputStream bais = null;
        ObjectInputStream ois = null;
        try {
            SharedPreferences mSharedPreferences = context.getSharedPreferences("base64", Context.MODE_PRIVATE);
            String personBase64 = mSharedPreferences.getString("PhoneInfoParam", "");
            byte[] base64Bytes = Base64.decode(personBase64.getBytes(), Base64.DEFAULT);

            // 2018/11/10 Hardy
            if (TextUtils.isEmpty(personBase64)) {
                return item;
            }

            bais = new ByteArrayInputStream(base64Bytes);
            ois = new ObjectInputStream(bais);

            item = (PhoneInfoParam) ois.readObject();
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
