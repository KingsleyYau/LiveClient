package com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.util.UIUtils;
import com.qpidnetwork.qnbridgemodule.view.blur_500px.BlurringView;

/**
 * Created by Hardy on 2019/3/18.
 * Hangout 直播间，add credits 的弹窗
 */
public class HangoutAddCreditsDialog extends Dialog implements View.OnClickListener {

    private BlurringView mIvBg;
    private ImageView mIvClose;
    private CircleImageView mIvIcon;
    private ImageView mIvLevel;
    private TextView mTvName;
    private TextView mTvId;
    private TextView mTvCredits;
    private Button mBtnAdd;
    private View mBlurRootView;

    private Context mContext;

    public HangoutAddCreditsDialog(@NonNull Context context) {
        super(context, R.style.CustomTheme_LiveGiftDialog);

        this.mContext = context;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        View mRootView = View.inflate(mContext, R.layout.dialog_hang_out_add_credits, null);
        setContentView(mRootView);
        initView(mRootView);

        //设置 dialog 窗口宽高，在 setContentView 之后设置
        WindowManager.LayoutParams layoutParams = getWindow().getAttributes();
        layoutParams.gravity = Gravity.BOTTOM;
        layoutParams.width = DisplayUtil.getScreenWidth(mContext);
        getWindow().setAttributes(layoutParams);

        initBgHeight(mRootView);

        // 设置数据
        initData();
    }

    private void initView(View rootView) {
        mIvBg = rootView.findViewById(R.id.dialog_hang_out_add_credits_iv_bg);
        mIvClose = rootView.findViewById(R.id.dialog_hang_out_add_credits_iv_close);
        mIvIcon = rootView.findViewById(R.id.dialog_hang_out_add_credits_iv_icon);
        mIvLevel = rootView.findViewById(R.id.dialog_hang_out_add_credits_iv_level);
        mTvName = rootView.findViewById(R.id.dialog_hang_out_add_credits_tv_name);
        mTvId = rootView.findViewById(R.id.dialog_hang_out_add_credits_tv_id);
        mTvCredits = rootView.findViewById(R.id.dialog_hang_out_add_credits_tv_credits);
        mBtnAdd = rootView.findViewById(R.id.dialog_hang_out_add_credits_btn_add);

        mIvClose.setOnClickListener(this);
        mBtnAdd.setOnClickListener(this);
    }

    private void initData() {
        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        if (loginItem != null) {
            // 头像
            PicassoLoadUtil.loadUrl(mIvIcon, loginItem.photoUrl, R.drawable.ic_default_photo_man);
            // 等级
            mIvLevel.setImageDrawable(DisplayUtil.getLevelDrawableByResName(mContext, loginItem.level));
            // 名字
            mTvName.setText(loginItem.nickName);
            // ID
            mTvId.setText(mContext.getString(R.string.live_balance_userId, loginItem.userId));
            // credits
            updateUserCredits();
        }
    }

    private void initBgHeight(View rootView) {
        int[] wh = UIUtils.getViewWidthAndHeight(rootView);
        Log.i("info", "height: -----> " + wh[1]);

        FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) mIvBg.getLayoutParams();
        params.height = wh[1];
        mIvBg.setLayoutParams(params);
    }

    private void updateUserCredits() {
        String credits = ApplicationSettingUtil.formatCoinValue(LiveRoomCreditRebateManager.getInstance().getCredit());
        mTvCredits.setText(mContext.getString(R.string.live_Credits, credits));
    }


    @Override
    public void show() {
        // 防止在退出直播间时，继续操作发送礼物，导致窗口没关闭而内存泄漏
        if (!UIUtils.isActExist(mContext)) {
            return;
        }

        super.show();

        // 更新最新的信用点
        updateUserCredits();

        if (mIvBg != null && mBlurRootView != null) {
            mIvBg.setBlurredView(mBlurRootView);
            mIvBg.invalidate();
        }
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();

        if (id == R.id.dialog_hang_out_add_credits_iv_close) {
            dismiss();
        } else if (id == R.id.dialog_hang_out_add_credits_btn_add) {
            dismiss();
            gotoAddCredits();
        }
    }

    public void setBlurBgView(View view) {
        mBlurRootView = view;
    }

    public void gotoAddCredits(){
        //2019/3/18  打开买点页面
        //edit by Jagger 2018-9-21 使用URL方式跳转
        String urlAddCredit = URL2ActivityManager.createAddCreditUrl("", "B30", "");
        new AppUrlHandler(mContext).urlHandle(urlAddCredit);
    }
}
