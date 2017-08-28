package com.qpidnetwork.livemodule.liveshow.liveroom.barrage;

import android.view.View;

/**
 * 弹幕动画单个Item填充
 * Created by Hunter Mun on 2017/6/19.
 */

public interface IBarrageViewFiller <T> {
    void onBarrageViewFill(View view, T item);
}
