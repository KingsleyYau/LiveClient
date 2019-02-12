package com.qpidnetwork.livemodule.liveshow.model;


import com.qpidnetwork.livemodule.livechathttprequest.item.MagicIconItem;

import java.io.Serializable;
import java.util.List;

/**
 * 封装实现数据传递
 * Created by Hunter on 18/7/16.
 */

public class MagicIconHomeParamBean implements Serializable{
    public MagicIconHomeParamBean(){

    }

    public MagicIconHomeParamBean(int vpHeight, List<MagicIconItem> magicIconList){
        this.vpHeight = vpHeight;
        this.magicIconList = magicIconList;
    }

    public int vpHeight;
    public List<MagicIconItem> magicIconList;
}
