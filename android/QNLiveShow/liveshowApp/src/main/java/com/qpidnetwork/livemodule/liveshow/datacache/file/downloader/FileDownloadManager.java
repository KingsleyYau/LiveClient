package com.qpidnetwork.livemodule.liveshow.datacache.file.downloader;

import android.content.Context;

import com.liulishuo.filedownloader.BaseDownloadTask;
import com.liulishuo.filedownloader.FileDownloadListener;
import com.liulishuo.filedownloader.FileDownloader;
import com.liulishuo.filedownloader.util.FileDownloadLog;
import com.liulishuo.filedownloader.util.FileDownloadUtils;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.qnbridgemodule.util.Authorization5179Util;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * Description:大礼物文件下载管理器,基于FileDownloader二次封装<p>
 * 1.对于大礼物下载,要求有
 *   start方法,成功下载有回调, 回调的实现方式二选一：1>listener、2>callback.
 *   这里采用2>方式，需要有一个List<giftId/giftUrl,callback>的映射表,
 *   这样下载成功后遍历回调成功的方法即可.</>;
 *   stop方法，彻底停止ID对应礼物文件的下载，并删除本地下载一半的文件及缓存文件数据;
 *   check方法，判断该ID对应的礼物文件是否已经存在，已经存在需要删除，目前暂时不用校验文件新旧;
 * <p>
 * Created by Harry on 2017/6/21.
 */

public class FileDownloadManager {

    private final String TAG = FileDownloadManager.class.getSimpleName();

    private static FileDownloadManager instance= null;
    private Map<String,List<IFileDownloadedListener>> singleTaskListenerMap;
    private Map<String, BaseDownloadTask> singleTaskMap = new HashMap<>();

    private FileDownloadManager(){
        singleTaskListenerMap = new HashMap<String,List<IFileDownloadedListener>>();
        singleTaskMap = new HashMap<String, BaseDownloadTask>();
    }

    public static void init(Context context, boolean debugLog){
        FileDownloadLog.NEED_LOG = debugLog;//显示调试信息
        FileDownloader.init(context.getApplicationContext());
    }

    /**
     * 初始化全局静态单例-懒汉模式
     * @return
     */
    public static FileDownloadManager getInstance(){
        if(null == instance){
            instance = new FileDownloadManager();
        }
        return instance;
    }

    /**
     * 销毁
     */
    public static void destory(){
        FileDownloader.getImpl().unBindService();
        FileDownloader.getImpl().clearAllTaskData();
        instance = null;
    }

    //---------------------------------以下对String做处理--------------------------------------------

    /**
     * 添加单任务监听器
     * @param url           //下载Url
     * @param listener
     * @return
     */
    private synchronized void addSingleTaskListener(String url, IFileDownloadedListener listener){
        List<IFileDownloadedListener> listeners;
        if(listener == null){
            return;
        }
        synchronized (singleTaskListenerMap){
            if(singleTaskListenerMap.containsKey(url)){
                listeners = singleTaskListenerMap.get(url);
                listeners.add(listener);
            }else{
                listeners = new ArrayList<IFileDownloadedListener>();
                listeners.add(listener);
                singleTaskListenerMap.put(url, listeners);
            }
        }
    }

    /**
     * 清除下载队列
     * @param url
     * @return
     */
    private synchronized List<IFileDownloadedListener> removeSingleTaskListener(String url){
        List<IFileDownloadedListener> listeners = new ArrayList<IFileDownloadedListener>();
        synchronized (singleTaskListenerMap){
            if(singleTaskListenerMap.containsKey(url)){
                listeners = singleTaskListenerMap.remove(url);
            }
        }
        return listeners;
    }

