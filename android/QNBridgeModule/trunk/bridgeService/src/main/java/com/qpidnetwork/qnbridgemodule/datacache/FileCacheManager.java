package com.qpidnetwork.qnbridgemodule.datacache;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Environment;
import android.text.TextUtils;

import com.qpidnetwork.qnbridgemodule.R;
import com.qpidnetwork.qnbridgemodule.util.Arithmetic;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;

public class FileCacheManager {
    //qn 模块缓存路径
    private static final String CRASH = "crash";
    private static final String IMAGE_DIR = "image";
    private static final String LADY_DIR = "lady";
    private static final String VIRTUAL_GIFT = "virtual_gift";
    private static final String PRIVATE_PHOTO = "private_photo";
    private static final String LC_EMOTION_DIR = "livechat/emotion";
    private static final String LC_VOICE_DIR = "livechat/voice";
    private static final String LC_PHTOT_DIR = "livechat/photo";
    private static final String LC_VIDEO_DIR = "livechat/video";
    private static final String LC_MAGICICON_DIR = "livechat/magicIcon";
    private static final String LC_TAKE_PHOTO_TEM_DIR = "livechat/photo/temp";
    private static final String LC_THEME_DIR = "livechat/theme";
    private static final String LOG_DIR = "log";
    private static final String TEMP = "temp";
    private static final String EMF = "emf";
    private static final String HTTP = "http";
    private static final String EMF_VIDEO = "emf/video";
    private static final String PICASS_LOCAL_DIR = "picassoLocalCache";

    //直播模块缓存路径
    private final String GIFT = "gift";                //本地礼物图片缓存路径
    private final String CAR = "car";                //本地座驾图片缓存路径
    private final String EMOTION = "emotion";                //本地表情图片缓存路径
    private final String MEDAL = "medal";                //本地勋章图片缓存路径
    private final String PLAYER_PUBLISHER_LOG_DIR = "coollive";     //本地播放器或推溜器log地址

    private static FileCacheManager gFileCacheManager;

    private String mMainPath = "";
    private Context mContext;

    public static FileCacheManager newInstance(Context context) {
        if( gFileCacheManager == null ) {
            gFileCacheManager = new FileCacheManager(context);
        }
        return gFileCacheManager;
    }


    public static FileCacheManager getInstance() {
        return gFileCacheManager;
    }

    public FileCacheManager(Context contenxt) {
        mContext = contenxt.getApplicationContext();

    }

    /**
     * 获取本地文件缓存根目录
     * @return
     */
    public String getFileCacheHomePath(){
        String appName = mContext.getResources().getString(R.string.app_name);
        return Environment.getExternalStorageDirectory().getAbsolutePath() + "/" + appName + "/";
    }

    /**
     *  创建主路径
     * @param path
     */
    public void ChangeMainPath(String path) {
        /* 创建主路径 */
        mMainPath = path;
        File file = new File(mMainPath);
        file.mkdirs();
    }

    /**
     * 获取站点主路径
     * @return
     */
    public String GetMainPath() {
        return mMainPath;
    }

    /**
     * LiveChat 发送私密照拍照存储临时路径，当发送返回LCMessage即删除本地路径
     * @return
     */
    public String getPrivatePhotoTempSavePath(){
        /*创建图片目录*/
        String path = mMainPath + "/" + LC_TAKE_PHOTO_TEM_DIR + "/";
        File file = new File(path);
        file.mkdir();
        return path;
    }

    /**
     * LiveChat 下载主题sd存放路径
     * @return
     */
    public String getThemeSavePath(){
        /*创建图片目录*/
        String path = mMainPath + "/" + LC_THEME_DIR + "/";
        File file = new File(path);
        file.mkdir();
        return path;
    }

    /**
     * 获取EMF拍照目录
     * @return
     */
    private String GetEMFPath() {
        /* 创建图片目录 */
        String path = mMainPath + "/" + EMF + "/";
        File file = new File(path);
        file.mkdirs();
        return path;
    }

