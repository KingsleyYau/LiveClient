package com.qpidnetwork.livemodule.view;

import android.content.Context;

import com.qpidnetwork.livemodule.R;

import q.rorbin.badgeview.Badge;

/**
 * 未读红点样式统一设置
 */
public class BadgeHelper {

    /**
     * 基础样式设置
     * @param qBadgeView
     */
    public static void setBaseStyle(Context context, Badge qBadgeView, int textSizePx){
        qBadgeView.setGravityOffset(0, 0 ,true);
        qBadgeView.setBadgePadding(4 , true);
        qBadgeView.setBadgeTextSize(textSizePx,false);
        qBadgeView.setBadgeBackgroundColor(context.getResources().getColor(R.color.live_main_top_menu_unread_bg));
        qBadgeView.setShowShadow(false);//不要阴影
    }

    /**
     * 基础样式设置
     * @param qBadgeView
     */
    public static void setBaseStyle(Context context, Badge qBadgeView){
        setBaseStyle(context , qBadgeView , context.getResources().getDimensionPixelSize(R.dimen.live_main_top_menu_badge_txt_size_max));
    }
}
