package com.qpidnetwork.livemodule.liveshow.livechat.album;

import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.qnbridgemodule.util.FileUtil;

/**
 * Created by hardy on 2019/5/14.
 */
public class AlbumUtil {

    private AlbumUtil() {
    }

    /**
     * 获取 LiveChat 图片的缓存路径
     *
     * @param fileName
     * @return
     */
    private static String getPhotoTempPath(String fileName) {
        return FileCacheManager.getInstance().getPrivatePhotoTempSavePath() + fileName;
    }

    /**
     * 判断图标是否被旋转了，如果是，旋转为原图后，保存在新建的路径下再返回该路径
     *
     * @param filePath
     * @param fileName
     * @return
     */
    public static String adjustImageDegree(String filePath, String fileName) {
        // 判断旋转角度
        int degree = ImageUtil.readImageDegree(filePath);

        if (degree != 0) {
            // 获取缓存路径
            String tempFilePath = getPhotoTempPath(fileName);

            // 判断该缓存文件，如果不存在
            if (!FileUtil.isFileExists(tempFilePath)) {
                ImageUtil.adjustImageDegree(filePath, tempFilePath);
            }

            filePath = tempFilePath;
        }

        return filePath;
    }

}
