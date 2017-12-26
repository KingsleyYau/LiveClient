package com.qpidnetwork.livemodule.liveshow.liveroom.talent;

import android.app.Activity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.RecycleViewDivider;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;
import com.qpidnetwork.livemodule.utils.DisplayUtil;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * 才艺列表PopupWindow
 * Created by Jagger on 2017/9/20.
 */

public class TalentsPopupWindow extends PopupWindow implements View.OnClickListener{
    private WeakReference<Activity> mActivity;
    private final String TAG = TalentsPopupWindow.class.getSimpleName();
    private TalentsAdapter mAdapter;
    private List<TalentInfoItem> mDatas = new ArrayList<>();
    private onBtnClickedListener mOnBtnClickedListener;
    private View rootView;
    private ImageView iv_closeTalentPw;
    private RecyclerView rv_talentList;
    private View ll_loading;
    private View ll_errorRetry;
    private View ll_emptyData;
    private TextView tv_reloadTalentList;

    @Override
    public void onClick(View v) {
        int viewId = v.getId();
        if(viewId == R.id.iv_closeTalentPw){
            dismiss();
        }else if(viewId == R.id.tv_reloadTalentList){
            if(null != mOnBtnClickedListener){
                mOnBtnClickedListener.onReloadClicked();
            }
        }
    }

    /**
     * 操作回调
     */
    public interface onBtnClickedListener{
        void onRequestClicked(TalentInfoItem talent);
        void onReloadClicked();
    }

    public TalentsPopupWindow(Activity activity){
        super();
        Log.d(TAG, "TalentsPopupWindow");
        mActivity = new WeakReference<Activity>(activity);
        rootView = View.inflate(activity,R.layout.view_live_popupwindow_talents_list, null);
        setContentView(rootView);
        initView();
        initPopupWindow();
    }

    private void initView(){
        iv_closeTalentPw = (ImageView) rootView.findViewById(R.id.iv_closeTalentPw);
        iv_closeTalentPw.setOnClickListener(this);
        rv_talentList = (RecyclerView) rootView.findViewById(R.id.rv_talentList);
        //创建默认的线性LayoutManager
        LinearLayoutManager layoutManager = new LinearLayoutManager(mActivity.get());
        rv_talentList.setLayoutManager(layoutManager);
        //设置分割线
        rv_talentList.addItemDecoration(new RecycleViewDivider(mActivity.get(), LinearLayoutManager.VERTICAL, R.drawable.live_divider_talent_list));
        //如果可以确定每个item的高度是固定的，设置这个选项可以提高性能
        rv_talentList.setHasFixedSize(true);
        //创建并设置Adapter
        mAdapter = new TalentsAdapter(mDatas);
        mAdapter.setOnRequestClickedListener(new TalentsAdapter.onRequestClickedListener() {
            @Override
            public void onRequestClicked(TalentInfoItem talent) {
                if(mOnBtnClickedListener != null){
                    mOnBtnClickedListener.onRequestClicked(talent);
                }
            }
        });
        rv_talentList.setAdapter(mAdapter);
        rv_talentList.setVisibility(View.GONE);
        ll_loading = rootView.findViewById(R.id.ll_loading);
        ll_loading.setVisibility(View.GONE);
        ll_errorRetry = rootView.findViewById(R.id.ll_errorRetry);
        ll_errorRetry.setVisibility(View.GONE);
        tv_reloadTalentList = (TextView) rootView.findViewById(R.id.tv_reloadTalentList);
        tv_reloadTalentList.setOnClickListener(this);
        ll_emptyData = rootView.findViewById(R.id.ll_emptyData);
        ll_emptyData.setVisibility(View.GONE);
    }

    private void initPopupWindow() {
        // 设置SelectPicPopupWindow弹出窗体的宽高
        this.setWidth(ViewGroup.LayoutParams.MATCH_PARENT);
        this.setHeight(ViewGroup.LayoutParams.WRAP_CONTENT);
        // 设置SelectPicPopupWindow弹出窗体可点击
        this.setFocusable(true);
        setOutsideTouchable(true);
        // 设置弹出窗体动画效果
        this.setAnimationStyle(android.R.style.Animation_Dialog);
        // mMenuView添加OnTouchListener监听判断获取触屏位置如果在选择框外面则销毁弹出框
        rootView.setOnTouchListener(new View.OnTouchListener() {
            public boolean onTouch(View v, MotionEvent event) {
                int top = rootView.findViewById(R.id.ll_talents).getTop();
                int y = (int) event.getY();
                if (event.getAction() == MotionEvent.ACTION_UP) {
                    if (y < top) {
                        dismiss();
                    }
                }
                return true;
            }
        });
    }

    public void setData(TalentInfoItem[] datas){
        if(null != datas){
            mDatas.clear();
            mDatas.addAll(Arrays.asList(datas));
            mAdapter.notifyDataSetChanged();
        }
    }

    public void refreshDataStatusView(boolean isLoading,boolean isErrRetry,boolean isEmpty){
        Log.d(TAG,"refreshDataStatusView-isLoading:"+isLoading+" isErrRetry:"+isErrRetry+" isEmpty:"+isEmpty);
        ll_errorRetry.setVisibility(isErrRetry ? View.VISIBLE : View.GONE);
        ll_emptyData.setVisibility(isEmpty ? View.VISIBLE : View.GONE);
        ll_loading.setVisibility(isLoading ? View.VISIBLE : View.GONE);
        if(isEmpty || isErrRetry || isEmpty){
            rv_talentList.setVisibility(View.GONE);
        }else{
            rv_talentList.setVisibility(View.VISIBLE);
        }
    }

    public void setOnBtnClickedListener(onBtnClickedListener l){
        mOnBtnClickedListener = l;
    }

    public void refreshData(TalentInfoItem[] datas){
        //转为列表，方便数据刷新
        if(datas != null){
            mDatas.clear();
            mDatas.addAll(Arrays.asList(datas));
        }
        mAdapter.notifyDataSetChanged();
    }

    /**
     * 计算出来的位置，y方向就在anchorView的上面和下面对齐显示，x方向就是与屏幕右边对齐显示
     * 如果anchorView的位置有变化，就可以适当自己额外加入偏移来修正
     * @param anchorView  呼出window的view
     * @param contentView   window的内容布局
     * @return window显示的左上角的xOff,yOff坐标
     */
    private static int[] calculatePopWindowPos(final View anchorView, final View contentView) {
        final int windowPos[] = new int[2];
        final int anchorLoc[] = new int[2];

        // 获取锚点View在屏幕上的左上角坐标位置
        anchorView.getLocationOnScreen(anchorLoc);
        final int anchorHeight = anchorView.getHeight();
        // 获取屏幕的高宽
        final int screenHeight = DisplayUtil.getScreenHeight(anchorView.getContext());
        final int screenWidth = DisplayUtil.getScreenWidth(anchorView.getContext());
        contentView.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
        // 计算contentView的高宽
        final int windowHeight = contentView.getMeasuredHeight();
        final int windowWidth = contentView.getMeasuredWidth();

        // 判断需要向上弹出还是向下弹出显示
        final boolean isNeedShowUp = (screenHeight - anchorLoc[1] - anchorHeight < windowHeight);
        if (isNeedShowUp) {
            windowPos[0] = screenWidth - windowWidth;
            windowPos[1] = anchorLoc[1] - windowHeight;
        } else {
            windowPos[0] = screenWidth - windowWidth;
            windowPos[1] = anchorLoc[1] + anchorHeight;
        }

        return windowPos;
    }
}
