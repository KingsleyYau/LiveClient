package com.qpidnetwork.livemodule.framework.canadapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Copyright 2016 canyinghao
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
public abstract class CanRVAdapter<T> extends RecyclerView.Adapter<CanRViewHolder> {

    protected int mItemLayoutId;
    protected Context mContext;
    protected List<T> mList;
    protected CanOnItemListener mOnItemListener;

    protected RecyclerView mRecyclerView;
    //    item项等分个数
    protected int ratio;


    public CanRVAdapter(RecyclerView mRecyclerView) {
        super();
        this.mContext = mRecyclerView.getContext();
        this.mRecyclerView = mRecyclerView;
        this.mList = new ArrayList<>();


    }


    public CanRVAdapter(RecyclerView mRecyclerView, int itemLayoutId) {
        this(mRecyclerView);
        this.mItemLayoutId = itemLayoutId;

    }

    public CanRVAdapter(RecyclerView mRecyclerView, int itemLayoutId, List<T> mList) {

        this(mRecyclerView, itemLayoutId);
        if (mList != null && !mList.isEmpty()) {
            this.mList.addAll(mList);
        }

    }

    @Override
    public int getItemCount() {
        return mList.size();
    }


    public T getItem(int position) {
        if (isSafePosition(position)) {
            return mList.get(position);
        }
        return null;
    }

    private boolean isSafePosition(int position) {


        return mList != null && position >= 0 && position < mList.size();

    }

    @Override
    public long getItemId(int position) {
        return position;
    }


    public int getRatio() {
        return ratio;
    }

    public void setRatio(int ratio) {
        this.ratio = ratio;
    }

    /**
     * 获取数据
     *
     * @return List
     */
    public List<T> getList() {
        return mList;
    }

    /**
     * 添加到头部
     *
     * @param datas List
     */
    public void addNewList(List<T> datas) {
        if (datas != null && !datas.isEmpty()) {
            mList.addAll(0, datas);
            notifyDataSetChanged();
        }
    }

    /**
     * 添加到末尾
     *
     * @param datas List
     */
    public void addMoreList(List<T> datas) {
        if (datas != null && !datas.isEmpty()) {
            mList.addAll(datas);
            notifyDataSetChanged();
        }
    }


    /**
     * 设置数据
     *
     * @param datas List
     */
    public void setList(List<T> datas) {

        mList.clear();

        if (datas != null && !datas.isEmpty()) {
            mList.addAll(datas);
        }
        notifyDataSetChanged();
    }

    /**
     * 清空
     */
    public void clear() {
        mList.clear();
        notifyDataSetChanged();
    }


    /**
     * 删除指定索引数据条目
     *
     * @param position position
     */
    public void removeItem(int position) {
        if (isSafePosition(position)) {
            mList.remove(position);
            notifyItemRangeRemoved(position, 1);
        }

    }

    /**
     * 删除指定数据条目
     *
     * @param model T
     */
    public void removeItem(T model) {

        if (mList != null && mList.contains(model)) {
            int index = mList.indexOf(model);
            if (isSafePosition(index)) {
                removeItem(index);
            }
        }


    }

    /**
     * 在指定位置添加数据条目
     *
     * @param position int
     * @param model    T
     */
    public void addItem(int position, T model) {

        if(position>=0&&position<=mList.size()){
            mList.add(position, model);
            notifyItemInserted(position);
        }



    }

    /**
     * 在集合头部添加数据条目
     *
     * @param model T
     */
    public void addFirstItem(T model) {
        addItem(0, model);
    }

    /**
     * 在集合末尾添加数据条目
     *
     * @param model T
     */
    public void addLastItem(T model) {
        addItem(mList.size(), model);
    }

    /**
     * 替换指定索引的数据条目
     *
     * @param location int
     * @param newModel T
     */
    public void setItem(int location, T newModel) {

        if (isSafePosition(location)) {
            mList.set(location, newModel);

            notifyItemChanged(location);
        }

    }

    /**
     * 替换指定数据条目
     *
     * @param oldModel T
     * @param newModel T
     */
    public void setItem(T oldModel, T newModel) {
        setItem(mList.indexOf(oldModel), newModel);
    }

    /**
     * 交换两个数据条目的位置
     *
     * @param fromPosition int
     * @param toPosition   int
     */
    public void moveItem(int fromPosition, int toPosition) {

        if (isSafePosition(fromPosition) && isSafePosition(toPosition)) {
            Collections.swap(mList, fromPosition, toPosition);
            notifyItemMoved(fromPosition, toPosition);
        }

    }


    @Override
    public CanRViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        View itemView = LayoutInflater.from(mContext).inflate(mItemLayoutId, parent, false);

        return new CanRViewHolder(mRecyclerView, itemView, ratio);
    }

    @Override
    public void onBindViewHolder(CanRViewHolder viewHolder, int position) {
        viewHolder.setOnItemListener(mOnItemListener);
        CanHolderHelper mHolderHelper = viewHolder.getCanHolderHelper();

        mHolderHelper.setPosition(position);
        mHolderHelper.setOnItemListener(mOnItemListener);
        setItemListener(mHolderHelper);
        setView(mHolderHelper, position, getItem(position));
    }

    /**
     * 设置item中的子控件点击事件监听器
     *
     * @param onItemListener CanOnItemListener
     */
    public void setOnItemListener(CanOnItemListener onItemListener) {
        mOnItemListener = onItemListener;
    }


    protected abstract void setView(CanHolderHelper helper, int position, T bean);

    protected abstract void setItemListener(CanHolderHelper helper);


}


