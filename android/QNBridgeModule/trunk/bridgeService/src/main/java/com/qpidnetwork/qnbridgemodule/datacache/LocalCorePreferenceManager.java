package com.qpidnetwork.qnbridgemodule.datacache;

import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;
import android.util.Base64;

import com.qpidnetwork.qnbridgemodule.bean.AccountInfoBean;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;
import com.qpidnetwork.qnbridgemodule.bean.GoogleReferrerItem;
import com.qpidnetwork.qnbridgemodule.bean.NotificationSettingBean;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.EOFException;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

public class LocalCorePreferenceManager {

    private Context mContext;
    private SharedPreferences mSharedPreferences;

    public LocalCorePreferenceManager(Context context){
        mContext = context;
        mSharedPreferences = mContext.getSharedPreferences(
                CommonConstant.LOCAL_CORE_DATACACHE_PREFERENCE_FILE,
                Context.MODE_PRIVATE);
    }

    public void save(String key, String value) {
        if (mSharedPreferences != null) {
            SharedPreferences.Editor edit = mSharedPreferences.edit();
            edit.putString(key, value);
            edit.commit();
        }
    }

    private void save(String key, boolean value) {
        if (mSharedPreferences != null) {
            SharedPreferences.Editor edit = mSharedPreferences.edit();
            edit.putBoolean(key, value);
            edit.commit();
        }
    }
    private void save(String key, int value) {
        if (mSharedPreferences != null) {
            SharedPreferences.Editor edit = mSharedPreferences.edit();
            edit.putInt(key, value);
            edit.commit();
        }
    }

    public String getString(String key) {
        String value = null;
        if (mSharedPreferences != null) {
            value = mSharedPreferences.getString(key, "");
        }
        return value;
    }

    private boolean getBoolean(String key) {
        return getBoolean(key, false);
    }

    private boolean getBoolean(String key, boolean defaultValue) {
        boolean value = false;
        if (mSharedPreferences != null) {
            value = mSharedPreferences.getBoolean(key, defaultValue);
        }
        return value;
    }

    private int getInt(String key) {
        int value = -1;
        if (mSharedPreferences != null) {
            value = mSharedPreferences.getInt(key, -1);
        }
        return value;
    }

    /**
     * 将序列化的对象存储到本地
     * @param object
     */
    public void save(String key,Object object) throws Exception {
        if(object instanceof Serializable && mSharedPreferences != null) {
            SharedPreferences.Editor editor = mSharedPreferences.edit();
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ObjectOutputStream oos = new ObjectOutputStream(baos);
            try {
                oos.writeObject(object);//把对象写到流里
                String temp = new String(Base64.encode(baos.toByteArray(), Base64.DEFAULT));
                editor.putString(key, temp);
                editor.commit();
            } catch (IOException e) {
                e.printStackTrace();
            }finally {
                if(baos != null){
                    baos.close();
                }
                if(oos != null){
                    oos.close();
                }
            }
        }else {
            throw new Exception("User must implements Serializable");
        }
    }

    /**
     * 读取本地存储的序列化的对象
     * @param key
     * @return
     */
    public Object getObject(String key) {
        Object obj = null;
        if(mSharedPreferences != null) {
            String temp = mSharedPreferences.getString(key, "");
            if(TextUtils.isEmpty(temp)){
                return obj;
            }
            ByteArrayInputStream bais = null;
            ObjectInputStream ois = null;
            try {
                bais = new ByteArrayInputStream(Base64.decode(temp.getBytes(), Base64.DEFAULT));
                ois = new ObjectInputStream(bais);
                obj = ois.readObject();
            } catch (EOFException eofex){
                eofex.printStackTrace();
            } catch (IOException ioex) {
                ioex.printStackTrace();
            } catch (ClassNotFoundException cnfex) {
                cnfex.printStackTrace();
            }finally {
                try {
                    if (bais != null) {
                        bais.close();
                    }
                    if (ois != null) {
                        ois.close();
                    }
                }catch (IOException e){
                    e.printStackTrace();
                }
            }
        }
        return obj;
    }

