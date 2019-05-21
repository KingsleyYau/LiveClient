package com.qpidnetwork.livemodule.liveshow.bubble;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.View;

import com.qpidnetwork.livemodule.utils.DisplayUtil;

/**
 * Created by Hardy on 2019/3/4.
 */
public class HangoutMsgPopViewHelper {

    public static final int PADDING_LEFT_RIGHT = 10;
    private static final int RIGHT_VIEW_SPACING = 20;

    private int screenWidth;
    private int itemWidthOne;       // 减去一个
    private int itemWidthNormal;    // 减去右边露头后的 item 宽度

    public HangoutMsgPopViewHelper(Context context) {
        // 屏幕宽度，减去左右 2 边的间距
        screenWidth = DisplayUtil.getScreenWidth(context) - DisplayUtil.dip2px(context, PADDING_LEFT_RIGHT) * 2;

        int dex = DisplayUtil.dip2px(context, RIGHT_VIEW_SPACING);
        itemWidthOne = screenWidth - dex;           // 列表只有 1 个 item 的宽度
        itemWidthNormal = screenWidth - dex * 2;    // 右边露头后的一般 item 宽度
    }

    public void initItemViewWidth(View itemView) {
        RecyclerView.LayoutParams layoutParams = (RecyclerView.LayoutParams) itemView.getLayoutParams();
        layoutParams.width = itemWidthNormal;
    }

    public int getItemWidthOne() {
        return itemWidthOne;
    }
}
