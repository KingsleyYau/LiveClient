package com.qpidnetwork.livemodule.utils;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.os.Build;
import android.support.v4.content.ContextCompat;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * Description:
 * <p>
 * Created by Harry on 2018/1/25.
 */

public class HotItemStyleManager {

    private static final String TAG = HotItemStyleManager.class.getSimpleName();

    /**
     * * 动态调整hot/following列表的view-now/invite-to-one-by-one的topmargin
     *
     * @param context
     * @param btnView
     * @param hasFreeFlag
     * @param publicLive
     */
    public static void resetHotItemButtomStyle(Context context, ImageView btnView, boolean hasFreeFlag, boolean publicLive){
        Log.d(TAG,"resetHotItemButtomStyle-hasFreeFlag:"+hasFreeFlag+" publicLive:"+publicLive);
        //具体的LayoutParams类型需要根据R.layout.item_hot_list.xml中btnPrivate、btnPublic两个按钮的父布局类型来定
        try {
            LinearLayout.LayoutParams btnLayoutParams =(LinearLayout.LayoutParams) btnView.getLayoutParams();
            //有free标识，距离顶部的间距为5dp，没有则为12dp
            btnLayoutParams.topMargin = DisplayUtil.dip2px(context,hasFreeFlag ? 4f : 11f);
            //Java对象持有相同指针引用
//            btnView.setLayoutParams(btnLayoutParams);
            Log.d(TAG,"resetHotItemButtomStyle-topMargin:"+btnLayoutParams.topMargin);
            int bgResId = 0;
            if(publicLive){
                bgResId = hasFreeFlag ? R.drawable.list_button_view_free_public_broadcast_free:
                        R.drawable.list_button_view_free_public_broadcast;
            }else{
                bgResId = hasFreeFlag ? R.drawable.list_button_start_private_broadcast_free :
                        R.drawable.list_button_start_private_broadcast;
            }
            btnView.setImageDrawable(context.getResources().getDrawable(bgResId));

            // 2019/4/22 Hardy
            setHotItemButtonForeground(btnView, hasFreeFlag);

        }catch (Exception ex){
            ex.printStackTrace();
        }
    }


    /**
     * 2019/04/22 Hardy
     * 获取图片水波纹的资源
     * @param btnView
     * @param hasFreeFlag
     */
    public static void setHotItemButtonForeground(ImageView btnView,boolean hasFreeFlag){
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            int resId = hasFreeFlag ? R.drawable.touch_feedback_btn_hot_list_free : R.drawable.touch_feedback_btn_hot_list;
            Drawable drawable = ContextCompat.getDrawable(btnView.getContext(), resId);
            btnView.setForeground(drawable);
        }
    }
}
