package com.qpidnetwork.livemodule.liveshow.personal;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.Switch;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetPushConfigCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * Created by Hardy on 2018/9/19.
 * <p>
 * Push Notifications
 * <p>
 * 直播——推送开关设置
 */
public class PushSettingsActivity extends BaseActionBarFragmentActivity implements CompoundButton.OnCheckedChangeListener {

    private static final int CODE_GET_DATA = 1;
    private static final int CODE_UPDATE_DATA = 2;
    private static final int CODE_FAILED = 3;

    /**
     * 开关状态保持类
     */
    private class PushCheckStatus {
        private boolean isPrivateCheck;
        private boolean isMailAppPush;
        private boolean isSayHiAppPush;

        public PushCheckStatus(boolean isPrivateCheck, boolean isMailAppPush, boolean isSayHiAppPush) {
            this.isPrivateCheck = isPrivateCheck;
            this.isMailAppPush = isMailAppPush;
            this.isSayHiAppPush = isSayHiAppPush;
        }

        public boolean isPrivateCheck() {
            return isPrivateCheck;
        }

        public boolean isMailAppPush() {
            return isMailAppPush;
        }

        public boolean isSayHiAppPush() {
            return isSayHiAppPush;
        }
    }

    private Switch mTvSayHi;
    private Switch mTvMails;

    private View mLLSwitch;

    private boolean isCheckByUser;

    public static void startAct(Context context) {
        Intent intent = new Intent(context, PushSettingsActivity.class);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_push_settings);

        initView();
    }

    @Override
    protected void onResume() {
        super.onResume();

        initData();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    private void initView() {
        setOnlyTitle("Push Notifications");

        mTvSayHi = (Switch) findViewById(R.id.act_push_setting_sw_sayHi);
        mTvMails = (Switch) findViewById(R.id.act_push_setting_sw_mails);
        mTvSayHi.setOnCheckedChangeListener(this);
        mTvMails.setOnCheckedChangeListener(this);

        mLLSwitch = findViewById(R.id.act_push_setting_ll);
        mLLSwitch.setVisibility(View.GONE);
    }

    private void initData() {
        //  2018/9/28   直接获取服务器、修改提交服务器
        getPushData();
    }


    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        HttpRespObject object = (HttpRespObject) msg.obj;

        switch (msg.what) {
            case CODE_GET_DATA:
                hideProgressDialog();


                PushCheckStatus pushCheckStatus = (PushCheckStatus) object.data;
                if (pushCheckStatus != null) {
                    refreshPushDataView(pushCheckStatus.isSayHiAppPush(), pushCheckStatus.isMailAppPush());

                    mLLSwitch.setVisibility(View.VISIBLE);
                }
                break;

            case CODE_UPDATE_DATA:
                showToastDone("Done");
                break;

            case CODE_FAILED:
                hideProgressDialog();
                cancelToastImmediately();
                showToast(R.string.common_connect_error_description);
                break;
        }

        // 设置数据后，再改变该标记位
        isCheckByUser = true;
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        Log.logD("info", "============ onCheckedChanged =====================");

//       setChecked() 方法，如果首次状态与获取服务器返回状态不一致，会回调这里，故在这里拦截一下，防止提交同样数据给服务器
        if (isCheckByUser) {
            Log.logD("info", "============ onCheckedChanged ===================== isCheckByUser");

            int id = buttonView.getId();

            if (id == R.id.act_push_setting_sw_private) {
                uploadPushData(isChecked, mTvMails.isChecked(), mTvSayHi.isChecked());

                //GA统计点击私密信push设置
                String actionString = isChecked ? getResources().getString(R.string.Live_Message_Action_Setting_PushOn) : getResources().getString(R.string.Live_Message_Action_Setting_PushOff);
                String labelString = isChecked ? getResources().getString(R.string.Live_Message_Label_Setting_PushOn) : getResources().getString(R.string.Live_Message_Label_Setting_PushOff);
                onAnalyticsEvent(getResources().getString(R.string.Live_Message_Category),
                        actionString,
                        labelString);

            } else if (id == R.id.act_push_setting_sw_mails) {
//                uploadPushData(mTvPrivate.isChecked(), isChecked);
                uploadPushData(true, isChecked, mTvSayHi.isChecked());

                //GA统计点击mail push设置
                String actionString = isChecked ? getResources().getString(R.string.Live_Mail_Action_Setting_PushOn) : getResources().getString(R.string.Live_Mail_Action_Setting_PushOff);
                String labelString = isChecked ? getResources().getString(R.string.Live_Mail_Label_Setting_PushOn) : getResources().getString(R.string.Live_Mail_Label_Setting_PushOff);
                onAnalyticsEvent(getResources().getString(R.string.Live_Mail_Category),
                        actionString,
                        labelString);
            } else if (id == R.id.act_push_setting_sw_sayHi) {
                uploadPushData(true, mTvMails.isChecked(), isChecked);

                // TODO: 2019/5/28
                //GA统计点击SayHi push设置


            }
        }
    }


    /**
     * 刷新 view
     */
    private void refreshPushDataView(boolean isSayHiCheck, boolean isMailCheck) {
        mTvSayHi.setChecked(isSayHiCheck);
        mTvMails.setChecked(isMailCheck);
    }


    private void uploadPushData(boolean isPrivateCheck, boolean isMailCheck, boolean isSayHiAppPush) {
        showToastProgressing("Setting...");

        LiveRequestOperator.getInstance().SetPushConfig(isPrivateCheck, isMailCheck, isSayHiAppPush, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                Message msg = Message.obtain();
                HttpRespObject obj = new HttpRespObject(isSuccess, errCode, errMsg, null);
                if (isSuccess) {
                    msg.what = CODE_UPDATE_DATA;
                } else {
                    // 失败
                    msg.what = CODE_FAILED;
                }
                msg.obj = obj;
                sendUiMessage(msg);
            }
        });
    }

    private void getPushData() {
        showProgressDialog("Loading...");

        isCheckByUser = false;

        LiveRequestOperator.getInstance().GetPushConfig(new OnGetPushConfigCallback() {
            @Override
            public void onGetPushConfig(boolean isSuccess, int errCode, String errMsg, boolean isPriMsgAppPush, boolean isMailAppPush, boolean isSayHiAppPush) {
                Message msg = Message.obtain();
                HttpRespObject obj = new HttpRespObject(isSuccess, errCode, errMsg, null);
                if (isSuccess) {
                    msg.what = CODE_GET_DATA;

                    PushCheckStatus pushCheckStatus = new PushCheckStatus(isPriMsgAppPush, isMailAppPush, isSayHiAppPush);
                    obj.data = pushCheckStatus;
                } else {
                    // 失败
                    msg.what = CODE_FAILED;
                }
                msg.obj = obj;
                sendUiMessage(msg);
            }
        });
    }

}
