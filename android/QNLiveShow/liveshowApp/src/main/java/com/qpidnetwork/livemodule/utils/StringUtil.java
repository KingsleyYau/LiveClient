package com.qpidnetwork.livemodule.utils;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.text.Html;
import android.text.Spanned;

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
}
