package com.qpidnetwork.anchor.framework.canadapter;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;

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
public abstract class CanAdapter<T> extends BaseAdapter {

    protected int mItemLayoutId;
    protected Context mContext;
    protected List<T> mList;
    protected CanOnItemListener mOnItemListener;

    public Context getAdapterContext(){
        return mContext;
    }

    public CanAdapter(Context context) {

        mContext = context;

        mList = new ArrayList<>();

    }

    public CanAdapter(Context context, int itemLayoutId) {
        this(context);
        mItemLayoutId = itemLayoutId;

    }

    public CanAdapter(Context context, int itemLayoutId, List<T> mList) {

        this(context, itemLayoutId);
        if (mList != null && !mList.isEmpty()) {
            this.mList.addAll(mList);
        }

    }

    @Override
    public int getCount() {
        return mList.size();
    }

    @Override
    public T getItem(int position) {
        return mList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }


    /**
     * 获取数据
     *
     * @return
     */
    public List<T> getList() {
        return mList;
    }

    /**
     * 添加到头部
     *
     * @param datas
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
     * @param datas
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
     * @param datas
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
     * @param position
     */
    public void removeItem(int position) {
        mList.remove(position);
        notifyDataSetChanged();
    }

    /**
     * 删除指定数据条目
     *
     * @param model
     */
    public void removeItem(T model) {
        mList.remove(model);
        notifyDataSetChanged();
    }

    /**
     * 在指定位置添加数据条目
     *
     * @param position
     * @param model
     */
    public void addItem(int position, T model) {
        mList.add(position, model);
        notifyDataSetChanged();
    }

    /**
     * 在集合头部添加数据条目
     *
     * @param model
     */
    public void addFirstItem(T model) {
        addItem(0, model);
    }

    /**
     * 在集合末尾添加数据条目
     *
     * @param model
     */
    public void addLastItem(T model) {
        addItem(mList.size(), model);
    }

    /**
     * 替换指定索引的数据条目
     *
     * @param location
     * @param newModel
     */
    public void setItem(int location, T newModel) {
        mList.set(location, newModel);
        notifyDataSetChanged();
    }

    /**
     * 替换指定数据条目
     *
     * @param oldModel
     * @param newModel
     */
    public void setItem(T oldModel, T newModel) {
        setItem(mList.indexOf(oldModel), newModel);
    }

    /**
     * 交换两个数据条目的位置
     *
     * @param fromPosition
     * @param toPosition
     */
    public void moveItem(int fromPosition, int toPosition) {
        Collections.swap(mList, fromPosition, toPosition);
        notifyDataSetChanged();
    }

    @Override
    public View getView(int i, View view, ViewGroup viewGroup) {

        CanHolderHelper helper = CanHolderHelper.holderHelperByConvertView(view, viewGroup, mItemLayoutId);


        helper.setOnItemListener(mOnItemListener);
        helper.setPosition(i);
        setItemListener(helper);
        setView(helper, i, getItem(i));
        return helper.getConvertView();
    }

    /**
     * 设置item中的子控件点击事件监听器
     *
     * @param onItemListener
     */
    public void setOnItemListener(CanOnItemListener onItemListener) {
        mOnItemListener = onItemListener;
    }


    protected abstract void setView(CanHolderHelper helper, int position, T bean);

    protected abstract void setItemListener(CanHolderHelper helper);
}
