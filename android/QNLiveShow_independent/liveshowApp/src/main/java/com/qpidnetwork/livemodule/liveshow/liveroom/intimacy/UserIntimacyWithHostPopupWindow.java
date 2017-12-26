package com.qpidnetwork.livemodule.liveshow.liveroom.intimacy;

import android.app.Activity;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.liveroom.RoomThemeManager;

import java.lang.ref.WeakReference;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/10/12.
 */

public class UserIntimacyWithHostPopupWindow extends PopupWindow {

    private final String TAG = UserIntimacyWithHostPopupWindow.class.getSimpleName();
    private WeakReference<Activity> mActivity;
    private View rootView;
    private ImageView iv_closeIntimacyPw;
    private View ll_loadFailed;
    private View ll_intimacyData;
    private View ll_loadintimacy;
    private TextView tv_currLoveLevelScale;
    private TextView tv_currLevel;
    private TextView tv_nextLevel;
    private TextView tv_intimacyWithWho;
    private ImageView iv_intimacy;

    private RoomThemeManager roomThemeManager = new RoomThemeManager();

    public UserIntimacyWithHostPopupWindow(Activity context) {
        super();
        Log.d(TAG, "RoomRebateTipsPopupWindow");
        this.mActivity = new WeakReference<Activity>(context);
        this.rootView = View.inflate(context, R.layout.view_user_intimacy_with_host, null);
        setContentView(rootView);
        initView();
        initPopupWindow();
    }

    private void initPopupWindow() {
        Log.d(TAG,"initPopupWindow");
        // 设置SelectPicPopupWindow弹出窗体的宽高
        this.setWidth(ViewGroup.LayoutParams.MATCH_PARENT);
        this.setHeight(ViewGroup.LayoutParams.WRAP_CONTENT);
        // 设置SelectPicPopupWindow弹出窗体可点击
        this.setFocusable(true);
        // 设置弹出窗体动画效果
        this.setAnimationStyle(android.R.style.Animation_Dialog);
    }

    private void initView() {
        Log.d(TAG, "initView");
        iv_closeIntimacyPw = (ImageView) rootView.findViewById(R.id.iv_closeIntimacyPw);
        ll_loadFailed = rootView.findViewById(R.id.ll_loadFailed);
        ll_intimacyData = rootView.findViewById(R.id.ll_intimacyData);
        ll_loadintimacy = rootView.findViewById(R.id.ll_loadintimacy);
        ll_intimacyData.setVisibility(View.VISIBLE);
        ll_loadintimacy.setVisibility(View.GONE);
        ll_loadFailed.setVisibility(View.GONE);
        tv_currLoveLevelScale = (TextView) rootView.findViewById(R.id.tv_currLoveLevelScale);
        tv_currLevel = (TextView) rootView.findViewById(R.id.tv_currLevel);
        tv_nextLevel = (TextView) rootView.findViewById(R.id.tv_nextLevel);
        tv_intimacyWithWho = (TextView) rootView.findViewById(R.id.tv_intimacyWithWho);
        iv_intimacy = (ImageView) rootView.findViewById(R.id.iv_intimacy);
    }

    public void updateViewData(String hostNickName, int loveLevel){
        Log.d(TAG,"updateViewData-hostNickName:"+hostNickName+" loveLevel:"+loveLevel);
        tv_intimacyWithWho.setText(mActivity.get().getResources().getString(R.string.live_intimacy_title,hostNickName));
        iv_intimacy.setImageDrawable(roomThemeManager.getPrivateRoomLoveLevelDrawable(mActivity.get(),loveLevel));
        tv_currLevel.setText(mActivity.get().getResources().getString(R.string.live_intimacy_whatlevel,String.valueOf(loveLevel)));
        tv_nextLevel.setText(mActivity.get().getResources().getString(R.string.live_intimacy_whatlevel,String.valueOf(loveLevel+1)));
        tv_currLoveLevelScale.setText(mActivity.get().getResources().getString(R.string.live_intimacy_levelscale,String.valueOf(loveLevel),String.valueOf(100)));
    }
}
