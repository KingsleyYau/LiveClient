package com.qpidnetwork.anchor.framework.base;

import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.annotation.DrawableRes;
import android.support.v4.widget.SwipeRefreshLayout;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;

/**
 * 基础加载fragment,主要处理错误页和无数据页
 * Created by Hunter on 17/9/28.
 */

public abstract class BaseLoadingFragment extends BaseFragment implements SwipeRefreshLayout.OnRefreshListener {

    protected FrameLayout fl_baseContainer;
    private FrameLayout flContent;
    private LinearLayout llErrorContainer;
    private LinearLayout llEmpty;
    private LinearLayout ll_emptyDesc;
    private LinearLayout ll_errorMsg;
    private ProgressBar pbLoading;

    //默认错误页
    private ImageView ivError;
    private TextView tvErrorMsg;
    private Button btnRetry;

    //默认无数据
    private ImageView ivNodata;
    private TextView tvEmptyDesc;
    private Button btnGuide;
    private SwipeRefreshLayout swipeRefreshLayoutEmpty;

    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState){
        TAG = BaseLoadingFragment.class.getSimpleName();
        View view = inflater.inflate(R.layout.live_base_loading_error_empty, null);
        initView(view);
        return view;
    }

    /**
     * 初始化
     * @param view
     */
    private void initView(View view){
        flContent = (FrameLayout)view.findViewById(R.id.flContent);
        fl_baseContainer = (FrameLayout)view.findViewById(R.id.fl_baseContainer);
        llErrorContainer = (LinearLayout)view.findViewById(R.id.llErrorContainer);
        llEmpty = (LinearLayout)view.findViewById(R.id.llEmpty);
        pbLoading = (ProgressBar)view.findViewById(R.id.pbLoading);

        //默认错误页
        ivError = (ImageView)view.findViewById(R.id.ivError);
        ll_errorMsg = (LinearLayout) view.findViewById(R.id.ll_errorMsg);
        tvErrorMsg = (TextView)view.findViewById(R.id.tvErrorMsg);
        btnRetry = (Button)view.findViewById(R.id.btnRetry);

        //默认无数据
        ivNodata = (ImageView)view.findViewById(R.id.ivNodata);
        ll_emptyDesc = (LinearLayout)view.findViewById(R.id.ll_emptyDesc);
        tvEmptyDesc = (TextView)view.findViewById(R.id.tvEmptyDesc);
        btnGuide = (Button)view.findViewById(R.id.btnGuide);
        swipeRefreshLayoutEmpty = (SwipeRefreshLayout)view.findViewById(R.id.swipeRefreshLayoutEmpty);
        swipeRefreshLayoutEmpty.setOnRefreshListener(this);

        btnRetry.setOnClickListener(this);
        btnGuide.setOnClickListener(this);

        tvErrorMsg.setText(R.string.tip_failed_to_load);

    }

    /**
     * 初始化显示内容区域
     * @param layourId
     */
    public void setCustomContent(int layourId){
        View view  = LayoutInflater.from(getActivity()).inflate(layourId, null);
        if(flContent != null){
            flContent.removeAllViews();
            flContent.addView(view);
        }
    }

    public void setCustomContent(View childView){
        if(flContent != null){
            flContent.removeAllViews();
            flContent.addView(childView);
        }
    }



    /**
     * 显示loading状态
     */
    public void showLoadingProcess(){
        if(pbLoading != null){
            pbLoading.setVisibility(View.VISIBLE);
        }
        hideErrorPage();
        hideNodataPage();
    }

    /**
     * 收起loading状态
     */
    public void hideLoadingProcess(){
        if(pbLoading != null){
            pbLoading.setVisibility(View.GONE);
        }

        //有可能是没数据界面操作刷新, 所以同时要隐藏它的Loading
        hideEmptyViewReloadProgress();
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int i = v.getId();
        if (i == R.id.btnRetry) {
            onDefaultErrorRetryClick();
        } else if (i == R.id.btnGuide) {
            onDefaultEmptyGuide();
        }
    }

    /**
     * 和showDefaultErrorPage配套适用，默认retry点击事件
     */
    protected void onDefaultErrorRetryClick(){
        if(llErrorContainer != null){
            llErrorContainer.setVisibility(View.GONE);
        }
    }

    /**
     * 默认无数据引导按钮
     */
    protected void onDefaultEmptyGuide(){
        if(llEmpty != null){
            llEmpty.setVisibility(View.GONE);
        }
    }

    /**
     * 显示错误页
     */
    public void showErrorPage(){
        if(llErrorContainer != null) {
            llErrorContainer.setVisibility(View.VISIBLE);
        }
    }

    /**
     * 隐藏无数据
     */
    public void hideErrorPage(){
        if(llErrorContainer != null) {
            llErrorContainer.setVisibility(View.GONE);
        }
    }

    /**
     * 显示无数据页
     */
    public void showNodataPage(){
        if(llEmpty != null) {
            llEmpty.setVisibility(View.VISIBLE);
            hideEmptyViewReloadProgress();
        }
    }

    /**
     * 隐藏无数据页
     */
    public void hideNodataPage(){
        if(llEmpty != null) {
            llEmpty.setVisibility(View.GONE);
            hideEmptyViewReloadProgress();
        }
    }

    /**
     * 设置默认无数据页样式中文字
     * @param message
     */
    public void setDefaultEmptyMessage(String message){
        if(tvEmptyDesc != null){
            tvEmptyDesc.setText(message);
        }
    }

    /**
     * 设置默认无数据页样式中文字
     * @param message
     */
    public void setDefaultEmptyMessage(String message  , @DrawableRes int drawableLeftId , int widthPx , int heightPx){
        if(tvEmptyDesc != null){
            tvEmptyDesc.setText(message);
            Drawable drawableLeft = mContext.getResources().getDrawable(drawableLeftId);
            // 这一步必须要做，否则不会显示。
            drawableLeft.setBounds(0,
                    0,
                    widthPx,
                    heightPx);// 设置图片宽高
            tvEmptyDesc.setCompoundDrawables(drawableLeft , null , null , null);
            tvEmptyDesc.setCompoundDrawablePadding(4);//设置图片和text之间的间距
        }
    }

    /**
     * 设置无数据引导按钮文字
     * @param guideText
     */
    public void setDefaultEmptyButtonText(String guideText){
        if(!TextUtils.isEmpty(guideText)){
            btnGuide.setVisibility(View.VISIBLE);
            btnGuide.setText(guideText);
        }else{
            btnGuide.setVisibility(View.GONE);
        }
    }

    /**
     * 设置默认无数据页图标
     * @param visible
     */
    public void setDefaultEmptyIconVisible(int visible){
        ivNodata.setVisibility(visible);
    }

    /**
     * 设置自定义错误页面
     * @param view
     */
    public void setCustomErrorView(View view){
        if(llErrorContainer != null) {
            llErrorContainer.removeAllViews();
            llErrorContainer.addView(view);
        }
    }

    /**
     * 自定义无数据页面样式及点击响应
     * @param view
     */
    public void setCustomEmptyView(View view){
        if(llEmpty != null) {
            llEmpty.removeAllViews();
            llEmpty.addView(view);
        }
    }

    /**
     * 没数据界面下拉刷新
     */
    @Override
    public void onRefresh() {
        onReloadDataInEmptyView();
    }

    /**
     * 隐藏没数据VIEW的下拉刷新Loading
     * showNodataPage(),hideNodataPage(),都会调用,不一定要重新调用一次
     */
    protected void hideEmptyViewReloadProgress(){
        swipeRefreshLayoutEmpty.setRefreshing(false);
    }

    public abstract void onReloadDataInEmptyView();
}
