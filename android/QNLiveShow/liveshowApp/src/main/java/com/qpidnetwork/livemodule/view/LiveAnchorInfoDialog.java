package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.UserInfoItem;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.utils.ButtonUtils;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder;
import com.qpidnetwork.qnbridgemodule.view.BaseSafeDialog;

public class LiveAnchorInfoDialog extends BaseSafeDialog implements View.OnClickListener {

    private View contentView;
    private CircleImageView civPhoto;
    private TextView tvAnchorName;
    private TextView tvAnchorId;
    private TextView tvAnchorDesc;
    private ImageView ivLeftFollow;

    private UserInfoItem mAnchorInfo;
    private boolean mIsFollow = false;
    private String mRoomId = "";


    public LiveAnchorInfoDialog(Context context) {
        super(context, R.style.themeDialog);
        // TODO Auto-generated constructor stub
        init(context);
    }

    private void init(Context context){
        contentView  = LayoutInflater.from(context).inflate(R.layout.dialog_anchor_info, null);
        civPhoto = (CircleImageView)contentView.findViewById(R.id.civPhoto);
        tvAnchorName = (TextView)contentView.findViewById(R.id.tvAnchorName);
        tvAnchorId = (TextView)contentView.findViewById(R.id.tvAnchorId);
        tvAnchorDesc = (TextView)contentView.findViewById(R.id.tvAnchorDesc);
        ivLeftFollow = (ImageView)contentView.findViewById(R.id.ivLeftFollow);

        //add click listener
        contentView.findViewById(R.id.ivClose).setOnClickListener(this);
        contentView.findViewById(R.id.ivChat).setOnClickListener(this);
        contentView.findViewById(R.id.ivMail).setOnClickListener(this);
        contentView.findViewById(R.id.llAnchorProfile).setOnClickListener(this);
        ivLeftFollow.setOnClickListener(this);

        //刷新数据显示
        refreshViews();
        this.setContentView(contentView);
    }

    /**
     * 设置显示数据
     * @param anchorInfo
     */
    public void setDialogData(UserInfoItem anchorInfo, boolean isFollow, String roomId){
        mAnchorInfo = anchorInfo;
        mIsFollow = isFollow;
        mRoomId = roomId;
        refreshViews();
    }

    /**
     * 刷新用户信息
     * @param anchorInfo
     */
    public void refreshData(UserInfoItem anchorInfo){
        mAnchorInfo = anchorInfo;
        refreshViews();
    }

    /**
     * 刷新信息显示
     */
    private void refreshViews(){
        if(mAnchorInfo != null && contentView != null){
            if(!TextUtils.isEmpty(mAnchorInfo.photoUrl)){
                PicassoLoadUtil.loadUrlNoMCache(civPhoto, mAnchorInfo.photoUrl, R.drawable.ic_default_photo_woman);
            }
            tvAnchorName.setText(mAnchorInfo.nickName);
            tvAnchorId.setText(String.format(getContext().getResources().getString(R.string.live_balance_userId), mAnchorInfo.userId));
            if(mAnchorInfo.anchorInfo != null){
                tvAnchorDesc.setText(mAnchorInfo.anchorInfo.introduction);
            }
            if(mIsFollow){
                ivLeftFollow.setBackgroundResource(R.drawable.ic_liveroom_profile_follow);
            }else{
                ivLeftFollow.setBackgroundResource(R.drawable.ic_liveroom_profile_unfollow);
            }
        }
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if (i == R.id.ivChat) {
            //跳转打开chat页面
            if(!ButtonUtils.isFastDoubleClick(v.getId())) {
                if(mAnchorInfo != null) {
                    String chatUrl = LiveUrlBuilder.createLiveChatActivityUrl(mAnchorInfo.userId, mAnchorInfo.nickName, mAnchorInfo.photoUrl);
                    new AppUrlHandler(getContext()).urlHandle(chatUrl);
                }
            }
        }else if(i == R.id.ivMail){
            //跳转打开写信页面
            if(!ButtonUtils.isFastDoubleClick(v.getId())) {
                if(mAnchorInfo != null) {
                    String sendMailUrl = LiveUrlBuilder.createSendMailActivityUrl(mAnchorInfo.userId);
                    new AppUrlHandler(getContext()).urlHandle(sendMailUrl);
                }
            }
        }else if(i == R.id.ivLeftFollow){
            //通知外部follow/unfollow
            if(!ButtonUtils.isFastDoubleClick(v.getId())) {
                onFollowClick();
            }
        }else if(i == R.id.llAnchorProfile){
            //打开资料页
            if(!ButtonUtils.isFastDoubleClick(v.getId())) {
                AnchorProfileActivity.launchAnchorInfoActivty(getContext(), getContext().getResources().getString(R.string.live_webview_anchor_profile_title),
                        mAnchorInfo.userId, false, AnchorProfileActivity.TagType.Album);
            }
        }else if(i == R.id.ivClose){
            dismiss();
        }
    }

    private void onFollowClick(){
        if(mAnchorInfo != null) {
            LiveRequestOperator.getInstance().AddOrCancelFavorite(mAnchorInfo.userId, mRoomId, !mIsFollow, new OnRequestCallback() {
                @Override
                public void onRequest(boolean isSuccess, int errCode, String errMsg) {

                }
            });
            mIsFollow = !mIsFollow;
            if (mIsFollow) {
                ivLeftFollow.setBackgroundResource(R.drawable.ic_liveroom_profile_follow);
            } else {
                ivLeftFollow.setBackgroundResource(R.drawable.ic_liveroom_profile_unfollow);
            }
        }
    }

    @Override
    public void show() {
        super.show();
        /**
         * 设置宽度全屏，要设置在show的后面
         */
        WindowManager.LayoutParams layoutParams = getWindow().getAttributes();
        layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;
        layoutParams.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        getWindow().getDecorView().setPadding(0, 0, 0, 0);
        getWindow().setAttributes(layoutParams);
    }
}