    /**
     * 获取EMF微视频缓存路径
     * @return
     */
    public String GetEMFVideoPath() {
        /* 创建图片目录 */
        String path = mMainPath + "/" + EMF_VIDEO + "/";
        File file = new File(path);
        file.mkdirs();
        return path;
    }

    /**
     * 获取http cache目录
     * @return
     */
    public String GetHttpPath() {
        /* 创建图片目录 */
        String path = mMainPath + "/" + HTTP + "/";
        File file = new File(path);
        file.mkdirs();
        return path;
    }

    /**
     * 获取临时目录
     * @return
     */
    public String GetTempPath() {
        String path = mMainPath + "/" + TEMP + "/";
        File file = new File(path);
        file.mkdirs();
        return path;
    }

    /**
     * 获取图片目录
     * @return
     */
    public String GetImagePath() {
        /* 创建图片目录 */
        String path = mMainPath + "/" + IMAGE_DIR + "/";
        File file = new File(path);
        file.mkdirs();
        return path;
    }

    /**
     * 获取女士(图片)目录
     * @return
     */
    public String GetLadyPath() {
        /* 创建女士(图片)目录 */
        String path = mMainPath + "/" + LADY_DIR + "/";
        File file = new File(path);
        if(!file.exists()){
            file.mkdirs();
        }
        return path;
    }

    /**
     * 获取图片目录
     * @return
     */
    private String GetPrivatePhotoPath() {
        /* 创建私密照路径 */
        String path = mMainPath + "/" + PRIVATE_PHOTO + "/";
        File file = new File(path);
        file.mkdirs();

        return path;
    }

    /**
     * 获取虚拟礼物目录
     * @return
     */
    private String GetVirtualGiftPath() {
        /* 创建虚拟礼物路径 */
        String path = mMainPath + "/" + VIRTUAL_GIFT + "/";
        File file = new File(path);
        file.mkdirs();

        return path;
    }

    /**
     * 获取livechat高级表情目录
     * @return
     */
    public String GetLCEmotionPath() {
        /* 创建虚拟礼物路径 */
        String path = mMainPath + "/" + LC_EMOTION_DIR + "/";
        File file = new File(path);
        file.mkdirs();

        return path;
    }

    /**
     * 获取livechat语音目录
     * @return
     */
    public String GetLCVoicePath() {
        /* 创建虚拟礼物路径 */
        String path = mMainPath + "/" + LC_VOICE_DIR + "/";
        File file = new File(path);
        if(!file.exists()){
            file.mkdirs();
        }
        return path;
    }

    /**
     * 获取livechat图片目录
     * @return
     */
    public String GetLCPhotoPath() {
        /* 创建虚拟礼物路径 */
        String path = mMainPath + "/" + LC_PHTOT_DIR + "/";
        File file = new File(path);
        file.mkdirs();

        return path;
    }

    /**
     * 获取livechat视频目录
     * @return
     */
    public String GetLCVideoPath() {
        /* 创建虚拟礼物路径 */
        String path = mMainPath + "/" + LC_VIDEO_DIR + "/";
        File file = new File(path);
        file.mkdirs();

        return path;
    }

    /**
     * 获取livechat小高情目录
     * @return
     */
    public String GetLCMagicIconPath() {
        /* 创建虚拟礼物路径 */
        String path = mMainPath + "/" + LC_MAGICICON_DIR + "/";
        File file = new File(path);
        file.mkdirs();

        return path;
    }

    /**
     * 获取crash日志保存路径
     * @return
     */
    public String GetCrashInfoPath() {
        /* 创建crash日志路径*/
        String path = mMainPath + "/" + CRASH + "/";
        File file = new File(path);
        file.mkdirs();

        return path;
    }

