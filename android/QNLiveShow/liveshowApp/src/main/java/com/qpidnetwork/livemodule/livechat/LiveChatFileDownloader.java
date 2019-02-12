package com.qpidnetwork.livemodule.livechat;

import android.content.Context;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.FileDownloadManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.IFileDownloadedListener;

public class LiveChatFileDownloader implements IFileDownloadedListener {

    private Context mContext;
    private FileDownloadManager mFileDownloadManager;

    private String mUrl;
    private String mLocalPath;
    private LiveChatFileDownloaderCallback mCallback;

    public LiveChatFileDownloader(Context context){
        this.mContext = context;
        mFileDownloadManager = FileDownloadManager.getInstance();
    }

    public void StartDownload(final String url, final String localPath, final LiveChatFileDownloaderCallback callback){
        //先停止之前的url下载
        Stop();

        this.mUrl = url;
        this.mLocalPath = localPath;
        this.mCallback = callback;
        if(mFileDownloadManager != null){
            mFileDownloadManager.start(url, localPath, this);
        }
    }

    /**
     * 停止之前的下载
     */
    public void Stop() {
        if(!TextUtils.isEmpty(mUrl) && mFileDownloadManager != null){
            mFileDownloadManager.stop(mUrl);
        }
    }

    /**
     * 是否下载中
     * @return
     */
    public boolean IsDownloading() {
        boolean bFlag = false;
        if( mFileDownloadManager != null ) {
            bFlag = mFileDownloadManager.isDownloading(mUrl);
        }
        return bFlag;
    }

    public String GetUrl() {
        return mUrl;
    }

    public String GetLocalPath() {
        return mLocalPath;
    }

    @Override
    public void onCompleted(boolean isSuccess, String localFilePath, String fileUrl) {
        if(mCallback != null) {
            if (isSuccess) {
                mCallback.onSuccess(this);
            } else {
                mCallback.onFail(this);
            }
        }
    }

    @Override
    public void onProgress(String fileUrl, int progress) {
        if(mCallback != null) {
            mCallback.onUpdate(this, progress);
        }
    }

    /**
     * 下载文件工具回调
     */
    public interface LiveChatFileDownloaderCallback {
        void onSuccess(LiveChatFileDownloader loader);
        void onFail(LiveChatFileDownloader loader);
        void onUpdate(LiveChatFileDownloader loader, int progress);
    }
}
