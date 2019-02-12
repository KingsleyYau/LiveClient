package com.qpidnetwork.anchor.liveshow.liveroom.audience;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.anchor.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.anchor.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.anchor.liveshow.datacache.file.downloader.FileDownloadManager;
import com.qpidnetwork.anchor.liveshow.liveroom.BaseImplLiveRoomActivity;
import com.qpidnetwork.anchor.liveshow.liveroom.PublicLiveRoomActivity;
import com.qpidnetwork.anchor.liveshow.member.MemberProfileActivity;
import com.qpidnetwork.anchor.utils.DisplayUtil;
import com.qpidnetwork.anchor.utils.ImageUtil;
import com.qpidnetwork.anchor.utils.SystemUtils;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import java.lang.ref.WeakReference;

public class AudienceInfoDialog extends Dialog implements View.OnClickListener{

    private final String TAG = AudienceInfoDialog.class.getSimpleName();
    private WeakReference<BaseImplLiveRoomActivity> mActivity;

    private View rootView;
    private ImageView iv_close;
    private Button btn_invitePriLive;
    private CircleImageView civ_audiencePic;
    private ImageView iv_audienceCar;
    private ImageView iv_audienceLevel;
    private TextView tv_audienceNickname;
    private AudienceInfoItem audienceInfoItem;

    private boolean outSizeTouchHasChecked = false;

    /**
     * 设置是否显示私密按钮
     */
    private boolean mPrivateBtnShowFlags = true;

    public void setOutSizeTouchHasChecked(boolean outSizeTouchHasChecked){
        this.outSizeTouchHasChecked = outSizeTouchHasChecked;
    }

    public AudienceInfoDialog(BaseImplLiveRoomActivity context){
        super(context, R.style.CustomTheme_LiveAudienceDialog);
        this.mActivity = new WeakReference<BaseImplLiveRoomActivity>(context);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG,"onCreate");
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH);
        rootView = View.inflate(getContext(),R.layout.view_live_audience_dialog,null);
        setContentView(rootView);
        initView(rootView);
    }


    private void initView(View rootView){
        Log.d(TAG,"initView");
        iv_close = (ImageView) rootView.findViewById(R.id.iv_close);
        btn_invitePriLive = (Button) rootView.findViewById(R.id.btn_invitePriLive);
        iv_close.setOnClickListener(this);
        btn_invitePriLive.setOnClickListener(this);
        civ_audiencePic = (CircleImageView) rootView.findViewById(R.id.civ_audiencePic);
        civ_audiencePic.setOnClickListener(this);
        iv_audienceCar = (ImageView) rootView.findViewById(R.id.iv_audienceCar);
        iv_audienceLevel = (ImageView) rootView.findViewById(R.id.iv_audienceLevel);
        tv_audienceNickname = (TextView) rootView.findViewById(R.id.tv_audienceNickname);
    }

    public void show(AudienceInfoItem item) {
        Log.d(TAG,"show-item:"+item);
        super.show();
        this.audienceInfoItem = item;
        if(!TextUtils.isEmpty(item.photoUrl)){
            Picasso.with(getContext().getApplicationContext())
                    .load(item.photoUrl).noFade()
                    .placeholder(R.drawable.ic_default_photo_man)
                    .error(R.drawable.ic_default_photo_man)
                    .memoryPolicy(MemoryPolicy.NO_CACHE)
                    .into(civ_audiencePic);
        }
        if(!TextUtils.isEmpty(item.nickName)){
            tv_audienceNickname.setText(item.nickName);
        }
        if(!TextUtils.isEmpty(item.mountId) && !TextUtils.isEmpty(item.mountUrl)){
            iv_audienceCar.setVisibility(View.VISIBLE);
            String localCarPath = FileCacheManager.getInstance()
                    .parseCarImgLocalPath(item.mountId, item.mountUrl);
           Log.d(TAG,"show-localCarPath:"+localCarPath);
           if(SystemUtils.fileExists(localCarPath)){
               iv_audienceCar.setImageBitmap(ImageUtil.decodeSampledBitmapFromFile(
                       localCarPath, DisplayUtil.dip2px(getContext(),57f),
                       DisplayUtil.dip2px(getContext(),57f)));
           }else{
               FileDownloadManager.getInstance().start(item.mountUrl, localCarPath,null);
               Picasso.with(getContext().getApplicationContext())
                       .load(item.mountUrl).noFade()
                       .placeholder(R.drawable.ic_liveroom_car)
                       .error(R.drawable.ic_liveroom_car)
                       .memoryPolicy(MemoryPolicy.NO_CACHE)
                       .into(iv_audienceCar);
           }
        }else{
            iv_audienceCar.setVisibility(View.GONE);
        }
        if(mPrivateBtnShowFlags){
            btn_invitePriLive.setVisibility(View.VISIBLE);
        }else{
            btn_invitePriLive.setVisibility(View.INVISIBLE);
        }

        iv_audienceLevel.setImageDrawable(DisplayUtil.getLevelDrawableByResName(getContext(),item.level));
    }

    /**
     * 设置ONE-ON-ONE是否可视
     * @param isShowPrivateBtn
     */
    public void setInvitePriLiveBtnVisible(boolean isShowPrivateBtn){
        mPrivateBtnShowFlags = isShowPrivateBtn;
    }

    @Override
    protected void onStop() {
        super.onStop();
        Log.d(TAG,"dismiss");

    }

    @Override
    public void dismiss() {
        Log.d(TAG,"dismiss");
        super.dismiss();

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
            case R.id.civ_audiencePic: {
                //点击头像进入男士资料页面
                if(mActivity != null && audienceInfoItem != null){
                    Context context = mActivity.get();
                    context.startActivity(MemberProfileActivity.getMemberInfoIntent(context, "", audienceInfoItem.userId, false));
                }
            }break;
            case R.id.btn_invitePriLive:
                if(null != audienceInfoItem && !TextUtils.isEmpty(audienceInfoItem.userId)
                        && null != mActivity && null != mActivity.get()){
                    if(mActivity.get() instanceof PublicLiveRoomActivity){
                        PublicLiveRoomActivity publicActivity = (PublicLiveRoomActivity) mActivity.get();
                        publicActivity.sendPrivLiveInvite2Man(audienceInfoItem.userId,
                                audienceInfoItem.nickName,audienceInfoItem.photoUrl);
                    }
                }
                dismiss();
                break;
        }
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
