package com.qpidnetwork.livemodule.liveshow.liveroom.tariffprompt;

import java.io.Serializable;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/9/6.
 */

public class TariffPrompt implements Serializable {

    public String tariff = "0.1";
    public boolean isFirstTimeIn = true;

    public TariffPrompt(){}
    public TariffPrompt(boolean isFirstTimeIn,String tariff){
        this.isFirstTimeIn = isFirstTimeIn;
        this.tariff = tariff;

    }
}
