package com.qpidnetwork.livemodule.liveshow.datacache.file;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Environment;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.utils.Log;

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
    private final String CAR = "car";                //本地座驾图片缓存路径
    private final String EMOTION = "emotion";                //本地表情图片缓存路径
    private final String MEDAL = "medal";                //本地勋章图片缓存路径
    private final String PICASS_LOCAL_DIR = "picassoLocalCache";

    private static FileCacheManager gFileCacheManager;

    private String mMainPath = "";

    private final String TAG = FileCacheManager.class.getSimpleName();

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
//        String path = Environment.getExternalStorageDirectory().getAbsolutePath() + "/" + context.getResources().getString(R.string.app_name);
        String path = Environment.getExternalStorageDirectory().getAbsolutePath() + "/" + "LiveShow";
        changeMainPath(path);
    }

    /**
     * 创建主路径
     *
     * @param path
     */
    private void changeMainPath(String path) {
        /* 创建主路径 */
        mMainPath = path + "/" + "live";
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
     * 获取picasso本地缓存路径
     * @return
     */
    public String GetPicassoLocalPath(){
        String path = mMainPath + "/" + PICASS_LOCAL_DIR + "/";
        File file = new File(path);
        file.mkdirs();

        return path;
    }

    /**
     * 获取图片目录
     *
     * @return
     */
    private String getImagePath() {
		/* 创建图片目录 */
        String path = mMainPath + IMAGE_DIR + File.separator;
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }
        Log.d("FileCacheManager","getImagePath-path:"+path);
        return path;
    }

    /**
     * 获取本地用户头像文件缓存
     * @param url
     * @return
     */
    public String getLocalImgPath(String url){
        String localPath = getImagePath();
        localPath += parseFileNameFromUrl(url);
        Log.d(TAG,"getLocalImgPath-localPath:"+localPath);
        return  localPath;
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
     * 本地存放路径(eg.  sdcard/live/gift/1/small.jpg)
     * @param giftId
     * @param url
     * @return
     */
    public String getGiftLocalPath(String giftId, String url){
        String localPath = getGiftPath();
        localPath += giftId;
        localPath += File.separator;
        localPath += parseFileNameFromUrl(url);
        Log.d(TAG,"getGiftLocalPath-localPath:"+localPath);
        return  localPath;
    }

    /**
     * 根据带文件后缀名的Url得到对应的文件名
     * @param fileUrl
     * @return
     */
    public String parseFileNameFromUrl(String fileUrl){
        String fileName = null;
        if(!TextUtils.isEmpty(fileUrl)){
            fileName = fileUrl.substring(fileUrl.lastIndexOf(File.separator)+1,fileUrl.length());
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
     * 获取log目录路径
     *
     * @return
     */
    public String getIMLogPath() {
		/* 创建log路径 */
        String path = mMainPath + LOG_DIR + "/" + "IM" + "/";
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }

        return path;
    }

    private String getCarImgRootPath(){
        /* 创建log路径 */
        String path = mMainPath + CAR + File.separator;
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }

        return path;
    }

    public String parseCarImgLocalPath(String riderId,String riderUrl){
        String localPath = getCarImgRootPath();
        localPath += riderId;
        localPath += riderUrl.substring(riderUrl.lastIndexOf(File.separator),riderUrl.length());
        return localPath;
    }

    private String getEmotionImgRootPath(){
        /* 创建emotion路径 */
        String path = mMainPath + EMOTION + File.separator;
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }

        return path;
    }

    public String parseEmotionImgLocalPath(String emotionId, String emotionUrl){
        String localPath = getEmotionImgRootPath();
        localPath += emotionId;
        localPath += emotionUrl.substring(emotionUrl.lastIndexOf(File.separator),emotionUrl.length());
        return localPath;
    }

    private String getMedalImgRootPath(){
         /* 创建medal路径 */
        String path = mMainPath + MEDAL + File.separator;
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }

        return path;
    }

    public String parseHonorImgLocalPath(String honorUrl){
        String localPath = getMedalImgRootPath();
        localPath += honorUrl.substring(honorUrl.lastIndexOf(File.separator)+1,honorUrl.length());
        return localPath;
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

    /**
     * 获取一个临时拍照图片的路径
     * @return
     */
    public String GetTempCameraImageUrl() {
        String temp = "";
        temp += getTempPath() + "cameraphoto.jpg";
        return temp;
    }

    /**
     * 获取一个临时图片的路径
     * @return
     */
    public String getTempImageUrl() {
        String temp = "";
        temp += getTempPath() + "uploadphoto.jpg";
        return temp;
    }
}
