package com.qpidnetwork.livemodule.liveshow.liveroom.gift;

import android.app.Activity;
import android.os.Handler;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.lang.ref.WeakReference;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/9/18.
 */

public class CustomShowTimeToast {

    private final String TAG = CustomShowTimeToast.class.getSimpleName();

    private WeakReference<Activity> context;
    private Toast toast;
    private long showTime;
    private Handler handler = new Handler();
    private long startTime = 0l;
    private boolean isShowingToast = false;

    public CustomShowTimeToast(Activity context, long showTime){
        this.showTime = showTime;
        this.context = new WeakReference<Activity>(context);
        toast = new Toast(context);
        toast.setGravity(Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL,0, DisplayUtil.dip2px(context,64f));
        toast.setView(View.inflate(context,R.layout.view_custom_toast, null));
    }

    public void setGravity(int gravity){
        if(Gravity.CENTER == gravity){
            toast.setGravity(gravity,0,0);
        }else{
            toast.setGravity(Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL,0,
                    DisplayUtil.dip2px(context.get(),64f));
        }
    }

    public void show(String msg){
        Log.d(TAG,"show-msg:"+msg);
        startTime = System.currentTimeMillis();
        TextView tv = (TextView) toast.getView().findViewById(android.R.id.message);
        tv.setText(msg);
        Log.d(TAG,"show-isShowingToast:"+isShowingToast);
        if(!isShowingToast){
            isShowingToast = true;
            handler.post(checkShowTimeRunnable);
        }

    }

    private void hide(){
        if(null != toast){
            toast.cancel();
            isShowingToast = false;
        }
    }

    private Runnable checkShowTimeRunnable = new Runnable() {
        @Override
        public void run() {
            long duration = showTime - System.currentTimeMillis()+startTime;
            if(duration>0){
                if(null != toast){
                    toast.show();
                }
                if(duration>=Toast.LENGTH_SHORT){
                    handler.postDelayed(checkShowTimeRunnable,Toast.LENGTH_SHORT);
                }else{
                    handler.postDelayed(checkShowTimeRunnable,duration);
                }
            }else{
                hide();
            }
        }
    };
}
