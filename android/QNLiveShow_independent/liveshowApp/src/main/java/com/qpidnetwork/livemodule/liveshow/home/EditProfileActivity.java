package com.qpidnetwork.livemodule.liveshow.home;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.support.v4.content.FileProvider;
import android.text.TextUtils;
import android.text.format.Time;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RadioButton;

import com.dou361.dialogui.DialogUIUtils;
import com.dou361.dialogui.adapter.TieAdapter;
import com.dou361.dialogui.bean.BuildBean;
import com.dou361.dialogui.bean.TieBean;
import com.dou361.dialogui.listener.DialogUIDateTimeSaveListener;
import com.dou361.dialogui.listener.DialogUIItemListener;
import com.dou361.dialogui.widget.DateSelectorWheelView;
import com.facebook.common.util.UriUtil;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.MaterialTextField;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.utils.CompatUtil;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * 填写资料
 * Created by Jagger on 2017/12/20.
 */
public class EditProfileActivity extends BaseFragmentActivity {

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

    //控件
    private MaterialTextField mEtvNickName, mEtvBirthday, mEtvInviteCode;
    private RadioButton mRbMale , mRbFemale;
    private ImageView  mImgTakePhoto;
    private SimpleDraweeView mSimpleDraweeView;

    //变量
    private int MAXLENGHT_NICKNAME = 16;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit_profile);

        initUI();
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
                    DraweeController controller = Fresco.newDraweeControllerBuilder()
                            .setUri(uri)
                            .setAutoPlayAnimations(true)
                            .build();
                    mSimpleDraweeView.setController(controller);
                    //隐藏拍照按钮
                    mImgTakePhoto.setVisibility(View.GONE);

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
     * 显示
     * @param context
     */
    public static void show(Context context){
        context.startActivity(EditProfileActivity.getIntent(context));
    }

    private static Intent getIntent(Context context){
        Intent intent = new Intent(context, EditProfileActivity.class);
        return intent;
    }

    private void initUI(){
        mEtvNickName = (MaterialTextField)findViewById(R.id.et_nickname);
        mEtvNickName.setHint(getString(R.string.live_edit_profile_nickname_tips1));
        mEtvNickName.setGravity(Gravity.CENTER);
        mEtvNickName.setMaxLenght(MAXLENGHT_NICKNAME);

        mEtvBirthday = (MaterialTextField)findViewById(R.id.et_birthday);
        mEtvBirthday.setHint(getString(R.string.live_edit_profile_birthday_tips1));
        mEtvBirthday.setGravity(Gravity.CENTER);
        mEtvBirthday.setEditEnable(false);
        mEtvBirthday.setImageRight(
                R.drawable.ic_down,
                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_14dp),
//                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_12dp),
                ViewGroup.LayoutParams.MATCH_PARENT,
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        onClickedBirthday();
                    }
                });

        mEtvInviteCode = (MaterialTextField)findViewById(R.id.et_invite_code);
        mEtvInviteCode.setHint(getString(R.string.live_edit_profile_invite_tips1));
        mEtvInviteCode.setGravity(Gravity.CENTER);
        mEtvInviteCode.setImageRight(
                R.drawable.ic_help,
                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_14dp),
//                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_12dp),
                ViewGroup.LayoutParams.MATCH_PARENT,
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        onClickedHelp();
                    }
                });

        mSimpleDraweeView = (SimpleDraweeView)findViewById(R.id.main_photo);

        mImgTakePhoto = (ImageView) findViewById(R.id.img_take_photo);
        mImgTakePhoto.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickedTakePhoto();
            }
        });


        mRbMale = (RadioButton)findViewById(R.id.rb_male);
        mRbMale.setChecked(true);

        mRbFemale = (RadioButton)findViewById(R.id.rb_female);
    }

    /**
     * TakePhoto
     */
    private void onClickedTakePhoto(){
        showPhotoMenu();
    }

    /**
     * 选择生日
     */
    private void onClickedBirthday(){
        //18年前年份
        Time t = new Time();
        t.setToNow(); // 取得系统时间。
        t.year = t.year - 18;   //回到18年前

        Date d = new Date();
        d.setTime(t.toMillis(true));    //转为毫秒,为了设置为18年前的今天

        //显示弹窗
        DialogUIUtils.showJDatePick(this,
                Gravity.BOTTOM,
                "",
                d.getTime(),    //选中18年前的今天
                t.year,         //18年前 年份
                1960,   //最小年份 , 不能再小了
                DateSelectorWheelView.TYPE_YYYYMMDD,
                0,
                new DialogUIDateTimeSaveListener() {
            @Override
            public void onSaveSelectedDate(int tag, String selectedDate) {
                mEtvBirthday.setText(selectedDate);
            }
        }).show();
    }

    /**
     * help
     */
    private void onClickedHelp(){

    }

    /**
     * ChoosePhoto
     */
    private void onClickedMenuChoosePhoto(){
        try{
            Intent intent = CompatUtil.getSelectPhotoFromAlumIntent();
            startActivityForResult(intent, RESULT_LOAD_IMAGE_ALBUMN);
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
        //7。0＋拍照图片存取兼容 使用：FileProvider.getUriForFile
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            intent.putExtra(
                    MediaStore.EXTRA_OUTPUT,
                    FileProvider.getUriForFile(mContext,getPackageName()+ ".provider", tempFile)
            );
            // 给目标应用一个临时授权
            intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION
                    | Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
        }else{
            intent.putExtra(
                    MediaStore.EXTRA_OUTPUT,
                    Uri.fromFile(tempFile)
            );
        }
        startActivityForResult(intent, RESULT_LOAD_IMAGE_CAPTURE);
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

        intent.putExtra("output", dest);// 指定裁剪后的图片存储路径
        intent.putExtra("outputX", 400);// outputX outputY裁剪保存的宽高(使各手机截取的图片质量一致)
        intent.putExtra("outputY", 500);

        intent.putExtra("noFaceDetection", true);// 取消人脸识别功能(系统的裁剪图片默认对图片进行人脸识别,当识别到有人脸时，会按aspectX和aspectY为1来处理)
        intent.putExtra("return-data", false);// 将相应的数据与URI关联起来，返回裁剪后的图片URI,true返回bitmap
        intent.putExtra("outputFormat", Bitmap.CompressFormat.JPEG.toString());
        startActivityForResult(intent, RESULT_LOAD_IMAGE_CUT);
    }
}
