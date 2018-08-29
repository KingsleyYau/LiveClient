package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;

import com.qpidnetwork.livemodule.R;

/**
 * 列表空数据界面
 * @author Jagger 2018-7-10
 */
public class ErrorView extends LinearLayout {

    private Button btnRetry;

    private OnClickedEventsListener mOnClickedEventsListener;

    /**
     * view内点击事件
     */
    public interface OnClickedEventsListener{
        void onRetry();
    }

    public ErrorView(Context context) {
        super(context);
        createView();
    }

    public ErrorView(Context context , AttributeSet attrs) {
        super(context, attrs);
        createView();
    }

    private void createView() {

        View v = LayoutInflater.from(getContext()).inflate(
                R.layout.live_layout_error_page, null);

        btnRetry = (Button)v.findViewById(R.id.btnRetry);
        btnRetry.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if(mOnClickedEventsListener != null){
                    mOnClickedEventsListener.onRetry();
                }
            }
        });

        this.setGravity(Gravity.CENTER);
        this.addView(v);
    }

    /**
     *
     * @param listener
     */
    public void setOnClickedEventsListener(OnClickedEventsListener listener){
        this.mOnClickedEventsListener = listener;
    }
}
