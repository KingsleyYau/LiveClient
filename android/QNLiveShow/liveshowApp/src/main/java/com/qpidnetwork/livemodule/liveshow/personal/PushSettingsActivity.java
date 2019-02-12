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
//public class PushSettingsActivity extends BaseActionBarFragmentActivity implements PushSettingManager.IOnPushDataGetListener {
public class PushSettingsActivity extends BaseActionBarFragmentActivity implements CompoundButton.OnCheckedChangeListener {

    private static final int CODE_GET_DATA = 1;
    private static final int CODE_UPDATE_DATA = 2;
    private static final int CODE_FAILED = 3;

//    private String[] PUSH_CHOOSE_ITEMS;
//    private String TITLE_PRIVATE_MESSAGES;
//    private String TITLE_MAILS_FROM_CHARMLIVE;
//    private String TITLE_ONE_ON_ONE_INVITATION;


//    private TextView mTvPrivate;
//    private TextView mTvMails;
//    private TextView mTvInvitation;

//    private View mRlPrivate;
//    private View mRlMails;
//    private View mRlInvitation;

//    private SettingPerfenceLive.NotificationItem mNotificationItem;
//    private PushItemType mPushItemType;
//
//    /**
//     * 3 个菜单选项
//     */
//    private enum PushItemType {
//        Private_Messages,
//        Mails_from_CharmLive,
//        One_on_one_Invitation
//    }

    /**
     * 开关状态保持类
     */
    private class PushCheckStatus {
        private boolean isPrivateCheck;
        private boolean isMailAppPush;

        public PushCheckStatus(boolean isPrivateCheck, boolean isMailAppPush) {
            this.isPrivateCheck = isPrivateCheck;
            this.isMailAppPush = isMailAppPush;
        }

        public boolean isPrivateCheck() {
            return isPrivateCheck;
        }

        public boolean isMailAppPush() {
            return isMailAppPush;
        }
    }

    private enum PushItemType {
        PUSH_PRIVATE,
        PUSH_MAILS
    }

//    private Switch mTvPrivate;
    private Switch mTvMails;

    private View mLLSwitch;

    private boolean isCheckByUser;
    private PushItemType mItemType;

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

//        PushSettingManager.getInstance().removeListener(this);
    }

    private void initView() {
        setOnlyTitle("Push Notifications");

//        PushSettingManager.getInstance().addListener(this);

//        mTvPrivate = (Switch) findViewById(R.id.act_push_setting_sw_private);
        mTvMails = (Switch) findViewById(R.id.act_push_setting_sw_mails);
//        mTvPrivate.setOnCheckedChangeListener(this);
        mTvMails.setOnCheckedChangeListener(this);

        mLLSwitch = findViewById(R.id.act_push_setting_ll);
        mLLSwitch.setVisibility(View.GONE);

//        mTvInvitation = (TextView) findViewById(R.id.act_push_setting_tv_invitation_desc);

//        mRlPrivate = findViewById(R.id.act_push_setting_rl_private_title);
//        mRlMails = findViewById(R.id.act_push_setting_rl_mails_title);
//        mRlInvitation = findViewById(R.id.act_push_setting_rl_invitation_title);
//        mRlPrivate.setOnClickListener(this);
//        mRlMails.setOnClickListener(this);
//        mRlInvitation.setOnClickListener(this);
    }

    private void initData() {
        //  2018/9/28   直接获取服务器、修改提交服务器
        getPushData();

        // old
//        PUSH_CHOOSE_ITEMS = getResources().getStringArray(R.array.notification);
//        TITLE_PRIVATE_MESSAGES = getResources().getString(R.string.Private_Messages);
//        TITLE_MAILS_FROM_CHARMLIVE = getResources().getString(R.string.Mails_from_CharmLive);
//        TITLE_ONE_ON_ONE_INVITATION = getResources().getString(R.string.One_on_One_Invitation);

//        mNotificationItem = PushSettingManager.getInstance().getNotificationItem();
//        if (mNotificationItem != null) {
//            refreshPushDataView();
//        } else {
//            PushSettingManager.getInstance().syncPushData(true);
//        }
    }

