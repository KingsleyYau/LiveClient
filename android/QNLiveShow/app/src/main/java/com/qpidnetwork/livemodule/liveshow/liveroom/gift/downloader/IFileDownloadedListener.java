package com.qpidnetwork.livemodule.liveshow.liveroom.gift.downloader;

/**
 * Description:文件下载管理器对应的下载状态回调接口
 * 基于FileDownloadListener封装
 * <p>
 * Created by Harry on 2017/6/21.
 */

public interface IFileDownloadedListener {
    /**
     *文件成功下载完成
     * @param isSuccess 是否成功
     * @param localFilePath 文件本地存储的绝对路径
     * @param fileUrl 文件下载链接
     */
    void onCompleted(boolean isSuccess, String localFilePath, String fileUrl);
}
