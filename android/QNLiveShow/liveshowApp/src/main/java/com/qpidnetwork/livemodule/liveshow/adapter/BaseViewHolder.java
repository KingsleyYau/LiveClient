package com.qpidnetwork.livemodule.liveshow.adapter;

import android.content.Context;
import android.support.annotation.IdRes;
import android.support.v7.widget.RecyclerView;
import android.view.View;

/**
 * Created by Hardy on 2018/9/19.
 */
public abstract class BaseViewHolder<T> extends RecyclerView.ViewHolder {

    public View convertView;
    public Context context;


    public BaseViewHolder(View itemView) {
        super(itemView);
        this.convertView = itemView;
        this.context = itemView.getContext();
        bindItemView(itemView);
    }

    protected final <E extends View> E f(@IdRes int id) {
        return (E) convertView.findViewById(id);
    }

    /**
     * 根据传入item的rootView，初始化item中的各个子控件
     *
     * @param itemView
     */
    public abstract void bindItemView(View itemView);


    /**
     * 根据传入对应的bean对象，进行 item 中的数据设置
     *
     * @param data
     * @param position
     */
    public abstract void setData(T data, int position);
}
