package com.qpidnetwork.liveshow.liveroom;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.View;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.Toast;

import com.qpidnetwork.httprequest.OnRequestCallback;
import com.qpidnetwork.httprequest.RequestJniLiveShow;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.liveshow.model.IMAnchorNotifyItem;
import com.qpidnetwork.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.liveshow.model.http.IMRespObject;
import com.qpidnetwork.utils.Log;
import com.qpidnetwork.view.SimpleDoubleBtnTipsDialog;

/**
 * 主播播放间
 * Created by Hunter Mun on 2017/6/16.
 */

public class AnchorLiveRoomActivity extends BaseCommonLiveRoomActivity{

    //避免和基类冲突，Audience 以 3*** 格式
    private static final int EVENT_ANCHOR_ROOMOUT = 3001;
    private static final int EVENT_ANCHOR_ROOMOUT_NOTIFY = 3002;

    //Views
    private RelativeLayout rl_anchorOperate;
    private Button btn_controlLive;
    private Button btn_switchCamera;
    private Button btn_switchFlash;
    private Button btn_switchBeauty;

    private boolean showControlView = true;
    private boolean onFrontCamera = true;       //前置后置摄像头切换标志
    private boolean onFlash = false;            //闪光灯状态标志
    private boolean onBeauty = false;           //美颜开关

    public static Intent getIntent(Context context, String roomId){
        Intent intent = new Intent(context, AnchorLiveRoomActivity.class);
        intent.putExtra(BaseCommonLiveRoomActivity.LIVEROOM_ROOM_ID, roomId);
        return intent;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initAnchorViews();
    }

    private void initAnchorViews(){
        //打开主播区域
        findViewById(R.id.include_anchor_area).setVisibility(View.VISIBLE);
        rl_anchorOperate = (RelativeLayout)findViewById(R.id.rl_anchorOperate);
        rl_anchorOperate.setVisibility(View.VISIBLE);

        //按钮功能区
        btn_controlLive = (Button)findViewById(R.id.btn_controlLive);
        btn_switchCamera = (Button)findViewById(R.id.btn_switchCamera);
        btn_switchFlash = (Button)findViewById(R.id.btn_switchFlash);
        btn_switchBeauty = (Button)findViewById(R.id.btn_switchBeauty);
        btn_switchBeauty.setSelected(onBeauty);
        btn_switchFlash.setSelected(onFlash);
        btn_switchCamera.setSelected(onFrontCamera);

        //设置按钮区域
        updateLiveControlView();
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()){
            case R.id.btn_showInputView:{
                rl_anchorOperate.setVisibility(View.GONE);
            }break;
            case R.id.btn_hostShare: {
                hostShare();
            }break;
            case R.id.btn_controlLive: {
                updateLiveControlView();
            }break;
            case R.id.btn_switchBeauty: {
                switchBeauty();
            }break;
            case R.id.btn_switchFlash: {
                switchFlash();
            }break;
            case R.id.btn_switchCamera: {
                switchCamera();
            }break;
            case R.id.iv_closeLiveRoom: {
                showAnchorRoomOutDialog();
            }break;
            default:
                break;
        }
        super.onClick(v);
    }

    /**
     * 显示或者隐藏功能控制按钮
     */
    private void updateLiveControlView(){
        showControlView = ! showControlView;
        btn_controlLive.setSelected(showControlView);
        int visable = showControlView ? View.VISIBLE : View.INVISIBLE;
        btn_switchBeauty.setVisibility(visable);
        btn_switchFlash.setVisibility(visable);
        btn_switchCamera.setVisibility(visable);
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        switch (msg.what){
            case EVENT_ANCHOR_ROOMOUT:{
                HttpRespObject response = (HttpRespObject)msg.obj;
                if(response.isSuccess){
                    //成功什么也不做，等IM服务器通知
                }else{
                    dismissCustomDialog();
                    showToast(response.errMsg);
                }
            }break;
            case EVENT_ANCHOR_ROOMOUT_NOTIFY:{
                dismissCustomDialog();
                IMAnchorNotifyItem notifyItem = (IMAnchorNotifyItem)msg.obj;
                Intent intent = new Intent(AnchorLiveRoomActivity.this, AnchorEndActivity.class);
                intent.putExtra("liveTimes",notifyItem.duration*1000l);
                intent.putExtra("shares",notifyItem.shares);
                intent.putExtra("newFans",notifyItem.newFans);
                intent.putExtra("viewers",notifyItem.fansNum);
                intent.putExtra("diamonds",notifyItem.income);
                startActivity(intent);
                finish();
            }break;
            default:
                break;
        }
    }

    /**
     * 切换前后摄像头
     */
    public void switchCamera(){
        onFrontCamera=!onFrontCamera;
        Toast.makeText(this, "switchCamera", Toast.LENGTH_SHORT).show();
    }

    /**
     * 打开或关闭闪光灯
     */
    public void switchFlash(){
        onFlash = !onFlash;
        btn_switchFlash.setSelected(onFlash);
        Toast.makeText(this, "switchFlash", Toast.LENGTH_SHORT).show();
    }

    /**
     * 打开或者关闭美颜功能
     */
    public void switchBeauty(){
        onBeauty = !onBeauty;
        btn_switchBeauty.setSelected(onBeauty);
        Toast.makeText(this, "iv_switchBeauty", Toast.LENGTH_SHORT).show();
    }

    /**
     * 键盘隐藏回调
     */
    @Override
    public void onSoftKeyboardHide() {
        super.onSoftKeyboardHide();
        rl_anchorOperate.setVisibility(View.VISIBLE);
    }

    /**
     * 主播分享
     */
    private void hostShare(){
        Toast.makeText(this, "hostShare", Toast.LENGTH_SHORT).show();
    }

    /**
     * 关闭直播间
     */
    public void closeLiveRoom(){
        showCustomDialog(0,0,R.string.liveroom_anchor_roomout_processing,true,true,null);
        RequestJniLiveShow.CloseLiveRoom(mRoomId, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                Message msg = Message.obtain();
                msg.what = EVENT_ANCHOR_ROOMOUT;
                msg.obj = new HttpRespObject(isSuccess, errCode,errMsg, null);
                sendUiMessage(msg);
            }
        });
    }

    private void showAnchorRoomOutDialog(){
        showCustomDialog(R.string.txt_cancel, R.string.txt_ok, R.string.tip_sureToCloseRoom,
                true, true, android.R.color.white, android.R.color.white,
                R.drawable.bg_custom_dialog_confirm, R.drawable.bg_custom_dialog_cancel,
                new SimpleDoubleBtnTipsDialog.OnTipsDialogBtnClickListener() {
                    @Override
                    public void onCancelBtnClick() {
                        dismissCustomDialog();
                    }

                    @Override
                    public void onConfirmBtnClick() {
                        dismissCustomDialog();
                        closeLiveRoom();
                    }
                });
    }

    /******************************** IM服务器回调  **************************************/
    //主播端房间关闭通知
    @Override
    public void OnRecvRoomCloseBroad(String roomId, int fansNum, int inCome, int newFans, int shares, int duration) {
        super.OnRecvRoomCloseBroad(roomId, fansNum, inCome, newFans, shares, duration);
        if(!TextUtils.isEmpty(roomId) && (roomId.equals(mRoomId))) {
            Message msg = Message.obtain();
            msg.what = EVENT_ANCHOR_ROOMOUT_NOTIFY;
            msg.obj = new IMAnchorNotifyItem(roomId, fansNum, inCome, newFans, shares, duration);
            sendUiMessage(msg);
        }
    }
}