    /**
     * 创建任务下载Task
     * @param url
     * @param localPath
     * @return
     */
    private BaseDownloadTask createDownloadTask(String url, String localPath){
        BaseDownloadTask task = FileDownloader.getImpl().create(url);
        if ( LiveModule.mIsDebug ) {
//            String basicAuth = "Basic " + new String(Base64.encode("test:5179".getBytes(), Base64.NO_WRAP));
//            task.addHeader("Authorization", basicAuth);
            task.addHeader(Authorization5179Util.getDemoAuthorizationHeaderKey(),
                    Authorization5179Util.getDemoAuthorizationHeaderValue());
        }
        task.setPath(localPath);
        task.setCallbackProgressTimes(500);
        task.setForceReDownload(false);
        task.setListener(new SingleTaskFileDownListener());
        return task;
    }

    /**
     * 添加到下载队列
     * @param url
     * @param task
     * @return
     */
    private void addToDownloadList(String url, BaseDownloadTask task){
        synchronized (singleTaskMap){
            if(!singleTaskMap.containsKey(url)){
                singleTaskMap.put(url, task);
            }
        }
    }

    /**
     * 下载完成等删除指定任务
     * @param url
     */
    private BaseDownloadTask removeDownloadingTask(String url){
        BaseDownloadTask task = null;
        synchronized (singleTaskMap){
            if(singleTaskMap.containsKey(url)){
                task = singleTaskMap.remove(url);
            }
        }
        return task;
    }

    /**
     * 是否正在下载
     * @param url
     * @return
     */
    public boolean isDownloading(String url){
        boolean isDownloading = false;
        synchronized (singleTaskMap){
            if(singleTaskMap.containsKey(url)){
                isDownloading = true;
            }
        }
        return isDownloading;
    }

    /**
     * 开始下载
     * @param url
     * @param localPath     指定本地存放路径
     * @param listener
     */
    public synchronized void start(String url, String localPath, IFileDownloadedListener listener){
        Log.d(TAG,"start-url:" + url + " localPath:" + localPath);
        addSingleTaskListener(url, listener);
        if(!isDownloading(url)){
            BaseDownloadTask task = createDownloadTask(url, localPath);
            addToDownloadList(url, task);
            boolean fileExists = SystemUtils.fileExists(localPath);
            Log.d(TAG,"start-fileExists:" + fileExists);
            if(task.isUsing()){
                task.reuse();
            }
            task.start();
        }
    }

    /**
     * 根据fileId停止单任务
     * @param fileUrl
     */
    public synchronized void stop(String fileUrl){
        Log.d(TAG,"stop fileUrl:"+fileUrl);
        BaseDownloadTask task = removeDownloadingTask(fileUrl);
        if(task != null){
            task.pause();
        }
        //停止某个任务后，由于可以断点续传，如果这个时候移除了listener，
        // 假设又重新调用了start，那么其他的listener就收不到通知了
    }

    private synchronized void clearAllSingleTask(){
        if(null != singleTaskMap){
            BaseDownloadTask task;
            for(Iterator<Map.Entry<String,BaseDownloadTask>> iterator = singleTaskMap.entrySet().iterator(); iterator.hasNext();){
                task = iterator.next().getValue();
                task.pause();
            }
            singleTaskMap.clear();
            singleTaskMap = null;
        }
    }

    /**
     * 清空所有下载器
     */
    private synchronized void clearAllListener(){
        synchronized (singleTaskListenerMap){
            singleTaskListenerMap.clear();
        }
    }



    /**
     * 清除临时文件
     * @param task
     */
    public void deleteTempFile(BaseDownloadTask task){
        if(task != null){
            String tempPath = FileDownloadUtils.getTempPath(task.getPath());
            if(SystemUtils.fileExists(tempPath)){
                new File(tempPath).delete();
            }
        }
    }