    /**
     * 保存通知中心通知设置
     */
    public void saveNotifcationSettings(NotificationSettingBean notificationSettings){
        try {
            save(CommonConstant.LOCAL_CORE_DATACACHE_KEY_NOTIFICATION, notificationSettings);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 获取通知中心通知设置
     * @return
     */
    public NotificationSettingBean getNotifcationSettings(){
        Object object = getObject(CommonConstant.LOCAL_CORE_DATACACHE_KEY_NOTIFICATION);
        if(object != null && (object instanceof NotificationSettingBean)){
            return (NotificationSettingBean)object;
        }
        return null;
    }


    /**
     * 获取最后使用站点
     * @return
     */
    public int getCurrentSelectedSiteId(){
        return getInt(CommonConstant.LOCAL_CORE_DATACACHE_KEY_CURRENT_SITEID);
    }

    /**
     * 缓存最后选中站点
     * @param websiteIndex
     */
    public void saveCurrentSelectedSiteId(int websiteIndex){
        save(CommonConstant.LOCAL_CORE_DATACACHE_KEY_CURRENT_SITEID, websiteIndex);
    }

    /**
     * 保存本地账号信息
     */
    public void saveAccountInfo(AccountInfoBean accountInfo){
        try {
            save(CommonConstant.LOCAL_CORE_DATACACHE_KEY_ACCOUNT_INFO, accountInfo);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 读取本地存储本地账号信息
     * @return
     */
    public AccountInfoBean getAccountInfo(){
        Object object = getObject(CommonConstant.LOCAL_CORE_DATACACHE_KEY_ACCOUNT_INFO);
        if(object != null && (object instanceof AccountInfoBean)){
            return (AccountInfoBean)object;
        }
        return null;
    }

    /**
     * 保存本地从Google service读取utm_reference
     * @param googleReferrer
     */
    public void saveGoogleReferrer(GoogleReferrerItem googleReferrer){
        try {
            save(CommonConstant.KEY_SP_GoogleReferrer, googleReferrer);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 读取本地从Google service读取的utm_reference
     * @return
     */
    public GoogleReferrerItem getGoogleReferrer(){
        Object object = getObject(CommonConstant.KEY_SP_GoogleReferrer);
        if(object != null && (object instanceof GoogleReferrerItem)){
            return (GoogleReferrerItem)object;
        }
        return null;
    }

    /**
     * 保存安装第一次注册是否提交过
     * @param isSummit
     */
    public void saveInstallRegisterSummitted(boolean isSummit){
        try {
            save(CommonConstant.KEY_INSTALL_FIRST_REGISTER_FLAGS, isSummit);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 读取安装第一次注册是否提交过
     * @return
     */
    public boolean getInstallRegisterSummitted(){
        return getBoolean(CommonConstant.KEY_INSTALL_FIRST_REGISTER_FLAGS);
    }

    /**
     * 保存已提交过InstallLog
     */
    public void saveInstallLogSummitedStatus(){
        try {
            save(CommonConstant.SP_KEY_INSTALL_LOGS_BEFORE_AUTH_IS_SUMMIT , true);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 是否提交过InstallLog
     * @return
     */
    public boolean getInstallLogSummitStatus(){
        boolean isSummit = false;
        isSummit = getBoolean(CommonConstant.SP_KEY_INSTALL_LOGS_BEFORE_AUTH_IS_SUMMIT);
//        Log.i("Jagger" , "InstallLogsManager getSummitStatus:" + isSummit);
        return isSummit;
    }

    /**
     * 保存是否显示hangout列表头
     */
    public void saveHangOutListHeaderGone(){
        try {
            save(CommonConstant.SP_KEY_HANG_OUT_LIST_HEADER_IS_VISIBLE , false);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 是否显示hangout列表头
     * @return
     */
    public boolean getHangOutListHeaderStatus(){
        boolean isSummit = false;
        isSummit = getBoolean(CommonConstant.SP_KEY_HANG_OUT_LIST_HEADER_IS_VISIBLE, true);
//        Log.i("Jagger" , "InstallLogsManager HangOutListHeader:" + isSummit);
        return isSummit;
    }
}
