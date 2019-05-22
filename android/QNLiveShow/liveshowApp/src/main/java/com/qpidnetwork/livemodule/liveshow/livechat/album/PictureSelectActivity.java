package com.qpidnetwork.livemodule.liveshow.livechat.album;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.qnbridgemodule.view.camera.AlbumDataHolderManager;
import com.qpidnetwork.qnbridgemodule.view.camera.ImageBean;

import java.util.List;

/**
 * 本地图库—— 3 列
 */
//public class PictureSelectActivity extends BaseFragmentActivity {
public class PictureSelectActivity extends BaseActionBarFragmentActivity {

    public static final String SELECT_PICTURE_PATH = "picturePath";
    private static final String SELECT_PICTURE_TYPE_KEY = "picSelectType";

    private static final int REQUEST_CODE_IMAGE = 11;

    // 选择的类别：chat 、camShare
    public static final int SELECT_PICTURE_TYPE_CHAT = 1;
    public static final int SELECT_PICTURE_TYPE_CAM_SHARE = 2;

    private GridView gvAlbum;
//    private ImageView ivClose;
    private AlbumGridAdapter mAdapter;

    private int mCurSelectPicType = SELECT_PICTURE_TYPE_CHAT;

    public static void startAct(Context context, int picSelectType, int requestCode) {
        Intent intent = new Intent(context, PictureSelectActivity.class);
        intent.putExtra(SELECT_PICTURE_TYPE_KEY, picSelectType);
        ((Activity) context).startActivityForResult(intent, requestCode);
    }


    @Override
    protected void onCreate(Bundle arg0) {
        super.onCreate(arg0);

        setCustomContentView(R.layout.activity_livechat_select_picture_live);

        setImmersionBarArtts(R.color.transparent_7);

        initViews();
        initData();
    }

    private void initViews() {
        if (getIntent() != null) {
            mCurSelectPicType = getIntent().getIntExtra(SELECT_PICTURE_TYPE_KEY, SELECT_PICTURE_TYPE_CHAT);
        }

        // 2018/12/17 Hardy
//        getCustomActionBar().addButtonToLeft(R.id.common_button_back, "", R.drawable.ic_arrow_back_grey600_24dp);
//        getCustomActionBar().setTitle("Album", ContextCompat.getColor(this, R.color.black));
//        getCustomActionBar().setAppbarBackgroundColor(ContextCompat.getColor(this, R.color.theme_actionbar_secoundary));
        setOnlyTitle("Album");

        gvAlbum = (GridView) findViewById(R.id.gvAlbum);
//        ivClose = (ImageView) findViewById(R.id.ivClose);
//        ivClose.setOnClickListener(this);
//        // 2018/12/17 Hardy
//        ivClose.setVisibility(View.GONE);
    }

    private void initData() {
//        AlbumHelper helper = new AlbumHelper(this);
        // 2018/12/20 Hardy
//        List<ImageBean> mDataList = helper.getAlbumImageList();
//        // 2019/5/10 Hardy
//        mDataList = helper.sortNotPngImagePath(mDataList);
//        AlbumDataHolderManager.getInstance().setDataList(mDataList);

        // 2019/5/21 Hardy
        List<ImageBean> mDataList = AlbumDataHolderManager.getInstance().getDataList();

        mAdapter = new AlbumGridAdapter(this, mDataList);
        gvAlbum.setAdapter(mAdapter);
        gvAlbum.setOnItemClickListener(new OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view,
                                    int position, long id) {
                // old
//				Intent intent = new Intent();
//				intent.putExtra(SELECT_PICTURE_PATH, mAdapter.getItem(position).imagePath);
//				setResult(RESULT_OK, intent);
//				finish();

                // 2018/12/14 Hardy
                if (mCurSelectPicType == SELECT_PICTURE_TYPE_CAM_SHARE) {
                    // 兼容 camShare 时，点击 item 直接返回选中结果
                    String localFilePath = mAdapter.getItem(position).imagePath;
                    handlerBackIntent(localFilePath);
                } else {
                    AlbumPhotoPreviewActivity.startAct(mContext, position, REQUEST_CODE_IMAGE);
                }
            }
        });
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);

//        switch (v.getId()) {
//            case R.id.ivClose:
//                finish();
//                break;
//
//            default:
//                break;
//        }
    }

    @Override
    public void finish() {
        super.finish();
        overridePendingTransition(R.anim.anim_donot_animate, R.anim.anim_translate_from_top_to_buttom);
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (requestCode == REQUEST_CODE_IMAGE && resultCode == Activity.RESULT_OK) {
            if (data != null) {
                String filePath = data.getStringExtra(AlbumPhotoPreviewActivity.LOCAL_FILE_PATH);
                if (!TextUtils.isEmpty(filePath)) {
                    handlerBackIntent(filePath);
                }
            }
        }
    }

    private void handlerBackIntent(String filePath) {
        Intent intent = new Intent();
        intent.putExtra(SELECT_PICTURE_PATH, filePath);
        setResult(RESULT_OK, intent);
        finish();
    }
}
