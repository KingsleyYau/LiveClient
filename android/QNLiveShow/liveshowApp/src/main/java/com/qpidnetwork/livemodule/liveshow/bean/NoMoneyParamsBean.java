package com.qpidnetwork.livemodule.liveshow.bean;

/**
 * 没点通知参数对象
 */
public class NoMoneyParamsBean {

    public NoMoneyParamsBean(){
        orderType = "0";
    }

    public NoMoneyParamsBean(String orderType, String clickFrom, String number){
        this.orderType = orderType;
        this.clickFrom = clickFrom;
        this.number = number;
    }

    public String orderType;
    public String clickFrom;
    public String number;

}
