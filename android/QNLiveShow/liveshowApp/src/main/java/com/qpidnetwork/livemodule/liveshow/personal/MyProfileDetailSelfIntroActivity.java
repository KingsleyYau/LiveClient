package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.EditText;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.LiveDomainRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetMyProfileCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.OnUpdateMyProfileCallback;
import com.qpidnetwork.livemodule.httprequest.item.LSProfileItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.NetworkUtil;
import com.qpidnetwork.livemodule.view.MaterialAppBar;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;


/**
 * MyProfile模块
 *
 * @author Max.Chiu
 */
public class MyProfileDetailSelfIntroActivity extends BaseFragmentActivity implements OnClickListener {

    public static final String SELF_INTRO = "self_intro";

    private static final int TEXT_LENGHT_MIN = 100;
    private static final int TEXT_LENGHT_MAX = 2000;

    /**
     * 个人简介
     */
    private EditText editTextSelfIntro;

    // Hardy
//    private ProfileItem mProfileItem;
    private LSProfileItem mProfileItem;
    private MaterialDialogAlert mUploadDialogDialog;

    private enum RequestFlag {
        REQUEST_UPDATE_PROFILE_SUCCESS,
        REQUEST_PROFILE_SUCCESS,
        REQUEST_FAIL,

        //  2018/10/15  Hardy
        REQUEST_START_EDIT_RESUME_SUCCESS,
        REQUEST_START_EDIT_RESUME_FAIL,
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mContext = this;

        InitView();
    }

    /**
     * 初始化界面
     */
    private void InitView() {
//        setContentView(R.layout.activity_my_profile_detail_selfintro);
        setContentView(R.layout.activity_my_profile_detail_selfintro_live);

        MaterialAppBar appbar = (MaterialAppBar) findViewById(R.id.appbar);
        appbar.setTouchFeedback(MaterialAppBar.TOUCH_FEEDBACK_HOLO_LIGHT);
        appbar.setAppbarBackgroundColor(getResources().getColor(R.color.white));
//        appbar.addButtonToLeft(R.id.common_button_back, "", R.drawable.ic_close_grey600_24dp);
        appbar.addButtonToLeft(R.id.common_button_back, "", R.drawable.ic_arrow_back_grey600_24dp);
        appbar.addButtonToRight(R.id.common_button_ok, "", R.drawable.ic_done_grey600_24dp);
        appbar.setTitle(getString(R.string.My_selfintro), getResources().getColor(R.color.text_color_dark));
        appbar.setOnButtonClickListener(this);

        /**
         * 个人简介
         */
        editTextSelfIntro = (EditText) findViewById(R.id.editTextSelfIntro);
        String text = getIntent().getExtras().getString(SELF_INTRO);
        setData(text);

        // Hardy
        // 创建界面时候，获取缓存数据
//        mProfileItem = MyProfilePerfence.GetProfileItem(mContext);
        mProfileItem = MyProfilePerfenceLive.GetProfileItem(mContext);
        if (mProfileItem == null) {
            GetMyProfile();
        }
    }

    private void showTipToast(String val) {
        Toast.makeText(this, val, Toast.LENGTH_SHORT).show();
    }

    private void setData(String val) {
        if (!TextUtils.isEmpty(val)) {
            editTextSelfIntro.setText(val);
            editTextSelfIntro.setSelection(val.length());
        }
    }

