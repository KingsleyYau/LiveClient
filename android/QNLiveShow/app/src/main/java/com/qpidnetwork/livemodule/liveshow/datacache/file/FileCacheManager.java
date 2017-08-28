package com.qpidnetwork.livemodule.liveshow.datacache.file;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Environment;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

/**
 * 文件缓存管理
 *
 * @author Hunter.Mun
 */
public class FileCacheManager {
    private final String CRASH = "crash";
    private final String IMAGE_DIR = "image";
    private final String LOG_DIR = "log";              //本地Log缓存路径
    private final String TEMP = "temp";                //本地临时缓存路径
    private final String HTTP = "http";                //本地http缓存路径
    private final String GIFT = "gift";                //本地礼物图片缓存路径

    private static FileCacheManager gFileCacheManager;

    private String mMainPath = "";

    public static FileCacheManager newInstance(Context context) {
        if (gFileCacheManager == null) {
            gFileCacheManager = new FileCacheManager(context);
        }
        return gFileCacheManager;
    }


    public static FileCacheManager getInstance() {
        return gFileCacheManager;
    }

    public FileCacheManager(Context context) {
        String path = Environment.getExternalStorageDirectory().getAbsolutePath() + "/" + context.getResources().getString(R.string.app_name);
        changeMainPath(path);
    }

    /**
     * 创建主路径
     *
     * @param path
     */
    private void changeMainPath(String path) {
        /* 创建主路径 */
        mMainPath = path;
        if (!mMainPath.regionMatches(mMainPath.length() - 1, "/", 0, 1)) {
            mMainPath += "/";
        }

        File file = new File(mMainPath);
        if (!file.exists()) {
            file.mkdirs();
        }
    }

    /**
     * 获取站点主路径
     *
     * @return
     */
    public String getMainPath() {
        return mMainPath;
    }

    /**
     * 获取http cache目录
     *
     * @return
     */
    public String getHttpPath() {
		/* 创建图片目录 */
        String path = mMainPath + HTTP + "/";
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }
        return path;
    }

    /**
     * 获取临时目录
     *
     * @return
     */
    public String getTempPath() {
        String path = mMainPath + TEMP + "/";
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }
        return path;
    }

    /**
     * 获取图片目录
     *
     * @return
     */
    public String getImagePath() {
		/* 创建图片目录 */
        String path = mMainPath + IMAGE_DIR + "/";
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }
        return path;
    }

    /**
     * 获取礼物文件存储目录
     *
     * @return
     */
    public String getGiftPath() {
		/* 创建图片目录 */
        String path = mMainPath + GIFT + File.separator;
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }
        return path;
    }

    /**
     * 本地存放路径
     * @param giftId
     * @param url
     * @return
     */
    public String getGiftLocalPath(String giftId, String url){
        String localPath = getGiftPath();
        localPath += giftId + File.separator;
        localPath += parseGiftNameFromUrl(url);
        return  localPath;
    }

    /**
     * 根据带文件后缀名的Url得到对应的文件名
     * @param fileUrl
     * @return
     */
    public String parseGiftNameFromUrl(String fileUrl){
        String fileName = null;
        if(!TextUtils.isEmpty(fileUrl)){
            fileName = fileUrl.substring(fileUrl.lastIndexOf(File.separator),fileUrl.length());
        }
        return fileName;
    }

    /**
     * 获取crash日志保存路径
     *
     * @return
     */
    public String getCrashInfoPath() {
		/* 创建crash日志路径*/
        String path = mMainPath + CRASH + "/";
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }

        return path;
    }

    /**
     * 获取log目录路径
     *
     * @return
     */
    public String getLogPath() {
		/* 创建log路径 */
        String path = mMainPath + LOG_DIR + "/";
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }

        return path;
    }

    /**
     * 删除指定目录下所有文件
     *
     * @param dirPath 目录路径
     * @return
     */
    public void doDelete(String dirPath) {
        delete(new File(dirPath), false);
    }

    /**
     * 清空缓存路径文件
     */
    public void clearCache() {
        delete(new File(getHttpPath()), false);
        delete(new File(getImagePath()), false);
        delete(new File(getTempPath()), false);
    }

    /**
     * 清空crash log
     */
    public void clearCrashLog() {
        delete(new File(getCrashInfoPath()), false);
    }


    public static void delete(File file, boolean deleteSelf) {
        if (file != null && file.exists()) {
            if (file.isFile()) {
                file.delete();
            } else if (file.isDirectory()) {
                File[] files = file.listFiles();
                for (int i = 0; i < files.length; i++) {
                    delete(files[i], true);
                }
            }
        }
        //针对文件夹
        if (deleteSelf){
            file.delete();
        }

    }

    /**
     * 写图片文件到SD卡
     *
     * @throws IOException
     */
    public void saveImage(String filePath, Bitmap bitmap, Bitmap.CompressFormat format, final int quality) throws IOException {
        if (bitmap != null) {
            File file = new File(filePath.substring(0,filePath.lastIndexOf(File.separator)));
            if (!file.exists()) {
                file.mkdirs();
            }
            BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(filePath));
            bitmap.compress(format, quality, bos);
            bos.flush();
            bos.close();
        }
    }
}
