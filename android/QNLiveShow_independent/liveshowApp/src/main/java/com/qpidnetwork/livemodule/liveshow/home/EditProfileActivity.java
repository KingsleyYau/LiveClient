package com.qpidnetwork.livemodule.liveshow.home;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.MediaStore;
import android.support.v4.content.FileProvider;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.format.Time;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
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
import com.facebook.imagepipeline.core.ImagePipeline;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.widget.MaterialTextField;
import com.qpidnetwork.livemodule.httprequest.OnRequestUploadPhotoCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniAuthorization;
import com.qpidnetwork.livemodule.httprequest.item.GenderType;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.authorization.interfaces.onRegisterListener;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.login.LiveLoginActivity;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.CompatUtil;
import com.qpidnetwork.livemodule.utils.DateUtil;
import com.qpidnetwork.livemodule.view.Dialogs.DialogNormal;

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
    private final static int RESULT_LOAD_IMAGE_CAPTURE = 0;
    /**
     * 相册
     */
    private final static int RESULT_LOAD_IMAGE_ALBUMN = 1;
    /**
     * 裁剪图片
     */
    private final static int RESULT_LOAD_IMAGE_CUT = 2;

    /**
     * 传入参数
     */
    private static String KEY_LOGIN_TYPE = "KEY_LOGIN_TYPE";
    private static String KEY_EMAIL = "KEY_EMAIL";
    private static String KEY_PW = "KEY_PW";
    /**
     * 请求返回结果
     */
    private final static int REQUEST_UPLOAD_PHOTO_SUCCESS = 200;
    private final static int REQUEST_UPLOAD_PHOTO_FAIL = -200;

    //控件
    private MaterialTextField mEtvNickName, mEtvBirthday, mEtvInviteCode;
    private RadioButton mRbMale , mRbFemale;
    private ImageView  mImgTakePhoto;
    private SimpleDraweeView mImgPhoto;
    private Button mBtnSummit;

    //变量
    private int MAXLENGHT_NICKNAME = 14;
    private LoginManager.LoginType mLoginType;
    private String mStrEmail , mStrPW;
    private boolean mIsSelectedPhoto = false;   //是否选择了头像

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_edit_profile);

        initIntent();
        initUI();
        initData();
        doCheckData();
    }

    /**
     * 使用这个Activity所需要的参数
     * @param context
     * @param email
     * @return
     */
    public static void show(Context context , LoginManager.LoginType loginType, String email, String password){
        Intent i  = new Intent(context , EditProfileActivity.class);
        i.putExtra(KEY_LOGIN_TYPE , loginType);
        i.putExtra(KEY_EMAIL , email);
        i.putExtra(KEY_PW , password);

        context.startActivity(i);
    }

    /**
     * 取 传入的参数
     */
    private void initIntent(){
        Bundle bundle = getIntent().getExtras();
        if( bundle != null) {
            if(bundle.containsKey(KEY_LOGIN_TYPE)){
                mLoginType = (LoginManager.LoginType) bundle.getSerializable(KEY_LOGIN_TYPE);
            }

            if(bundle.containsKey(KEY_EMAIL)){
                mStrEmail =  bundle.getString(KEY_EMAIL);
            }

            if(bundle.containsKey(KEY_PW)){
                mStrPW =  bundle.getString(KEY_PW);
            }

        }

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
                    //
                    mIsSelectedPhoto = true;

                    //裁剪后图片 显示到头像处
                    Uri uri = new Uri.Builder()
                            .scheme(UriUtil.LOCAL_FILE_SCHEME)
                            .path(FileCacheManager.getInstance().getTempImageUrl())
                            .build();

                    //清空缓存, 因为修改头像也用同一URI的图片,不清就不会替换
                    ImagePipeline imagePipeline = Fresco.getImagePipeline();
                    imagePipeline.evictFromMemoryCache(uri);

                    //重新加载
                    DraweeController controller = Fresco.newDraweeControllerBuilder()
                            .setUri(uri)
                            .build();
                    mImgPhoto.setController(controller);
                    //隐藏拍照按钮
                    mImgTakePhoto.setVisibility(View.GONE);

                }
            }break;
            default:break;
        }
    }

    private void initUI(){
        //
        TextWatcher textWatcher = new TextWatcher() {

            @Override
            public void onTextChanged(CharSequence s, int start, int before,
                                      int count) {
            }

            @Override
            public void beforeTextChanged(CharSequence s, int start, int count,
                                          int after) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                doCheckData();
            }
        };

        mEtvNickName = (MaterialTextField)findViewById(R.id.et_nickname);
        mEtvNickName.setHint(getString(R.string.live_edit_profile_nickname_tips));
        mEtvNickName.setGravity(Gravity.CENTER);
        mEtvNickName.setMaxLenght(MAXLENGHT_NICKNAME);
        mEtvNickName.setNormalStateColor(getResources().getColor(R.color.email_sign_up_devide));
        mEtvNickName.setFocusedStateColor(getResources().getColor(R.color.email_sign_up_devide));
        mEtvNickName.boldDevideOnFocus = false;
        mEtvNickName.getEditor().setTextSize(12);
        mEtvNickName.getEditor().setTextColor(getResources().getColor(R.color.custom_dialog_txt_color_simple));
        mEtvNickName.getEditor().setHintTextColor(getResources().getColor(R.color.email_sign_up_hint_txt));
        mEtvNickName.getEditor().addTextChangedListener(textWatcher);

        mEtvBirthday = (MaterialTextField)findViewById(R.id.et_birthday);
        mEtvBirthday.setHint(getString(R.string.live_edit_profile_birthday_tips1));
        mEtvBirthday.setGravity(Gravity.CENTER);
        //或者setKeyListener(null)禁止弹出输入法
        mEtvBirthday.getEditor().setFocusable(false);
        mEtvBirthday.setNormalStateColor(getResources().getColor(R.color.email_sign_up_devide));
        mEtvBirthday.setFocusedStateColor(getResources().getColor(R.color.email_sign_up_devide));
        mEtvBirthday.boldDevideOnFocus = false;
        mEtvBirthday.getEditor().setTextSize(12);
        mEtvBirthday.getEditor().setTextColor(getResources().getColor(R.color.custom_dialog_txt_color_simple));
        mEtvBirthday.getEditor().setHintTextColor(getResources().getColor(R.color.email_sign_up_hint_txt));
        mEtvBirthday.getEditor().addTextChangedListener(textWatcher);
        mEtvBirthday.setImageRight(
                R.drawable.ic_down,
                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_14dp),
