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
import android.widget.Button;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
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
    private Button btn_gotoRecharge;
    private int manLevel = 0;
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
        btn_gotoRecharge = (Button) rootView.findViewById(R.id.btn_gotoRecharge);
        btn_gotoRecharge.setOnClickListener(this);
    }

    private void updateViewData() {
        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        if (null != loginItem) {
            tv_userNickName.setText(loginItem.nickName);
            String userId = context.getResources().getString(R.string.live_balance_userId, loginItem.userId);
            Log.d(TAG,"updateViewData-nickName:"+loginItem.nickName+" userId:"+userId);
            tv_userId.setText(userId);
            if (!TextUtils.isEmpty(loginItem.photoUrl)) {
                Picasso.with(context).load(loginItem.photoUrl)
                        .placeholder(R.drawable.ic_default_photo_man)
                        .error(R.drawable.ic_default_photo_man)
                        .fit().
                        into(civ_userIcon);
            }
        }
        iv_userLevel.setImageDrawable(DisplayUtil.getLevelDrawableByResName(context,manLevel));
        String userBalance =context.getResources().getString(R.string.live_balance_credits,
                String.valueOf(LiveRoomCreditRebateManager.getInstance().getCredit()));
        SpannableString spannableString = new SpannableString(userBalance);
        ForegroundColorSpan foregroundColorSpan1 = new ForegroundColorSpan(
                context.getResources().getColor(R.color.custom_dialog_txt_color_simple));
        int index = userBalance.indexOf(":");
        spannableString.setSpan(foregroundColorSpan1,0,index, Spannable.SPAN_INCLUSIVE_INCLUSIVE);
        ForegroundColorSpan foregroundColorSpan2 = new ForegroundColorSpan(Color.parseColor("#ffd205"));
        spannableString.setSpan(foregroundColorSpan2,index,userBalance.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        tv_userBalance.setText(spannableString);
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if (i == R.id.iv_backBalanceDialog) {
            dismiss();

        } else if (i == R.id.btn_gotoRecharge) {
            Toast.makeText(context, "跳转到充值界面", Toast.LENGTH_SHORT).show();

        } else {
        }
    }

    @Override
    public void showAtLocation(View parent, int gravity, int x, int y) {
        super.showAtLocation(parent, gravity, x, y);
        updateViewData();
    }

    public void setUserLevel(int manLevel) {
        Log.d(TAG, "setUserLevel");
        this.manLevel = manLevel;
    }
}
