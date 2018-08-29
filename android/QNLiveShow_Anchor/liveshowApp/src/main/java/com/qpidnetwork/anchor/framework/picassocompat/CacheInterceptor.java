package com.qpidnetwork.anchor.framework.picassocompat;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/12/12.
 */

import android.content.Context;

import com.qpidnetwork.anchor.utils.Log;
import com.qpidnetwork.anchor.utils.NetworkUtil;

import java.io.IOException;

import okhttp3.CacheControl;
import okhttp3.Interceptor;
import okhttp3.Request;
import okhttp3.Response;


public class CacheInterceptor implements Interceptor {

    private Context mContext;
    private final String TAG = CacheInterceptor.class.getSimpleName();
    private long maxTime = 60*60*24*7;

    public CacheInterceptor(Context context, long maxTime){
        this.mContext = context.getApplicationContext();
        this.maxTime = maxTime;
    }

    @Override
    public Response intercept(Chain chain) throws IOException {
        Request request = chain.request();
        Response response = null;
        //如果没有网络，则启用FORCE_CACHE
        if (NetworkUtil.isNetworkConnected(mContext)) {
            response = chain.proceed(request);
            String cacheControl = request.cacheControl().toString();
            Log.d(TAG, "intercept-"+maxTime+ "s load cahe:" + cacheControl);
            response = response.newBuilder()
                    .header("Cache-Control", "public, max-age=" + maxTime)
                    .removeHeader("Pragma")
                    .build();
        } else {
            Log.d(TAG, "intercept-no network load cahe");
            request = request.newBuilder()
                    .cacheControl(CacheControl.FORCE_CACHE)
                    .build();
            response = chain.proceed(request);
            response = response.newBuilder()
                    .header("Cache-Control", "public, only-if-cached, max-stale=" + maxTime)
                    .removeHeader("Pragma")
                    .build();
        }
        return response;
    }
}
