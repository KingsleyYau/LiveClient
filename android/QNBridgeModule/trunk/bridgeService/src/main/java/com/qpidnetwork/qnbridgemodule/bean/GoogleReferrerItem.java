package com.qpidnetwork.qnbridgemodule.bean;

import java.io.Serializable;

public class GoogleReferrerItem implements Serializable {

    private static final long serialVersionUID = -7706589600142277934L;

    public String utm_reference = "";
    public boolean isSuccess = false;

    public GoogleReferrerItem(){

    }

    public GoogleReferrerItem(String utm_reference, boolean isSuccess){
        this.isSuccess = isSuccess;
        this.utm_reference = utm_reference;
    }

}
