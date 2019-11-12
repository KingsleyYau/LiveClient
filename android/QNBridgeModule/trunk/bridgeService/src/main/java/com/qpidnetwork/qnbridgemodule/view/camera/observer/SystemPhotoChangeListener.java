package com.qpidnetwork.qnbridgemodule.view.camera.observer;

import com.qpidnetwork.qnbridgemodule.view.camera.ImageBean;

import java.util.List;

/**
 * Created by Hardy on 2019/5/23.
 */
public interface SystemPhotoChangeListener {

    void onSystemPhotoChange(List<ImageBean> list);

}
