package com.qpidnetwork.livemodule.view.dialog;

import android.content.Context;
import android.support.v4.content.ContextCompat;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.qnbridgemodule.util.TextViewUtil;

/**
 * Created by Hardy on 2019/5/28.
 * <p>
 * SayHi 新手引导 dialog
 */
public class SayHiGuideDialog extends BaseCommonDialog {

    public SayHiGuideDialog(Context context) {
        super(context, R.layout.dialog_say_hi_guide, R.style.SayHiGuideDialog);
    }

    @Override
    public void initView(View v) {
        // 关闭按钮
        ImageView mIvClose = v.findViewById(R.id.dialog_say_hi_guide_iv_close);
        mIvClose.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });

        // FREE 文案
        TextView mTvFree = v.findViewById(R.id.dialog_say_hi_guide_tv_tip_free);
        String formatStr = mContext.getString(R.string.say_hi_guide_tip3);
        String formatStrKey = "FREE";
        int color = ContextCompat.getColor(mContext, R.color.live_main_top_menu_unread_bg);
        TextViewUtil.formatColorText(mTvFree, formatStr, formatStrKey, color);
    }

    @Override
    public void initDialogAttributes(WindowManager.LayoutParams params) {
        params.gravity = Gravity.CENTER;
        params.width = getDialogNormalWidth();
        setDialogParams(params);

        setDialogCancelable(false);
    }
}
