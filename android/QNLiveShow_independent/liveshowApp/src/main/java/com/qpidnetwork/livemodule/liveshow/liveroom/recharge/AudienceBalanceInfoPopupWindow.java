package com.qpidnetwork.livemodule.liveshow.liveroom.recharge;

import android.content.Context;
import android.graphics.Color;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextUtils;
import android.text.style.ForegroundColorSpan;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.squareup.picasso.Picasso;


public class AudienceBalanceInfoPopupWindow extends PopupWindow implements View.OnClickListener {

    private final String TAG = AudienceBalanceInfoPopupWindow.class.getSimpleName();
    private Context context;
    private ImageView iv_backBalanceDialog;
    private CircleImageView civ_userIcon;
    private TextView tv_userNickName;
    private TextView tv_userId;
    private TextView tv_userBalance;
    private ImageView iv_userLevel;
    private TextView tv_gotoRecharge;
    private String userId = "";
    private int manLevel = 0;
    private String nickName=null;
    private String photoUrl = null;
    private View rootView;

    public AudienceBalanceInfoPopupWindow(Context context) {
        super();
        Log.d(TAG, "SimpleListPopupWindow");
        this.context = context;
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
        if(null != context){
            String userBalance =context.getResources().getString(R.string.live_balance_credits,
                    ApplicationSettingUtil.formatCoinValue(LiveRoomCreditRebateManager.getInstance().getCredit()));
            SpannableString spannableString = new SpannableString(userBalance);
            ForegroundColorSpan foregroundColorSpan1 = new ForegroundColorSpan(
                    context.getResources().getColor(R.color.custom_dialog_txt_color_simple));
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
       if(!TextUtils.isEmpty(userId)){
           tv_userId.setText(context.getResources().getString(R.string.live_balance_userId, userId));
       }

        //昵称/头像/等级就外部传递进来，跟接口同步
        if(!TextUtils.isEmpty(nickName)){
            tv_userNickName.setText(nickName);
        }

        if (!TextUtils.isEmpty(photoUrl)) {
            Picasso.with(context).load(photoUrl)
                    .placeholder(R.drawable.ic_default_photo_man)
                    .error(R.drawable.ic_default_photo_man)
                    .fit().
                    into(civ_userIcon);
        }
        //等级在baseactivity的creditsUpdate和show方法里面更i性能
        iv_userLevel.setImageDrawable(DisplayUtil.getLevelDrawableByResName(context,manLevel));

        //userBalance就拿manager里面的实时数据即可
        String userBalance =context.getResources().getString(R.string.live_balance_credits,
                ApplicationSettingUtil.formatCoinValue(LiveRoomCreditRebateManager.getInstance().getCredit()));
        SpannableString spannableString = new SpannableString(userBalance);
        ForegroundColorSpan foregroundColorSpan1 = new ForegroundColorSpan(
                context.getResources().getColor(R.color.custom_dialog_txt_color_simple));
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
            LiveService.getInstance().onAddCreditClick(context);

            //GA统计点击充值
            AnalyticsManager.getsInstance().ReportEvent(context.getResources().getString(R.string.Live_Global_Category),
                    context.getResources().getString(R.string.Live_Global_Action_AddCredit),
                    context.getResources().getString(R.string.Live_Global_Label_AddCredit));
        } else {
        }
    }

    @Override
    public void showAtLocation(View parent, int gravity, int x, int y) {
        super.showAtLocation(parent, gravity, x, y);
        updateViewData();
    }

    public void setUserLevel(int manLevel) {
        Log.d(TAG, "setUserLevel-manLevel:"+manLevel);
        this.manLevel = manLevel;
    }

    public void setNickName(String nickName){
        Log.d(TAG, "setNickName-nickName:"+nickName);
        this.nickName = nickName;
    }

    public void setPhotoUrl(String photoUrl){
        Log.d(TAG, "setPhotoUrl-photoUrl:"+photoUrl);
        this.photoUrl = photoUrl;
    }

    public void setUserId(String userId){
        Log.d(TAG, "setUserId-userId:"+userId);
        this.userId = userId;
    }
}
