package com.qpidnetwork.livemodule.liveshow;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.FileDownloadManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.downloader.IFileDownloadedListener;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.SystemUtils;

/**
 * 测试下载器是否支持304错误
 * 测试礼物图片下载地址
 * http://172.25.32.17:84/uploadfiles/virtual_gift/icon/big/G00078.png
 * http://172.25.32.17:84/uploadfiles/virtual_gift/icon/big/G00067.png
 * http://172.25.32.17:84/uploadfiles/virtual_gift/icon/big/G00063.png
 * http://172.25.32.17:84/uploadfiles/virtual_gift/icon/big/G00061.png
 * http://172.25.32.17:84/uploadfiles/virtual_gift/icon/big/G00109.png
 * http://172.25.32.17:84/uploadfiles/virtual_gift/icon/big/G00108.png
 * http://172.25.32.17:84/uploadfiles/virtual_gift/icon/big/G00107.png
 * http://172.25.32.17:84/uploadfiles/virtual_gift/icon/big/G00088.png
 *
 */
public class TestFileDnLderSup304Activity extends BaseFragmentActivity implements View.OnClickListener{

//    private String defaultImgUrl = "http://192.168.8.242/uploadfiles/cover_photo/origin/201710/1b26d79101da99f11d697dc89072375f.png";
//    private String defaultImgUrl = "http://172.25.32.17:84/uploadfiles/virtual_gift/icon/big/G00078.png";
    private String defaultImgUrl = "http://192.168.8.242/uploadfiles/virtual_gift/app/G010.webp";
    private String defaultImgId = "79";

    private TextView btn_downloader;
    private ImageView iv_test304;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = TestFileDnLderSup304Activity.class.getSimpleName();
        setContentView(R.layout.activity_test304);
        initView();
    }

    private void initView(){
        btn_downloader = (Button) findViewById(R.id.btn_downloader);
        iv_test304 = (ImageView) findViewById(R.id.iv_test304);
        btn_downloader.setOnClickListener(this);
    }

    public void onClick(View v) {
        int viewResId = v.getId();
        if(viewResId == R.id.btn_downloader) {
            String localPath = FileCacheManager.getInstance().getGiftLocalPath(defaultImgId, defaultImgUrl);
            boolean fileExisted = SystemUtils.fileExists(localPath);
            Log.d(TAG,"onClick localPath:"+localPath);
            Log.d(TAG,"onClick fileExisted:"+fileExisted);

            FileDownloadManager.getInstance().start(defaultImgUrl, localPath, new IFileDownloadedListener() {
                @Override
                public void onCompleted(final boolean isSuccess, final String localFilePath, String fileUrl) {
                    Log.d(TAG,"onCompleted isSuccess:"+isSuccess+" localFilePath:"+localFilePath+" fileUrl:"+fileUrl );
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if(isSuccess && SystemUtils.fileExists(localFilePath)){
//                                Picasso.with(getApplicationContext())
//                                        .load(new File(localFilePath))
//                                        .into(iv_test304);

                                Toast.makeText(TestFileDnLderSup304Activity.this,"success",Toast.LENGTH_SHORT).show();
                            }
                        }
                    });
                }
            });
        }
    }
}
