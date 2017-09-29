package com.qpidnetwork.livemodule.liveshow.personal;

import android.app.Activity;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;
import com.qpidnetwork.livemodule.im.IMLiveRoomEventListener;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.IMOtherEventListener;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMPackageUpdateItem;
import com.qpidnetwork.livemodule.im.listener.IMRebateItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.talent.TalentManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.talent.interfaces.onRequestConfirmListener;

/**
 * 测试　才艺点播
 */
public class TestTalentActivity extends Activity implements IMLiveRoomEventListener , IMOtherEventListener {

    private TalentManager mTalentManager;
    private String mRoomId = "1";
    private String mTalentId = "", mBroadcasterName = "你哥我才艺爆表" , mTalentName = "";  //测试用

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_live_test);

        //IM相关
        IMManager.getInstance().registerIMLiveRoomEventListener(this);
        IMManager.getInstance().registerIMOtherEventListener(this);

        //才艺相关
        mTalentManager = new TalentManager(this);
        mTalentManager.getTalentsData(mRoomId);
        mTalentManager.setOnClickedRequestConfirmListener(new onRequestConfirmListener() {
            @Override
            public void onConfirm(TalentInfoItem talent) {
                Log.i("Jagger" , "TestTalentActivity　IM发送才艺请求:" + talent.talentId);
                mTalentId = talent.talentId;
                mTalentName = talent.talentName;
                //调用IM接口
                IMManager.getInstance().sendTalentInvite(mRoomId , talent.talentId);
            }
        });

        Button button = (Button)findViewById(R.id.btn_showTalent);
        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTalentManager.showTalentsList(v , mBroadcasterName);
            }
        });

        //test
        Button button1 = (Button)findViewById(R.id.btn_test1);
        button1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mTalentManager.onTanlentProcessed(mTalentId , mTalentName ,IMClientListener.TalentInviteStatus.Accepted);
            }
        });
    }

    @Override
    protected void onDestroy() {
        //IM相关
        IMManager.getInstance().unregisterIMLiveRoomEventListener(this);
        IMManager.getInstance().registerIMOtherEventListener(this);
        super.onDestroy();
    }

    //--------------- 以下是要实现的IM接口　---------------------
    @Override
    public void OnRecvRoomCloseNotice(String roomId, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvEnterRoomNotice(String roomId, String userId, String nickName, String photoUrl, String riderId, String riderName, String riderUrl, int fansNum) {

    }

    @Override
    public void OnRecvLeaveRoomNotice(String roomId, String userId, String nickName, String photoUrl, int fansNum) {

    }

    @Override
    public void OnRecvRebateInfoNotice(String roomId, IMRebateItem item) {

    }

    @Override
    public void OnRecvLeavingPublicRoomNotice(String roomId, IMClientListener.LCC_ERR_TYPE err, String errMsg) {

    }

    @Override
    public void OnRecvRoomKickoffNotice(String roomId, IMClientListener.LCC_ERR_TYPE err, String errMsg, double credit) {

    }

    @Override
    public void OnRecvChangeVideoUrl(String roomId, boolean isAnchor, String playUrl) {

    }

    @Override
    public void OnControlManPush(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String[] manPushUrl) {

    }

    @Override
    public void OnSendRoomMsg(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem) {

    }

    @Override
    public void OnRecvRoomMsg(IMMessageItem msgItem) {

    }

    @Override
    public void OnRecvSendSystemNotice(IMMessageItem msgItem) {

    }

    @Override
    public void OnSendGift(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem, double credit, double rebateCredit) {

    }

    @Override
    public void OnRecvRoomGiftNotice(IMMessageItem msgItem) {

    }

    @Override
    public void OnSendBarrage(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, IMMessageItem msgItem, double credit, double rebateCredit) {

    }

    @Override
    public void OnRecvRoomToastNotice(IMMessageItem msgItem) {

    }

    @Override
    public void OnSendTalent(int reqId, boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        Log.i("Jagger" , "TestTalentActivity　IM发送才艺请求 回调:" + errMsg);
        mTalentManager.onTanlentSent(success , errMsg);
    }

    @Override
    public void OnRecvSendTalentNotice(String roomId, String talentInviteId, String talentId, String name, double credit, IMClientListener.TalentInviteStatus status) {
        Log.i("Jagger" , "TestTalentActivity　才艺请求被主播处理 回调:" + talentId);
        mTalentManager.onTanlentProcessed(talentId,name,status);
    }

    @Override
    public void OnLogin(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {
        //IM断线重登录
        //获取才艺ID状态
        mTalentManager.getTalentStatus();
    }

    @Override
    public void OnLogout(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnKickOff(IMClientListener.LCC_ERR_TYPE errType, String errMsg) {

    }

    @Override
    public void OnRecvLackOfCreditNotice(String roomId, String message, double credit) {

    }

    @Override
    public void OnRecvCreditNotice(String roomId, double credit) {

    }

    @Override
    public void OnRecvAnchoeInviteNotify(String logId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {

    }

    @Override
    public void OnRecvScheduledInviteNotify(String inviteId, String anchorId, String anchorName, String anchorPhotoUrl, String message) {

    }

    @Override
    public void OnRecvSendBookingReplyNotice(String inviteId, IMClientListener.BookInviteReplyType replyType) {

    }

    @Override
    public void OnRecvBookingNotice(String roomId, String userId, String nickName, String photoUrl, int leftSeconds) {

    }

    @Override
    public void OnRecvLevelUpNotice(int level) {

    }

    @Override
    public void OnRecvLoveLevelUpNotice(int lovelevel) {

    }

    @Override
    public void OnRecvBackpackUpdateNotice(IMPackageUpdateItem item) {

    }
}
