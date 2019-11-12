package com.dou361.dialogui.holder;

import android.content.Context;
import android.support.v7.widget.DefaultItemAnimator;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutCompat;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.dou361.dialogui.DialogUIUtils;
import com.dou361.dialogui.R;
import com.dou361.dialogui.adapter.TieAdapter;
import com.dou361.dialogui.bean.BuildBean;
import com.dou361.dialogui.listener.OnItemClickListener;
import com.dou361.dialogui.widget.DialogUIDividerItemDecoration;

/**
 * ========================================
 * <p/>
 * 版 权：dou361.com 版权所有 （C） 2015
 * <p/>
 * 作 者：陈冠明
 * <p/>
 * 个人网站：http://www.dou361.com
 * <p/>
 * 版 本：1.0
 * <p/>
 * 创建日期：2016/11/25 16:54
 * <p/>
 * 描 述：列表holder
 * <p/>
 * <p/>
 * 修订历史：
 * <p/>
 * ========================================
 */
public class SheetHolder extends SuperHolder {

    private TextView tvTitle;
    private RecyclerView rView;
    private Button btnBottom;
    private boolean isItemType;
    private LinearLayout mllTitle , mllBg;

    public SheetHolder(Context context, boolean isItemType) {
        super(context);
        this.isItemType = isItemType;
    }

    @Override
    protected void findViews() {
        mllBg = (LinearLayout)rootView.findViewById(R.id.dialogui_ll_bg);
        mllTitle = (LinearLayout)rootView.findViewById(R.id.dialogui_ll_title);
        tvTitle = (TextView) rootView.findViewById(R.id.dialogui_tv_title);
        rView = (RecyclerView) rootView.findViewById(R.id.rlv);
        btnBottom = (Button) rootView.findViewById(R.id.btn_bottom);

    }

    @Override
    protected int setLayoutRes() {
        return R.layout.dialogui_holder_sheet;
    }

    @Override
    public void assingDatasAndEvents(final Context context, final BuildBean bean) {
        mllBg.setGravity(bean.gravity);
        if(bean.gravity == Gravity.BOTTOM){
            mllBg.getLayoutParams().height = LinearLayoutCompat.LayoutParams.WRAP_CONTENT;
        }

        if (TextUtils.isEmpty(bean.bottomTxt)) {
            btnBottom.setVisibility(View.GONE);
        } else {
            btnBottom.setVisibility(View.VISIBLE);
            btnBottom.setText(bean.bottomTxt);
            btnBottom.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    DialogUIUtils.dismiss(bean.dialog, bean.alertDialog);
                    bean.itemListener.onBottomBtnClick();

                }
            });
        }

        if (TextUtils.isEmpty(bean.title)) {
            mllTitle.setVisibility(View.GONE);
        } else {
            mllTitle.setVisibility(View.VISIBLE);
            tvTitle.setText(bean.title);
        }

        if (bean.isVertical) {
            rView.setLayoutManager(new LinearLayoutManager(bean.mContext));
            rView.addItemDecoration(new DialogUIDividerItemDecoration(bean.mContext));
        } else {
            rView.setLayoutManager(new GridLayoutManager(bean.mContext, bean.gridColumns));// 布局管理器。
        }
        rView.setHasFixedSize(true);// 如果Item够简单，高度是确定的，打开FixSize将提高性能。
        rView.setItemAnimator(new DefaultItemAnimator());// 设置Item默认动画，加也行，不加也行。
        if (bean.mAdapter == null) {
            TieAdapter adapter = new TieAdapter(bean.mContext, bean.mLists, isItemType);
            bean.mAdapter = adapter;
        }
        rView.setAdapter(bean.mAdapter);
        bean.mAdapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onItemClick(int position) {
                DialogUIUtils.dismiss(bean.dialog, bean.alertDialog);
                bean.itemListener.onItemClick(bean.mLists.get(position).getTitle(), position);
            }
        });
    }


}
