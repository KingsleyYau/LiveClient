package com.qpidnetwork.livemodule.liveshow.share;


import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.Gravity;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

import com.qpidnetwork.livemodule.R;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/12/26.
 */

public class LiveShareDialog extends Dialog implements View.OnClickListener {

    private View rootView;
    private View ll_share2Fb;
    private View ll_shareByCopyLink;
    private View ll_share4More;

    public LiveShareDialog(@NonNull Context context) {
        super(context, R.style.CustomTheme_LiveShareDialog);
        Window window = getWindow();
        window.setGravity(Gravity.BOTTOM);
        window.setWindowAnimations(R.style.CustomTheme_LiveShareDialog);
        window.getDecorView().setPadding(0, 0, 0, 0);
        android.view.WindowManager.LayoutParams lp = window.getAttributes();
        lp.width = WindowManager.LayoutParams.MATCH_PARENT;
        lp.height = WindowManager.LayoutParams.WRAP_CONTENT;
        window.setAttributes(lp);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH);
        rootView = View.inflate(getContext(),R.layout.view_liveroom_share,null);
        setContentView(rootView);
        initView();
    }

    private void initView(){
        ll_share2Fb = rootView.findViewById(R.id.ll_share2Fb);
        ll_shareByCopyLink = rootView.findViewById(R.id.ll_shareByCopyLink);
        ll_share4More = rootView.findViewById(R.id.ll_share4More);
        ll_share2Fb.setOnClickListener(this);
        ll_shareByCopyLink.setOnClickListener(this);
        ll_share4More.setOnClickListener(this);
        rootView.findViewById(R.id.v_blank).setOnClickListener(this);
    }

    public OnShareBtnClickListener listener;

    public void setListener(OnShareBtnClickListener listener){
        this.listener = listener;
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.v_blank:
                dismiss();
                break;
            case R.id.ll_share2Fb:
                if(null != listener){
                    listener.onFbShareBtnClick();
                }
                break;
            case R.id.ll_shareByCopyLink:
                if(null != listener){
                    listener.onCopyLinkBtnClick();
                }
                break;
            case R.id.ll_share4More:
                if(null != listener){
                    listener.onMoreShareMethodBtnClick();
                }
                break;
        }
        dismiss();
    }

    public interface OnShareBtnClickListener{
        void onFbShareBtnClick();
        void onCopyLinkBtnClick();
        void onMoreShareMethodBtnClick();
    }
}
