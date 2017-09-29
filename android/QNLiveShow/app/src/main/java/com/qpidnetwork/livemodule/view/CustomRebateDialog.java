package com.qpidnetwork.livemodule.view;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseDialog;
import com.qpidnetwork.livemodule.im.listener.IMRebateItem;

import java.util.Timer;
import java.util.TimerTask;

/**
 * Created by Hunter Mun on 2017/9/14.
 */

public class CustomRebateDialog extends BaseDialog{

    private Context mConext;
    private RelativeLayout contentView;

    private LinearLayout llContentBody;
    private Button btnCancel;
    private TextView tvRebateCredit;
    private TextView tvCountDown;
    private TextView tvRules;

    private MaterialProgressBar pbLoading;

    private Timer mReciprocalTimer;
    private int mLeftSeconds = 0;

    public CustomRebateDialog(Context context){
        super(context);
        this.getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));

        this.mConext = context;

        contentView = (RelativeLayout)LayoutInflater.from(context).inflate(R.layout.dialog_custom_rebate_countdown, null);
        contentView.setGravity(Gravity.TOP | Gravity.CENTER);
        llContentBody = (LinearLayout)contentView.findViewById(R.id.llContentBody);
        btnCancel = (Button) contentView.findViewById(R.id.btnCancel);
        tvRebateCredit = (TextView)contentView.findViewById(R.id.tvRebateCredit);
        tvCountDown = (TextView)contentView.findViewById(R.id.tvCountDown);
        tvRules = (TextView)contentView.findViewById(R.id.tvRules);

        pbLoading = (MaterialProgressBar)contentView.findViewById(R.id.pbLoading);

        btnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });

        this.setContentView(contentView);
    }

    /**
     * 更新数据刷新
     * @param lastUpdate
     * @param rebateItem
     */
    public void setRebateInfo(long lastUpdate, IMRebateItem rebateItem){
        mLeftSeconds = 0;
        if(System.currentTimeMillis() < lastUpdate + rebateItem.cur_time * 1000){
            //计算返点周期剩余时间
            mLeftSeconds = (int)(lastUpdate + rebateItem.cur_time * 1000 - System.currentTimeMillis())/1000;
        }

        tvRebateCredit.setText(String.valueOf(rebateItem.cur_credit));
        tvRules.setText(String.format(mConext.getResources().getString(R.string.liveroom_rebate_rules),
                String.valueOf(rebateItem.pre_time), String.valueOf(rebateItem.pre_credit)));

        if(mLeftSeconds > 0){
            //倒计时
            llContentBody.setVisibility(View.VISIBLE);
            pbLoading.setVisibility(View.GONE);
            startTimer();
        }else{
            llContentBody.setVisibility(View.INVISIBLE);
            pbLoading.setVisibility(View.VISIBLE);
        }
    }

    /**
     * 倒计时刷新界面
     */
    private void onCountDownRefresh(final int leftSeconds){
        if(mConext instanceof Activity){
            ((Activity)mConext).runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if(leftSeconds > 0){
                        tvCountDown.setText(String.valueOf(leftSeconds));
                    }else{
                        llContentBody.setVisibility(View.INVISIBLE);
                        pbLoading.setVisibility(View.VISIBLE);
                    }
                }
            });
        }
    }

    /**
     * 开始倒计时
     */
    private void startTimer(){
        if(mReciprocalTimer != null){
            mReciprocalTimer.cancel();
        }
        mReciprocalTimer = new Timer();
        mReciprocalTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                //界面刷新
                onCountDownRefresh(mLeftSeconds);
                if(mLeftSeconds <= 0){
                    //开播倒数结束
                    stopTimer();
                }else {
                    mLeftSeconds--;
                }
            }
        }, 0 , 1000);
    }

    /**
     * 停止倒计时
     */
    private void stopTimer(){
        if(mReciprocalTimer != null){
            mReciprocalTimer.cancel();
        }
    }

    @Override
    protected void onStop() {
        super.onStop();
        stopTimer();
    }
}
