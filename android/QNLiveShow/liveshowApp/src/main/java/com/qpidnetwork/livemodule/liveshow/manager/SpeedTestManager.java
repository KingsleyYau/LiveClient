package com.qpidnetwork.livemodule.liveshow.manager;

import android.content.Context;
import android.util.Log;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniOther;
import com.qpidnetwork.livemodule.httprequest.item.ServerItem;

import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Vector;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLSession;

/**
 * Created by Jagger on 2017/11/1.
 */

public class SpeedTestManager {

    private final int TimeOut = 10000;

    private Context mContext;
    private Vector<SpeedBean> mListSpeedBean = new Vector<>();
//    private int mIndex = 0 ;
    private boolean mIsWorking = false;

    /**
     * 测速数据和结果
     */
    class SpeedBean{
        private String serId = "";
        private String url = "";
        private int resTime = 0;
    }

    public static SpeedTestManager getInstance(Context c) {
        if (singleton == null) {
            singleton = new SpeedTestManager(c);
        }

        return singleton;
    }

    private static SpeedTestManager singleton;

    private SpeedTestManager(Context c) {
        mContext = c.getApplicationContext();
    }

    /**
     * 测试开始
     * @param serverItems
     */
    public void doTest(ServerItem[] serverItems){
        if(!mIsWorking){
            //上锁
            mIsWorking = true;
            //清空数据
            mListSpeedBean.clear();

            //更新数据
            for(int i = 0; i < serverItems.length; i++){
                SpeedBean speedBean = new SpeedBean();
                speedBean.serId = serverItems[i].serId;
                speedBean.url = serverItems[i].tUrl;

                mListSpeedBean.add(speedBean);
            }

            //测试开始
            start();
        }
    }

    /**
     * 测试开始
     */
    private synchronized void start(){
        if(mListSpeedBean.size() > 0){
            getResTime(mListSpeedBean.get(0));
        }else{
            //结束
            end();
        }
    }

    /**
     * 测试下一个
     */
    private void next(){
        if( mListSpeedBean.size() > 0){
            mListSpeedBean.remove(0);
            start();
        }
    }

    /**
     * 测速结束
     */
    private void end(){
        mIsWorking = false;
    }

    /**
     * 测试连接速度
     * @param speedBean
     */
    private void getResTime(final SpeedBean speedBean){
        Runnable r = new Runnable() {
            @Override
            public void run() {
            URL url = null;

            //判断协议
            try{
                url = new URL(speedBean.url);
            }catch (Exception e){
                //URL有错误,下一个
                next();
                return;
            }

            //请求
            if(url != null){
                if (url.getProtocol().toLowerCase().equals("https")) {
                    doHttpsRequest(speedBean);
                }else {
                    doHttpRequest(speedBean);
                }
            }else{
                //URL有错误,下一个
                next();
            }
            }
        };

        Thread t = new Thread(r);
        t.start();
    }

    /**
     * 如果连接失败，会被catch
     * @param speedBean
     */
    private void doHttpRequest(final SpeedBean speedBean){
        try {
            //开始时间
            long timeBegin = System.currentTimeMillis();

            //建立连接
            HttpURLConnection urlConnection = null;
            URL u = new URL(speedBean.url);
            urlConnection = (HttpURLConnection) u.openConnection();
            urlConnection.setConnectTimeout(TimeOut);

            //响应
            if(urlConnection.getResponseCode() == HttpsURLConnection.HTTP_OK){
                //结束时间
                long timeEnd = System.currentTimeMillis();
                int time = (int)(timeEnd - timeBegin);

                speedBean.resTime = time;
            }else{
                speedBean.resTime = -1;
            }

            //提交
            doSummit(speedBean);

        } catch (Exception e) {
            e.printStackTrace();
            //add by Jagger 2018-5-10
            //连接失败也提交结果
            if(speedBean != null){
                speedBean.resTime = -1;
                //提交
                doSummit(speedBean);
            }
        }
    }

    /**
     * 如果连接失败，会被catch
     * @param speedBean
     */
    private void doHttpsRequest(final SpeedBean speedBean){
        try {
            //开始时间
            long timeBegin = System.currentTimeMillis();

            //建立连接
            HttpsURLConnection urlConnection = null;
            URL u = new URL(speedBean.url);
            urlConnection = (HttpsURLConnection) u.openConnection();
            urlConnection.setConnectTimeout(TimeOut);
            urlConnection.setHostnameVerifier(new HostnameVerifier() {
                @Override
                public boolean verify(String hostname, SSLSession session) {
                    return true;
                }
            });

            //响应
            if(urlConnection.getResponseCode() == HttpsURLConnection.HTTP_OK){
                //结束时间
                long timeEnd = System.currentTimeMillis();
                int time = (int)(timeEnd - timeBegin);

                speedBean.resTime = time;
            }else{
                speedBean.resTime = -1;
            }

            //提交
            doSummit(speedBean);

        } catch (Exception e) {
            e.printStackTrace();
            //add by Jagger 2018-5-10
            //连接失败也提交结果
            if(speedBean != null){
                speedBean.resTime = -1;
                //提交
                doSummit(speedBean);
            }
        }
    }


    /**
     * 结果提交到服务器
     */
    private void doSummit(final SpeedBean speedBean){

        LiveRequestOperator.getInstance().ServerSpeed(speedBean.serId, speedBean.resTime, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                //下一个
                next();
            }
        });
    }

}
