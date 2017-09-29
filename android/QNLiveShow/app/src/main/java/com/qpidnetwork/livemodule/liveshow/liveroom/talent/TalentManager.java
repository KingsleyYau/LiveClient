package com.qpidnetwork.livemodule.liveshow.liveroom.talent;

import android.app.Activity;
import android.os.Build;
import android.os.Handler;
import android.os.Message;
import android.text.Html;
import android.text.Spanned;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.OnGetTalentInviteStatusCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetTalentListCallback;
import com.qpidnetwork.livemodule.httprequest.RequestJniLiveShow;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.TalentInviteItem;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.liveshow.liveroom.talent.interfaces.onRequestConfirmListener;
import com.qpidnetwork.livemodule.view.MaterialDialogAlert;

import java.lang.ref.WeakReference;

/**
 * 才艺管理工具
 * Created by Jagger on 2017/9/20.
 */

public class TalentManager implements TalentsPopupWindow.onBtnClickedListener {

    private final int REQUEST_LIST_SUCCESS = 0;
    private final int REQUEST_LIST_FAILED = 1;

    private Activity mActivity;
    private TalentsPopupWindow mTalentsPopupWindow;

    private onRequestConfirmListener mOnRequestConfirmListener;
    private TalentInfoItem[] mDatas;            //数据源
    private UIHandler mUIHandler;
    private String mNickName;                   //主播名
    private String mRoomId;                     //房间ID
    private TalentInfoItem mRequestingTalent ;  //正在请求的才艺，用作判断能否发送其它才艺请求

