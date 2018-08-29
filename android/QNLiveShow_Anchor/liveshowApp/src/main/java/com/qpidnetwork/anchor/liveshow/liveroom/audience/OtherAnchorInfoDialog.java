package com.qpidnetwork.anchor.liveshow.liveroom.audience;

import android.app.Dialog;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.anchor.httprequest.LiveRequestOperator;
import com.qpidnetwork.anchor.httprequest.OnGetHangoutFriendRelationCallback;
import com.qpidnetwork.anchor.httprequest.OnRequestCallback;
import com.qpidnetwork.anchor.httprequest.item.AnchorInfoItem;
import com.qpidnetwork.anchor.httprequest.item.HangoutFriendType;
import com.qpidnetwork.anchor.httprequest.item.HttpLccErrType;
import com.qpidnetwork.anchor.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.anchor.liveshow.liveroom.BaseHangOutLiveRoomActivity;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import java.lang.ref.WeakReference;

/**
 * 其他主播资料页面
 */
public class OtherAnchorInfoDialog extends Dialog implements View.OnClickListener{

    private final String TAG = OtherAnchorInfoDialog.class.getSimpleName();
    private WeakReference<BaseHangOutLiveRoomActivity> mActivity;

    private View rootView;
    private ImageView iv_close;
    private ProgressBar pb_loading;
    private View ll_errorRetry;
    private TextView tv_errerReload;
    private View ll_anchorInfo;
    private Button btn_sendFriendReq;
    private CircleImageView civ_anchorPic;
    private TextView tv_anchorAge;
    private TextView tv_anchorNickname;
    private TextView tv_anchorLocate;
    private String mAnchorId;