//    @Override
//    public void onClick(View v) {
//        super.onClick(v);
//
////        int id = v.getId();
////        if (id == R.id.act_push_setting_rl_private_title) {
////            mPushItemType = PushItemType.Private_Messages;
////            showChooseDialog(TITLE_PRIVATE_MESSAGES);
////
////        } else if (id == R.id.act_push_setting_rl_mails_title) {
////            mPushItemType = PushItemType.Mails_from_CharmLive;
////            showChooseDialog(TITLE_MAILS_FROM_CHARMLIVE);
////
////        } else if (id == R.id.act_push_setting_rl_invitation_title) {
////            mPushItemType = PushItemType.One_on_one_Invitation;
////            showChooseDialog(TITLE_ONE_ON_ONE_INVITATION);
////        }
//    }


    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        HttpRespObject object = (HttpRespObject) msg.obj;

        switch (msg.what) {
            case CODE_GET_DATA:
                hideProgressDialog();


                PushCheckStatus pushCheckStatus = (PushCheckStatus) object.data;
                if (pushCheckStatus != null) {
                    refreshPushDataView(pushCheckStatus.isPrivateCheck(), pushCheckStatus.isMailAppPush());

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

//                if (isCheckByUser && mItemType != null) {
//                    if (mItemType == PushItemType.PUSH_PRIVATE) {
//                        mTvPrivate.setChecked(!mTvPrivate.isChecked());
//                    } else {
//                        mTvMails.setChecked(!mTvMails.isChecked());
//                    }
//                }
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
                mItemType = PushItemType.PUSH_PRIVATE;
                uploadPushData(isChecked, mTvMails.isChecked());
                //GA统计点击私密信push设置
                String actionString = isChecked ? getResources().getString(R.string.Live_Message_Action_Setting_PushOn) : getResources().getString(R.string.Live_Message_Action_Setting_PushOff);
                String labelString = isChecked ? getResources().getString(R.string.Live_Message_Label_Setting_PushOn) : getResources().getString(R.string.Live_Message_Label_Setting_PushOff);
                onAnalyticsEvent(getResources().getString(R.string.Live_Message_Category),
                        actionString,
                        labelString);

            } else if (id == R.id.act_push_setting_sw_mails) {
                mItemType = PushItemType.PUSH_MAILS;
//                uploadPushData(mTvPrivate.isChecked(), isChecked);
                uploadPushData(true, isChecked);

                //GA统计点击mail push设置
                String actionString = isChecked ? getResources().getString(R.string.Live_Mail_Action_Setting_PushOn) : getResources().getString(R.string.Live_Mail_Action_Setting_PushOff);
                String labelString = isChecked ? getResources().getString(R.string.Live_Mail_Label_Setting_PushOn) : getResources().getString(R.string.Live_Mail_Label_Setting_PushOff);
                onAnalyticsEvent(getResources().getString(R.string.Live_Mail_Category),
                        actionString,
                        labelString);
            }
        }
    }


    /**
     * 刷新 view
     */
    private void refreshPushDataView(boolean isPrivateCheck, boolean isMailCheck) {
//        mTvPrivate.setChecked(isPrivateCheck);
        mTvMails.setChecked(isMailCheck);

//        if (mNotificationItem != null) {
//            mTvPrivate.setText(PUSH_CHOOSE_ITEMS[mNotificationItem.mPrivateNotification.ordinal()]);
//            mTvMails.setText(PUSH_CHOOSE_ITEMS[mNotificationItem.mMailNotification.ordinal()]);
//            mTvInvitation.setText(PUSH_CHOOSE_ITEMS[mNotificationItem.mInvitationNotification.ordinal()]);
//        }
    }


    private void uploadPushData(boolean isPrivateCheck, boolean isMailCheck) {
        showToastProgressing("Setting...");

        LiveRequestOperator.getInstance().SetPushConfig(isPrivateCheck, isMailCheck, new OnRequestCallback() {
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
            public void onGetPushConfig(boolean isSuccess, int errCode, String errMsg, boolean isPriMsgAppPush, boolean isMailAppPush) {
                Message msg = Message.obtain();
                HttpRespObject obj = new HttpRespObject(isSuccess, errCode, errMsg, null);
                if (isSuccess) {
                    msg.what = CODE_GET_DATA;

                    PushCheckStatus pushCheckStatus = new PushCheckStatus(isPriMsgAppPush, isMailAppPush);
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


//    /**
//     * dialog
//     *
//     * @param title
//     */
//    private void showChooseDialog(String title) {
//        int dex;
//        if (mPushItemType == PushItemType.Private_Messages) {
//            dex = mNotificationItem.mPrivateNotification.ordinal();
//        } else if (mPushItemType == PushItemType.Mails_from_CharmLive) {
//            dex = mNotificationItem.mMailNotification.ordinal();
//        } else {
//            dex = mNotificationItem.mInvitationNotification.ordinal();
//        }
//
//        MaterialDialogSingleChoice dialog = new MaterialDialogSingleChoice(this, PUSH_CHOOSE_ITEMS,
//                new MaterialDialogSingleChoice.OnClickCallback() {
//                    @Override
//                    public void onClick(AdapterView<?> adptView, View v, int which) {
//                        if (which > -1 && which < SettingPerfenceLive.NotificationSetting.values().length) {
//
//                            if (mPushItemType == PushItemType.Private_Messages) {
//                                mNotificationItem.mPrivateNotification = SettingPerfenceLive.NotificationSetting.values()[which];
//                            } else if (mPushItemType == PushItemType.Mails_from_CharmLive) {
//                                mNotificationItem.mMailNotification = SettingPerfenceLive.NotificationSetting.values()[which];
//                            } else {
//                                mNotificationItem.mInvitationNotification = SettingPerfenceLive.NotificationSetting.values()[which];
//                            }
//
////                            PushSettingManager.getInstance().saveNotificationItem(mNotificationItem);
//
//                            refreshPushDataView();
//                        }
//                    }
//                }, dex);
//
//        dialog.setTitle(title);
//        dialog.show();
//    }

//    /**
//     * 获取推送设置
//     *
//     * @param notificationItem
//     */
//    @Override
//    public void onGetData(SettingPerfenceLive.NotificationItem notificationItem) {
//        this.mNotificationItem = notificationItem;
//        refreshPushDataView();
//    }
}
