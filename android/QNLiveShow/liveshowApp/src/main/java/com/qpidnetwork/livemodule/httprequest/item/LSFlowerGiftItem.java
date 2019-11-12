package com.qpidnetwork.livemodule.httprequest.item;

import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;

/**
 * 鲜花礼品Item
 *
 * @author Alex
 */
public class LSFlowerGiftItem {

    public LSFlowerGiftItem() {

    }

    /**
     * 鲜花礼品Item
     *
     * @param typeId             分类ID
     * @param giftId             礼品ID
     * @param giftName           礼品名称
     * @param giftImg            礼品图片
     * @param priceShowType      显示何种价格
     * @param giftWeekdayPrice   平日价
     * @param giftDiscountPrice  优惠价
     * @param giftPrice          显示价格
     * @param isNew              是否NEW
     * @param deliverableCountry 配送国家
     * @param giftDescription    描述
     */
    public LSFlowerGiftItem(String typeId,
                            String giftId,
                            String giftName,
                            String giftImg,
                            int priceShowType,
                            double giftWeekdayPrice,
                            double giftDiscountPrice,
                            double giftPrice,
                            boolean isNew,
                            String[] deliverableCountry,
                            String giftDescription) {
        this.typeId = typeId;
        this.giftId = giftId;
        this.giftName = giftName;
        this.giftImg = giftImg;
        if (priceShowType < 0 || priceShowType >= LSPriceShowType.values().length) {
            this.priceShowType = LSPriceShowType.weekday;
        } else {
            this.priceShowType = LSPriceShowType.values()[priceShowType];
        }
        this.giftWeekdayPrice = giftWeekdayPrice;
        this.giftDiscountPrice = giftDiscountPrice;
        this.giftPrice = giftPrice;
        this.isNew = isNew;
        this.deliverableCountry = deliverableCountry;
        this.giftDescription = giftDescription;

        // 2019/10/9 Hardy
        this.giftViewType = FlowerGiftViewType.VIEW_ITEM_NORMAL;
        this.giftWeekdayPriceStr = PRICE_SYMBOL + ApplicationSettingUtil.formatCoinValue(this.giftWeekdayPrice);
        this.giftDiscountPriceStr = PRICE_SYMBOL + ApplicationSettingUtil.formatCoinValue(this.giftDiscountPrice);
        this.giftPriceStr = PRICE_SYMBOL + ApplicationSettingUtil.formatCoinValue(this.giftPrice);
    }

    public String typeId;
    public String giftId;
    public String giftName;
    public String giftImg;
    public LSPriceShowType priceShowType;
    public double giftWeekdayPrice;
    public double giftDiscountPrice;
    public double giftPrice;
    public boolean isNew;
    public String[] deliverableCountry;
    public String giftDescription;


    @Override
    public String toString() {
        return "LSFlowerGiftItem[typeId:" + typeId
                + " giftId:" + giftId
                + " giftName:" + giftName
                + " giftImg:" + giftImg
                + " priceShowType:" + priceShowType
                + " giftWeekdayPrice:" + giftWeekdayPrice
                + " giftDiscountPrice:" + giftDiscountPrice
                + " giftPrice:" + giftPrice
                + " isNew:" + isNew
                + " giftDescription:" + giftDescription
                + "]";
    }


    //================	2019/10/9 Hardy	自定义字段	=========================================
    public static final String PRICE_SYMBOL = "$";

    public enum FlowerGiftViewType {
        VIEW_ITEM_NORMAL,           // 普通封面 item
        VIEW_ITEM_GROUP_TITLE,      // 分类组标题
//        VIEW_ITEM_LINE              // 分类组的分割线
    }

    public FlowerGiftViewType giftViewType;

    public String giftWeekdayPriceStr;
    public String giftDiscountPriceStr;
    public String giftPriceStr;
    // 在组内的 pos
    public int groupPos;
    public int groupCount;
}
