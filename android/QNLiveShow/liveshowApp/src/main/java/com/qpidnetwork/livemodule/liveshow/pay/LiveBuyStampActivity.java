package com.qpidnetwork.livemodule.liveshow.pay;

import android.content.Context;
import android.content.Intent;

/**
 * 购买邮票
 * ps：拆分纯为了解决GA统计问题
 */
public class LiveBuyStampActivity extends LiveBuyCreditActivity{
    /**
     *
     * @param context
     * @param orderType LSOrderType枚举索引
     * @param clickFrom
     * @param numberId
     */
    public static void lunchActivity(Context context, int orderType, String clickFrom, String numberId){
        Intent intent = new Intent(context, LiveBuyStampActivity.class);
        intent.putExtra(KEY_ORDER_TYPE_INDEX, orderType);
        intent.putExtra(KEY_CLICK_FROM, clickFrom);
        intent.putExtra(KEY_NUMBER_ID, numberId);
        intent.putExtra(WEB_TITLE_BAR_SHOW_LOADSUC, true);
        context.startActivity(intent);
    }
}