    private void showUploadDialog() {
        if (mUploadDialogDialog == null) {
            mUploadDialogDialog = new MaterialDialogAlert(this);
            mUploadDialogDialog.setMessage("After you save your description, edit will be disable until it's approved.");
            mUploadDialogDialog.addButton(mUploadDialogDialog.createButton(
                    getString(R.string.common_btn_cancel), null));
            mUploadDialogDialog.addButton(mUploadDialogDialog.createButton(
                    getString(R.string.common_btn_ok), new OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            // 2018/10/15
                            StartEditResume();
                        }
                    }));
        }
        if (isActivityVisible()) {
            mUploadDialogDialog.show();
        }
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.common_button_back) {
            setResult(RESULT_CANCELED, null);
            finish();
        } else if (id == R.id.common_button_ok) {
            // 2018/9/25 Hardy
            String val = editTextSelfIntro.getText().toString().trim();
            if (TextUtils.isEmpty(val)) {
                val = "";
            }
            if (!NetworkUtil.isNetworkConnected(this)) {
                showTipToast(getResources().getString(R.string.common_connect_error_description));
                return;
            }
            int len = val.length();
            if (len < TEXT_LENGHT_MIN) {
                showTipToast("Minimum 100 characters required.");
                return;
            }
            if (len > TEXT_LENGHT_MAX) {
                showTipToast("Maximum 2000 characters allowed.");
                return;
            }

            // 2018/9/25 提交数据去服务器
            mProfileItem.resume = val;

            showUploadDialog();
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        HttpRespObject obj = (HttpRespObject) msg.obj;
        switch (RequestFlag.values()[msg.what]) {
            case REQUEST_PROFILE_SUCCESS:
                hideProgressDialog();
                // 缓存数据
                mProfileItem = (LSProfileItem) obj.data;
                MyProfilePerfenceLive.SaveProfileItem(mContext, mProfileItem);

                // 刷新界面
                setData(mProfileItem.resume_status == LSProfileItem.ResumeStatus.UnVerify ?
                        mProfileItem.resume_content : mProfileItem.resume);
                break;

            case REQUEST_UPDATE_PROFILE_SUCCESS:
                showToastDone("Done");

                // 缓存数据
                mProfileItem.resume_status = LSProfileItem.ResumeStatus.UnVerify;
                mProfileItem.resume_content = editTextSelfIntro.getText().toString().trim();
                MyProfilePerfenceLive.SaveProfileItem(mContext, mProfileItem);

                editTextSelfIntro.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        handlerUnloadSuccess();
                    }
                }, 1000);
                break;

            case REQUEST_FAIL: {
                hideProgressDialog();
                showTipToast(obj.errMsg);
            }
            break;


            case REQUEST_START_EDIT_RESUME_SUCCESS:
                uploadProfile();
                break;

            case REQUEST_START_EDIT_RESUME_FAIL:
                hideProgressDialog();
                showTipToast(getResources().getString(R.string.my_profile_change_profile_failed_tip));
                break;

            default:
                break;
        }
    }

    private void StartEditResume() {
        LiveDomainRequestOperator.getInstance().StartEditResume(new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                Message msg = Message.obtain();
                if (isSuccess) {
                    msg.what = RequestFlag.REQUEST_START_EDIT_RESUME_SUCCESS.ordinal();
                } else {
                    msg.what = RequestFlag.REQUEST_START_EDIT_RESUME_FAIL.ordinal();
                }

                sendUiMessage(msg);
            }
        });
    }


    /**
     * 获取个人信息
     */
    private void GetMyProfile() {
        // 此处应有菊花
        showProgressDialog("Loading...");
//        LiveRequestOperator.getInstance().GetMyProfile(new OnGetMyProfileCallback() {
        LiveDomainRequestOperator.getInstance().GetMyProfile(new OnGetMyProfileCallback() {
            @Override
            public void onGetMyProfile(boolean isSuccess, int errno, String errmsg,
                                       LSProfileItem item) {
                Message msg = Message.obtain();
                HttpRespObject obj = new HttpRespObject(isSuccess, errno, errmsg, item);
                if (isSuccess) {
                    // 获取个人信息成功
                    msg.what = RequestFlag.REQUEST_PROFILE_SUCCESS.ordinal();
                } else {
                    // 获取个人信息失败
                    msg.what = RequestFlag.REQUEST_FAIL.ordinal();
                }
                msg.obj = obj;
                sendUiMessage(msg);
            }
        });
    }

    private void uploadProfile() {
        showToastProgressing("Loading...");
//        LiveRequestOperator.getInstance().UpdateProfile(
        LiveDomainRequestOperator.getInstance().UpdateProfile(
                mProfileItem.weight,
                mProfileItem.height,
                mProfileItem.language,
                mProfileItem.ethnicity,
                mProfileItem.religion,
                mProfileItem.education,
                mProfileItem.profession,
                mProfileItem.income,
                mProfileItem.children,
                mProfileItem.smoke,
                mProfileItem.drink,
                mProfileItem.resume,
                mProfileItem.interests.toArray(new String[mProfileItem.interests.size()]),
                mProfileItem.zodiac,
                new OnUpdateMyProfileCallback() {

                    @Override
                    public void onUpdateMyProfile(boolean isSuccess, int errno,
                                                  String errmsg, boolean rsModified) {
                        Message msg = Message.obtain();
                        HttpRespObject obj = new HttpRespObject(isSuccess, errno, errmsg, null);
                        if (isSuccess) {
                            // 上传个人信息成功
                            msg.what = RequestFlag.REQUEST_UPDATE_PROFILE_SUCCESS.ordinal();
                        } else {
                            // 上传个人信息失败
                            msg.what = RequestFlag.REQUEST_FAIL.ordinal();
                        }
                        msg.obj = obj;
                        sendUiMessage(msg);
                    }
                });

    }


    private void handlerUnloadSuccess() {
        // old
        Intent intent = new Intent();
        intent.putExtra(SELF_INTRO, editTextSelfIntro.getText().toString().trim());
        setResult(RESULT_OK, intent);
        finish();
    }

}
