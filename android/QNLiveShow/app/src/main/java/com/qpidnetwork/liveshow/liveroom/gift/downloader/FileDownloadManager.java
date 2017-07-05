package com.qpidnetwork.liveshow.liveroom.gift.downloader;

import android.content.Context;
import android.text.TextUtils;

import com.liulishuo.filedownloader.BaseDownloadTask;
import com.liulishuo.filedownloader.FileDownloadListener;
import com.liulishuo.filedownloader.FileDownloadQueueSet;
import com.liulishuo.filedownloader.FileDownloader;
import com.liulishuo.filedownloader.util.FileDownloadLog;
import com.liulishuo.filedownloader.util.FileDownloadUtils;
import com.qpidnetwork.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.utils.Log;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
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

    public enum DownloadStatus{
        Default,
        Downloading,
        Done
    }

    private static FileDownloadManager instance= null;
    private String fileLocalDir = null;
    private Map<String,List<IFileDownloadedListener>> singleTaskListenerMap = new HashMap<>();
    private Map<String, DownloadStatus> singleTaskDownStatusMap = new HashMap<>();
    private Map<String,BaseDownloadTask> singleTaskMap = new HashMap<>();

    private FileDownloadManager(){
        fileLocalDir = FileCacheManager.getInstance().getGiftPath();
    }

    public static void init(Context context, boolean debugLog){
        FileDownloadLog.NEED_LOG = debugLog;//显示调试信息
        FileDownloader.init(context);
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
     * 检测fileId对应的礼物文件是否存在
     * @param fileId
     * @return
     */
    public boolean fileExists(String fileId, String fileUrl){
        boolean exists = false;
        String filePath = fileLocalDir + parseGiftNameFromUrl(fileUrl);
        if(!TextUtils.isEmpty(filePath)){
            File file = new File(filePath);
            exists = null != file && file.exists();
        }

        return exists;
    }

    /**
     * 获取本地文件路径
     * @param fileId
     * @param fileUrl
     * @return
     */
    public String getLocalFilePath(String fileId, String fileUrl){
        return fileLocalDir + parseGiftNameFromUrl(fileUrl);
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

//---------------------------------以下对String做处理--------------------------------------------

    /**
     * 添加单任务监听器
     * @param fileId
     * @param listener
     * @return
     */
    private synchronized boolean addSingleTaskListener(String fileId, IFileDownloadedListener listener){
        boolean isAddSuc = false;
        if (null != listener) {
            if(null == singleTaskListenerMap){
                singleTaskListenerMap = new HashMap<>();
            }
            List<IFileDownloadedListener> listeners;
            if(singleTaskListenerMap.containsKey(fileId)){
                listeners = singleTaskListenerMap.get(fileId);
                if(!listeners.contains(listener)){
                    listeners.add(listener);
                }
                isAddSuc = true;
            }else{
                listeners = new ArrayList<>();
                listeners.add(listener);
                isAddSuc = true;
            }
            singleTaskListenerMap.put(fileId,listeners);
        }
        Log.d(TAG,"addSingleTaskListener-fileId:"+fileId+" isAddSuc:"+isAddSuc);
        return isAddSuc;
    }

    private synchronized boolean unDownLoading(String fileId){
        boolean unDownLoading = false;
        if(null == singleTaskDownStatusMap){
            singleTaskDownStatusMap = new HashMap<>();
        }
        if(singleTaskDownStatusMap.containsKey(fileId)){
            unDownLoading = singleTaskDownStatusMap.get(fileId)!=DownloadStatus.Downloading;
        }else{
            unDownLoading = true;
        }
        Log.d(TAG,"unDownLoading-fileId:"+fileId+" unDownLoading:"+unDownLoading);
        return unDownLoading;
    }

    /**
     * 设置下载状态
     * @param fileId
     * @return
     */
    private synchronized void changeDownloadStatus(String fileId,DownloadStatus status){
        if(null == singleTaskDownStatusMap){
            singleTaskDownStatusMap = new HashMap<>();
        }
        if(singleTaskDownStatusMap.containsKey(fileId)){
            if(singleTaskDownStatusMap.get(fileId) != status){
                singleTaskDownStatusMap.put(fileId,status);
            }
        }else{
            singleTaskDownStatusMap.put(fileId,status);
        }
    }

    /**
     * 添加单任务
     * @param fileId
     * @param fileUrl
     * @return
     */
    private synchronized BaseDownloadTask addDownloadTask(String fileId, String fileUrl){
        if(null == singleTaskMap){
            singleTaskMap = new HashMap<>();
        }
        BaseDownloadTask task;
        if(!singleTaskMap.containsKey(fileId)){
            task = FileDownloader.getImpl().create(fileUrl)
                    .setPath(fileLocalDir + parseGiftNameFromUrl(fileUrl))
//                        .setCallbackProgressIgnored()
                    .setCallbackProgressTimes(300)
                    .setListener(new SingleTaskFileDownListener(fileId));
            singleTaskMap.put(fileId,task);
        }else{
            task = singleTaskMap.get(fileId);
        }
        return task;
    }

    /**
     * 开始下载(单任务,任何task调用自己的start都是全局并行启动)
     */
    public synchronized void start(String fileId, String fileUrl, IFileDownloadedListener listener){
        Log.d(TAG,"start-fileId:"+fileId+" fileUrl:"+fileUrl);
        if(addSingleTaskListener(fileId,listener) && unDownLoading(fileId)){
            changeDownloadStatus(fileId,DownloadStatus.Downloading);
            BaseDownloadTask task = addDownloadTask(fileId,fileUrl);
            boolean isReusedOldFile = task.isReusedOldFile();
            Log.d(TAG,"start-isReusedOldFile1:"+isReusedOldFile);
            boolean fileExists = fileExists(fileId,task.getPath());
            Log.d(TAG,"start-fileExists1:"+fileExists);
            if(fileExists){
                //存在则先删除
                new File(task.getPath()).delete();
                new File(FileDownloadUtils.getTempPath(task.getPath())).delete();
//                fileExists = fileExists(fileId,task.getPath());
//                Log.d(TAG,"start-fileExists2:"+fileExists);
            }
            if(task.isUsing()){
                task.reuse();
            }
            task.setTag(fileId);
            task.start();
        }
    }

    /**
     * 根据fileId停止单任务
     * @param fileId
     * @param fileUrl
     */
    public synchronized void stop(String fileId, String fileUrl){
        Log.d(TAG,"stop-fileId:"+fileId+" fileUrl:"+fileUrl);
        if(null != singleTaskMap && singleTaskMap.containsKey(fileId)){
            BaseDownloadTask task = singleTaskMap.get(fileId);
//            if(task.getUrl().equals(fileUrl)){
                task.pause();
//            }
//             singleTaskMap.remove(task);
        }
        changeDownloadStatus(fileId,DownloadStatus.Default);
        //停止某个任务后，由于可以断点续传，如果这个时候移除了listener，
        // 假设又重新调用了start，那么其他的listener就收不到通知了
    }

    private synchronized void clearAllSingleTask(){
        if(null != singleTaskMap){
            BaseDownloadTask task;
            for(Iterator<Map.Entry<String,BaseDownloadTask>> iterator = singleTaskMap.entrySet().iterator();iterator.hasNext();){
                task = iterator.next().getValue();
                task.pause();
                singleTaskMap.remove(task);
            }
            singleTaskMap.clear();
            singleTaskMap = null;
        }
    }

    private class SingleTaskFileDownListener extends FileDownloadListener{
        private String fileId = null;

        public SingleTaskFileDownListener(String fileId){
            this.fileId = fileId;
        }

        @Override
        protected void pending(BaseDownloadTask task, int soFarBytes, int totalBytes) {
            Log.d(TAG,"pending-id:"+task.getTag().toString()+" soFarBytes:"+soFarBytes+" totalBytes:"+totalBytes);
        }

        @Override
        protected void connected(BaseDownloadTask task, String etag, boolean isContinue, int soFarBytes, int totalBytes) {
            Log.d(TAG,"connected-id:"+task.getTag().toString()+" soFarBytes:"+soFarBytes+" totalBytes:"+totalBytes+" etag:"+etag+" isContinue:"+isContinue);
        }

        @Override
        protected void progress(BaseDownloadTask task, int soFarBytes, int totalBytes) {
            Log.d(TAG,"progress-id:"+task.getTag().toString()+" soFarBytes:"+soFarBytes+" totalBytes:"+totalBytes);
        }

        @Override
        protected void blockComplete(BaseDownloadTask task) {
            Log.d(TAG,"blockComplete-id:"+task.getTag().toString());
        }

        @Override
        protected void retry(final BaseDownloadTask task, final Throwable ex, final int retryingTimes, final int soFarBytes) {
            Log.d(TAG,"retry-id:"+task.getTag().toString()+" soFarBytes:"+soFarBytes+" retryingTimes:"+retryingTimes);
        }

        @Override
        protected void completed(BaseDownloadTask task) {
            Log.d(TAG,"completed-id:"+task.getTag().toString()+" isReuseOldFile:"+task.isReusedOldFile());
            if(null != singleTaskListenerMap && singleTaskListenerMap.containsKey(fileId)){
                List<IFileDownloadedListener> listeners = singleTaskListenerMap.get(fileId);
                if(null != listeners && listeners.size()>0){
                    for(IFileDownloadedListener listener : listeners){
                        listener.onCompleted(task.getPath(),String.valueOf(fileId),task.getUrl());
                    }
                }
                changeDownloadStatus(task.getTag().toString(),DownloadStatus.Done);
            }
        }

        @Override
        protected void paused(BaseDownloadTask task, int soFarBytes, int totalBytes) {
            Log.d(TAG,"paused-id:"+task.getTag().toString()+" soFarBytes:"+soFarBytes+" totalBytes:"+totalBytes);
        }

        @Override
        protected void error(BaseDownloadTask task, Throwable e) {
            Log.d(TAG,"error-id:"+task.getTag().toString());
            e.printStackTrace();
            changeDownloadStatus(task.getTag().toString(),DownloadStatus.Default);
        }

        @Override
        protected void warn(BaseDownloadTask task) {
            Log.d(TAG,"warn");
        }
    }

//---------------------------------以下对String[]做处理--------------------------------------------


    private Map<String,FileDownloadQueueSet> queueSetMap = new HashMap<>();
    private Map<String, List<BaseDownloadTask>> queueTaskMap = new HashMap<>();
    private Map<String, List<String>> allFileIdMap = new HashMap<>();
    private Map<String, List<String>> allFileUrlMap = new HashMap<>();
    private Map<String, List<IFileDownloadedListener>> allFileDownListenerMap = new HashMap<>();
    private DownloadStatus allFileDownStatus = DownloadStatus.Default;

    /**
     * 开始下载(任务队列，依据queueSetTag管理队列)
     * @param queueSetTag
     * @param fileIds
     * @param fileUrls
     * @param listener
     * @throws Exception
     */
    public synchronized void start(String queueSetTag, String[] fileIds, String[] fileUrls, IFileDownloadedListener listener) throws Exception{
        if(TextUtils.isEmpty(queueSetTag)){
            throw new IllegalStateException("queueSetTag不能为空！");
        }

        if(null == fileIds || fileIds.length == 0){
            throw new IllegalStateException("fileIds不能为空！");
        }

        if(null == fileUrls || fileUrls.length == 0){
            throw new IllegalStateException("fileUrls不能为空！");
        }

        addFileIdList(queueSetTag,fileIds);
        addFileUrlList(queueSetTag,fileUrls);
        if(addMultiFileDownListener(queueSetTag, listener) && allFileDownStatus == DownloadStatus.Default){

        }
    }

    private void addFileIdList(String queueSetTag, String[] fileIds) throws Exception{
        List<String> fileIdList = Arrays.asList(fileIds);
        List<String> tempFileIds = new ArrayList<>();
        if(null == allFileIdMap){
            allFileIdMap = new HashMap<>();
        }
        if(allFileIdMap.containsKey(queueSetTag)){
            tempFileIds.addAll(allFileIdMap.get(queueSetTag));
            tempFileIds.removeAll(fileIdList);
            if(0 != tempFileIds.size()){
                throw new IllegalStateException("queueSetTag="+queueSetTag+"对应的fileIds数据不匹配！");
            }
        }else{
            allFileIdMap.put(queueSetTag,fileIdList);
        }
    }

    private void addFileUrlList(String queueSetTag,String[] fileUrls) throws Exception{
        List<String> fileUrlList = Arrays.asList(fileUrls);
        List<String> tempFileUrlList = new ArrayList<>();
        if(null == allFileUrlMap){
            allFileUrlMap = new HashMap<>();
        }
        if(allFileUrlMap.containsKey(queueSetTag)){
            tempFileUrlList.addAll(allFileUrlMap.get(queueSetTag));
            tempFileUrlList.removeAll(fileUrlList);
            if(0 != tempFileUrlList.size()){
                throw new IllegalStateException("queueSetTag="+queueSetTag+"对应的fileUrls数据不匹配！");
            }
        }else{
            allFileUrlMap.put(queueSetTag,fileUrlList);
        }
    }

    private boolean addMultiFileDownListener(String queueSetTag,IFileDownloadedListener listener){
        boolean isAddMultiListenerSuc = false;
        if(null == allFileDownListenerMap){
            allFileDownListenerMap = new HashMap<>();
        }
        if(allFileDownListenerMap.containsKey(queueSetTag)){
            if(allFileDownListenerMap.get(queueSetTag).contains(listener)){
                isAddMultiListenerSuc = false;
            }else{
                allFileDownListenerMap.get(queueSetTag).add(listener);
                isAddMultiListenerSuc = true;
            }
        }else{
            List<IFileDownloadedListener> list = new ArrayList<>();
            list.add(listener);
            allFileDownListenerMap.put(queueSetTag,list);
            isAddMultiListenerSuc = true;
        }
        return isAddMultiListenerSuc;
    }

    /**
     *判断两个String[]内容是否相同
     */
    private boolean isEqual(String[] strs1, String[] strs2){
        List list1 = Arrays.asList(strs1);
        list1.removeAll(Arrays.asList(strs2));
        return list1.size() == 0;
    }

    /**
     * 清空所有的instance/list和map
     */
    public void release(){
        clearAllSingleTask();
        if(null != singleTaskListenerMap){
            singleTaskListenerMap.clear();
            singleTaskListenerMap = null;
        }
        if(null != singleTaskDownStatusMap){
            singleTaskDownStatusMap.clear();
            singleTaskDownStatusMap = null;
        }
    }
}
