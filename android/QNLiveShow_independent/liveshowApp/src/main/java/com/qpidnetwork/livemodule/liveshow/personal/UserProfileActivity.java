package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.annotation.Nullable;
import android.support.v4.content.FileProvider;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.dou361.dialogui.DialogUIUtils;
import com.dou361.dialogui.adapter.TieAdapter;
import com.dou361.dialogui.bean.BuildBean;
import com.dou361.dialogui.bean.TieBean;
import com.dou361.dialogui.listener.DialogUIItemListener;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.item.GenderType;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.httprequest.item.ManBaseInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.NickNameVerifyType;
import com.qpidnetwork.livemodule.httprequest.item.PhotoVerifyType;
import com.qpidnetwork.livemodule.liveshow.authorization.MainBaseInfoManager;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.utils.CompatUtil;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;
import com.squareup.picasso.Target;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * Description:个人资料编辑页
 * <p>
 * Created by Harry on 2017/12/25.
 */

public class UserProfileActivity extends BaseActionBarFragmentActivity
        implements MainBaseInfoManager.OnUpdateUserPhotoListener,
        MainBaseInfoManager.OnGetMainBaseInfoListener {

    /**
     * 拍照
     */
    private static final int REQCODE_LOAD_IMAGE_CAPTURE = 0;
    /**
     * 相册
     */
    private static final int REQCODE_LOAD_IMAGE_ALBUMN = 1;
    /**
     * 裁剪图片
     */
    private static final int REQCODE_LOAD_IMAGE_CUT = 2;

    private static final int REQCODE_EDIT_NICKNAME = 3;



    private TextView tv_photoStatus;
    private CircleImageView civ_currPhoto;
    private TextView tv_userId;
    private TextView tv_nickName;
    private TextView tv_nickNameStatus;
    private TextView tv_gender;
    private TextView tv_birthday;
    private LoginItem loginItem;
    private ManBaseInfoItem manBaseInfoItem;
    private View view_errLoad;
    private TextView tvErrorMsg;
    private Button btnRetry;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = UserProfileActivity.class.getSimpleName();
        setCustomContentView(R.layout.activity_user_profile);
        setTitle(getResources().getString(R.string.profile_title), Color.WHITE);
        initView();
        refreshData();
        showLoadingDialog();
        MainBaseInfoManager.getInstance().getMainBaseInfoFromServ(this);
    }

    private void initView(){
        tv_photoStatus = (TextView) findViewById(R.id.tv_photoStatus);
        civ_currPhoto = (CircleImageView) findViewById(R.id.civ_currPhoto);
        tv_userId = (TextView) findViewById(R.id.tv_userId);
        tv_nickName = (TextView) findViewById(R.id.tv_nickName);
        tv_nickNameStatus = (TextView) findViewById(R.id.tv_nickNameStatus);
        tv_gender = (TextView) findViewById(R.id.tv_gender);
        tv_birthday = (TextView) findViewById(R.id.tv_birthday);

        view_errLoad = findViewById(R.id.view_errLoad);
        view_errLoad.setVisibility(View.GONE);
        tvErrorMsg = (TextView) findViewById(R.id.tvErrorMsg);
        btnRetry = (Button) findViewById(R.id.btnRetry);
        btnRetry.setOnClickListener(this);
    }

    private void refreshData(){
        //正常数据加载显示
        manBaseInfoItem = MainBaseInfoManager.getInstance().getLocalMainBaseInfo();
        if(null != manBaseInfoItem){
            //头像审核状态
            if(manBaseInfoItem.photoStatus == PhotoVerifyType.nophotoandfinish){
                tv_photoStatus.setText(getResources().getString(R.string.profile_photo));
            }else if(manBaseInfoItem.photoStatus == PhotoVerifyType.handleing){
                String currStatus = getResources().getString(R.string.profile_photo_status_pending);
                String photoStatusTips = getResources().getString(R.string.profile_photo_status, currStatus);
                SpannableString photoStatusSpan = new SpannableString(photoStatusTips);
                ForegroundColorSpan foregroundColorSpan = new ForegroundColorSpan(getResources().getColor(R.color.profile_photo_status_pending));
                photoStatusSpan.setSpan(foregroundColorSpan, photoStatusTips.indexOf(currStatus),
                        photoStatusTips.indexOf(currStatus)+currStatus.length(),
                        Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                tv_photoStatus.setText(photoStatusSpan);

            }else if(manBaseInfoItem.photoStatus == PhotoVerifyType.nopass){
                String currStatus = getResources().getString(R.string.profile_photo_status_rejected);
                String photoStatusTips = getResources().getString(R.string.profile_photo_status, currStatus);
                SpannableString photoStatusSpan = new SpannableString(photoStatusTips);
                ForegroundColorSpan foregroundColorSpan = new ForegroundColorSpan(getResources().getColor(R.color.profile_photo_status_rejecte));
                photoStatusSpan.setSpan(foregroundColorSpan, photoStatusTips.indexOf(currStatus),
                        photoStatusTips.indexOf(currStatus)+currStatus.length(),
                        Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                tv_photoStatus.setText(photoStatusSpan);
            }
            //加载头像
            if(!TextUtils.isEmpty(manBaseInfoItem.photoUrl)){
                Picasso.with(getApplicationContext())
                        .load(manBaseInfoItem.photoUrl)
                        .memoryPolicy(MemoryPolicy.NO_CACHE)
                        .error(R.drawable.ic_default_photo_man)
                        .noPlaceholder()
                        .into(civ_currPhoto);
//                        .into(new Target() {
//                            @Override
//                            public void onBitmapLoaded(Bitmap bitmap, Picasso.LoadedFrom loadedFrom) {
//                                civ_currPhoto.setImageBitmap(bitmap);
//                            }
//
//                            @Override
//                            public void onBitmapFailed(Drawable drawable) {
//                                if(null != drawable){
//                                    civ_currPhoto.setImageDrawable(drawable);
//                                }
//                            }
//
//                            @Override
//                            public void onPrepareLoad(Drawable drawable) {
//
//                            }
//                        });
            }
            //ID
            tv_userId.setText(manBaseInfoItem.userId);
            //nickname
            if(manBaseInfoItem.nickNameStatus == NickNameVerifyType.handleing){
                String currStatus = getResources().getString(R.string.profile_nickname_status_pending);
                String nickNameStatusTips = getResources().getString(R.string.profile_nickname_status, currStatus);
                SpannableString nickNameStatusSpan = new SpannableString(nickNameStatusTips);
                ForegroundColorSpan foregroundColorSpan = new ForegroundColorSpan(getResources().getColor(R.color.profile_nickname_status_pending));
                nickNameStatusSpan.setSpan(foregroundColorSpan, nickNameStatusTips.indexOf(currStatus),
                        nickNameStatusTips.indexOf(currStatus)+currStatus.length(),
                        Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                tv_nickNameStatus.setText(nickNameStatusSpan);
            }else{
                tv_nickNameStatus.setText(getResources().getString(R.string.profile_nickname));
            }
            tv_nickName.setText(manBaseInfoItem.nickName);
            tv_gender.setText(getResources().getString(
                    manBaseInfoItem.gender== GenderType.Man ? R.string.live_edit_profile_male :
                        R.string.live_edit_profile_female));
            //birthday
            tv_birthday.setText(manBaseInfoItem.birthday);
        }
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int id = v.getId();
        if(id == R.id.btnRetry){
            //重新加载
            showLoadingDialog();
            MainBaseInfoManager.getInstance().getMainBaseInfoFromServ(this);
        }if(id == R.id.ll_nickname){
            //修改昵称
            startActivityForResult(
                    new Intent(this,EditNickNameActivity.class),REQCODE_EDIT_NICKNAME);
        }else if(id == R.id.ll_userPhoto){
            if(null != manBaseInfoItem){
                if(manBaseInfoItem.photoStatus == PhotoVerifyType.handleing){
                    showToast(R.string.profile_photo_status_pending_tips);
                }else{
                    //避免图库显示与裁剪时显示的图像不一致
                    String tempImgPath = FileCacheManager.getInstance().getTempImageUrl();
                    ImageUtil.realDeleteFile(this,tempImgPath);
                    String tempCameraImgPath = FileCacheManager.getInstance().GetTempCameraImageUrl();
                    ImageUtil.realDeleteFile(this,tempCameraImgPath);
                    showPhotoMenu();
                }
            }

            //GA统计，点击上传头像
            onAnalyticsEvent(getResources().getString(R.string.Live_PersonalCenter_Category),
                    getResources().getString(R.string.Live_PersonalCenter_Action_Upload_Photo),
                    getResources().getString(R.string.Live_PersonalCenter_Label_Upload_Photo));
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
            startActivityForResult(CompatUtil.getSelectPhotoFromAlumIntent(), REQCODE_LOAD_IMAGE_ALBUMN);
        }catch(Exception e){
            Intent intent = new Intent();
            intent.setType("image/*");
            intent.setAction(Intent.ACTION_GET_CONTENT);
            startActivityForResult(intent, REQCODE_LOAD_IMAGE_ALBUMN);
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
            intent.putExtra(MediaStore.EXTRA_OUTPUT, FileProvider.getUriForFile(mContext,
                            getPackageName()+ ".provider", tempFile));
            // 给目标应用一个临时授权
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        }else{
            intent.putExtra(MediaStore.EXTRA_OUTPUT, Uri.fromFile(tempFile));
        }
        startActivityForResult(intent, REQCODE_LOAD_IMAGE_CAPTURE);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        switch(requestCode) {
            case REQCODE_EDIT_NICKNAME://编辑昵称界面返回
                if(null != data ){
                    boolean hasNicknameChanged =  data.getBooleanExtra(
                            "hasNicknameChanged",false);
                    Log.d(TAG,"onActivityResult hasNicknameChanged:"+hasNicknameChanged);
                    if(hasNicknameChanged){
                        showLoadingDialog();
                        MainBaseInfoManager.getInstance().getMainBaseInfoFromServ(this);
                    }
                }

                break;
            case REQCODE_LOAD_IMAGE_CAPTURE:{//拍照界面返回
                if( resultCode == RESULT_OK ) {
                    File tempCameraImgFile = new File(FileCacheManager.getInstance().GetTempCameraImageUrl());
                    File tempImgFile = new File(FileCacheManager.getInstance().getTempImageUrl());
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                        //照片 截取输出的outputUri， 只能使用 Uri.fromFile，不能用FileProvider.getUriForFile
                        //不然会报：Permission Denial: writing android.support.v4.content.FileProvider
                        doStartPhotoZoom(FileProvider.getUriForFile(mContext,getPackageName()+ ".provider", tempCameraImgFile),
                                Uri.fromFile(tempImgFile));
                    }else{
                        doStartPhotoZoom(Uri.fromFile(tempCameraImgFile), Uri.fromFile(tempImgFile));
                    }
                }
            }break;
            case REQCODE_LOAD_IMAGE_ALBUMN:{//相册选择界面返回
                if( resultCode == RESULT_OK && null != data ) {
                    Uri selectedImage = data.getData();
                    String picturePath = CompatUtil.getSelectedPhotoPath(this, selectedImage);
                    if(!TextUtils.isEmpty(picturePath)){
                        File pic = new File(picturePath);
                        File picCut = new File(FileCacheManager.getInstance().getTempImageUrl());

                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            //照片 截取输出的outputUri， 只能使用 Uri.fromFile，不能用FileProvider.getUriForFile
                            //不然会报：Permission Denial: writing android.support.v4.content.FileProvider
                            doStartPhotoZoom(FileProvider.getUriForFile(mContext,getPackageName()+ ".provider", pic), Uri.fromFile(picCut)
                            );
                        }else{
                            doStartPhotoZoom(Uri.fromFile(pic), Uri.fromFile(picCut));
                        }
                    }
                }
            }break;
            case REQCODE_LOAD_IMAGE_CUT:{//图片裁剪界面返回
                if( resultCode == RESULT_OK) {
                    //裁剪后图片 显示到头像处(上传成功拿到最新头像再显示)
                    updateUserPhoto();
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
        startActivityForResult(intent, REQCODE_LOAD_IMAGE_CUT);
    }

    /**
     * 更新头像
     */
    private void updateUserPhoto(){
        Log.d(TAG,"updateUserPhoto");
        // 上传头像
        showLoadingDialog();
        MainBaseInfoManager.getInstance().updateUserPhoto(FileCacheManager.getInstance().getTempImageUrl(), this);
    }

    @Override
    public void onUpdateUserPhoto(final boolean isSuccess, int errCode, final String errMsg) {
        Log.d(TAG,"onUpdateUserPhoto-isSuccess:"+isSuccess+" errCode:"+errCode +" errMsg:"+errMsg);
        runOnUiThread(new Thread(){
            @Override
            public void run() {
                if(isSuccess){
                    //这里需要删除之前旧图片的磁盘缓存，避免url不变的情况下，图片还是使用旧有的
                    MainBaseInfoManager.getInstance().getMainBaseInfoFromServ(UserProfileActivity.this);
                }else{
                    hideLoadingDialog();
                    showToast(errMsg);
                }
            }
        });

    }

    @Override
    public void onGetMainBaseInfo(final boolean isSuccess, int errCode, final String errMsg) {
        Log.d(TAG,"onGetMainBaseInfo-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg);
        runOnUiThread(new Thread(){
            @Override
            public void run() {
                hideLoadingDialog();
                if(isSuccess){
                    refreshData();
                    view_errLoad.setVisibility(View.GONE);
                }else{
                    showToast(errMsg);
                    if(null == MainBaseInfoManager.getInstance().getLocalMainBaseInfo()){
                        //加载前数据就不存在那么显示reload界面
                        view_errLoad.setVisibility(View.VISIBLE);
                        tvErrorMsg.setText(getResources().getString(R.string.tip_failed_to_load));
                    }
                }
            }
        });
    }
}
