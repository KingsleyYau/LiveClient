package com.qpidnetwork.livemodule.view.indicator;

import com.flyco.tablayout.listener.CustomTabEntity;

/**
 * Created by Hardy on 2019/9/5.
 * 直播间 emoji 表情切换 tab 的 icon
 */
public class EmojiTabEntity implements CustomTabEntity {

    private int tabSelectIcon;
    private int tabUnSelectIcon;

    public EmojiTabEntity(int tabIcon) {
        this.tabSelectIcon = tabIcon;
        this.tabUnSelectIcon = tabIcon;
    }

    @Override
    public String getTabTitle() {
        return null;
    }

    @Override
    public int getTabSelectedIcon() {
        return tabSelectIcon;
    }

    @Override
    public int getTabUnselectedIcon() {
        return tabUnSelectIcon;
    }
}