    public TalentManager(Activity activity){
        mActivity = activity;

        //处理请求返回
        mUIHandler = new UIHandler(mActivity){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                if(msg != null){
                    switch (msg.what){
                        case REQUEST_LIST_SUCCESS:

                            if(mTalentsPopupWindow != null){
                                mTalentsPopupWindow.setLoadingVisible(false);
                                mTalentsPopupWindow.refreshData(mDatas);
                            }
                            break;
                        case REQUEST_LIST_FAILED:
                            if(mTalentsPopupWindow != null){
                                mTalentsPopupWindow.setLoadingVisible(false);
                                mTalentsPopupWindow.setEmptyViewVisible(true);
                            }

                            //test
//                            Toast.makeText(mActivity , "请求才艺列表失败 ,　给你点假数据" , Toast.LENGTH_LONG).show();
//                            mDatas = new TalentInfoItem[4];
//                            TalentInfoItem t1 = new TalentInfoItem("id1","吃面", 0.1);
//                            TalentInfoItem t2 = new TalentInfoItem("id2","吃饭", 0.2);
//                            TalentInfoItem t3 = new TalentInfoItem("id3","吃粉", 0.1);
//                            TalentInfoItem t4 = new TalentInfoItem("id4","吃番薯", 0.3);
//
//                            mDatas[0] = t1;
//                            mDatas[1] = t2;
//                            mDatas[2] = t3;
//                            mDatas[3] = t4;
//
//                            if(mTalentsPopupWindow != null){
//                                mTalentsPopupWindow.refreshData(mDatas);
//                            }
                            //end test
                            break;
                    }
                }
            }
        };
    }

    //------------------ 公开函数　-----------------
    /**
     * 请求才艺列表数据
     */
    public void getTalentsData(String roomId){
        mRoomId = roomId;
        //
        RequestJniLiveShow.GetTalentList(mRoomId, new OnGetTalentListCallback() {
            @Override
            public void onGetTalentList(boolean isSuccess, int errCode, String errMsg, TalentInfoItem[] talentList) {
                mDatas = talentList;

                if(isSuccess){
                    mUIHandler.sendEmptyMessage(REQUEST_LIST_SUCCESS);
                }else {
                    mUIHandler.sendEmptyMessage(REQUEST_LIST_FAILED);
                }

            }
        });
    }

    /**
     * 点击发送才艺要求确认事件回调
     * @param l
     */
    public void setOnClickedRequestConfirmListener(onRequestConfirmListener l){
        mOnRequestConfirmListener = l;
    }

    /**
     * 显示才艺列表
     * @param anchorView
     * @param nickName 主播昵称
     */
    public void showTalentsList(View anchorView , String nickName){
        mNickName = nickName;

        //弹出列表
        if(mTalentsPopupWindow == null){
            mTalentsPopupWindow = new TalentsPopupWindow(mActivity , anchorView , mDatas);
            mTalentsPopupWindow.setTitleText(nickName);
            mTalentsPopupWindow.setOnBtnClickedListener(this);
        }
        mTalentsPopupWindow.show();

        //看看有没有数据
        if(mDatas == null){
            reGetTalentsData();
        }

        //如果之前点了才艺而又没被主播处理，需要设置请求按钮是否能点
        if(mRequestingTalent == null){
            setTalentCanRequest(true);
        }else {
            setTalentCanRequest(false);
        }

    }

    /**
     * 才艺发送结果回调,会弹出相应提示
     */
    public void onTanlentSent(final boolean result , final String errMsg){
        mActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if(result){
                    Toast.makeText(mActivity , mActivity.getString(R.string.live_talent_request_success , mRequestingTalent.talentName) ,Toast.LENGTH_LONG).show();
                }else{
                    mRequestingTalent = null;
                    setTalentCanRequest(true);

                    if(TextUtils.isEmpty(errMsg)){

                    Toast.makeText(mActivity , mActivity.getString(R.string.live_talent_request_failed) ,Toast.LENGTH_LONG).show();
                    }else{
                        Toast.makeText(mActivity , errMsg ,Toast.LENGTH_LONG).show();
                    }
                }
            }
        });
    }

    /**
     * 才艺请求被主播处理回调,会弹出相应提示
     */
    public void onTanlentProcessed(final String talentId , final String talentName , final IMClientListener.TalentInviteStatus status){
        mRequestingTalent = null;

        mActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                setTalentCanRequest(true);
                if(status == IMClientListener.TalentInviteStatus.Accepted){
                    Toast.makeText(mActivity , mActivity.getString(R.string.live_talent_accepted , mNickName ,talentName) ,Toast.LENGTH_LONG).show();
                }else if(status == IMClientListener.TalentInviteStatus.Rejested){
                    Toast.makeText(mActivity , mActivity.getString(R.string.live_talent_declined , mNickName ,talentName) ,Toast.LENGTH_LONG).show();
                }else if(status == IMClientListener.TalentInviteStatus.Unknown){
                    Toast.makeText(mActivity , mActivity.getString(R.string.live_talent_unknow) ,Toast.LENGTH_LONG).show();
                }
            }
        });

    }

    /**
     * 获取才艺点状态
     */
    public void getTalentStatus(){
        //如果是发送过请求，才去获取
        if(mRequestingTalent != null){
            RequestJniLiveShow.GetTalentInviteStatus(mRoomId, mRequestingTalent.talentId, new OnGetTalentInviteStatusCallback() {
                @Override
                public void onGetTalentInviteStatus(boolean isSuccess, int errCode, String errMsg, TalentInviteItem inviteItem) {
                    //如果已被主播处理了
                    if(inviteItem.inviteStatus != TalentInviteItem.TalentInviteStatus.NoReplied){
                        mRequestingTalent = null;
                    }
                }
            });
        }
    }

    //--------------------------------------------



    //------------------ 私有函数　-----------------
    /**
     * 重新获取数据
     */
    private void reGetTalentsData(){
        if(mTalentsPopupWindow != null){
            mTalentsPopupWindow.setLoadingVisible(true);
        }

        getTalentsData(mRoomId);
    }

    @Override
    public void onRequestClicked(TalentInfoItem talent) {
        //
        Log.i("Jagger" , "request talentId:" + talent.talentId);
        //关闭才艺列表
        if(mTalentsPopupWindow != null) {
            mTalentsPopupWindow.dismiss();
        }
        //弹出确认对话框
        showDConfirmDialog(talent);
    }

    @Override
    public void onReloadClicked() {
        reGetTalentsData();
    }

    /**
     * 确定要点播才艺的对话框
     * @param talent
     */
    private void showDConfirmDialog(final TalentInfoItem talent){
        String msgStr = mActivity.getString(R.string.live_talent_confirm , talent.talentName , String.valueOf(talent.talentCredit));
        Spanned msgHtml;
        if(Build.VERSION.SDK_INT > 23){
            msgHtml = Html.fromHtml(msgStr , Html.FROM_HTML_MODE_LEGACY);
        }else{
            msgHtml = Html.fromHtml(msgStr);
        }

        MaterialDialogAlert dialog = new MaterialDialogAlert(mActivity);
        dialog.setCancelable(false);
        dialog.setMessage(msgHtml);
        dialog.addButton(dialog.createButton(mActivity.getString(R.string.common_btn_ok), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mOnRequestConfirmListener != null){
                    mOnRequestConfirmListener.onConfirm(talent);
                }
                //记下才艺
                mRequestingTalent = talent;
            }
        }));
        dialog.addButton(dialog.createButton(mActivity.getString(R.string.common_btn_cancel), new View.OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        }));
        dialog.show();
    }

    /**
     * 设置才艺列表能否点击Request
     * @param canRequest
     */
    private void setTalentCanRequest(boolean canRequest){
        if(mDatas != null){
            //设置才艺能再次请求
            for (TalentInfoItem talent : mDatas) {
                talent.canRequest = canRequest;
            }

            //刷新列表
            if(mTalentsPopupWindow != null){
                mTalentsPopupWindow.refreshData(mDatas);
            }
        }
    }

    /**
     * 显示主播处理结果
     */
    private void showTalentProcessedResult(){

    }

    /**
     * 处理 请求返回,可避免Activity关闭后还处理界面的问题
     * @author Jagger
     * 2017-9-19
     */
    private static class UIHandler extends Handler {
        private final WeakReference<Activity> mActivity;

        public UIHandler(Activity activity){
            mActivity = new WeakReference<Activity>(activity);
        }

        @Override
        public void handleMessage(Message msg) {
            // TODO Auto-generated method stub
            super.handleMessage(msg);
            if(mActivity == null) return;
        }
    }
    //--------------------------------------------
}
