package com.qpidnetwork.anchor.framework.picassocompat;

import android.content.Context;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.anchor.utils.Log;
import com.squareup.picasso.Picasso;

import java.io.File;
import java.security.SecureRandom;
import java.security.cert.CertificateException;
import java.security.cert.X509Certificate;
import java.util.Collections;

import javax.net.ssl.HostnameVerifier;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLSession;
import javax.net.ssl.SSLSocketFactory;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;

import okhttp3.Cache;
import okhttp3.OkHttpClient;
import okhttp3.Protocol;

/**
 * 为picasso增加https支持(需要进程启动的时候初始化)
 * Created by Hunter on 17/11/22.
 */

public class PicassoHttpsSupportUtil {

    public static final long CACHE_MAX_TIME= 60*60*24*7;
    public static final long CACHE_MAX_SIZE= 100*1024*1024;

    private static final String TAG = PicassoHttpsSupportUtil.class.getSimpleName();

    /**
     * 添加picasso https支持
     */
    public static void openHttpsSupport(Context context){
        try{
            Picasso picasso = new Picasso.Builder(context)
                    .downloader(new ImageDownLoader(getUnsafeOkHttpClient(context)))
                    .build();
            //是否开启log
            boolean isDebug = context.getResources().getBoolean(R.bool.demo);
            Log.d(TAG,"openHttpsSupport-isDebug:"+isDebug);
            picasso.setLoggingEnabled(isDebug);
            //是否开启图片左上角图片加载来源角标标识，蓝色-disk,绿色-memory,红色-network
            picasso.setIndicatorsEnabled(false);
            Picasso.setSingletonInstance(picasso);
        }catch (Exception e){
            Log.i(TAG, "openHttpsSupport Exception: " + e.toString());
            e.printStackTrace();
        }
    }

    private static OkHttpClient getUnsafeOkHttpClient(Context context) throws  Exception{
        final X509TrustManager trustManager = new X509TrustManager() {
            @Override
            public void checkClientTrusted(X509Certificate[] chain, String authType) throws CertificateException {

            }

            @Override
            public void checkServerTrusted(X509Certificate[] chain, String authType) throws CertificateException {

            }

            @Override
            public X509Certificate[] getAcceptedIssuers() {
                return new X509Certificate[0];
            }
        };

        //Install the all-trusring trust manager
        SSLContext sslContext = SSLContext.getInstance("SSL");
        sslContext.init(null, new TrustManager[]{trustManager}, new SecureRandom());
        //create an ssl socket factory with all-trusting manager
        SSLSocketFactory sslSocketFactory = sslContext.getSocketFactory();

        OkHttpClient okHttpClient = new OkHttpClient
                .Builder()
                .protocols(Collections.singletonList(Protocol.HTTP_1_1))
                .sslSocketFactory(sslSocketFactory, trustManager)
                .hostnameVerifier(new HostnameVerifier() {
                    @Override
                    public boolean verify(String hostname, SSLSession session) {
                        return true;
                    }
                })
                .addNetworkInterceptor(new FileDownloadInterceptor())
                .cache(new Cache(new File(FileCacheManager.getInstance().GetPicassoLocalPath()), CACHE_MAX_SIZE))
                .addInterceptor(new CacheInterceptor(context, CACHE_MAX_TIME))
                .addNetworkInterceptor(new CacheInterceptor(context, CACHE_MAX_TIME))
                .build();

        return okHttpClient;
    }
}
