package com.qpidnetwork.livemodule.httprequest.item;

public class GiftTypeItem {

    // 2019/9/3 Hardy
    public static final String FREE = "Free";
    public static final String ALL = "All";

    public GiftTypeItem() {

    }

    /**
     * @param typeId   //类型ID
     * @param typeName //类型名称
     */
    public GiftTypeItem(String typeId,
                        String typeName) {
        this.typeId = typeId;
        this.typeName = typeName;
    }

    public String typeId;
    public String typeName;


    //************************	2019/9/3	Hardy	==============================
    public static GiftTypeItem getFreeGiftTypeItem() {
        return new GiftTypeItem(FREE, FREE);
    }

    public static GiftTypeItem getAllGiftTypeItem() {
        return new GiftTypeItem(ALL, ALL);
    }

    public static boolean isFreeGiftType(GiftTypeItem item) {
        if (item != null && FREE.equals(item.typeId)) {
            return true;
        }

        return false;
    }

    public static boolean isAllGiftType(GiftTypeItem item) {
        if (item != null && ALL.equals(item.typeId)) {
            return true;
        }

        return false;
    }
    //************************	2019/9/3	Hardy	==============================
}
