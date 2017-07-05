package com.qpidnetwork.liveshow.datacache.preference;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Base64;

import com.qpidnetwork.httprequest.item.LoginItem;
import com.qpidnetwork.liveshow.model.LoginParam;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;

/**
 * 本地Preference缓存管理器
 * Created by Hunter Mun on 2017/5/27.
 */

public class LocalPreferenceManager {

    private Context mContext;
    private SharedPreferences mSharedPreferences;

    public LocalPreferenceManager(Context context) {
        mContext = context;
        mSharedPreferences = mContext.getSharedPreferences(
                LocalPreferenceConstant.LIVE_SHOW_PREFERENCE_NAME,
                Context.MODE_PRIVATE);
    }

    private void save(String key, String value) {
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

    private String getString(String key) {
        String value = null;
        if (mSharedPreferences != null) {
            value = mSharedPreferences.getString(key, "");
        }
        return value;
    }

    private boolean getBoolean(String key) {
        boolean value = false;
        if (mSharedPreferences != null) {
            value = mSharedPreferences.getBoolean(key, false);
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
    private void save(String key,Object object) throws Exception {
        if(object instanceof Serializable && mSharedPreferences != null) {
            SharedPreferences.Editor editor = mSharedPreferences.edit();
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            try {
                ObjectOutputStream oos = new ObjectOutputStream(baos);
                oos.writeObject(object);//把对象写到流里
                String temp = new String(Base64.encode(baos.toByteArray(), Base64.DEFAULT));
                editor.putString(key, temp);
                editor.commit();
            } catch (IOException e) {
                e.printStackTrace();
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
    private Object getObject(String key) {
        Object obj = null;
        if(mSharedPreferences != null) {
            String temp = mSharedPreferences.getString(key, "");
            ByteArrayInputStream bais = new ByteArrayInputStream(Base64.decode(temp.getBytes(), Base64.DEFAULT));

            try {
                ObjectInputStream ois = new ObjectInputStream(bais);
                obj = ois.readObject();
            } catch (IOException ioex) {
                ioex.printStackTrace();
            } catch (ClassNotFoundException cnfex) {
                cnfex.printStackTrace();
            }
        }
        return obj;
    }

    /**
     * 获取初次启动标志位
     * @return
     */
    public boolean getFirstLaunchFlags(){
        return getBoolean(LocalPreferenceConstant.KEY_FIRST_START);
    }

    /**
     * 存储初次启动标志
     * @param isFirstLaunch
     */
    public void saveFirstLaunchFlags(boolean isFirstLaunch){
        save(LocalPreferenceConstant.KEY_FIRST_START, isFirstLaunch);
    }

    /**
     * 获取本地存储上次选择国家码
     * @return
     */
    public String getDefaultCountryCode(){
        return getString(LocalPreferenceConstant.KEY_DEFAULT_COUNTRY_CODE);
    }

    /**
     * 本地存储上次选择国家码
     * @param countryCode
     */
    public void saveDefaultCountryCode(String countryCode){
        save(LocalPreferenceConstant.KEY_DEFAULT_COUNTRY_CODE, countryCode);
    }

    /**
     * 获取状态栏高度
     * @return
     */
    public int getStatusBarHeight(){
        return getInt(LocalPreferenceConstant.KEY_SYSTEM_STATUS_BAR_HEIGHT);
    }

    /**
     * 存储状态栏高度
     * @param statusBarHeight
     */
    public void saveStatusBarHeight(int statusBarHeight){
        save(LocalPreferenceConstant.KEY_SYSTEM_STATUS_BAR_HEIGHT, statusBarHeight);
    }

    /**
     * 保存用户登录账户信息
     */
    public void saveLoginAccountInfoItem(LoginParam loginParam){
        try {
            save(LocalPreferenceConstant.KEY_LOGIN_ACCOUNT_INFO, loginParam);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     *
     * @return
     */
    public LoginParam getLoginAccountInfoItem(){
        Object object = getObject(LocalPreferenceConstant.KEY_LOGIN_ACCOUNT_INFO);
        if(object != null && (object instanceof LoginParam)){
            return (LoginParam)object;
        }
        return null;
    }

}