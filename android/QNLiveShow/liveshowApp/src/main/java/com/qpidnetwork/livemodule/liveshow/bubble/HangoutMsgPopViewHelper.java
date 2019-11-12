package com.qpidnetwork.livemodule.liveshow.bubble;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.View;

import com.qpidnetwork.livemodule.R;
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

    // 主播头像的 icon 图片宽高压缩的宽高大小
    private int mIconBigWH;
    private int mIconSmallWH;

    public HangoutMsgPopViewHelper(Context context) {
        // 屏幕宽度，减去左右 2 边的间距
        screenWidth = DisplayUtil.getScreenWidth(context) - DisplayUtil.dip2px(context, PADDING_LEFT_RIGHT) * 2;

        int dex = DisplayUtil.dip2px(context, RIGHT_VIEW_SPACING);
        itemWidthOne = screenWidth - dex;           // 列表只有 1 个 item 的宽度
        itemWidthNormal = screenWidth - dex * 2;    // 右边露头后的一般 item 宽度

        mIconBigWH = context.getResources().getDimensionPixelSize(R.dimen.live_size_30dp);
        mIconSmallWH = context.getResources().getDimensionPixelSize(R.dimen.live_size_16dp);
    }

    public void initItemViewWidth(View itemView) {
        RecyclerView.LayoutParams layoutParams = (RecyclerView.LayoutParams) itemView.getLayoutParams();
        layoutParams.width = itemWidthNormal;
    }

    public int getItemWidthOne() {
        return itemWidthOne;
    }

    public int getIconBigWH() {
        return mIconBigWH;
    }

    public int getIconSmallWH() {
        return mIconSmallWH;
    }


    //========================= static  ==========================

    /**
     * 获取冒泡当前的进度
     *
     * @param firstShowTime 第一次 add 进展示列表的时间戳
     * @param maxShowTime   最大显示时长的时间戳
     * @return 当前进度
     */
    public static int getBubblePopCurProgress(long firstShowTime, int maxShowTime) {
        int progress = 0;

        // 计算[当前时间戳 - 第一次展示时间]=即消逝的时间
        float progressF = ((float) (System.currentTimeMillis() - firstShowTime)) * 100 / maxShowTime;

        // 计算进度百分比
        progress = progressF >= 100 ? 0 : (100 - (int) progressF);

        return progress;
    }
}