    /**
     * 统一处理下载进度事件回调
     * @param task
     * @param soFarBytes
     * @param totalBytes
     */
    private void notifyDownloadProgress(BaseDownloadTask task, int soFarBytes, int totalBytes){
        int progress = 0;
        if(totalBytes > 0){
            progress = (soFarBytes * 100) % soFarBytes;
        }else{
            progress = 100;
        }
        String url = task.getUrl();
        synchronized (singleTaskListenerMap){
            if(singleTaskListenerMap.containsKey(url)){
                List<IFileDownloadedListener> listeners = singleTaskListenerMap.get(url);
                for(IFileDownloadedListener listener : listeners){
                    listener.onProgress(url, progress);
                }
            }
        }
    }

    /**
     * 统一处理完成事件回调
     * @param result
     * @param task
     */
    private void notifyDownloadComplete(boolean result, BaseDownloadTask task){
        //清除监听器
        List<IFileDownloadedListener> listeners = removeSingleTaskListener(task.getUrl());
        if(null != listeners && listeners.size()>0){
            for(IFileDownloadedListener listener : listeners){
//                Log.d(TAG,"notifyDownloadComplete:" + listener.toString());
                listener.onCompleted(result, task.getPath(), task.getUrl());
            }
        }
    }

    private class SingleTaskFileDownListener extends FileDownloadListener {

        public SingleTaskFileDownListener(){

        }

        @Override
        protected void pending(BaseDownloadTask task, int soFarBytes, int totalBytes) {
            Log.d(TAG,"pending-task.url: " + task.getUrl()+" soFarBytes:"+soFarBytes+" totalBytes:"+totalBytes);
        }

        @Override
        protected void connected(BaseDownloadTask task, String etag, boolean isContinue, int soFarBytes, int totalBytes) {
            Log.d(TAG,"connected-task.url: " + task.getUrl()+" etag:"+etag
                    +" isContinue:"+isContinue+" soFarBytes:"+soFarBytes+" totalBytes:"+totalBytes);
        }

        @Override
        protected void progress(BaseDownloadTask task, int soFarBytes, int totalBytes) {
            Log.d(TAG,"progress-task.url: " + task.getUrl()+" soFarBytes:"+soFarBytes+" totalBytes:"+totalBytes);
            notifyDownloadProgress(task, soFarBytes, totalBytes);
        }

        @Override
        protected void blockComplete(BaseDownloadTask task) {
            Log.d(TAG,"blockComplete-task.url: " + task.getUrl());
        }

        @Override
        protected void retry(final BaseDownloadTask task, final Throwable ex, final int retryingTimes, final int soFarBytes) {
            Log.d(TAG,"retry soFarBytes:"+soFarBytes+" retryingTimes:"+retryingTimes);
        }

        @Override
        protected void completed(BaseDownloadTask task) {
            Log.d(TAG,"completed isReuseOldFile:"+task.isReusedOldFile() +
                    " task.isForceReDownload:"+task.isForceReDownload()+ " task url: " + task.getUrl());
            //统一处理分发回调结果
            notifyDownloadComplete(true, task);
            //清除正在下载任务
            removeDownloadingTask(task.getUrl());
            //清除临时文件及本地文件
            deleteTempFile(task);
        }

        @Override
        protected void paused(BaseDownloadTask task, int soFarBytes, int totalBytes) {
//            Log.d(TAG,"paused soFarBytes:"+soFarBytes+" totalBytes:"+totalBytes);
            //暂停当结束使用，不存在续传需求
            //清除监听器
            removeSingleTaskListener(task.getUrl());
        }

        @Override
        protected void error(BaseDownloadTask task, Throwable e) {
//            Log.d(TAG,"error-task.url:"+task.getUrl()+" errmsg:"+e.getMessage());
            e.printStackTrace();
            //统一处理分发回调结果
            notifyDownloadComplete(false, task);
            //清除正在下载任务
            removeDownloadingTask(task.getUrl());
            //清除临时文件及本地文件
            deleteTempFile(task);
        }

        @Override
        protected void warn(BaseDownloadTask task) {
            Log.d(TAG,"warn");
            //统一处理分发回调结果
            notifyDownloadComplete(false, task);
        }

    }
}
