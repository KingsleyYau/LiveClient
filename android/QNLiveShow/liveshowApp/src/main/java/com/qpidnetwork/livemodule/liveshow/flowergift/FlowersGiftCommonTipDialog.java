package com.qpidnetwork.livemodule.liveshow.flowergift;

import android.content.Context;
import android.graphics.Paint;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.view.dialog.BaseCommonDialog;

/**
 * Created by Hardy on 2019/10/11.
 * <p>
 * 鲜花礼品的通用 dialog
 * ——蓝色实体按钮
 * ——带下划线按钮
 */
public abstract class FlowersGiftCommonTipDialog extends BaseCommonDialog {

    private TextView mTvTitleIcon;
    private TextView mTvTitle;

    private Button mBtnTop;
    private TextView mBtnBottom;

    public FlowersGiftCommonTipDialog(Context context) {
        super(context, R.layout.dialog_flowers_gift_commont_tip);
    }

    @Override
    public void initDialogAttributes(WindowManager.LayoutParams params) {
        params.gravity = Gravity.CENTER;
        params.width = getDialogNormalWidth();
        setDialogParams(params);
    }

    @Override
    public void initView(View v) {
        mTvTitleIcon = v.findViewById(R.id.dialog_flowers_gift_common_tip_tv_title_icon);
        mTvTitle = v.findViewById(R.id.dialog_flowers_gift_common_tip_tv_title);
        setTitleIconText("");

        mBtnTop = v.findViewById(R.id.dialog_flowers_gift_common_tip_btn_top);
        mBtnBottom = v.findViewById(R.id.dialog_flowers_gift_common_tip_btn_bottom);
        // 下划线
        mBtnBottom.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);

        mBtnTop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
                onBtnTopClick();
            }
        });

        mBtnBottom.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
                onBtnBottomClick();
            }
        });
    }

    public void setTitleIconText(String val) {
        if (!TextUtils.isEmpty(val)) {
            mTvTitleIcon.setVisibility(View.VISIBLE);
            mTvTitleIcon.setText(val);
        } else {
            mTvTitleIcon.setVisibility(View.GONE);
        }
    }

    public void setTitleText(String title) {
        mTvTitle.setText(title);
    }

    public void setBtnTopText(String val) {
        mBtnTop.setText(val);
    }

    public void setBtnBottomText(String val) {
        mBtnBottom.setText(val);
    }

    //=======================   abstract    ===========================

    public abstract void onBtnTopClick();

    public abstract void onBtnBottomClick();
}
