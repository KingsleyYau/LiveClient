package com.qpidnetwork.anchor.liveshow.liveroom.beautyfilter;

/**
 * Created by Hardy on 2019/10/30.
 */
public class BeautyFilterBean {

    // 滤镜名字
    public String filterName;
    // 是否选中
    public boolean isSelect;
    // 滤镜类型
    public BeautyFilterType filterType;

    public BeautyFilterBean(BeautyFilterType filterType) {
        this.filterType = filterType;
        // 赋值名字
        this.filterName = filterType.name();
    }
}
