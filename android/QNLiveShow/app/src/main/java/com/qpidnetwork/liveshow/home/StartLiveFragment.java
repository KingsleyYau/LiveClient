package com.qpidnetwork.liveshow.home;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;

import com.qpidnetwork.framework.base.BaseFragment;
import com.qpidnetwork.httprequest.OnCreateLiveRoomCallback;
import com.qpidnetwork.httprequest.RequestJniLiveShow;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.liveshow.home.live.CoverManagerActivity;
import com.qpidnetwork.liveshow.liveroom.AnchorLiveRoomActivity;
import com.qpidnetwork.liveshow.model.http.CreateRoomRsp;
import com.squareup.picasso.Picasso;

import java.lang.ref.WeakReference;

/**
 */
public class StartLiveFragment extends BaseFragment {

    private EditText et_liveTitle;
    private ImageView iv_coverPhoto;
    private Button btn_goLive;
    private int liveTitleMaxLength = 0;
    private TextWatcher tw_liveTitle;

    private WeakReference<MainFragmentActivity> mActivity;

    public StartLiveFragment() {
        TAG = StartLiveFragment.class.getSimpleName();
        Log.d(TAG,TAG+"()");
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        mActivity = new WeakReference<MainFragmentActivity>((MainFragmentActivity) getActivity());
        View rootView = inflater.inflate (R.layout.fragment_start_mobile_live, container, false);
        initData();
        initView(rootView);
        return rootView;
    }

    private void initData(){
        liveTitleMaxLength = getActivity().getResources().getInteger(R.integer.liveTitleMaxLength);
    }

    private void initView(View rootView){
        rootView.findViewById(R.id.iv_shareFacebook).setOnClickListener(this);
        rootView.findViewById(R.id.iv_shareTwitter).setOnClickListener(this);
        rootView.findViewById(R.id.iv_shareInstagram).setOnClickListener(this);
        rootView.findViewById(R.id.iv_close).setOnClickListener(this);

        et_liveTitle = (EditText) rootView.findViewById(R.id.et_liveTitle);
        btn_goLive = (Button) rootView.findViewById(R.id.btn_goLive);

        if(null == tw_liveTitle){
            tw_liveTitle = new TextWatcher() {
                @Override
                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
                }

                @Override
                public void onTextChanged(CharSequence s, int start, int before, int count) {
                }

                @Override
                public void afterTextChanged(Editable s) {
                    Log.d(TAG,"afterTextChanged-s:"+s.toString());
                    int selectedStartIndex = et_liveTitle.getSelectionStart();
                    int selectedEndIndex = et_liveTitle.getSelectionEnd();
                    if(s.toString().length()>liveTitleMaxLength){
                        if(null != mActivity && null != mActivity.get()){
                            mActivity.get().showToast("超了");
                        }
                        s.delete(selectedStartIndex-1,selectedEndIndex);
                        if(null != et_liveTitle){
                            et_liveTitle.removeTextChangedListener(tw_liveTitle);
                            et_liveTitle.setText(s.toString());
                            et_liveTitle.setSelection(s.toString().length());
                            et_liveTitle.addTextChangedListener(tw_liveTitle);
                        }
                    }
                }
            };
        }
        et_liveTitle.addTextChangedListener(tw_liveTitle);

