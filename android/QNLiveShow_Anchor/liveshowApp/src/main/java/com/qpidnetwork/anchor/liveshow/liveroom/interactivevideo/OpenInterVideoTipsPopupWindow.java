package com.qpidnetwork.anchor.liveshow.liveroom.interactivevideo;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;


public class OpenInterVideoTipsPopupWindow extends PopupWindow implements View.OnClickListener {

    private final String TAG = OpenInterVideoTipsPopupWindow.class.getSimpleName();
    private Context context;
    private View rootView;

    private View ll_showTipsChooser;
    private TextView tv_openTips;
    private ImageView iv_neverShowAgain;
    private Button btn_confirmVideo;
    private Button btn_cancelVideo;

    private boolean neverShowOpenTipsAgained = false;

    public OpenInterVideoTipsPopupWindow(Context context) {
        super();
        Log.d(TAG, "SimpleListPopupWindow");
        this.context = context;
        this.rootView = View.inflate(context, R.layout.view_interactive_video_open_tips, null);
        setContentView(rootView);
        initPopupWindow();
        initView();
    }

    /**
     * 设置提示文字
     * @param textDesc
     */
    public void setTextDesc(String textDesc){
        if(tv_openTips != null){
            tv_openTips.setText(textDesc);
        }
    }

    private void updateViewData(){
        iv_neverShowAgain.setImageDrawable(context.getResources().getDrawable(
                neverShowOpenTipsAgained ? R.drawable.ic_interactive_video_never_show_again
                        : R.drawable.ic_interactive_video_show_again));
    }

    private void initPopupWindow() {
        // 设置SelectPicPopupWindow弹出窗体的宽高
        this.setWidth(ViewGroup.LayoutParams.WRAP_CONTENT);
        this.setHeight(ViewGroup.LayoutParams.WRAP_CONTENT);
        // 设置SelectPicPopupWindow弹出窗体可点击
        this.setFocusable(true);
        // 设置弹出窗体动画效果
        this.setAnimationStyle(android.R.style.Animation_Dialog);
        setOutsideTouchable(false);
    }

    private void initView() {
        Log.d(TAG, "initView");
        ll_showTipsChooser =rootView.findViewById(R.id.ll_showTipsChooser);

        //处理资费提示
        String priceDesc = "";

        tv_openTips = (TextView) rootView.findViewById(R.id.tv_openTips);
        iv_neverShowAgain =(ImageView)rootView.findViewById(R.id.iv_neverShowAgain);
        btn_confirmVideo =(Button)rootView.findViewById(R.id.btn_confirmVideo);
        btn_cancelVideo =(Button)rootView.findViewById(R.id.btn_cancelVideo);
        ll_showTipsChooser.setOnClickListener(this);
        btn_confirmVideo.setOnClickListener(this);
        btn_cancelVideo.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if (i == R.id.ll_showTipsChooser) {
            //更新本地
            neverShowOpenTipsAgained = !neverShowOpenTipsAgained;
            Log.d(TAG,"onClick-neverShowOpenTipsAgained:"+neverShowOpenTipsAgained);
            iv_neverShowAgain.setImageDrawable(context.getResources().getDrawable(
                    neverShowOpenTipsAgained ? R.drawable.ic_interactive_video_never_show_again
                            : R.drawable.ic_interactive_video_show_again));
        } else if (i == R.id.btn_confirmVideo) {
            hideOpenTipsDialog(true);
        } else if (i == R.id.btn_cancelVideo) {
            hideOpenTipsDialog(false);
        }
    }

    private void hideOpenTipsDialog(boolean isOpenVideo){
        if(null != listener){
            listener.onBtnClicked(isOpenVideo,neverShowOpenTipsAgained);
        }
        dismiss();
    }

    public void showAtLocation(View parent, int gravity,int x, int y) {
        super.showAtLocation(parent, gravity, x, y);
        updateViewData();
    }

    public void showAtLocation(View parent, int gravity, boolean isFromDialog) {
        getContentView().measure(0,0);
        if(isFromDialog){
            this.showAtLocation(parent, gravity, 0, -getContentView().getMeasuredHeight());
        }else{
            this.showAtLocation(parent, gravity, 0, 0);
        }
    }

    private OnOpenTipsBtnClickListener listener;
    public void setOnBtnClickListener(OnOpenTipsBtnClickListener listener){
        this.listener = listener;
    }
    public interface OnOpenTipsBtnClickListener{
        void onBtnClicked(boolean isOpenVideo,boolean neverShowTipsAgain);
    }
}
