package com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.style.ForegroundColorSpan;
import android.text.style.StyleSpan;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.view.dialog.BaseCommonDialog;

/**
 * Created by Hardy on 2019/9/2.
 * Virtual Gift Store 提示 dialog
 */
public class VirtualGiftStoreTipDialog extends BaseCommonDialog {


    public VirtualGiftStoreTipDialog(Context context) {
        super(context, R.layout.dialog_virtual_gift_store_tip);
    }

    @Override
    public void initView(View v) {
        ImageView mIvBack = v.findViewById(R.id.dialog_virtual_gift_store_tip_iv_back);
        mIvBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });

        TextView mTvFormat = v.findViewById(R.id.dialog_virtual_gift_store_tip_tv_format);
        String formatStr = mContext.getString(R.string.virtual_gift_store_tip_1);
        String formatStrKey = "Virtual Gifts";
        int color = Color.parseColor("#FD7200");    // 黄色
        mTvFormat.setText(getFormatColorString(formatStr, formatStrKey, color));
    }

    @Override
    public void initDialogAttributes(WindowManager.LayoutParams params) {
        params.gravity = Gravity.CENTER;
        params.width = getDialogNormalWidth();
        params.x = DisplayUtil.dip2px(mContext, 15) / 2;    // 往右偏移，交叉按钮距离右边的边距的一半
        setDialogParams(params);
    }

    /**
     * 格式化字体
     */
    private SpannableString getFormatColorString(String formatString, String key, int color) {
        SpannableString spString = new SpannableString(formatString);
        // 起始位置
        int startIndex = formatString.indexOf(key);
        int endIndex = startIndex + key.length();
        // 字体颜色
        ForegroundColorSpan span = new ForegroundColorSpan(color);
        spString.setSpan(span, startIndex, endIndex, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        // 粗体
        StyleSpan spanBold = new StyleSpan(Typeface.BOLD);
        spString.setSpan(spanBold, startIndex, endIndex, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

        return spString;
    }
}
