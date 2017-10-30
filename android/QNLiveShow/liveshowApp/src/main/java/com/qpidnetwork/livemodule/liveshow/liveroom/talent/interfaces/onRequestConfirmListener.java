package com.qpidnetwork.livemodule.liveshow.liveroom.talent.interfaces;

import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;

/**
 * 点击发送才艺确认事件
 * Created by Jagger on 2017/9/20.
 */

public interface onRequestConfirmListener {
    void onConfirm(TalentInfoItem talent);
}
