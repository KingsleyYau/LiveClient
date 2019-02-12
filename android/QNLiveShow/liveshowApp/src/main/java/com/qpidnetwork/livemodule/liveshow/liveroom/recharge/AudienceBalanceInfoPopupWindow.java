package com.qpidnetwork.livemodule.liveshow.liveroom.recharge;

import android.content.Context;
import android.graphics.Color;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import com.qpidnetwork.qnbridgemodule.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.im.IMManager;
import com.qpidnetwork.livemodule.im.listener.IMUserBaseInfoItem;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.squareup.picasso.Picasso;


public class AudienceBalanceInfoPopupWindow extends PopupWindow implements View.OnClickListener {

    private final String TAG = AudienceBalanceInfoPopupWindow.class.getSimpleName();
    private Context mContext;
    private ImageView iv_backBalanceDialog;
    private CircleImageView civ_userIcon;
    private TextView tv_userNickName;
    private TextView tv_userId;
    private TextView tv_userBalance;
    private ImageView iv_userLevel;
    private TextView tv_gotoRecharge;
    private View rootView;

    public AudienceBalanceInfoPopupWindow(Context context) {
        super();
        Log.d(TAG, "SimpleListPopupWindow");
        this.mContext = context;
        this.rootView = View.inflate(context, R.layout.view_user_balance, null);
        initView();
        setContentView(rootView);
        initPopupWindow();
    }

    private void initPopupWindow() {
        // 设置SelectPicPopupWindow弹出窗体的宽
        this.setWidth(ViewGroup.LayoutParams.FILL_PARENT);
        // 设置SelectPicPopupWindow弹出窗体的高
        this.setHeight(ViewGroup.LayoutParams.WRAP_CONTENT);
        // 设置SelectPicPopupWindow弹出窗体可点击
        this.setFocusable(true);
        // 设置弹出窗体动画效果
        this.setAnimationStyle(R.style.CustomTheme_SimpleDialog_Anim);
        // 实例化一个ColorDrawable颜色为半透明
//        ColorDrawable dw = new ColorDrawable(0x30000000);
        // 设置SelectPicPopupWindow弹出窗体的背景
//        this.setBackgroundDrawable(dw);
        // mMenuView添加OnTouchListener监听判断获取触屏位置如果在选择框外面则销毁弹出框
        rootView.setOnTouchListener(new View.OnTouchListener() {
            public boolean onTouch(View v, MotionEvent event) {
                int height = rootView.findViewById(R.id.fl_userBalanceInfo).getTop();
                int y = (int) event.getY();
                if (event.getAction() == MotionEvent.ACTION_UP) {
                    if (y < height) {
                        dismiss();
                    }
                }
                return true;
            }
        });
    }

    private void initView() {
        Log.d(TAG, "initView");
        iv_backBalanceDialog = (ImageView) rootView.findViewById(R.id.iv_backBalanceDialog);
        iv_backBalanceDialog.setOnClickListener(this);
        civ_userIcon = (CircleImageView) rootView.findViewById(R.id.civ_userIcon);
        tv_userNickName = (TextView) rootView.findViewById(R.id.tv_userNickName);
        tv_userId = (TextView) rootView.findViewById(R.id.tv_userId);
        tv_userBalance = (TextView) rootView.findViewById(R.id.tv_userBalance);
        iv_userLevel = (ImageView) rootView.findViewById(R.id.iv_userLevel);
        tv_gotoRecharge = (TextView) rootView.findViewById(R.id.tv_gotoRecharge);
        tv_gotoRecharge.setOnClickListener(this);
    }

    public void updateBalanceViewData(){
        if(null != mContext){
            String userBalance = mContext.getResources().getString(R.string.live_balance_credits,
                    ApplicationSettingUtil.formatCoinValue(LiveRoomCreditRebateManager.getInstance().getCredit()));
            SpannableString spannableString = new SpannableString(userBalance);
            ForegroundColorSpan foregroundColorSpan1 = new ForegroundColorSpan(
                    mContext.getResources().getColor(R.color.custom_dialog_txt_color_simple));
            int index = userBalance.indexOf(":");
            if(index >= 0) {
                spannableString.setSpan(foregroundColorSpan1, 0, index, Spannable.SPAN_INCLUSIVE_INCLUSIVE);
                ForegroundColorSpan foregroundColorSpan2 = new ForegroundColorSpan(Color.parseColor("#ffd205"));
                spannableString.setSpan(foregroundColorSpan2, index+1, userBalance.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
                if (tv_userBalance != null) {
                    tv_userBalance.setText(spannableString);
                }
            }
        }
    }

    private void updateViewData() {
        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        if (null != loginItem) {
            IMUserBaseInfoItem imUserBaseInfoItem = IMManager.getInstance().getUserInfo(loginItem.userId);
            if(null != imUserBaseInfoItem){
                //昵称从缓存获取
                if(!TextUtils.isEmpty(imUserBaseInfoItem.nickName)){
                    tv_userNickName.setText(imUserBaseInfoItem.nickName);
                }
                //头像从缓存获取
                if (!TextUtils.isEmpty(imUserBaseInfoItem.photoUrl)) {
//                    Picasso.with(mContext)
                    Picasso.get()
                            .load(imUserBaseInfoItem.photoUrl)
                            .placeholder(R.drawable.ic_default_photo_man)
                            .error(R.drawable.ic_default_photo_man)
                            .fit()
                            .into(civ_userIcon);

                }
            }
            // level使用外部的直播间外部(loginItem)的数据
            iv_userLevel.setImageDrawable(DisplayUtil.getLevelDrawableByResName(mContext,loginItem.level));
            //userId
            String userId = mContext.getResources().getString(R.string.live_balance_userId, loginItem.userId);
            Log.d(TAG,"updateViewData-nickName:"+loginItem.nickName+" userId:"+userId);
            tv_userId.setText(userId);

        }
        //金币余额-userBalance
        String userBalance = mContext.getResources().getString(R.string.live_balance_credits,
                ApplicationSettingUtil.formatCoinValue(LiveRoomCreditRebateManager.getInstance().getCredit()));
        SpannableString spannableString = new SpannableString(userBalance);
        ForegroundColorSpan foregroundColorSpan1 = new ForegroundColorSpan(
                mContext.getResources().getColor(R.color.custom_dialog_txt_color_simple));
        int index = userBalance.indexOf(":");
        if(index >= 0) {
            spannableString.setSpan(foregroundColorSpan1, 0, index, Spannable.SPAN_INCLUSIVE_INCLUSIVE);
            ForegroundColorSpan foregroundColorSpan2 = new ForegroundColorSpan(Color.parseColor("#ffd205"));
            spannableString.setSpan(foregroundColorSpan2, index + 1, userBalance.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
            tv_userBalance.setText(spannableString);
        }
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if (i == R.id.iv_backBalanceDialog) {
            dismiss();

        } else if (i == R.id.tv_gotoRecharge) {
            LiveModule.getInstance().onAddCreditClick(mContext, new NoMoneyParamsBean());

            //GA统计点击充值
            AnalyticsManager.getsInstance().ReportEvent(mContext.getResources().getString(R.string.Live_Global_Category),
                    mContext.getResources().getString(R.string.Live_Global_Action_AddCredit),
                    mContext.getResources().getString(R.string.Live_Global_Label_AddCredit));
        } else {
        }
    }

    @Override
    public void showAtLocation(View parent, int gravity, int x, int y) {
        super.showAtLocation(parent, gravity, x, y);
        updateViewData();
    }
}
