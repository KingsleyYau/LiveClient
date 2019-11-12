package com.qpidnetwork.livemodule.liveshow.flowergift.checkout;

import com.qpidnetwork.livemodule.httprequest.item.LSCheckoutGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.LSGreetingCardItem;

/**
 * 定单物品列表项
 * @author Jagger 2019-10-11
 */
public class CheckOutListItem {
    enum Type{
        Gift,
        Card
    }

    Type type = Type.Gift;
    LSCheckoutGiftItem giftItem;
    LSGreetingCardItem cardItem;
}