    /**
     * 获取log目录路径
     * @return
     */
    public String GetLogPath() {
        String path = mMainPath + "/" + LOG_DIR + "/";
        File file = new File(path);
        file.mkdirs();

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
     * 根据私密照 发送ID 和 照片ID 获取图片缓存路径
     * @param sendId		发送ID
     * @param photoId		照片ID
     * @return				缓存路径
     */
    public String CachePrivatePhotoImagePath(String sendId, String photoId, String photoType, String mode) {
        String path = "";
        String name = "";

        if( sendId != null && sendId.length() > 0 && photoId != null && photoId.length() > 0 ) {
            path = GetPrivatePhotoPath();
            name = Arithmetic.MD5(sendId.getBytes(), sendId.getBytes().length);
            name += photoId;
            name = Arithmetic.MD5(name.getBytes(), name.getBytes().length);
            name += ".";
            name += photoType;
            name += "_";
            name += mode;
            path += name;
        }

        return path;
    }

    /**
     * 根据url获取图片缓存路径
     * @param url			网址
     * @return				缓存路径
     */
    public String CacheVirtualGiftImagePath(String url) {
        String path = "";
        String name = "";

        if( url != null && url.length() > 0  ) {
            path = GetVirtualGiftPath();
            name = Arithmetic.MD5(url.getBytes(), url.getBytes().length);
            path += name;
            path += ".thumb";
        }

        return path;
    }

    /**
     * 根据url获取视频缓存路径
     * @param url			网址
     * @return				缓存路径
     */
    public String CacheVirtualGiftVideoPath(String url) {
        String path = "";
        String name = "";

        if( url != null && url.length() > 0  ) {
            path = GetVirtualGiftPath();
            name = Arithmetic.MD5(url.getBytes(), url.getBytes().length);
            path += name;
        }

        return path;
    }

    /**
     * 根据url获取图片缓存路径
     * @param url			网址
     * @return				缓存路径
     */
    public String CacheImagePathFromUrl(String url) {
        String path = "";
        String name = "";

        if( url != null && url.length() > 0 ) {
            path = GetImagePath();
            name = Arithmetic.MD5(url.getBytes(), url.getBytes().length);
            path += name;
        }

        return path;
    }

    /**
     * 视频本地录制
     * @return
     */
    public String CacheCamshareVideo(){
        String path = mMainPath + "/" + "Camshare" + "/";
        File file = new File(path);
        file.mkdirs();
        return path;
    }


    public enum LadyFileType {
        /**
         * 女士头像
         */
        LADY_PHOTO
    }
    /**
     * 根据url获取图片缓存路径
     * @param womanId		女士ID
     * @param fileType		文件类型
     * @return				缓存路径
     */
    public String CacheLadyPathFromUrl(String womanId, LadyFileType fileType) {
        String path = "";
        String name = "";

        if( womanId != null && !womanId.isEmpty() ) {
            path = GetLadyPath();
            String strMd5 = womanId;
            name = Arithmetic.MD5(strMd5.getBytes(), strMd5.getBytes().length);
            name += "_" + fileType.name();
            path += name;
        }

        return path;
    }

    /**
     * 根据url获取清除图片缓存
     * @param url
     */
    public void CleanCacheImageFromUrl(String url) {
        String path = CacheImagePathFromUrl(url);
        File file = new File(path);
        if( file.exists() ) {
            file.delete();
        }
    }


    /**
     * 获取一个临时拍照图片的路径
     * @return
     */
    public String GetTempCameraImageUrl() {
        String temp = "";
        temp += GetTempPath() + "cameraphoto.jpg";
        return temp;
    }

    /**
     * 获取一个临时图片的路径
     * @return
     */
    public String GetTempImageUrl() {
        String temp = "";
        temp += GetTempPath() + "uploadphoto.jpg";
        return temp;
    }

    /**
     * 获取一个以时间命名EMF拍照图片的路径
     * @return
     */
    @SuppressLint("SimpleDateFormat")
    public String GetEMFCameraUrl() {
        String temp ="";

        SimpleDateFormat format = new SimpleDateFormat("yyyy-MM-dd_HH-mm-ss_SS");
        String fileName = format.format( new Timestamp( System.currentTimeMillis()) ) + ".jpg";

        temp += GetEMFPath() + fileName;
        return temp;
    }

    /**
     * 取APP缓存路径,等于系统-->设置里的清除缓存,不会删掉SP和数据库
     * 删的是:/data/data/com.qpidnetwork.dating/cache/
     * 注:红米 Webview缓存:/data/data/com.qpidnetwork.dating/cache/org.chromium.android_webview
     * @return
     */
    private String GetCahcheUri(){
        String temp ="";
        temp = mContext.getCacheDir().getAbsolutePath();// + "/webviewCahce";
        return temp;
    }

    /**
     * 取APP文件路径
     * @return
     */
    private String GetFilesUri(){
        String temp ="";
        temp = mContext.getFilesDir().getAbsolutePath();// + "/webCahce";
        return temp;
    }

    /**
     * 删除指定目录下所有文件
     * @param dirPath 目录路径
     * @return
     */
    public void doDelete(String dirPath) {
        delete(new File(dirPath), false);
//		String cmd = "rm -rf " + dirPath;
//		try {
//			Runtime.getRuntime().exec(cmd);
//		} catch (IOException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
    }


    /**
     * 清空缓存路径文件
     */
    public void ClearCache() {
//        delete(new File(GetHttpPath()), false);
//        delete(new File(GetImagePath()), false);
//        delete(new File(GetTempPath()), false);
//        delete(new File(GetEMFPath()), false);
//        delete(new File(GetEMFVideoPath()), false);
//        delete(new File(GetLadyPath()), false);
//
//        delete(new File(GetVirtualGiftPath()), false);
//        delete(new File(GetPrivatePhotoPath()), false);
//
//        delete(new File(getPrivatePhotoTempSavePath()), false);
//        delete(new File(GetLCEmotionPath()), false);
//        delete(new File(GetLCPhotoPath()), false);
//        delete(new File(GetLCVoicePath()), false);
//        delete(new File(GetLCVideoPath()), false);
//
//        //直播模块算大小
//        delete(new File(getGiftPath()), false);
//        delete(new File(getCarImgRootPath()), false);
//        delete(new File(getEmotionImgRootPath()), false);
//        delete(new File(getMedalImgRootPath()), false);
//
//        //删除webview缓存  add by Jagger 2017-6-13
//        delete(new File(GetCahcheUri()), false);
//        delete(new File(GetFilesUri()), false);
        //清除所有缓存
        delete(new File(getFileCacheHomePath()), false);
        mContext.deleteDatabase("webview.db");					//红米Note2 没作用,返回false
        mContext.deleteDatabase("webviewCache.db");	//url记录	//红米Note2 没作用,返回false

//		String cmd = "rm -rf " + mMainPath;
//		try {
//			Runtime.getRuntime().exec(cmd);
//		} catch (IOException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
    }

    /**
     * 清空虚拟礼物缓存
     */
    public void ClearVirtualGift() {
        delete(new File(GetVirtualGiftPath()), false);
//		String cmd = "rm -rf " + GetVirtualGiftPath();
//		try {
//			Runtime.getRuntime().exec(cmd);
//		} catch (IOException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
    }

    /**
     * 清空crash log
     */
    public void ClearCrashLog() {
        delete(new File(GetCrashInfoPath()), false);
//		String cmd = "rm -rf " + GetCrashInfoPath();
//		try {
//			Runtime.getRuntime().exec(cmd);
//		} catch (IOException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
    }

    private static void delete(File file, boolean deleteSelf) {
        if ( file != null && file.exists() ) {
            if (file.isFile()) {
                file.delete();
            } else if ( file.isDirectory() ) {
                File[] files = file.listFiles();
                if(files != null){
                    for (int i = 0; i < files.length; i++) {
                        delete(files[i], true);
                    }
                }
            }
        }

        if( deleteSelf )
            file.delete();
    }

    /**
     * 清除指定目录下private photo缓存（EMF相关）
     */
    public void clearAllPrivatePhotoCache(){
        String path = mMainPath + "/" + PRIVATE_PHOTO + "/";
        clearAllFileByDirectory(path);
    }

    /**
     * 清除所有livechat 私密照临时缓存
     */
    public void clearAllPrivatePhotoTempCache(){
        String path = getPrivatePhotoTempSavePath();
        File file = new File(path);
        if(file.isDirectory()){
            doDelete(path);
        }
    }

    /**
     * 清除指定目录下vide缓存（EMF相关）
     */
    public void clearAllVideoCache(){
        String path = mMainPath + "/" + EMF_VIDEO + "/";
        clearAllFileByDirectory(path);
    }

    /**
     * 清除指定目录下所有文件
     * @param directory
     */
    private void clearAllFileByDirectory(String directory){
        if (!directory.isEmpty()){
            String dirPath = directory + "*";
            String cmd = "rm -f " + dirPath;
            try {
                Runtime.getRuntime().exec(cmd);
            } catch (IOException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
    }

    /**********************************************  直播模块相关本地缓存路径  ******************************************/
    /**
     * 获取礼物文件存储目录
     *
     * @return
     */
    public String getGiftPath() {
        /* 创建图片目录 */
        String path = mMainPath + File.separator + GIFT + File.separator;
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
        localPath += parseFileNameFromUrl(url);
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
            fileName = fileUrl.substring(fileUrl.lastIndexOf(File.separator),fileUrl.length());
            //add by Jagger 2018-5-10
            fileName = getFileNameNoEx(fileName);
        }
        return fileName;
    }

    /**
     * 获取推流器/播放器本地缓存目录（库内获取sd路径拼接）
     * @return
     */
    public String GetPublisherPlayerLogLocalPath(){
        String LOCAL_CACHE_ROOT_DIR = mContext.getResources().getString(R.string.app_name);
        String path = LOCAL_CACHE_ROOT_DIR + "/" + PLAYER_PUBLISHER_LOG_DIR;
        return path;
    }

    /**
     * 获取log目录路径
     *
     * @return
     */
    public String getIMLogPath() {
        /* 创建log路径 */
        String path = mMainPath + File.separator + LOG_DIR + "/" + "IM" + "/";
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
    public String getLMLogPath() {
        /* 创建log路径 */
        String path = mMainPath + File.separator + LOG_DIR + "/" + "LM" + "/";
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }

        return path;
    }

    private String getCarImgRootPath(){
        /* 创建log路径 */
        String path = mMainPath + File.separator + CAR + File.separator;
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }

        return path;
    }

    public String parseCarImgLocalPath(String riderId,String riderUrl){
        String localPath = getCarImgRootPath();
        localPath += riderId;
        //edit by Jagger 2018-5-10
        localPath += getFileNameNoEx(riderUrl.substring(riderUrl.lastIndexOf(File.separator),riderUrl.length()));
        return localPath;
    }

    private String getEmotionImgRootPath(){
        /* 创建emotion路径 */
        String path = mMainPath + File.separator + EMOTION + File.separator;
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }

        return path;
    }

    public String parseEmotionImgLocalPath(String emotionId, String emotionUrl){
        String localPath = getEmotionImgRootPath();
        localPath += emotionId;
        //edit by Jagger 2018-5-10
        localPath += getFileNameNoEx(emotionUrl.substring(emotionUrl.lastIndexOf(File.separator),emotionUrl.length()));
        return localPath;
    }

    private String getMedalImgRootPath(){
        /* 创建medal路径 */
        String path = mMainPath + File.separator + MEDAL + File.separator;
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
     * 获取不带扩展名的文件名
     * 例如：把 .png 转换为 _png， 而不是把.png去掉，
     * 是因为避免 abc.png和abc.webp下载到同一目录下 先下载的会被覆盖的问题
     * add by Jagger 2018-5-10
     */
    public static String getFileNameNoEx(String filename) {
        if ((filename != null) && (filename.length() > 0)) {
            int dot = filename.lastIndexOf('.');
            if ((dot >-1) && (dot < (filename.length()))) {
                return filename.replace("." , "_");
            }
        }
        return filename;
    }
}
