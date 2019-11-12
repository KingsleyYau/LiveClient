package com.qpidnetwork.qnbridgemodule.util;

import android.graphics.Typeface;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.style.ForegroundColorSpan;
import android.text.style.StrikethroughSpan;
import android.text.style.UnderlineSpan;
import android.widget.TextView;

/**
 * Created by Hardy on 2019/5/29.
 */
public class TextViewUtil {


    /**
     * 设置文本粗体
     */
    public static void setTextBold(TextView mTv, boolean isBold) {
//        mTv.getPaint().setFakeBoldText(isBold);      // 无效

        //        https://blog.csdn.net/qq_33650812/article/details/76670224
        mTv.setTypeface(Typeface.defaultFromStyle(isBold ? Typeface.BOLD : Typeface.NORMAL));
    }

    /**
     * 设置文本斜体
     *
     * @param isItalics 是否斜体
     */
    public static void setTextItalics(TextView mTv, boolean isItalics) {
        mTv.setTypeface(Typeface.defaultFromStyle(isItalics ? Typeface.ITALIC : Typeface.NORMAL));
    }

    /**
     * 增加中间删除线
     */
    public static void formatCenterDeleteLineText(TextView tv, String val) {
        SpannableString spString = new SpannableString(val);
        StrikethroughSpan span = new StrikethroughSpan();
        spString.setSpan(span, 0, val.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        tv.setText(spString);
    }

    /**
     * 字符串的下划线
     */
    public static void formatUnderLineText(TextView tv, String formatString) {
        SpannableString spString = new SpannableString(formatString);
        // 下划线
        UnderlineSpan span = new UnderlineSpan();
        spString.setSpan(span, 0, formatString.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        tv.append(spString);
    }

    /**
     * 格式化指定字体颜色
     *
     * @param formatString 原来的整段文本
     * @param key          格式化的指定文本
     * @param color        颜色值
     */
    public static void formatColorText(TextView tv, String formatString, String key, int color) {
        SpannableString spString = new SpannableString(formatString);
        // 起始位置
        int startIndex = formatString.indexOf(key);
        int endIndex = startIndex + key.length();
        // 字体颜色
        ForegroundColorSpan span = new ForegroundColorSpan(color);
        spString.setSpan(span, startIndex, endIndex, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        tv.setText(spString);
    }


}
