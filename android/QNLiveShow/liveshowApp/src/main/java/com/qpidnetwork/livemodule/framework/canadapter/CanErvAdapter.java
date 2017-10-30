package com.qpidnetwork.livemodule.framework.canadapter;

import android.content.Context;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.SparseBooleanArray;
import android.view.InflateException;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import java.util.ArrayList;
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
public abstract class CanErvAdapter<G, C> extends RecyclerView.Adapter<CanRViewHolder> {
    public static final int TYPE_GROUP = 0;
    public static final int TYPE_CHILD = 1;

    protected int itemGroupLayoutId;
    protected int itemChildLayoutId;
    protected Context mContext;
    protected List<G> mGroupList;
    protected List<List<C>> mChildList;

    protected RecyclerView mRecyclerView;
    private int mSpanCount = 1;

    // 是否能够收拢
    private boolean isCannotCollapse;
    // 是否只能展开一个
    private boolean isSingleExpand;
    // 当前展开的groupid
    protected int mSingleExpand = -1;
    //  当前展开的helper
    private CanHolderHelper mLastExpandHelper;


    // 存储展开的group状态
    private SparseBooleanArray expandArray = new SparseBooleanArray();


    public CanErvAdapter(RecyclerView mRecyclerView) {
        super();
        this.mContext = mRecyclerView.getContext();
        this.mRecyclerView = mRecyclerView;
        this.mGroupList = new ArrayList<>();
        this.mChildList = new ArrayList<>();

        RecyclerView.LayoutManager manager = mRecyclerView.getLayoutManager();

        if (manager == null) {
            throw new InflateException("LayoutManager is null");
        }
        if (manager instanceof GridLayoutManager) {

            mSpanCount = ((GridLayoutManager) manager).getSpanCount();
        }


    }


    public CanErvAdapter(RecyclerView mRecyclerView, int itemGroupLayoutId, int itemChildLayoutId) {
        this(mRecyclerView);
        this.itemGroupLayoutId = itemGroupLayoutId;
        this.itemChildLayoutId = itemChildLayoutId;

    }

    public CanErvAdapter(RecyclerView mRecyclerView, int itemGroupLayoutId, int itemChildLayoutId, List<G> mGroupList, List<List<C>> mChildList) {

        this(mRecyclerView, itemGroupLayoutId, itemChildLayoutId);
        if (mGroupList != null && !mGroupList.isEmpty()) {
            this.mGroupList.addAll(mGroupList);
        }

        if (mChildList != null && !mChildList.isEmpty()) {
            this.mChildList.addAll(mChildList);
        }

    }


    public boolean isSingleExpand() {
        return isSingleExpand;
    }


    public void setSingleExpand(boolean singleExpand) {
        isSingleExpand = singleExpand;
    }

    public boolean isCannotCollapse() {
        return isCannotCollapse;
    }

    public void setCannotCollapse(boolean cannotCollapse) {
        isCannotCollapse = cannotCollapse;
    }

    public boolean isExpanded(int group) {

        if (isCannotCollapse) {
            return true;
        }
        return expandArray.get(group);
    }

    public SparseBooleanArray getExpandArray() {
        return expandArray;
    }

    public void setExpandArray(SparseBooleanArray expandArray) {
        this.expandArray = expandArray;
    }

    /**
     * 展开
     *
     * @param helper
     * @param group
     */
    public void expand(CanHolderHelper helper, int group) {

        if (isCannotCollapse) {
            return;
        }

        if (isExpanded(group))
            return;


        if (isSingleExpand) {

            if (mSingleExpand > -1 && expandArray.get(mSingleExpand) && mLastExpandHelper != null) {
                collapse(mLastExpandHelper, mSingleExpand);
            }
        }

        int position = getPositionByGroup(group);

        position += mSpanCount;

        if (isSingleExpand) {
            mSingleExpand = group;
        }

        notifyItemRangeInserted(position, getChildItemCountF(group));
        expandArray.put(group, true);
        if (isSingleExpand) {
            onSingleExpand(helper, group);
            mLastExpandHelper = helper;
        }


    }


    /**
     * 收拢
     *
     * @param helper
     * @param group
     */
    public void collapse(CanHolderHelper helper, int group) {

        if (isCannotCollapse) {
            return;
        }
        if (!isExpanded(group))
            return;

        int position = getPositionByGroup(group);

        position += mSpanCount;

        if (isSingleExpand) {

            onSingleCollapse(helper, group);
            mSingleExpand = -1;
        }

        notifyItemRangeRemoved(position, getChildItemCountF(group));
        expandArray.put(group, false);
    }

    /**
     * child的实际个数
     *
     * @param group
     * @return
     */
    public int getChildItemCount(int group) {

        if (mChildList.size() <= group) {
            return 0;
        }
        return mChildList.get(group).size();
    }

    /**
     * child需要的个数
     *
     * @param group
     * @return
     */
    public int getChildItemCountF(int group) {
        return (int) Math.ceil(getChildItemCount(group) / (double) mSpanCount) * mSpanCount;
    }


    /**
     * group的个数
     *
     * @return
     */
    public int getGroupItemCount() {
        if (mGroupList.isEmpty()) {
            return 0;
        }

        return mGroupList.size();


    }

