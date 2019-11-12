package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveDomainRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetMyProfileCallback;
import com.qpidnetwork.livemodule.httprequest.item.LSProfileItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

/**
 * 2019/08/13 Hardy
 * 查看头像大图
 */
public class MyProfilePhotoActivity extends BaseUserIconUploadActivity {

    private static final String ICON_URL = "iconUrl";

    private ImageView mIvBack;
    private SimpleDraweeView mIvImage;
    private TextView mTvDesc;
    private Button mBtnChange;

    private String iconUrl;

    private enum RequestFlag {
        REQUEST_PROFILE_SUCCESS,
        REQUEST_FAIL,
    }

    public static void startAct(Context context, String iconUrl) {
        Intent intent = new Intent(context, MyProfilePhotoActivity.class);
        intent.putExtra(ICON_URL, iconUrl);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_my_profile_photo_live);

        parseIntentData();
        initView();
        initData();
    }

    private void parseIntentData() {
        if (getIntent() != null) {
            iconUrl = getIntent().getStringExtra(ICON_URL);
        }
    }

    private void initView() {
        mIvBack = (ImageView) findViewById(R.id.act_my_profile_photo_live_iv_back);
        mIvImage = (SimpleDraweeView) findViewById(R.id.act_my_profile_photo_live_iv_image);
        mTvDesc = (TextView) findViewById(R.id.act_my_profile_photo_live_tv_desc);
        mBtnChange = (Button) findViewById(R.id.act_my_profile_photo_live_btn_change);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) mIvBack.getLayoutParams();
            params.topMargin += DisplayUtil.getStatusBarHeight(mContext);
            mIvBack.setLayoutParams(params);
        }

        mIvBack.setOnClickListener(this);
        mBtnChange.setOnClickListener(this);
    }

    private void initData() {
        setIconUrl(iconUrl);

        getMyProfile();
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);

        int id = v.getId();

        if (id == R.id.act_my_profile_photo_live_iv_back) {
            finish();
        } else if (id == R.id.act_my_profile_photo_live_btn_change) {
            showIconUploadDialog();
        }
    }

    @Override
    protected void onUploadIconSuccess() {
        finish();
    }

    @Override
    protected void onLoadUserInfo() {

    }

    /**
     * 不监听上传头像成功后的再次获取用户资料。
     * 需求：
     * 上传成功后均返回个人中心或个人资料页（视具体来源而定）
     *
     * @return
     */
    @Override
    protected boolean isRegisterGetUserInfoBroadcast() {
        return false;
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        HttpRespObject obj = (HttpRespObject) msg.obj;

        if (msg.what >= RequestFlag.values().length) {
            return;
        }

        switch (RequestFlag.values()[msg.what]) {
            case REQUEST_PROFILE_SUCCESS:
                LSProfileItem mProfileItem = (LSProfileItem) obj.data;
                setLsProfileItem(mProfileItem);

                setData(mProfileItem);
                break;

            case REQUEST_FAIL:
                hideProgressDialog();
                ToastUtil.showToast(mContext, obj.errMsg);
                break;

            default:
                break;
        }
    }

    /**
     * 获取个人信息
     */
    private void getMyProfile() {
        showProgressDialog("Loading...");

        LiveDomainRequestOperator.getInstance().GetMyProfile(new OnGetMyProfileCallback() {
            @Override
            public void onGetMyProfile(boolean isSuccess, int errno, String errmsg, LSProfileItem item) {
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

    private void setData(LSProfileItem mProfileItem) {
        if (mProfileItem != null) {
            setIconUrl(mProfileItem.photoURL);

            // TODO: 2019/8/13 test
//            mTvDesc.setVisibility(View.GONE);
//            mBtnChange.setVisibility(View.VISIBLE);

            if (mProfileItem.showUpload()) {
                mTvDesc.setVisibility(View.GONE);
                mBtnChange.setVisibility(View.VISIBLE);
            } else {
                // 审核中
                mBtnChange.setVisibility(View.GONE);
                mTvDesc.setVisibility(View.VISIBLE);
            }
        }
    }

    private void setIconUrl(String url) {
        if (!TextUtils.isEmpty(url)) {
            //占位图，拉伸方式
            GenericDraweeHierarchyBuilder builder = new GenericDraweeHierarchyBuilder(mContext.getResources());
            GenericDraweeHierarchy hierarchy = builder
                    .setActualImageScaleType(ScalingUtils.ScaleType.FIT_CENTER)
                    .build();
            mIvImage.setHierarchy(hierarchy);
            FrescoLoadUtil.loadUrl(mIvImage, url, DisplayUtil.getScreenWidth(mContext));
        }
    }
}
