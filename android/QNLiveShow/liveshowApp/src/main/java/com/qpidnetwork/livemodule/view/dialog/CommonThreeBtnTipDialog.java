package com.qpidnetwork.livemodule.view.dialog;

import android.content.Context;
import android.support.annotation.ColorRes;
import android.support.v4.content.ContextCompat;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;

/**
 * Created by Hardy on 2019/5/28.
 * <p>
 * 通用的带提示文案 + 3 个按钮事件的 dialog
 */
public abstract class CommonThreeBtnTipDialog extends BaseCommonDialog {

    private TextView mTvTitle;
    private Button mBtnOk;
    private Button mBtnDontAsk;
    private Button mBtnCancel;

    public CommonThreeBtnTipDialog(Context context) {
        super(context, R.layout.dialog_say_hi_tip_three_btn);
    }

    @Override
    public void initView(View v) {
        mTvTitle = v.findViewById(R.id.dialog_say_hi_tip_three_btn_tv_title);

        mBtnOk = v.findViewById(R.id.dialog_say_hi_tip_three_btn_ok);
        mBtnDontAsk = v.findViewById(R.id.dialog_say_hi_tip_three_btn_no_ask);
        mBtnCancel = v.findViewById(R.id.dialog_say_hi_tip_three_btn_cancel);

        mBtnOk.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
                onClickOK();
            }
        });

        mBtnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
                onClickCancel();
            }
        });

        mBtnDontAsk.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
                onClickDontAsk();
            }
        });
    }

    @Override
    public void initDialogAttributes(WindowManager.LayoutParams params) {
        params.gravity = Gravity.CENTER;
        params.width = getDialogNormalWidth();
        setDialogParams(params);
    }

    /**
     * 设置标题
     */
    public void setTitle(String title) {
        mTvTitle.setText(title);
    }

    /**
     * 设置标题文字颜色
     */
    public void setTitleTextColor(@ColorRes int textColor) {
        mTvTitle.setTextColor(ContextCompat.getColor(mContext, textColor));
    }

    /**
     * 设置第一个按钮的文案
     */
    public void setBtnFirstText(String text) {
        mBtnOk.setText(text);
    }

    /**
     * 设置第一个按钮的文字颜色
     */
    public void setBtnFirstTextColor(@ColorRes int textColor) {
        mBtnOk.setTextColor(ContextCompat.getColor(mContext, textColor));
    }

    /**
     * 设置第二个按钮的文案
     */
    public void setBtnSecondText(String text) {
        mBtnDontAsk.setText(text);
    }

    /**
     * 设置第二个按钮的文字颜色
     */
    public void setBtnSecondTextColor(@ColorRes int textColor) {
        mBtnDontAsk.setTextColor(ContextCompat.getColor(mContext, textColor));
    }

    /**
     * 设置第三个按钮的文案
     */
    public void setBtnThreeText(String text) {
        mBtnCancel.setText(text);
    }

    /**
     * 设置第三个按钮的文字颜色
     */
    public void setBtnThreeTextColor(@ColorRes int textColor) {
        mBtnCancel.setTextColor(ContextCompat.getColor(mContext, textColor));
    }


    //=======================   abstract    method  =================================

    public abstract void onClickOK();

    public abstract void onClickCancel();

    public abstract void onClickDontAsk();
}
