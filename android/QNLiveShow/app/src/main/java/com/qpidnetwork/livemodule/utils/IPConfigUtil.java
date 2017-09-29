package com.qpidnetwork.livemodule.utils;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/9/18.
 */

public class IPConfigUtil {

    public static boolean isSimulatorEnv = true;

    //真机
    private static final String testVedioUrlInRealDevice = "rtmp://172.25.32.17:1936/aac/hunter";
    private static final String testIMServerUrlInRealDevice = "ws://172.25.32.17:3106";
    private static final String testWebSiteUrlInRealDevice = "http://172.25.32.17:3107";

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
}