        iv_coverPhoto = (ImageView) rootView.findViewById(R.id.iv_coverPhoto);
        iv_coverPhoto.setOnClickListener(this);
        btn_goLive.setOnClickListener(this);
    }

    private final int REQ_CODE_COVERMANAGER = 1;
    public static final int RES_CODE_COVERMANAGER = 2;

    @Override
    public void onClick(View view){
        super.onClick(view);
        switch (view.getId()){
            case R.id.iv_close:
                if(null != mActivity && mActivity.get()!= null){
                    mActivity.get().updateButtomTabStyle(mActivity.get().lastSelectedPosition);
                }
                break;
            case R.id.btn_goLive:
                goLive();
                break;
            case R.id.iv_coverPhoto:
                startActivityForResult(new Intent(mActivity.get(),CoverManagerActivity.class),REQ_CODE_COVERMANAGER);
                break;
            case R.id.iv_shareFacebook:
                if(null != mActivity && mActivity.get()!= null){
                    mActivity.get().showToast("iv_shareFacebook");
                }
                break;
            case R.id.iv_shareTwitter:
                if(null != mActivity && mActivity.get()!= null){
                    mActivity.get().showToast("iv_shareTwitter");
                }
                break;
            case R.id.iv_shareInstagram:
                if(null != mActivity && mActivity.get()!= null){
                    mActivity.get().showToast("iv_shareInstagram");
                }
                break;
        }
    }

    private String inUsingPhotoId = "";
    private String inUsingPhotoUrl = "";

    private void goLive(){
        if(TextUtils.isEmpty(inUsingPhotoId)){
            if(null != mActivity && mActivity.get()!= null){
                mActivity.get().showToast(getResources().getString(R.string.tip_needCoverPhoto));
            }
            return;
        }
        if(TextUtils.isEmpty(et_liveTitle.getText().toString())){
            if(null != mActivity && mActivity.get()!= null){
                mActivity.get().showToast(getResources().getString(R.string.tip_needRoomTitle));
            }
            return;
        }

        if(null != mActivity && mActivity.get()!= null){
            mActivity.get().showCustomDialog(0,0,R.string.tip_createRoom,false,false,null);
        }
        RequestJniLiveShow.CreateLiveRoom(et_liveTitle.getText().toString(),inUsingPhotoId,new OnCreateLiveRoomCallback(){
            @Override
            public void onCreateLiveRoom(boolean isSuccess, int errCode, String errMsg, String roomId, String roomStreamUrl) {
                Log.d(TAG,"onCreateLiveRoom-isSuccess:"+isSuccess+" errCode:"+errCode+" errMsg:"+errMsg+" roomId:"+roomId+" roomStreamUrl:"+roomStreamUrl);
                Message msg = handler.obtainMessage(MSG_WHAT_CREATEROOM_RSP);
                CreateRoomRsp rsp = new CreateRoomRsp(isSuccess,errCode,errMsg,roomId,roomStreamUrl);
                msg.obj = rsp;
                handler.sendMessage(msg);
            }
        });
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if(null != mActivity && mActivity.get()!=null){
            mActivity.clear();
            mActivity = null;
        }
    }

    private final int MSG_WHAT_CREATEROOM_RSP = 0;
    private Handler handler = new Handler(){
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what){
                case MSG_WHAT_CREATEROOM_RSP:
                    CreateRoomRsp rsp = (CreateRoomRsp)msg.obj;
                    if(null != mActivity && mActivity.get()!= null){
                        mActivity.get().dismissCustomDialog();
                        mActivity.get().showToast(rsp.isSuccess ? mActivity.get().getString(R.string.tip_createRoomSuccessed) : rsp.errMsg);
                        //                    Intent intent = new Intent(mActivity.get(),BroadcastActivity.class);
//                    Intent intent = new Intent(mActivity.get(),AnchorLiveRoomActivity.class);
//                    intent.putExtra("isHost",true);
//                    intent.putExtra("roomStreamUrl",rsp.roomStreamUrl);
//                    intent.putExtra("roomId",rsp.roomId);
//                    intent.putExtra("localSelectedPicUri", localSelectedPicUri);//localSelectedPicUri
//                    intent.putExtra("roomPhotoUrl", localSelectedPicUri.getFilePathFromUri());//localSelectedPicUri
                        startActivity(AnchorLiveRoomActivity.getIntent(mActivity.get(), rsp.roomId));
                        mActivity.get().updateButtomTabStyle(0);
                    }
                    break;
            }
            super.handleMessage(msg);
        }
    };

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        Log.d(TAG,"onActivityResult-requestCode:"+requestCode+" resultCode:"+resultCode);
        if(REQ_CODE_COVERMANAGER==requestCode && RES_CODE_COVERMANAGER == resultCode){
            if(null != data){
                inUsingPhotoId = data.getStringExtra("inUsingPhotoId");
                inUsingPhotoUrl = data.getStringExtra("inUsingPhotoUrl");
                Log.d(TAG,"onActivityResult-inUsingPhotoId:"+inUsingPhotoId+" inUsingPhotoUrl:"+inUsingPhotoUrl);
                if(!TextUtils.isEmpty(inUsingPhotoUrl)){
                    Picasso.with(getContext()).load(inUsingPhotoUrl).into(iv_coverPhoto);
                }
            }
        }
    }
}
