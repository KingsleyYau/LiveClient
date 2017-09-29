package com.qpidnetwork.livemodule.httprequest.item;

/**
 * Created by Hunter Mun on 2017/9/13.
 */

public class PackageUnreadCountItem {

    public PackageUnreadCountItem(){

    }

    public PackageUnreadCountItem(int total, int voucherNum, int giftNum, int rideNum){
        this.total = total;
        this.voucherNum = voucherNum;
        this.giftNum = giftNum;
        this.rideNum = rideNum;
    }

    public int total;
    public int voucherNum;
    public int giftNum;
    public int rideNum;
}
