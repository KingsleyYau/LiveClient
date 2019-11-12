package com.dou361.dialogui.holder;

import android.content.Context;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.dou361.dialogui.R;
import com.dou361.dialogui.bean.TieBean;
import com.dou361.dialogui.listener.OnItemClickListener;


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
 * 创建日期：2016/10/5
 * <p/>
 * 描 述：消息的item
 * <p/>
 * <p/>
 * 修订历史：
 * <p/>
 * ========================================
 */
public class TieItemHolder extends SuperItemHolder<TieBean> {


    LinearLayout llTie;
    TextView tvTitle;

    public TieItemHolder(Context mContext, OnItemClickListener listener, View itemView) {
        super(mContext, listener, itemView);
        tvTitle = (TextView) itemView.findViewById(R.id.tv_title);
        llTie = (LinearLayout) itemView.findViewById(R.id.ll_tie);
    }

    @Override
    public void refreshView() {
        /**
         * 1top 2midle 3bottom 4all
         */
//        if (itemPositionType == 1) {
//            llTie.setBackgroundResource(R.drawable.dialogui_selector_all_top);
//        } else if (itemPositionType == 3) {
//            llTie.setBackgroundResource(R.drawable.dialogui_selector_all_bottom);
//        } else if (itemPositionType == 4) {
//            llTie.setBackgroundResource(R.drawable.dialogui_selector_all);
//        } else {
//            llTie.setBackgroundResource(R.drawable.dialogui_selector_all_no);
//        }
        TieBean data = getData();
        tvTitle.setText("" + data.getTitle());
    }
}
