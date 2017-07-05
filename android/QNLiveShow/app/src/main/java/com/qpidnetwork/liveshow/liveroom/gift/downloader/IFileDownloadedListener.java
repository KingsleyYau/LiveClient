package com.qpidnetwork.liveshow.liveroom.gift.downloader;

/**
 * Description:文件下载管理器对应的下载状态回调接口
 * 基于FileDownloadListener封装
 * <p>
 * Created by Harry on 2017/6/21.
 */

public interface IFileDownloadedListener {
    /**
     *文件成功下载完成
     * @param localFilePath 文件本地存储的绝对路径
     * @param fileId 文件ID
     * @param fileUrl 文件下载链接
     */
    void onCompleted(String localFilePath, String fileId, String fileUrl);
}
