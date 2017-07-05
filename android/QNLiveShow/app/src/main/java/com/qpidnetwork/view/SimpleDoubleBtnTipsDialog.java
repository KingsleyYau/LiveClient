package com.qpidnetwork.view;

import android.app.Dialog;
import android.content.Context;
import android.support.annotation.NonNull;
import android.view.View;
import android.widget.TextView;

import com.qpidnetwork.liveshow.R;


/**
 * Description:
 * <p>
 * Created by Harry on 2017/5/24.
 */

public class SimpleDoubleBtnTipsDialog extends Dialog {

    private Context mContext;

    public interface OnTipsDialogBtnClickListener{
        void onCancelBtnClick();
        void onConfirmBtnClick();
    }

    private TextView tv_simple_dbbtn_cancel,tv_simple_dbbtn_confirm;
    private TextView rdceastv_simple_dbbtn_content;

    public SimpleDoubleBtnTipsDialog(@NonNull Context context,int cancelStrId, int confirmStrId, int contentStrId, final OnTipsDialogBtnClickListener onTipsDialogBtnClickListener) {
        super(context, R.style.CustomTheme_SimpleDialog);
        this.mContext = context;
        View rootView = View.inflate(context,R.layout.dialog_simple_double_btn,null);
        tv_simple_dbbtn_cancel = (TextView)rootView.findViewById(R.id.tv_simple_dbbtn_cancel);
        tv_simple_dbbtn_confirm = (TextView)rootView.findViewById(R.id.tv_simple_dbbtn_confirm);
        if(null != onTipsDialogBtnClickListener){
            View.OnClickListener onClickListener = new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    switch (v.getId()){
                        case R.id.tv_simple_dbbtn_cancel:
                            onTipsDialogBtnClickListener.onCancelBtnClick();
                            break;
                        case R.id.tv_simple_dbbtn_confirm:
                            onTipsDialogBtnClickListener.onConfirmBtnClick();
                            break;
                    }
                }
            };
            tv_simple_dbbtn_cancel.setOnClickListener(onClickListener);
            tv_simple_dbbtn_confirm.setOnClickListener(onClickListener);
        }



        rdceastv_simple_dbbtn_content = (TextView)rootView.findViewById(R.id.rdceastv_simple_dbbtn_content);

        if(0 == cancelStrId){
            tv_simple_dbbtn_cancel.setVisibility(View.GONE);
        }else{
            tv_simple_dbbtn_cancel.setVisibility(View.VISIBLE);
            tv_simple_dbbtn_cancel.setText(context.getString(cancelStrId));
        }

        if(0 == confirmStrId){
            tv_simple_dbbtn_confirm.setVisibility(View.GONE);
        }else{
            tv_simple_dbbtn_confirm.setVisibility(View.VISIBLE);
            tv_simple_dbbtn_confirm.setText(context.getString(confirmStrId));
        }
        //暂时不要设置成true，效果会和预设的margin或padding冲突
//        rdceastv_simple_dbbtn_content.setAutoSpliteTextEnable(false);
        rdceastv_simple_dbbtn_content.setText(context.getString(contentStrId));
        setContentView(rootView);
    }

    public void setCancelBtnStyle(int cancelTxtColorId, int bgDrawableId){
        tv_simple_dbbtn_cancel.setBackgroundDrawable(mContext.getResources().getDrawable(bgDrawableId));
        tv_simple_dbbtn_cancel.setTextColor(mContext.getResources().getColor(cancelTxtColorId));
    }

    public void setConfirmBtnStyle(int confirmTxtColorId, int bgDrawableId){
        tv_simple_dbbtn_confirm.setBackgroundDrawable(mContext.getResources().getDrawable(bgDrawableId));
        tv_simple_dbbtn_confirm.setTextColor(mContext.getResources().getColor(confirmTxtColorId));
    }

}
