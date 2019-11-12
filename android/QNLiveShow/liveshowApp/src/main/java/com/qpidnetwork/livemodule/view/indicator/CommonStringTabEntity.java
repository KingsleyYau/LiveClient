package com.qpidnetwork.livemodule.view.indicator;

import com.flyco.tablayout.listener.CustomTabEntity;

/**
 * Created by Hardy on 2019/3/13.
 */
public class CommonStringTabEntity implements CustomTabEntity {

    private String title;

    public CommonStringTabEntity(String title) {
        this.title = title;
    }

    @Override
    public String getTabTitle() {
        return title;
    }

    @Override
    public int getTabSelectedIcon() {
        return 0;
    }

    @Override
    public int getTabUnselectedIcon() {
        return 0;
    }
}