    @Override
    public int getItemCount() {
        int count = 0;
        for (int i = 0; i < getGroupItemCount(); i++) {


            if (!isExpanded(i)) {
                count += mSpanCount;
            } else {
                count += mSpanCount + getChildItemCountF(i);
            }


        }


        return count;
    }


    public G getGroupItem(int position) {
        return mGroupList.get(position);
    }

    public C getChildItem(int group, int position) {
        return mChildList.get(group).get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }


    public List<G> getGroupList() {
        return mGroupList;
    }


    public List<List<C>> getChildList() {
        return mChildList;
    }

    /**
     * 设置数据
     *
     * @param datas
     */
    public void setList(List<G> datas, List<List<C>> childData) {

        mGroupList.clear();
        mChildList.clear();
        reset();
        if (datas != null && !datas.isEmpty()) {
            mGroupList.addAll(datas);
        }
        if (childData != null && !childData.isEmpty()) {
            mChildList.addAll(childData);
        }
        notifyDataSetChanged();
    }

    /**
     * 清空
     */
    public void clear() {
        mGroupList.clear();
        mChildList.clear();
        reset();
        notifyDataSetChanged();
    }

    /**
     * 删除某一项
     * @param group
     */
    public void remove(int group){
        mGroupList.remove(group);
        mChildList.remove(group);

        int position = getPositionByGroup(group);

        int itemCount = mSpanCount;
        if (isExpanded(group)){
            itemCount += getChildItemCountF(group);
        }

        reset();
        notifyItemRangeRemoved(position, itemCount);


    }


    /**
     * 通过group得到当前position
     * @param group
     * @return
     */
    public int getPositionByGroup(int group){

        int position = 0;
        for (int i = 0; i < group; i++) {
            position += mSpanCount;
            if (isExpanded(i))
                position += getChildItemCountF(i);
        }


        return position;


    }


    /**
     * 重置
     */
    private void reset(){

        mSingleExpand = -1;
        expandArray.clear();

    }


    @Override
    public int getItemViewType(int i) {


        ErvType ervType = getItemErvType(i);


        return ervType.type;
    }


    /**
     * 计算正确的group和position
     * @param i
     * @return
     */
    public ErvType getItemErvType(int i) {

        for (int group = 0; group < getGroupItemCount(); group++) {

            if (i >= mSpanCount && !isExpanded(group)) {
                i -= mSpanCount;

                continue;
            }

            if (i >= mSpanCount && isExpanded(group)) {

                i -= mSpanCount;

                if (i < getChildItemCountF(group)) {


                    return new ErvType(TYPE_CHILD, group, i);
                }

                i -= getChildItemCountF(group);
                continue;

            }

            if (i < mSpanCount) {

                return new ErvType(TYPE_GROUP, group, i);
            }


        }


        throw new IndexOutOfBoundsException("IndexOutOfBounds " + i);
    }

    protected CanRViewHolder onCreateGroupViewHolder(ViewGroup parent) {

        View itemView = LayoutInflater.from(mContext).inflate(itemGroupLayoutId, parent, false);

        return new CanRViewHolder(mRecyclerView, itemView);

    }

    protected CanRViewHolder onCreateChildViewHolder(ViewGroup parent, int viewType) {

        View itemView = LayoutInflater.from(mContext).inflate(itemChildLayoutId, parent, false);

        return new CanRViewHolder(mRecyclerView, itemView);

    }





    @Override
    public CanRViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {

        return viewType == TYPE_GROUP ? onCreateGroupViewHolder(parent) : onCreateChildViewHolder(parent, viewType);
    }

    @Override
    public void onBindViewHolder(CanRViewHolder viewHolder, int i) {
        CanHolderHelper mHolderHelper = viewHolder.getCanHolderHelper();
        mHolderHelper.setPosition(i);


        ErvType ervType = getItemErvType(i);

        if (ervType.type == TYPE_GROUP) {
            onBindGroupViewHolder(mHolderHelper, ervType.group, ervType.position);
        } else {
            onBindChildViewHolder(mHolderHelper, ervType.group, ervType.position);
        }


    }


    public void onBindChildViewHolder(CanHolderHelper helper, final int group, final int position) {

        if (position >= getChildItemCount(group)) {
            helper.getConvertView().setVisibility(View.GONE);
        } else {
            setChildView(helper, group, position, getChildItem(group, position));
            helper.getConvertView().setVisibility(View.VISIBLE);

        }


    }


    public void onBindGroupViewHolder(CanHolderHelper helper, final int group, final int position) {


        if (position == 0) {
            helper.getConvertView().setVisibility(View.VISIBLE);
            setGroupView(helper, group, position, getGroupItem(group));
        } else {
            helper.getConvertView().setVisibility(View.GONE);
        }


    }

    public boolean toggle(CanHolderHelper helper, int group) {

        if (isExpanded(group)) {
            collapse(helper, group);

            return false;
        } else {
            expand(helper, group);

            return true;

        }
    }


    protected abstract void setChildView(CanHolderHelper helper, int group, int position, C bean);

    protected abstract void setGroupView(CanHolderHelper helper, int group, int position, G bean);


    protected void onSingleExpand(CanHolderHelper groupHelper, int group) {
    }

    protected void onSingleCollapse(CanHolderHelper groupHelper, int group) {
    }


    public static class ErvType {

        public int type;
        public int group;
        public int position;


        public ErvType(int type, int group, int position) {
            this.type = type;
            this.group = group;
            this.position = position;
        }
    }
}


