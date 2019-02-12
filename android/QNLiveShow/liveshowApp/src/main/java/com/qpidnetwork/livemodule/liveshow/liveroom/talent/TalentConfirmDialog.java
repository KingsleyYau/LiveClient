package com.qpidnetwork.livemodule.liveshow.liveroom.talent;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.graphics.Paint;
import com.qpidnetwork.qnbridgemodule.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.dou361.dialogui.DialogUIUtils;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;

/**
 * 才艺确认对话框
 */
public class TalentConfirmDialog implements View.OnClickListener {

    private final String TAG = TalentConfirmDialog.class.getSimpleName();
    private Dialog mDialog;
    private Context mContext;
    private View rootView;
    private TextView tv_talentNameValue;
    private TextView tv_talentPriceValue;
    private TextView tv_talentPrice;
    private TextView tv_cancelTalent;
    private TextView tv_requestTalent;
    private TalentInfoItem talentInfoItem;
    private ImageView iv_closeConfirm;

    public TalentConfirmDialog(Activity context) {
        super();
        Log.d(TAG, "TalentConfirmPopubWindow");
        this.mContext = context;
        this.rootView = View.inflate(context, R.layout.view_talent_confirm, null);
        initView();
    }

    public void setTalentInfoItem(TalentInfoItem talentInfoItem){
        this.talentInfoItem = talentInfoItem;
        tv_talentNameValue.setText(talentInfoItem.talentName);
        tv_talentPriceValue.setText(mContext.getResources().getString(R.string.live_talent_credits,String.valueOf(talentInfoItem.talentCredit)));
    }


    private void initView() {
        Log.d(TAG, "initView");
        tv_talentNameValue = (TextView) rootView.findViewById(R.id.tv_talentNameValue);
        iv_closeConfirm = (ImageView) rootView.findViewById(R.id.iv_closeConfirm);
        iv_closeConfirm.setOnClickListener(this);
        tv_talentPriceValue = (TextView) rootView.findViewById(R.id.tv_talentPriceValue);
        tv_talentPrice = (TextView) rootView.findViewById(R.id.tv_talentPrice);
        tv_talentPrice.getPaint().setFlags(Paint. UNDERLINE_TEXT_FLAG );//设置下划线
        tv_cancelTalent = (TextView) rootView.findViewById(R.id.tv_cancelTalent);
        tv_cancelTalent.setOnClickListener(this);
        tv_requestTalent = (TextView) rootView.findViewById(R.id.tv_requestTalent);
        tv_requestTalent.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if(i == R.id.tv_cancelTalent){
            if(null != listener){
                listener.onTalentConfirmRequest(false,talentInfoItem);
            }
            dismiss();
        }else if(i == R.id.tv_requestTalent){
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

    public void show(){
        mDialog = DialogUIUtils.showCustomAlert(mContext, rootView,
                null,
                null,
                Gravity.CENTER, true, true,
                null).show();
    }

    public void dismiss() {
        mDialog.dismiss();
        Log.d(TAG, "dismiss");
    }
}