    public OtherAnchorInfoDialog(BaseHangOutLiveRoomActivity context){
        super(context, R.style.CustomTheme_LiveAudienceDialog);
        this.mActivity = new WeakReference<BaseHangOutLiveRoomActivity>(context);
        setOutSizeTouchHasChecked(true);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG,"onCreate");
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH);
        rootView = View.inflate(getContext(),R.layout.view_hangout_anchor_info_dialog,null);
        setContentView(rootView);
        initView(rootView);
    }


    private void initView(View rootView){
        Log.d(TAG,"initView");
        iv_close = (ImageView) rootView.findViewById(R.id.iv_close);
        pb_loading = (ProgressBar) rootView.findViewById(R.id.pb_loading);
        ll_errorRetry = rootView.findViewById(R.id.ll_errorRetry);
        ll_errorRetry.setOnClickListener(this);
        tv_errerReload = (TextView) rootView.findViewById(R.id.tv_errerReload);
        tv_errerReload.setOnClickListener(this);
        ll_anchorInfo = rootView.findViewById(R.id.ll_anchorInfo);
        btn_sendFriendReq = (Button) rootView.findViewById(R.id.btn_sendFriendReq);
        iv_close.setOnClickListener(this);
        btn_sendFriendReq.setOnClickListener(this);
        civ_anchorPic = (CircleImageView) rootView.findViewById(R.id.civ_anchorPic);
        civ_anchorPic.setOnClickListener(this);
        tv_anchorNickname = (TextView) rootView.findViewById(R.id.tv_anchorNickname);
        tv_anchorAge = (TextView) rootView.findViewById(R.id.tv_anchorAge);
        tv_anchorLocate = (TextView) rootView.findViewById(R.id.tv_anchorLocate);
    }

    /**
     * 显示loading
     */
    public void show(String currAnchorId) {
        Log.d(TAG,"show-currAnchorId:"+ currAnchorId);
        super.show();
        this.mAnchorId = currAnchorId;
        showLoadingView();
        updateOtherAnchorInfoItemByUserId();
    }

    private void showLoadingView(){
        pb_loading.setVisibility(View.VISIBLE);
        ll_errorRetry.setVisibility(View.GONE);
        ll_anchorInfo.setVisibility(View.INVISIBLE);
    }

    /**
     * 显示加载错误尝试重试页面
     */
    public void showErrorRetryView(){
        pb_loading.setVisibility(View.GONE);
        ll_errorRetry.setVisibility(View.VISIBLE);
        ll_anchorInfo.setVisibility(View.INVISIBLE);
    }

    /**
     * 查询同某个anchorId对应的主播的好友关系
     */
    public void updateOtherAnchorInfoItemByUserId(){
        Log.d(TAG,"updateOtherAnchorInfoItemByUserId-mAnchorId:"+mAnchorId);
        LiveRequestOperator.getInstance().GetHangoutFriendRelation(mAnchorId, new OnGetHangoutFriendRelationCallback() {
            @Override
            public void onGetHangoutFriendRelation(final boolean isSuccess, int errCode, final String errMsg, final AnchorInfoItem item) {
                Log.d(TAG,"onGetHangoutFriendRelation-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg+" item:"+item);
                if(null != mActivity && null != mActivity.get()){
                    //更新dialog
                    mActivity.get().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            //如果目标主播弹框可见
                            if(isShowing()){
                                if(isSuccess){
                                    if(null != item &&  !TextUtils.isEmpty(mAnchorId)& mAnchorId.equals(item.anchorId)){
                                        //成功则刷新界面数据
                                        updateOtherAnchorInfo2View(item);
                                    }
                                }else{
                                    //失败提示并展示错误重试页面
                                    showToast(errMsg);
                                    showErrorRetryView();
                                }
                            }
                        }
                    });
                }
            }
        });
    }

    /**
     * 刷新其他主播资料界面展示
     * @param item
     */
    public void updateOtherAnchorInfo2View(AnchorInfoItem item){
        Log.d(TAG,"updateOtherAnchorInfo2View-item:"+item);
        pb_loading.setVisibility(View.GONE);
        ll_errorRetry.setVisibility(View.GONE);
        ll_anchorInfo.setVisibility(View.VISIBLE);
        //更新头像
        if(!TextUtils.isEmpty(item.photoUrl)){
            Picasso.with(getContext().getApplicationContext())
                    .load(item.photoUrl).noFade()
                    .error(R.drawable.ic_default_photo_man)
                    .memoryPolicy(MemoryPolicy.NO_CACHE)
                    .into(civ_anchorPic);
        }
        //更新昵称
        if(!TextUtils.isEmpty(item.nickName)){
            tv_anchorNickname.setText(item.nickName);
        }
        //年龄
        if(null != mActivity && null != mActivity.get()){
            tv_anchorAge.setText(mActivity.get().getResources().getString(
                    R.string.hangout_other_anchor_dialog_age, String.valueOf(item.age)));
        }

        //地区
        if(!TextUtils.isEmpty(item.country)){
            tv_anchorLocate.setText(item.country);
        }
        if(item.friendType == HangoutFriendType.No){
            btn_sendFriendReq.setVisibility(View.VISIBLE);
            btn_sendFriendReq.setEnabled(true);
            btn_sendFriendReq.setText(mActivity.get().getResources().getString(R.string.hangout_other_anchor_dialog_addfriend));
        }else if(item.friendType == HangoutFriendType.Requesting){
            btn_sendFriendReq.setVisibility(View.VISIBLE);
            btn_sendFriendReq.setEnabled(false);
            btn_sendFriendReq.setText(mActivity.get().getResources().getString(R.string.hangout_other_anchor_dialog_friendreq_sent));
        }else{
            btn_sendFriendReq.setVisibility(View.INVISIBLE);
        }
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        Log.d(TAG,"onWindowFocusChanged-hasFocus:"+hasFocus);
        if (!hasFocus) {
            return;
        }
    }

    @Override
    public void onClick(View view){
        switch (view.getId()){
            case R.id.iv_close:
                dismiss();
                break;
            case R.id.civ_anchorPic: {
            }break;
            case R.id.btn_sendFriendReq:
                if(!TextUtils.isEmpty(mAnchorId)){
                    sendAddAnchorFriendRequest();
                }
                break;
            case R.id.ll_errorRetry:
            case R.id.tv_errerReload:
                if(!TextUtils.isEmpty(mAnchorId)){
                    updateOtherAnchorInfoItemByUserId();
                    showLoadingView();
                }
                break;
        }
    }

    /**
     * 发送好友添加请求
     */
    public void sendAddAnchorFriendRequest(){
        Log.d(TAG,"sendAddAnchorFriendRequest-mAnchorId:"+mAnchorId);
        LiveRequestOperator.getInstance().AddAnchorFriend(mAnchorId, new OnRequestCallback() {
            @Override
            public void onRequest(final boolean isSuccess, final int errCode, final String errMsg) {
                Log.d(TAG,"sendAddAnchorFriendRequest-onRequest-isSuccess:"+isSuccess
                        +" errCode:"+errCode+" errMsg:"+errMsg);
                if(null != mActivity && null != mActivity.get()){
                    //更新本地数据 弹出提示
                    mActivity.get().runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            if(isSuccess){
                                if(isShowing()){
                                    btn_sendFriendReq.setVisibility(View.VISIBLE);
                                    btn_sendFriendReq.setEnabled(false);
                                    btn_sendFriendReq.setText(mActivity.get().getResources().getString(
                                            R.string.hangout_other_anchor_dialog_friendreq_sent));
                                    showToast(R.string.hangout_other_anchor_dialog_friendreq_sentsuc);
                                    dismiss();
                                }
                            }else{
                                HttpLccErrType errType = IntToEnumUtils.intToHttpErrorType(errCode);
                                if(errType == HttpLccErrType.HTTP_LCC_ERR_CONNECTFAIL){
                                    showToast(R.string.hangout_other_anchor_dialog_friendreq_sentfailed);
                                }else if(!TextUtils.isEmpty(errMsg)){
                                    showToast(errMsg);
                                }
                            }
                        }
                    });
                }
            }
        });
    }

    private void showToast(String msg){
        if(null != mActivity && null != mActivity.get() && !TextUtils.isEmpty(msg)){
            mActivity.get().showToast(msg);
        }
    }

    private void showToast(int msgResId){
        if(null != mActivity && null != mActivity.get()){
            mActivity.get().showToast(msgResId);
        }
    }

    private boolean outSizeTouchHasChecked = false;

    public void setOutSizeTouchHasChecked(boolean outSizeTouchHasChecked){
        this.outSizeTouchHasChecked = outSizeTouchHasChecked;
    }

    @Override
    public boolean onTouchEvent(@NonNull MotionEvent event) {
        Log.d(TAG,"onTouchEvent-event.action:"+event.getAction());
        if (MotionEvent.ACTION_OUTSIDE == event.getAction() && !outSizeTouchHasChecked) {
            dismiss();
            return true;
        }
        return super.onTouchEvent(event);
    }
}
