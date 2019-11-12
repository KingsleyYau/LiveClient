package com.qpidnetwork.livemodule.utils;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.Html;
import android.text.Spanned;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;

import java.util.ArrayList;
import java.util.List;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/5/24.
 */

public class StringUtil {

    /**
     * 节目描述模版插入图标
     * @param context
     * @param programDesc
     * @return
     */
    public static Spanned parseHotFollowProgramDesc(final Context context, String programDesc , List<Integer> returnDrawableWidths){
        Spanned spanned = null;
        try {
            String result = String.format(context.getResources().getString(R.string.livemsg_program_hot_follow_desc_template), programDesc);

            spanned = Html.fromHtml(result, new Html.ImageGetter() {
                @Override
                public Drawable getDrawable(String source) {
                    Drawable drawable = context.getResources().getDrawable(R.drawable.list_program_ticket);
                    int width = (int)context.getResources().getDimension(R.dimen.live_size_20dp);
                    int height = (int)context.getResources().getDimension(R.dimen.live_size_20dp);
                    drawable.setBounds(0, 0, (width == 0 ? drawable.getIntrinsicWidth() : width),
                            (height == 0 ? drawable.getIntrinsicHeight() : height));

                    return drawable;
                }
            }, null);

            //返回被加上的图标的宽度（加了几个图标，就在数组里加几个值）
            if(returnDrawableWidths == null){
                returnDrawableWidths = new ArrayList<>();
            }
            returnDrawableWidths.add((int)context.getResources().getDimension(R.dimen.live_size_20dp));

        } catch (Exception e) {
            e.printStackTrace();
        }
        return spanned;
    }

    public static String addAtFirst(String str){
        return new StringBuilder("@ ").append(str).toString();
    }

    /**
     * 主播昵称超过12个字符时从中奖截断(Hangout)
     * @param name
     * @return
     */
    public static String truncateName(String name){
        return truncateName(name, 12);
    }

    /**
     * 主播昵称超过@length个字符时从中截断，前后显示3个字母
     * @param name
     * @param length
     * @return
     */
    public static String truncateName(String name, int length) {
        StringBuffer truncatedName = new StringBuffer();
        if (length > 7 && name.length() > length) {    //因为前后要保留3个字母，所以至少要大于7个字符才会省略
            truncatedName.append(name.subSequence(0, 3));
            truncatedName.append("...");
            truncatedName.append(name.subSequence(name.length()-3, name.length()));
        } else {
            truncatedName.append(name);
        }
        return truncatedName.toString();
    }

    /**
     * 2019/4/16 Hardy
     * 截取指定长度的字符串，尾部补全省略号
     * @param val
     * @param len
     * @return
     */
    public static String truncateSpecifiedLenString(String val, int len){
        if (!TextUtils.isEmpty(val) && len > 0 && val.length() > len) {
            val = val.substring(0, len) + "...";
        }

        return val;
    }
}