//                mContext.getResources().getDimensionPixelSize(R.dimen.live_size_12dp),
                ViewGroup.LayoutParams.MATCH_PARENT,
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Log.d(TAG,"onClick-et_birthday-ic_down");
                        onClickedBirthday();
                    }
                });
        mEtvBirthday.getEditor().setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.d(TAG,"onClick-et_birthday");
                onClickedBirthday();
            }
        });
        mEtvBirthday.getEditor().setTextColor(getResources().getColor(R.color.custom_dialog_txt_color_simple));
        mEtvInviteCode = (MaterialTextField)findViewById(R.id.et_invite_code);
        mEtvInviteCode.setHint(getString(R.string.live_edit_profile_invite_tips1));
        mEtvInviteCode.setGravity(Gravity.CENTER);
        mEtvInviteCode.setNormalStateColor(getResources().getColor(R.color.email_sign_up_devide));
        mEtvInviteCode.setFocusedStateColor(getResources().getColor(R.color.email_sign_up_devide));
        mEtvInviteCode.boldDevideOnFocus = false;
        mEtvInviteCode.getEditor().setTextSize(12);
        mEtvInviteCode.getEditor().setTextColor(getResources().getColor(R.color.custom_dialog_txt_color_simple));
        mEtvInviteCode.getEditor().setHintTextColor(getResources().getColor(R.color.email_sign_up_hint_txt));
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

        mImgPhoto = (SimpleDraweeView)findViewById(R.id.main_photo);
        mImgPhoto.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickedTakePhoto();
            }
        });

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

        mBtnSummit = (Button)findViewById(R.id.btn_submit);
        mBtnSummit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickedSummit();
            }
        });

        findViewById(R.id.btnBack).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }

    private void initData(){
        GenderType genderType = LoginManager.getInstance().getAuthorizedGender(mLoginType);
        if(genderType == GenderType.Lady){
            mRbFemale.setChecked(true);
        }

        String nickName = LoginManager.getInstance().getAuthorizedNickName(mLoginType);
        if(!TextUtils.isEmpty(nickName)){
            mEtvNickName.setText(nickName);
        }
    }

    /**
     * 注册结果
     */
    @SuppressLint("HandlerLeak")
    private Handler mHandlerRegister = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            hideLoadingDialog();
            if(msg.obj != null ){
                HttpRespObject response = (HttpRespObject)msg.obj;

                if(response.isSuccess){
                    // 上传头像
                    doUploadPhoto();

                    //如果成功,返回登录界面自动
                    LiveLoginActivity.show(mContext , LiveLoginActivity.OPEN_TYPE_AUTO_LOGIN, "");

                    //GA统计，注册成功统计
                    String label = "";
                    if(mLoginType != null && mLoginType == LoginManager.LoginType.FACEBOOK){
                        label = getResources().getString(R.string.Live_Registe_Label_Success_Facebook);
                    }else{
                        label = getResources().getString(R.string.Live_Registe_Label_Success_Email);
                    }
                    onAnalyticsEvent(getResources().getString(R.string.Live_Registe_Category),
                            getResources().getString(R.string.Live_Registe_Action_Success),
                            label);
                }else{
                    //如果错误
                    //错误提示
                    showToast(response.errMsg);
                }
            }
        }
    };

    /**
     * 提交头像结果
     */
    @SuppressLint("HandlerLeak")
    private Handler mHandlerUploadPhoto = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            super.handleMessage(msg);
            if(msg.obj != null ){
                HttpRespObject response = (HttpRespObject)msg.obj;
                if(response.isSuccess){
                    //如果成功
                }else{
                    //如果错误
                }
            }
        }
    };

    /**
     * 检查数据是否完整
     */
    private void doCheckData(){
        if(mEtvNickName.getText().length() < 2 || mEtvBirthday.getText().length() < 1 ){
            mBtnSummit.setEnabled(false);
            mBtnSummit.setTextColor(getResources().getColor(R.color.submit_unusable));
        }else{
            mBtnSummit.setTextColor(Color.WHITE);
            mBtnSummit.setEnabled(true);
        }
    }

    /**
     * TakePhoto
     */
    private void onClickedTakePhoto(){
        showPhotoMenu();
        //GA统计，注册点击上传头像
        onAnalyticsEvent(getResources().getString(R.string.Live_Registe_Category),
                getResources().getString(R.string.Live_Registe_Action_Upload_Photo),
                getResources().getString(R.string.Live_Registe_Label_Upload_Photo));
    }

    /**
     * 选择生日
     */
    private void onClickedBirthday(){
        Log.d(TAG,"onClickedBirthday");
        //18年前年份
        Time t = getTimeBefore18Y();
        //显示弹窗
        DialogUIUtils.showJDatePick(this,
                Gravity.BOTTOM,
                "",
                t.toMillis(true), //选中18年前的今天
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
     * 取18年前的今天
     * @return
     */
    private Time getTimeBefore18Y(){
        //18年前年份
        Time t = new Time();
        t.setToNow(); // 取得系统时间。
        t.year = t.year - 18;   //回到18年前
        return t;
    }

    /**
     * help
     */
    private void onClickedHelp(){
        showHelpDialog();
    }

    /**
     * 提交
     */
    private void onClickedSummit(){
        Log.d(TAG,"onClickedSummit");
        //昵称不能少于2个字
        if(mEtvNickName.getText().length() < 2){
            showToast(getString(R.string.live_register_tips1));
            return;
        }

        //年龄不能少于18岁
        Date date = DateUtil.getDate(mEtvBirthday.getText().toString() , "yyyy-MM-dd");
        Time t = getTimeBefore18Y();
        Date date18 = new Date();
        date18.setTime(t.toMillis(true));
        if(date.after(date18)){
            show18YDialog();
            return;
        }

        showLoadingDialog();
        doRegister();
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
     * 邀请码说明 对话框
     */
    private void showHelpDialog(){
        DialogNormal.Builder builder = new DialogNormal.Builder()
                .setContext(mContext)
                .setContent(getString(R.string.live_edit_profile_invite_code_help))
                .textGravity(Gravity.LEFT)
                .btnRight(new DialogNormal.Button(
                        getString(R.string.common_btn_ok),
                        false,
                        null
                ));

        DialogNormal.setBuilder(builder).show();
    }

    /**
     * 提示 没够18岁
     */
    private void show18YDialog(){
        DialogNormal.Builder builder = new DialogNormal.Builder()
                .setContext(mContext)
                .setContent(getString(R.string.live_edit_profile_not_18y))
                .textGravity(Gravity.CENTER)
                .btnRight(new DialogNormal.Button(
                        getString(R.string.common_btn_ok),
                        false,
                        null
                ));

        DialogNormal.setBuilder(builder).show();
    }

    /**
     * 裁剪图片方法实现
     *
     */
    private void doStartPhotoZoom(Uri src, Uri dest) {
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

    /**
     * 上传头像
     */
    private void doUploadPhoto(){
        if(mIsSelectedPhoto){
            RequestJniAuthorization.LSUploadPhoto(
                    FileCacheManager.getInstance().getTempImageUrl(),
                    new OnRequestUploadPhotoCallback() {
                        @Override
                        public void onUploadPhoto(boolean isSuccess, int errCode, String errMsg, String photoUrl) {
                            //不需要管结果,因为Activity已关闭了
//                        HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, photoUrl);
//
//                        Message msg = new Message();
//                        msg.obj = response;
//                        mHandlerUploadPhoto.sendMessage(msg);
                        }
                    }
            );
        }
    }

    /**
     * 提交资料注册
     */
    private void doRegister(){
        LoginManager.getInstance().register(mLoginType,
                mStrEmail, mStrPW,
                mRbMale.isChecked()? GenderType.Man :GenderType.Lady,
                mEtvNickName.getText().toString(), mEtvBirthday.getText().toString(), mEtvInviteCode.getText().toString(),
                new onRegisterListener() {
                    @Override
                    public void onResult(boolean isSuccess, int errCode, String errMsg, String sessionId) {
                        Log.i("Jagger" , "EditProfileActivity doRegister isSuccess:" + isSuccess + ",errCode:" + errCode);
                        HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, sessionId);
                        Message msg = new Message();
                        msg.obj = response;
                        mHandlerRegister.sendMessage(msg);
                    }
                });
    }
}
