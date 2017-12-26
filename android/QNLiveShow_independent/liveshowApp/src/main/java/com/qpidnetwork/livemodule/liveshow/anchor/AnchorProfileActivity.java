package com.qpidnetwork.livemodule.liveshow.anchor;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.webkit.WebView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.AnchorLevelType;
import com.qpidnetwork.livemodule.httprequest.item.ConfigItem;
import com.qpidnetwork.livemodule.httprequest.item.UserType;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.liveshow.BaseWebViewActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.guide.GuideActivity;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;

/**
 * Created by Hunter Mun on 2017/10/13.
 */

public class AnchorProfileActivity extends BaseWebViewActivity {

    public static final String WEB_URL_KEY_ENTERROOM = "enterroom";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //判断显示启动引导页
        showGuideView();
    }

    @Override
    public boolean onShouldOverrideUrlLoading(WebView view, String url) {
        //增加GA统计
        String moduleName = URL2ActivityManager.getInstance().getModuleNameByUrl(url);
        if(!TextUtils.isEmpty(moduleName)){
            if(moduleName.equals(URL2ActivityManager.KEY_URL_MODULE_NAME_NEW_BOOKING)){
                //点击预约直播按钮
                onAnalyticsEvent(getResources().getString(R.string.Live_EnterBroadcast_Category),
                        getResources().getString(R.string.Live_EnterBroadcast_Action_RequestBooking),
                        getResources().getString(R.string.Live_EnterBroadcast_Label_RequestBooking));
            }else if(moduleName.equals(URL2ActivityManager.KEY_URL_MODULE_NAME_LIVE_ROOM)){
                //点击进入直播间
                AnchorLevelType anchorType = URL2ActivityManager.getInstance().getAnchorTypeByUrl(url);
                String roomId = URL2ActivityManager.getInstance().getRoomIdByUrl(url);
                if(anchorType == AnchorLevelType.gold){
                    if(!TextUtils.isEmpty(roomId)){
                        //进入豪华私密直播间
                        onAnalyticsEvent(getResources().getString(R.string.Live_EnterBroadcast_Category),
                                getResources().getString(R.string.Live_EnterBroadcast_Action_VIPPrivateBroadcast),
                                getResources().getString(R.string.Live_EnterBroadcast_Label_VIPPrivateBroadcast));
                    }else{
                        //进入付费公开直播间
                        onAnalyticsEvent(getResources().getString(R.string.Live_EnterBroadcast_Category),
                                getResources().getString(R.string.Live_EnterBroadcast_Action_VIPPublicBroadcast),
                                getResources().getString(R.string.Live_EnterBroadcast_Label_VIPPublicBroadcast));
                    }
                }else if(anchorType == AnchorLevelType.silver){
                    if(!TextUtils.isEmpty(roomId)){
                        //进入标准私密直播间
                        onAnalyticsEvent(getResources().getString(R.string.Live_EnterBroadcast_Category),
                                getResources().getString(R.string.Live_EnterBroadcast_Action_PrivateBroadcast),
                                getResources().getString(R.string.Live_EnterBroadcast_Label_PrivateBroadcast));
                    }else{
                        //进入免费公开直播间
                        onAnalyticsEvent(getResources().getString(R.string.Live_EnterBroadcast_Category),
                                getResources().getString(R.string.Live_EnterBroadcast_Action_PublicBroadcast),
                                getResources().getString(R.string.Live_EnterBroadcast_Label_PublicBroadcast));
                    }
                }
            }
        }
        return super.onShouldOverrideUrlLoading(view, url);
    }

    /**
     * 普通webview加载网页
     * @param context
     * @param title
     * @param anchorid
     * @param showTitleBarWhenLoadSuc
     * @return
     */
    public static Intent getAnchorInfoIntent(Context context, String title, String anchorid, boolean showTitleBarWhenLoadSuc){
        Intent intent = new Intent(context, AnchorProfileActivity.class);
        intent.putExtra(WEB_TITLE, title);
        intent.putExtra(WEB_TITLE_BAR_SHOW_LOADSUC, showTitleBarWhenLoadSuc);
        ConfigItem configItem = LoginManager.getInstance().getLocalConfigItem();
        String url = configItem.anchorPage;
        StringBuilder sb = new StringBuilder(url);
        if(url.contains("?")){
            sb.append("&device=30");
        }else{
            sb.append("?device=30");
        }
        sb.append("&anchorid=");
        sb.append(anchorid);

        //修改为根据是否直播中提示
        int isEnterRoom = IMManager.getInstance().isCurrentInLive() ? 0:1;
        sb.append("&" + WEB_URL_KEY_ENTERROOM + "=");
        sb.append(String.valueOf(isEnterRoom));
        url = sb.toString();
        if(!TextUtils.isEmpty(url)){
            intent.putExtra(WEB_URL, url);
        }
        return intent;
    }

    /***************************************  显示启动引导页  **********************************/
    /**
     * 显示引导页
     */
    private void showGuideView(){
        if(LoginManager.getInstance().getLoginItem()!=null && LoginManager.getInstance().getLoginItem().userType == UserType.AllRoom){
            GuideActivity.show(mContext , GuideActivity.GuideType.PROFILE_A);
        }else{
            GuideActivity.show(mContext , GuideActivity.GuideType.PROFILE_B);
        }
    }
}
