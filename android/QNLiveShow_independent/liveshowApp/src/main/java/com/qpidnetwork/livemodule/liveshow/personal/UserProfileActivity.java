package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.support.v4.content.FileProvider;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;

import com.dou361.dialogui.DialogUIUtils;
import com.dou361.dialogui.adapter.TieAdapter;
import com.dou361.dialogui.bean.BuildBean;
import com.dou361.dialogui.bean.TieBean;
import com.dou361.dialogui.listener.DialogUIItemListener;
import com.facebook.common.util.UriUtil;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.utils.CompatUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.squareup.picasso.Picasso;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/12/25.
 */

public class UserProfileActivity extends BaseActionBarFragmentActivity{

    /**
     * 拍照
     */
    private static final int RESULT_LOAD_IMAGE_CAPTURE = 0;
    /**
     * 相册
     */
    private static final int RESULT_LOAD_IMAGE_ALBUMN = 1;
    /**
     * 裁剪图片
     */
    private static final int RESULT_LOAD_IMAGE_CUT = 2;

    private CircleImageView civ_currPhoto;

    private TextView tv_nickName;

    private LoginItem loginItem;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = UserProfileActivity.class.getSimpleName();
        setCustomContentView(R.layout.activity_user_profile);
        setTitle(getResources().getString(R.string.live_edit_profile_nickname_tips1));
        initView();
    }

    private void initView(){
        civ_currPhoto = (CircleImageView) findViewById(R.id.civ_currPhoto);
        tv_nickName = (TextView) findViewById(R.id.tv_nickName);
    }

    private void initData(){
        loginItem = LoginManager.getInstance().getLoginItem();
        if(null != loginItem){
            tv_nickName.setText(loginItem.nickName);
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        initData();
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int id = v.getId();
        if(id == R.id.ll_nickname){
            startActivity(new Intent(this,EditNickNameActivity.class));
        }else if(id == R.id.ll_userPhoto){
            showPhotoMenu();
        }
    }

    /**
     * 拍照菜单列表
     */
    private void showPhotoMenu(){
        //列表选项
        TieBean tieLogin = new TieBean(getString(R.string.live_edit_profile_menu_choose_photo));
        tieLogin.setGravity(Gravity.CENTER);

        TieBean tieSignup = new TieBean(getString(R.string.live_edit_profile_menu_take_photo));
        tieSignup.setGravity(Gravity.CENTER);

        TieBean tieCancel = new TieBean(getString(R.string.common_btn_cancel));
        tieCancel.setColor(getResources().getColor(R.color.black3));
        tieCancel.setGravity(Gravity.CENTER);

        List<TieBean> listMenu = new ArrayList<>();
        listMenu.add(tieLogin);
        listMenu.add(tieSignup);
        listMenu.add(tieCancel);

        //对话框
        TieAdapter adapter = new TieAdapter(mContext, listMenu, true);
        BuildBean buildBean = DialogUIUtils.showMdBottomSheet(this, true, "", listMenu, 0, new DialogUIItemListener() {
            @Override
            public void onItemClick(CharSequence text, int position) {
                if(position == 0){
                    onClickedMenuChoosePhoto();
                }else if(position == 1){
                    onClickedMenuTakePhoto();
                }
            }
        });
        buildBean.mAdapter = adapter;
        buildBean.show();
    }

    /**
     * ChoosePhoto
     */
    private void onClickedMenuChoosePhoto(){
        try{
            startActivityForResult(CompatUtil.getSelectPhotoFromAlumIntent(), RESULT_LOAD_IMAGE_ALBUMN);
        }catch(Exception e){
            Intent intent = new Intent();
            intent.setType("image/*");
            intent.setAction(Intent.ACTION_GET_CONTENT);
            startActivityForResult(intent, RESULT_LOAD_IMAGE_ALBUMN);
        }
    }

    /**
     * TakePhoto
     */
    private void onClickedMenuTakePhoto(){
        File tempFile = new File(FileCacheManager.getInstance().GetTempCameraImageUrl());

        Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
        //7.0＋拍照图片存取兼容 使用：FileProvider.getUriForFile
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            intent.putExtra(MediaStore.EXTRA_OUTPUT,
                    FileProvider.getUriForFile(mContext,
                            getPackageName()+ ".provider", tempFile));
            // 给目标应用一个临时授权
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        }else{
            intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(tempFile));
        }
        startActivityForResult(intent, RESULT_LOAD_IMAGE_CAPTURE);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch(requestCode) {
            case RESULT_LOAD_IMAGE_CAPTURE:{
                if( resultCode == RESULT_OK ) {
                    File tempCameraImager = new File(FileCacheManager.getInstance().GetTempCameraImageUrl());
                    File tempImager = new File(FileCacheManager.getInstance().getTempImageUrl());

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        doStartPhotoZoom(
                                FileProvider.getUriForFile(mContext,getPackageName()+ ".provider", tempCameraImager),
                                Uri.fromFile(tempImager)	//照片 截取输出的outputUri， 只能使用 Uri.fromFile，不能用FileProvider.getUriForFile
                                //不然会报：Permission Denial: writing android.support.v4.content.FileProvider
                        );
                    }else{
                        doStartPhotoZoom(
                                Uri.fromFile(tempCameraImager),
                                Uri.fromFile(tempImager)
                        );
                    }
                }
            }break;
            case RESULT_LOAD_IMAGE_ALBUMN:{
                if( resultCode == RESULT_OK && null != data ) {
                    Uri selectedImage = data.getData();
                    String picturePath = CompatUtil.getSelectedPhotoPath(this, selectedImage);
                    if(!TextUtils.isEmpty(picturePath)){
                        File pic = new File(picturePath);
                        File picCut = new File(FileCacheManager.getInstance().getTempImageUrl());

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            doStartPhotoZoom(
                                    FileProvider.getUriForFile(mContext,getPackageName()+ ".provider", pic),
                                    Uri.fromFile(picCut)	//照片 截取输出的outputUri， 只能使用 Uri.fromFile，不能用FileProvider.getUriForFile
                                    //不然会报：Permission Denial: writing android.support.v4.content.FileProvider
                            );
                        }else{
                            doStartPhotoZoom(
                                    Uri.fromFile(pic),
                                    Uri.fromFile(picCut)
                            );
                        }

                    }

                }
            }break;
            case RESULT_LOAD_IMAGE_CUT:{
                if( resultCode == RESULT_OK) {
                    //裁剪后图片 显示到头像处
                    Uri uri = new Uri.Builder()
                            .scheme(UriUtil.LOCAL_FILE_SCHEME)
                            .path(FileCacheManager.getInstance().getTempImageUrl())
                            .build();
                    Log.d(TAG,"RESULT_LOAD_IMAGE_CUT uri:"+uri);
                    Picasso.with(getApplicationContext())
                            .load(uri)
                            .placeholder(R.drawable.ic_default_photo_man)
                            .error(R.drawable.ic_default_photo_man)
                            .into(civ_currPhoto);


                    // 上传头像
//                    showProgressDialog("Uploading...");
//                    RequestOperator.getInstance().UploadHeaderPhoto(
//                            FileCacheManager.getInstance().GetTempImageUrl(),
//                            new OnRequestCallback() {
//
//                                @Override
//                                public void OnRequest(boolean isSuccess, String errno, String errmsg) {
//                                    // TODO Auto-generated method stub
//                                    Message msg = Message.obtain();
//                                    RequestBaseResponse obj = new RequestBaseResponse(isSuccess, errno, errmsg, null);
//                                    if( isSuccess ) {
//                                        // 上传头像成功
//                                        msg.what = RequestFlag.REQUEST_UPLOAD_SUCCESS.ordinal();
//                                    } else {
//                                        // 上传头像失败
//                                        msg.what = RequestFlag.REQUEST_FAIL.ordinal();
//                                    }
//                                    msg.obj = obj;
//                                    sendUiMessage(msg);
//                                }
//                            });
                }
            }break;
            default:break;
        }
    }

    /**
     * 裁剪图片方法实现
     *
     */
    public void doStartPhotoZoom(Uri src, Uri dest) {
        Intent intent = new Intent("com.android.camera.action.CROP");
        // 给目标应用一个临时授权
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION
                    | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        }
        intent.setDataAndType(src, "image/*");
        // 下面这个crop=true是设置在开启的Intent中设置显示的VIEW可裁剪
        intent.putExtra("crop", "true");
        // aspectX aspectY 是宽高(x y方向上)的比例，其小于1的时候可以操作截图框,若不设定，则可以任意宽度和高度
        intent.putExtra("aspectX", 4);
        intent.putExtra("aspectY", 5);
        intent.putExtra("scale", true);
        // 指定裁剪后的图片存储路径
        intent.putExtra("output", dest);
        // outputX outputY裁剪保存的宽高(使各手机截取的图片质量一致)
        intent.putExtra("outputY", 500);
        intent.putExtra("outputX", 400);
        // 取消人脸识别功能(系统的裁剪图片默认对图片进行人脸识别,当识别到有人脸时，会按aspectX和aspectY为1来处理)
        intent.putExtra("noFaceDetection", true);
        // 将相应的数据与URI关联起来，返回裁剪后的图片URI,true返回bitmap
        intent.putExtra("return-data", false);
        intent.putExtra("outputFormat", Bitmap.CompressFormat.JPEG.toString());
        startActivityForResult(intent, RESULT_LOAD_IMAGE_CUT);
    }
}
