package com.qpidnetwork.livemodule.livechat;

import android.text.TextUtils;

import com.qpidnetwork.livemodule.livechathttprequest.OnLCGetThemeConfigCallback;
import com.qpidnetwork.livemodule.livechathttprequest.OnLCGetThemeDetailCallback;
import com.qpidnetwork.livemodule.livechathttprequest.item.ThemeConfig;
import com.qpidnetwork.livemodule.livechathttprequest.item.ThemeItem;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;

import java.util.HashMap;
import java.util.List;

public class ThemeConfigManager {
    private static ThemeConfigManager gThemeConfigManager;
    private ThemeConfig mThemeConfigItem = null;

    public static ThemeConfigManager newInstance() {
        if( gThemeConfigManager == null ) {
            gThemeConfigManager = new ThemeConfigManager();
        }
        return gThemeConfigManager;
    }

    public static ThemeConfigManager getInstance() {
        return gThemeConfigManager;
    }

    public ThemeConfigManager() {
        mPaidThemeList = new HashMap<String, ThemeItem>();
    }

    /**
     * 获取主题配置
     * @param user_sid
     * @param user_id
     */
    public void GetThemeConfig(String user_sid, String user_id, final OnLCGetThemeConfigCallback callback){
//        LCRequestJniLiveChat.GetThemeConfig(user_sid, user_id, new OnLCGetThemeConfigCallback() {
//
//            @Override
//            public void OnLCGetThemeConfig(boolean isSuccess, String errno,
//                                         String errmsg, ThemeConfig config) {
//                if((mThemeConfigItem == null) || (config != null && config.themeVersion != null
//                        && !config.themeVersion.equals(mThemeConfigItem.themeVersion))){
//                    //版本更新，更新本地缓存
//                    mThemeConfigItem = config;
//                }
//                callback.OnLCGetThemeConfig(isSuccess, errno, errmsg, config);
//            }
//        });
    }

    /**
     * 获取主题配置本地缓存
     * @return
     */
    public ThemeConfig getThemeConfig(){
        return mThemeConfigItem;
    }

    /**
     * 主题是否在商城中，否则为下架
     * @param themeId
     * @return
     */
    public boolean isThemeOffShelf(String themeId){
        boolean isOff = true;
        if(mThemeConfigItem != null
                && mThemeConfigItem.themeList != null){
            for(ThemeItem item : mThemeConfigItem.themeList){
                if(item.themeId.equals(themeId)){
                    isOff = false;
                    break;
                }
            }
        }
        return isOff;
    }

    /**
     * 获取主题详情
     * @param themeId
     * @return
     */
    public ThemeItem getThemeItemByThemeId(String themeId){
        ThemeItem themeItem = null;
        if(mThemeConfigItem != null
                && mThemeConfigItem.themeList != null){
            for(ThemeItem item : mThemeConfigItem.themeList){
                if(item.themeId.equals(themeId)){
                    themeItem = item;
                }
            }
        }
        if(themeItem == null){
            themeItem = getThemeItemFromPaidTheme(themeId);
        }
        return themeItem;
    }

    /**
     * 获取主题封面图下载URL
     * @param themeId
     * @return
     */
    public String getThemeThumbUrl(String themeId){
        StringBuffer loadUrl = new StringBuffer();
        if(mThemeConfigItem != null){
            String appSiteHost = WebSiteConfigManager.getInstance().getCurrentWebSite().getWebSiteHost();
            loadUrl.append(appSiteHost).append(mThemeConfigItem.themePath).append("img/").append(themeId).append("-mobile.png");
        }

        return loadUrl.toString();
    }

    /**
     * @param themeId
     *            图片的id
     * @return 拼接ImageUrl
     */
    public String getThemePreImgUrl(String themeId) {
        StringBuffer imgUrl = new StringBuffer();
        if(mThemeConfigItem != null){
            if (!TextUtils.isEmpty(mThemeConfigItem.themePath)) {
                String appSiteHost = WebSiteConfigManager.getInstance().getCurrentWebSite().getWebSiteHost();// 获取服务器地址
                imgUrl.append(appSiteHost).append(mThemeConfigItem.themePath).append("img/").append(themeId).append("_preview-mobile.png");
            }
        }
        return imgUrl.toString();
    }

    /************************** 获取已购买主题详情 ***********************************************/
    /**
     * 存放单独获取主题详情
     */
    private HashMap<String, ThemeItem> mPaidThemeList;

    public void GetThemeDetail(List<String> themeIds, String user_sid, String user_id, final OnLCGetThemeDetailCallback callback){
//        LCRequestJniLiveChat.GetThemeDetail(themeIds, user_sid, user_id, new OnLCGetThemeDetailCallback() {
//
//            @Override
//            public void OnLCGetThemeDetail(boolean isSuccess, String errno,
//                                         String errmsg, ThemeItem[] themeList) {
//                // TODO Auto-generated method stub
//                if(isSuccess){
//                    updatePaidThemeList(themeList);
//                }
//                callback.OnLCGetThemeDetail(isSuccess, errno, errmsg, themeList);
//            }
//        });
    }

    /**
     * 本地缓存主题详情
     * @param themeList
     */
    private void updatePaidThemeList(ThemeItem[] themeList){
        if(themeList != null){
            for(ThemeItem item : themeList){
                synchronized (mPaidThemeList) {
                    if(!mPaidThemeList.containsKey(item.themeId)){
                        mPaidThemeList.put(item.themeId, item);
                    }
                }
            }
        }
    }

    /**
     * 查看易购买的获取的主题详情是否存在
     * @param themeId
     */
    private ThemeItem getThemeItemFromPaidTheme(String themeId){
        ThemeItem item = null;
        synchronized (mPaidThemeList) {
            if(mPaidThemeList.containsKey(themeId)){
                item = mPaidThemeList.get(themeId);
            }
        }
        return item;
    }
}
