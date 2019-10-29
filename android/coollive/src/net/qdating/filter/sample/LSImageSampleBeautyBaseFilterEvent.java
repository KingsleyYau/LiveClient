package net.qdating.filter.sample;

/**
 * Created by Hardy on 2019/10/29.
 */
public interface LSImageSampleBeautyBaseFilterEvent {

    /**
     * 设置美颜等级
     *
     * @param beautyLevel [0.0, 1.0]
     */
    void setBeautyLevel(float beautyLevel);

    /**
     * 设置美肤等级
     *
     * @param strength [0.0, 1.0]
     */
    void setStrength(float strength);
}
