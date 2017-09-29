package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;


public class CreditsNoEnoughTipsPopupWindow extends PopupWindow implements View.OnClickListener {

    private final String TAG = CreditsNoEnoughTipsPopupWindow.class.getSimpleName();
    private Context context;
    private View rootView;
    private ImageView iv_closeCreditsTips;
    private TextView tv_balanceTips;
    private String creditsTips;
    private Button btn_getCredits;

    public CreditsNoEnoughTipsPopupWindow(Context context) {
        super();
        Log.d(TAG, "SimpleListPopupWindow");
        this.context = context;
        this.rootView = View.inflate(context, R.layout.view_balance_noenough, null);
        initView();
        setContentView(rootView);
        initPopupWindow();
    }

    private void initPopupWindow() {
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
        // mMenuView添加OnTouchListener监听判断获取触屏位置如果在选择框外面则销毁弹出框
        rootView.setOnTouchListener(new View.OnTouchListener() {
            public boolean onTouch(View v, MotionEvent event) {
                int top = rootView.findViewById(R.id.ll_creditsNoEnough).getTop();
                int y = (int) event.getY();
                if (event.getAction() == MotionEvent.ACTION_UP) {
                    if (y < top) {
                        dismiss();
                    }
                }
                return true;
            }
        });
    }

    private void initView() {
        Log.d(TAG, "initView");
        iv_closeCreditsTips = (ImageView) rootView.findViewById(R.id.iv_closeCreditsTips);
        iv_closeCreditsTips.setOnClickListener(this);
        tv_balanceTips = (TextView) rootView.findViewById(R.id.tv_balanceTips);
        btn_getCredits = (Button) rootView.findViewById(R.id.btn_getCredits);
        btn_getCredits.setOnClickListener(this);
    }

    private void updateViewData() {
        if(null != creditsTips){
            tv_balanceTips.setText(creditsTips);
        }
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.iv_closeCreditsTips:
                dismiss();
                break;
            case R.id.btn_getCredits:
                Toast.makeText(context, "跳转到充值界面", Toast.LENGTH_SHORT).show();
                break;
            default:
                break;
        }
    }

    //TODO:参数的设置需要调优
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

    public void setCreditsTips(String creditsTips){
        this.creditsTips = creditsTips;
    }
}
