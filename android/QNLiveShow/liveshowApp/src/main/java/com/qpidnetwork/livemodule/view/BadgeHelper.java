package com.qpidnetwork.livemodule.view;

import android.content.Context;

import com.qpidnetwork.livemodule.R;

import q.rorbin.badgeview.Badge;

/**
 * 未读红点样式统一设置
 */
public class BadgeHelper {

    private static final int BADGE_GRAVITY_OFFSET_XY = 0;
    private static final int BADGE_PADDING = 4;
    public static final int HOT_BADGE_PADDING = 5;
    /**
     * 基础样式设置
     *
     * @param qBadgeView
     */
    public static void setBaseStyle(Context context, Badge qBadgeView, int textSizePx) {
        qBadgeView.setGravityOffset(BADGE_GRAVITY_OFFSET_XY, BADGE_GRAVITY_OFFSET_XY, true);
        qBadgeView.setBadgePadding(BADGE_PADDING, true);
        qBadgeView.setBadgeTextSize(textSizePx, false);
        qBadgeView.setBadgeBackgroundColor(context.getResources().getColor(R.color.live_main_top_menu_unread_bg));
        qBadgeView.setShowShadow(false);//不要阴影
    }

    /**
     * 基础样式设置
     *
     * @param qBadgeView
     */
    public static void setBaseStyle(Context context, Badge qBadgeView) {
        setBaseStyle(context, qBadgeView, context.getResources().getDimensionPixelSize(R.dimen.live_main_top_menu_badge_txt_size_max));
    }

    /**
     * 2018/11/26 Hardy
     * hot 列表的小红点样式设置
     */
    public static void setHotCircleStyle(Badge qBadgeView, boolean isRedCircle) {
        if (isRedCircle) {
            qBadgeView.setGravityOffset(2, 2, true);
            qBadgeView.setBadgePadding(HOT_BADGE_PADDING, true);
        } else {
            qBadgeView.setGravityOffset(BADGE_GRAVITY_OFFSET_XY, BADGE_GRAVITY_OFFSET_XY, true);
            qBadgeView.setBadgePadding(BADGE_PADDING, true);
        }
    }
}
