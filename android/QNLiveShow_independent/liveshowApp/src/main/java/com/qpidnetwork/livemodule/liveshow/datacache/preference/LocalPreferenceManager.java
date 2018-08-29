package com.qpidnetwork.livemodule.liveshow.datacache.preference;

import android.content.Context;
import android.content.SharedPreferences;
import android.text.TextUtils;
import android.util.Base64;

import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.model.LoginAccount;
import com.qpidnetwork.livemodule.liveshow.model.LoginParam;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.EOFException;
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
            ByteArrayInputStream bais = new ByteArrayInputStream(Base64.decode(temp.getBytes(), Base64.DEFAULT));
            ObjectInputStream ois = null;
            try {
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

    /**
     * 用于独立版本
     * 保存用户最近登录方式
     */
    public void saveLoginType(LoginManager.LoginType loginType){
        try {
            save(LocalPreferenceConstant.KEY_LOGIN_TYPE, loginType);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 用于独立版本
     * 取用户最近登录方式
     * @return
     */
    public LoginManager.LoginType getLoginType(){
        Object object = getObject(LocalPreferenceConstant.KEY_LOGIN_TYPE);
        if(object != null && (object instanceof LoginManager.LoginType)){
            return (LoginManager.LoginType)object;
        }
        return null;
    }

    /**
     * 用于独立版本
     * 保存用户FaceBook登录账户信息
     */
    public void saveFaceBookLoginAccount(LoginAccount loginAccount){
        try {
            save(LocalPreferenceConstant.KEY_FACEBOOK_LOGIN_ACCOUNT, loginAccount);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 用于独立版本
     * 取用户FaceBook登录账户信息
     * @return
     */
    public LoginAccount getFaceBookLoginAccount(){
        Object object = getObject(LocalPreferenceConstant.KEY_FACEBOOK_LOGIN_ACCOUNT);
        if(object != null && (object instanceof LoginAccount)){
            return (LoginAccount)object;
        }
        return null;
    }

    /**
     * 用于独立版本
     * 保存用户Email登录账户信息
     */
    public void saveEmailLoginAccount(LoginAccount loginAccount){
        try {
            save(LocalPreferenceConstant.KEY_EMAIL_LOGIN_ACCOUNT, loginAccount);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * 用于独立版本
     * 取用户Email登录账户信息
     * @return
     */
    public LoginAccount getEmailLoginAccount(){
        Object object = getObject(LocalPreferenceConstant.KEY_EMAIL_LOGIN_ACCOUNT);
        if(object != null && (object instanceof LoginAccount)){
            return (LoginAccount)object;
        }
        return null;
    }

    /**
     * 获取本地存储广告推广utm_reference
     * @return
     */
    public String getPromotionUtmReference(){
        return getString(LocalPreferenceConstant.KEY_PROMOTION_UTM_REFERENCE);
    }

    /**
     * 本地存储安装推广utm_reference
     * @param utm_reference
     */
    public void savePromotionUtmReference(String utm_reference){
        save(LocalPreferenceConstant.KEY_PROMOTION_UTM_REFERENCE, utm_reference);
    }
}
