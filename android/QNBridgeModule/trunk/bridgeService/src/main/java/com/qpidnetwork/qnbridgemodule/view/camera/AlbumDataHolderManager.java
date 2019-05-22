package com.qpidnetwork.qnbridgemodule.view.camera;

import com.qpidnetwork.qnbridgemodule.util.ListUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Hardy on 2018/12/20.
 * <p>
 * 本地相册的图片数据持久化管理器
 * 用于在不同界面的数据一致性
 */
public class AlbumDataHolderManager {

    private static AlbumDataHolderManager instance;

    // 本地相册数据集合
    private List<ImageBean> mDataList;


    public static AlbumDataHolderManager getInstance() {
        if (instance == null) {
            instance = new AlbumDataHolderManager();
        }

        return instance;
    }

    private AlbumDataHolderManager() {
        if (mDataList == null) {
            mDataList = new ArrayList<>();
        }
    }

    /**
     * 设置本地相册数据——多张图片
     * 用于在多张图片切换的界面
     * @param mDataList
     */
    public void setDataList(List<ImageBean> mDataList) {
        this.mDataList.clear();

        if (ListUtils.isList(mDataList)) {
            this.mDataList.addAll(mDataList);
        }
    }

    /**
     * 设置本地相册——单张图片
     * 用于在只展示单张图片的界面
     * @param imageBean
     */
    public void setDataList(ImageBean imageBean){
        this.mDataList.clear();

        if (imageBean != null) {
            this.mDataList.add(imageBean);
        }
    }

    /**
     * 获取本地相册数据
     *
     * @return
     */
    public List<ImageBean> getDataList() {
        return mDataList;
    }

    /**
     * 清理本地相册数据
     */
    public void clear() {
        if (ListUtils.isList(mDataList)) {
            mDataList.clear();
        }
    }
}
