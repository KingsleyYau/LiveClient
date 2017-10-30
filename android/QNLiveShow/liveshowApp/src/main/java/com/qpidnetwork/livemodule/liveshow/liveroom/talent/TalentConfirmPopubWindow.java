package com.qpidnetwork.livemodule.liveshow.liveroom.talent;

import android.app.Activity;
import android.graphics.Paint;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;

import java.lang.ref.WeakReference;


public class TalentConfirmPopubWindow extends PopupWindow implements View.OnClickListener {

    private final String TAG = TalentConfirmPopubWindow.class.getSimpleName();
    private WeakReference<Activity> mActivity;
    private View rootView;
    private TextView tv_talentNameValue;
    private TextView tv_talentPriceValue;
    private TextView tv_talentPrice;
    private Button btn_cancelTalent;
    private Button btn_requestTalent;
    private TalentInfoItem talentInfoItem;
    private ImageView iv_closeConfirm;

    public TalentConfirmPopubWindow(Activity context) {
        super();
        Log.d(TAG, "TalentConfirmPopubWindow");
        this.mActivity = new WeakReference<Activity>(context);
        this.rootView = View.inflate(context, R.layout.view_talent_confirm, null);
        initView();
        setContentView(rootView);
        initPopupWindow();
    }

    public void setTalentInfoItem(TalentInfoItem talentInfoItem){
        this.talentInfoItem = talentInfoItem;
        tv_talentNameValue.setText(talentInfoItem.talentName);
        tv_talentPriceValue.setText(mActivity.get().getResources().getString(R.string.live_talent_credits,String.valueOf(talentInfoItem.talentCredit)));
    }

    private void initPopupWindow() {
        Log.d(TAG,"initPopupWindow");
        // 设置SelectPicPopupWindow弹出窗体的宽高
        this.setWidth(ViewGroup.LayoutParams.WRAP_CONTENT);
        this.setHeight(ViewGroup.LayoutParams.WRAP_CONTENT);
        // 设置SelectPicPopupWindow弹出窗体可点击
        this.setFocusable(true);
        setOutsideTouchable(false);
        // 设置弹出窗体动画效果
        this.setAnimationStyle(android.R.style.Animation_Dialog);

        // 实例化一个ColorDrawable颜色为半透明
//        ColorDrawable dw = new ColorDrawable(0x30000000);
        // 设置SelectPicPopupWindow弹出窗体的背景
//        this.setBackgroundDrawable(dw);
    }

    private void initView() {
        Log.d(TAG, "initView");
        tv_talentNameValue = (TextView) rootView.findViewById(R.id.tv_talentNameValue);
        iv_closeConfirm = (ImageView) rootView.findViewById(R.id.iv_closeConfirm);
        iv_closeConfirm.setOnClickListener(this);
        tv_talentPriceValue = (TextView) rootView.findViewById(R.id.tv_talentPriceValue);
        tv_talentPrice = (TextView) rootView.findViewById(R.id.tv_talentPrice);
        tv_talentPrice.getPaint().setFlags(Paint. UNDERLINE_TEXT_FLAG );//设置下划线
        btn_cancelTalent = (Button) rootView.findViewById(R.id.btn_cancelTalent);
        btn_cancelTalent.setOnClickListener(this);
        btn_requestTalent = (Button) rootView.findViewById(R.id.btn_requestTalent);
        btn_requestTalent.setOnClickListener(this);
    }

    @Override
    public void showAtLocation(View parent, int gravity, int x, int y) {
        super.showAtLocation(parent, gravity, x, y);
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if(i == R.id.btn_cancelTalent){
            if(null != listener){
                listener.onTalentConfirmRequest(false,talentInfoItem);
            }
            dismiss();
        }else if(i == R.id.btn_requestTalent){
            if(null != listener){
                listener.onTalentConfirmRequest(true,talentInfoItem);
            }
            dismiss();
        }else if(i == R.id.iv_closeConfirm){
            dismiss();
        }
    }

    private OnConfirmRequestTalentListener listener;

    public void setOnConfirmListener(OnConfirmRequestTalentListener listener){
        this.listener = listener;
    }

    public interface OnConfirmRequestTalentListener{
        void onTalentConfirmRequest(boolean isConfirm, TalentInfoItem talentInfoItem);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        Log.d(TAG, "dismiss");
    }
}
