package com.qpidnetwork.livemodule.liveshow.model;

import com.qpidnetwork.livemodule.httprequest.item.LSOrderType;

/**
 * 没点通知参数对象
 */
public class NoMoneyParamsBean {

    public static final int ORDER_TYPE_CREDIT = 0;
    public static final int ORDER_TYPE_MONTHLY_FEE = 5;
    public static final int ORDER_TYPE_STAMP = 7;

    public NoMoneyParamsBean(){
        orderType = LSOrderType.credit;
    }

    public NoMoneyParamsBean(String orderType, String clickFrom, String number){
        this.orderType = parseLSOrderType(orderType);
        this.clickFrom = clickFrom;
        this.number = number;
    }

    /**
     * 设置订单类型
     * @param orderTyp
     */
    public void setOrderTyp(String orderTyp){
        this.orderType = parseLSOrderType(orderTyp);
    }

    public LSOrderType orderType;
    public String clickFrom;
    public String number;

    /**
     * 买点触发转换器
     * @param orderType
     * @return
     */
    public LSOrderType parseLSOrderType(String orderType){
        LSOrderType lsOrderType = LSOrderType.credit;
        try {
            switch (Integer.valueOf(orderType)){
                case ORDER_TYPE_CREDIT:{
                    lsOrderType = LSOrderType.credit;
                }break;
                case ORDER_TYPE_MONTHLY_FEE:{
                    lsOrderType = LSOrderType.monthFree;
                }break;
                case ORDER_TYPE_STAMP:{
                    lsOrderType = LSOrderType.stamp;
                }break;
            }
        }catch (Exception e){
            e.printStackTrace();
        }
        return lsOrderType;
    }
}
