package com.qpidnetwork.qnbridgemodule.statics;

public class PhoneInfoCheckResult {

    public PhoneInfoCheckResult(boolean isNewUser, boolean isRequst){
        this.isNewUser = isNewUser;
        this.isRequst = isRequst;
    }

    public boolean isNewUser = false;
    public boolean isRequst = false;
}
