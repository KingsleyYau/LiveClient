package com.qpidnetwork.livemodule.liveshow.liveroom.hangout.view;

import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.qpidnetwork.livemodule.R;

/**
 * Description:HangOut直播间控制面板
 * <p>
 * Created by Harry on 2018/4/26.
 */
public class HangOutVedioController extends FrameLayout implements View.OnClickListener {

    public HangOutVedioController(Context context) {
        super(context);
        init(context);
    }

    public HangOutVedioController(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context);
    }

    public HangOutVedioController(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private View rootView = null;
    private ImageView iv_closeVedioControll;
    private ImageView iv_mute;
    private ImageView iv_silent;
    private ImageView iv_exitHangout;

    private boolean isMuteOn = false;
    private boolean isSilentOn = false;

    private void init(Context context){
        rootView = LayoutInflater.from(context).inflate(R.layout.view_liveroom_hangout_vediocontroll, this);
        iv_closeVedioControll = (ImageView) findViewById(R.id.iv_closeVedioControll);
        iv_closeVedioControll.setOnClickListener(this);
        iv_mute = (ImageView) findViewById(R.id.iv_mute);
        iv_mute.setOnClickListener(this);
        iv_mute.setSelected(isMuteOn);
        iv_silent = (ImageView) findViewById(R.id.iv_silent);
        iv_silent.setOnClickListener(this);
        iv_silent.setSelected(isSilentOn);
        iv_exitHangout = (ImageView) findViewById(R.id.iv_exitHangout);
        iv_exitHangout.setOnClickListener(this);

        findViewById(R.id.rl_controll).setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if (i == R.id.rl_controll) {//拦截点击事件，防止触发浮层底部公告点击
            return;
        } else if (i == R.id.iv_closeVedioControll) {
            if (null != listener) {
                listener.onCloseClicked();
            }

        } else if (i == R.id.iv_mute || i == R.id.ll_mute) {
            isMuteOn = !isMuteOn;
            iv_mute.setSelected(isMuteOn);
            if (null != listener) {
                listener.onMuteStatusChanged(isMuteOn);
            }

        } else if (i == R.id.ll_silent || i == R.id.iv_silent) {
            isSilentOn = !isSilentOn;
            iv_silent.setSelected(isSilentOn);
            if (null != listener) {
                listener.onSilentStatusChanged(isSilentOn);
            }

        } else if (i == R.id.iv_exitHangout || i == R.id.ll_exitHangout) {
            if (null != listener) {
                listener.onExitHangOutClicked();
            }

        }
        setVisibility(View.GONE);
    }

    private OnControllerEventListener listener;

    public void setListener(OnControllerEventListener listener){
        this.listener = listener;
    }

    /**
     * 控制面板点击事件监听类
     */
    public interface OnControllerEventListener{
        /**
         * 视频控制面板关闭回调
         */
        void onCloseClicked();

        /**
         * 推流-音频输入开关状态切换回调
         * @param onOrOff
         */
        void onMuteStatusChanged(boolean onOrOff);

        /**
         * 拉流-静音开关状态切换回调
         * @param onOrOff
         */
        void onSilentStatusChanged(boolean onOrOff);

        /**
         * 退出HangOut直播间回调
         */
        void onExitHangOutClicked();
    }
}
