package com.qpidnetwork.livemodule.liveshow.liveroom.rebate;

import android.app.Activity;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.im.listener.IMRebateItem;

import java.lang.ref.WeakReference;
import java.util.Timer;
import java.util.TimerTask;


public class RoomRebateTipsPopupWindow extends PopupWindow implements View.OnClickListener {

    private final String TAG = RoomRebateTipsPopupWindow.class.getSimpleName();
    private WeakReference<Activity> mActivity;
    private View rootView;
    private ImageView iv_closeRebateTips;
    private TextView tv_currRoomRebate;
    private TextView tv_countRebateUpdated;
    private TextView tv_rebateNote2;
    private ProgressBar pb_loadingRebate;
    private View rl_roomRebate;
    private IMRebateItem rebateItem;
    private Timer timer;
    private TimerTask timerTask;
    private OnRoomRebateCountTimeEndListener listener;

    public void setListener(OnRoomRebateCountTimeEndListener listener){
        this.listener = listener;
    }

    public RoomRebateTipsPopupWindow(Activity context) {
        super();
        Log.d(TAG, "RoomRebateTipsPopupWindow");
        this.mActivity = new WeakReference<Activity>(context);
        this.rootView = View.inflate(context, R.layout.view_room_rebate, null);
        initView();
        setContentView(rootView);
        initPopupWindow();
    }

    private void initPopupWindow() {
        Log.d(TAG,"initPopupWindow");
        // 设置SelectPicPopupWindow弹出窗体的宽高
        this.setWidth(ViewGroup.LayoutParams.MATCH_PARENT);
        this.setHeight(ViewGroup.LayoutParams.WRAP_CONTENT);
        // 设置SelectPicPopupWindow弹出窗体可点击
        this.setFocusable(true);
        // 设置弹出窗体动画效果
        this.setAnimationStyle(android.R.style.Animation_Dialog);

        // 实例化一个ColorDrawable颜色为半透明
//        ColorDrawable dw = new ColorDrawable(0x30000000);
        // 设置SelectPicPopupWindow弹出窗体的背景
//        this.setBackgroundDrawable(dw);
        initView();
    }

    private void initView() {
        Log.d(TAG, "initView");
        iv_closeRebateTips = (ImageView) rootView.findViewById(R.id.iv_closeRebateTips);
        rl_roomRebate = rootView.findViewById(R.id.rl_roomRebate);
        rl_roomRebate.setVisibility(View.VISIBLE);
        tv_currRoomRebate = (TextView) rootView.findViewById(R.id.tv_currRoomRebate);
        tv_countRebateUpdated = (TextView) rootView.findViewById(R.id.tv_countRebateUpdated);
        tv_rebateNote2 = (TextView) rootView.findViewById(R.id.tv_rebateNote2);
        pb_loadingRebate = (ProgressBar) rootView.findViewById(R.id.pb_loadingRebate);
        pb_loadingRebate.setVisibility(View.GONE);
        iv_closeRebateTips.setOnClickListener(this);
    }

    private Runnable runnable1= new Runnable() {
        @Override
        public void run() {
            rl_roomRebate.setVisibility(View.INVISIBLE);
            pb_loadingRebate.setVisibility(View.VISIBLE);
        }
    };

    private Runnable runnable2 = new Runnable() {
        @Override
        public void run() {
            if(null != rebateItem && null != mActivity && null != mActivity.get()){
                tv_countRebateUpdated.setText(mActivity.get().getResources().getString(
                        R.string.live_backcredits_tips3,String.valueOf(rebateItem.cur_time)));
                rebateItem.cur_time -= 1;
            }
        }
    };

    private void initTimeCounter(){
        Log.d(TAG, "initTimeCounter");
        if(null == timer){
            timerTask = new TimerTask() {
                @Override
                public void run() {
                    if(null != rebateItem){
                        if(0 > rebateItem.cur_time){
                            if(null != mActivity && null != mActivity.get() && null != runnable1){
                                mActivity.get().runOnUiThread(runnable1);
                            }
                            if(null != listener){
                                listener.onRoomRebateCountTimeEnd();
                            }
                            //倒计时完毕，界面loading
                            stopTimeCount();
                        }else{
                            //更新剩余时间
                            if(null != mActivity && null != mActivity.get() && null != runnable2){
                                mActivity.get().runOnUiThread(runnable2);
                            }
                        }
                    }
                }
            };
            timer = new Timer();
        }
    }

    public void notifyReBateUpdate(IMRebateItem tempRebateItem){
        Log.d(TAG,"notifyReBateUpdate-tempRebateItem:"+tempRebateItem);
        //0.关闭计时器
        stopTimeCount();
        if(null != tempRebateItem){
            //1.更新本地数据
            rebateItem = new IMRebateItem(tempRebateItem.cur_credit,tempRebateItem.cur_time,
                    tempRebateItem.pre_credit,tempRebateItem.pre_time);
            //2.隐藏loading显示数据
            rl_roomRebate.setVisibility(View.VISIBLE);
            pb_loadingRebate.setVisibility(View.GONE);
            //3.更新规则说明以及当前已返点
            if(null != mActivity && null != mActivity.get()){
                tv_rebateNote2.setText(mActivity.get().getResources().getString(R.string.live_backcredits_tips42));
            }
            tv_currRoomRebate.setText(String.valueOf(rebateItem.cur_credit));
            //4.重新开始倒计时
            initTimeCounter();
            timer.schedule(timerTask,0,1000l);
        }else{
            rl_roomRebate.setVisibility(View.INVISIBLE);
            pb_loadingRebate.setVisibility(View.VISIBLE);
        }

    }

    public void stopTimeCount(){
        Log.d(TAG, "stopTimeCount");
        if(null != timer ){
            timerTask.cancel();
            timerTask = null;
            timer.cancel();
            timer = null;
        }
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if (i == R.id.iv_closeRebateTips) {
            dismiss();

        } else {
        }
    }

    public void release(){
        stopTimeCount();
        this.listener = null;
        this.runnable1 = null;
        this.runnable2 = null;
        mActivity.clear();
        mActivity = null;
    }

    @Override
    public void dismiss() {
        super.dismiss();
        Log.d(TAG, "dismiss");
    }

    public void showAtLocation(View parent, int gravity, int x, int y) {
        super.showAtLocation(parent, gravity, x, y);
    }
}
