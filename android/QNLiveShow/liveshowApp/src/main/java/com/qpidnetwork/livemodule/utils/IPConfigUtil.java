package com.qpidnetwork.livemodule.utils;

import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/9/18.
 */

public class IPConfigUtil {

    public static boolean isSimulatorEnv = false;

    //真机
    private static final String testVedioUrlInRealDevice = "rtmp://172.25.32.17:1936/aac/hunter";
    private static final String testIMServerUrlInRealDevice = "ws://demo-live.charmdate.com:3006";  //"ws://172.25.32.17:7716";     //"ws://demo-live.charmdate.com:3006"
    private static final String testWebSiteUrlInRealDevice = "http://demo-live.charmdate.com:3007"; //"http://172.25.32.17:7717";    //"http://demo-live.charmdate.com:3007"

    //模拟器
    private static final String testVedioUrlInSimulator = "rtmp://192.168.88.17:1936/speex/hunter";
    private static final String testIMServerUrlInSimulator = "ws://192.168.88.17:3106";
    private static final String testWebSiteUrlInSimulator = "http://192.168.88.17:3107";

    /**
     * 视频流url
     * @return
     */
    public static String getTestVedioUrl(){
        return isSimulatorEnv ? testVedioUrlInSimulator : testVedioUrlInRealDevice;
    }

    /**
     * IM服务器
     * @return
     */
    public static String getTestIMServerUrl(){
        return isSimulatorEnv ? testIMServerUrlInSimulator : testIMServerUrlInRealDevice;
    }

    public static String getTestWebSiteUrl(){
        return isSimulatorEnv ? testWebSiteUrlInSimulator : testWebSiteUrlInRealDevice;
    }

    public static String getGiftNormalImgUrl(String giftId){
        if(!IPConfigUtil.isSimulatorEnv){
            throw new IllegalStateException("非礼物图片测试环境!");
        }
        return "http://192.168.88.152:8888/html/gift/"+giftId+".png";
    }

    public static String getGiftAdvanceAnimImgUrl(String giftId){
        String url = null;
        if(!IPConfigUtil.isSimulatorEnv){
            throw new IllegalStateException("非礼物图片测试环境!");
        }
        switch (Integer.valueOf(giftId).intValue()){
            case 10:
                url = "http://192.168.88.152:8888/html/gift/10.webp";
                break;
            case 11:
                url = "http://192.168.88.152:8888/html/gift/11.webp";
                break;
            default:
                break;
        }
        return url;
    }

    /**
     * 获取个人等级信息展示H5
     * @return
     */
    public static String getUserLevelInfoH5Url(){
        //http://192.168.88.17:8817/page/msite.html#/mylevel
        String result = "https://172.25.32.17:8717/page/msite.html?device=30#/mylevel";
        Log.d("IPConfigUtil","getUserLevelInfoH5Url- result:"+result);
        return result;
    }

    /**
     * 获取主播个人页展示H5
     * @param hostId
     * @return
     */
    public static String getBroadcasterInfoH5Url(String hostId){
        String result = "https://172.25.32.17:8717/page/app_page.html?AnchorData=AnchorData&device=30&anchorid="+hostId;
        Log.d("IPConfigUtil","getBroadcasterInfoH5Url- result:"+result);
        return result;
    }

    /**
     * 获取亲密度等级h5
     * @param hostId
     * @return
     */
    public static String getIntimacyH5Url(String hostId){
        String result = "https://172.25.32.17:8717/page/app_page.html?Intimacy=Intimacy&device=30&anchorid="+hostId;
        Log.d("IPConfigUtil","getBroadcasterInfoH5Url- result:"+result);
        return result;
    }

    public static String addCommonParamsToH5Url(String url){
        Log.d("IPConfigUtil","addCommonParamsToH5Url- url:"+url);
        StringBuilder sb = new StringBuilder(url);
        if(url.contains("?")){
            sb.append("&device=30");
        }else{
            sb.append("?device=30");
        }
        String result = sb.toString();
        Log.d("IPConfigUtil","addCommonParamsToH5Url- result:"+result);
        return result;
    }
}
