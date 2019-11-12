package com.qpidnetwork.livemodule.liveshow.flowergift;

import android.widget.TextView;

import com.qpidnetwork.livemodule.httprequest.item.LSFlowerGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.LSPriceShowType;
import com.qpidnetwork.qnbridgemodule.util.TextViewUtil;

/**
 * Created by Hardy on 2019/10/11.
 * <p>
 * 鲜花礼品的工具类
 */
public class FlowersGiftUtil {


    public static void handlerFlowersStoreListPrice(TextView mTvPriceRed, TextView mTvPriceGrey, LSFlowerGiftItem data) {
        if (data == null) {
            return;
        }

        switch (data.priceShowType) {
            case hoiday:    // 节日价
//                mTvPriceRed.setText(data.giftPriceStr+data.giftPriceStr+data.giftPriceStr);

                mTvPriceRed.setText(data.giftPriceStr);
                mTvPriceGrey.setText("");
                break;

            case discount:  // 优惠价
                mTvPriceRed.setText(data.giftDiscountPriceStr);
                TextViewUtil.formatCenterDeleteLineText(mTvPriceGrey, data.giftWeekdayPriceStr);

//                mTvPriceRed.setText(data.giftWeekdayPriceStr+data.giftWeekdayPriceStr+data.giftWeekdayPriceStr);
//                TextViewUtil.formatCenterDeleteLineText(mTvPriceGrey, data.giftDiscountPriceStr+data.giftDiscountPriceStr+data.giftDiscountPriceStr);
                break;

            default:        // 平日价
//                mTvPriceRed.setText(data.giftWeekdayPriceStr+data.giftWeekdayPriceStr+data.giftWeekdayPriceStr);

                mTvPriceRed.setText(data.giftWeekdayPriceStr);
                mTvPriceGrey.setText("");
                break;
        }
    }

    public static void handlerFlowersDetailPrice(TextView mTvPriceRed, TextView mTvPriceGrey, LSFlowerGiftItem data) {
        if (data == null) {
            return;
        }

        data.giftPriceStr = data.giftPriceStr.replace(LSFlowerGiftItem.PRICE_SYMBOL, "");
        data.giftDiscountPriceStr = data.giftDiscountPriceStr.replace(LSFlowerGiftItem.PRICE_SYMBOL, "");

        if (data.priceShowType != LSPriceShowType.discount) {
            data.giftWeekdayPriceStr = data.giftWeekdayPriceStr.replace(LSFlowerGiftItem.PRICE_SYMBOL, "");
        }

        handlerFlowersStoreListPrice(mTvPriceRed, mTvPriceGrey, data);
    }
}
