package com.qpidnetwork.anchor.framework.canadapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.util.SparseArray;
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
public abstract class CanRVHFAdapter<C, G, H, F> extends RecyclerView.Adapter<CanRViewHolder> implements CanSpanSize {


    public static final int TYPE_GROUP = 0;
    public static final int TYPE_CHILD = 1;
    public static final int TYPE_HEADER = 2;
    public static final int TYPE_FOOTER = 3;


    protected int itemGroupLayoutId;
    protected int itemChildLayoutId;
    protected int itemHeaderLayoutId;
    protected int itemFooterLayoutId;

    protected Context mContext;

    protected List<G> mGroupList;
    protected List<List<C>> mChildList;


    private SparseArray<ErvType> ervTypes;


    private F footer;
    private H header;
    protected RecyclerView mRecyclerView;


    public CanRVHFAdapter(RecyclerView mRecyclerView) {
        super();
        this.mContext = mRecyclerView.getContext();
        this.mRecyclerView = mRecyclerView;
        this.mGroupList = new ArrayList<>();
        this.mChildList = new ArrayList<>();
        this.ervTypes = new SparseArray<>();

    }


    public CanRVHFAdapter(RecyclerView mRecyclerView, int itemChildLayoutId, int itemGroupLayoutId, int itemHeaderLayoutId, int itemFooterLayoutId) {
        this(mRecyclerView);
        this.itemChildLayoutId = itemChildLayoutId;
        this.itemGroupLayoutId = itemGroupLayoutId;
        this.itemHeaderLayoutId = itemHeaderLayoutId;
        this.itemFooterLayoutId = itemFooterLayoutId;

    }


    public void setFooter(F footer) {
        this.footer = footer;

    }

    public F getFooter() {
        return footer;
    }

    public void setHeader(H header) {
        this.header = header;

    }

    public H getHeader() {
        return header;
    }

    public void resetStatus(){

        ervTypes.clear();

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

        int headerCount = header == null ? 0 : 1;
        int footerCount = footer == null ? 0 : 1;


        int groupCount = getGroupItemCount();


        if (groupCount == 0) {


            count = headerCount + footerCount + getChildItemCount(0);


        } else {

            for (int i = 0; i < groupCount; i++) {


                count += getChildItemCount(i);


            }

            count += groupCount + headerCount + footerCount;


        }


        return count;
    }


    @Override
    public long getItemId(int position) {
        return position;
    }


    public G getGroupItem(int position) {
        return mGroupList.get(position);
    }

    public C getChildItem(int group, int position) {
        return mChildList.get(group).get(position);
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

        if (datas != null && !datas.isEmpty()) {
            mGroupList.addAll(datas);
        }
        if (childData != null && !childData.isEmpty()) {
            mChildList.addAll(childData);
        }
        notifyDataSetChanged();
    }


    protected CanRViewHolder onCreateGroupViewHolder(ViewGroup parent, int viewType) {

        View itemView = LayoutInflater.from(mContext).inflate(itemGroupLayoutId, parent, false);

        return new CanRViewHolder(mRecyclerView, itemView).setViewType(viewType);

    }

    protected CanRViewHolder onCreateChildViewHolder(ViewGroup parent, int viewType) {

        View itemView = LayoutInflater.from(mContext).inflate(itemChildLayoutId, parent, false);

        return new CanRViewHolder(mRecyclerView, itemView).setViewType(viewType);

    }


    protected CanRViewHolder onCreateHeaderViewHolder(ViewGroup parent, int viewType) {

        View itemView = LayoutInflater.from(mContext).inflate(itemHeaderLayoutId, parent, false);

        return new CanRViewHolder(mRecyclerView, itemView).setViewType(viewType);

    }

    protected CanRViewHolder onCreateFooterViewHolder(ViewGroup parent, int viewType) {

        View itemView = LayoutInflater.from(mContext).inflate(itemFooterLayoutId, parent, false);

        return new CanRViewHolder(mRecyclerView, itemView).setViewType(viewType);

    }


    @Override
    public int getItemViewType(int position) {
        int viewType = TYPE_CHILD;
        if (isHeaderPosition(position)) {
            viewType = TYPE_HEADER;
        } else if (isFooterPosition(position)) {
            viewType = TYPE_FOOTER;
        } else {

            ErvType ervType = ervTypes.get(position);

            if(ervType==null){
                ervType = getItemErvType(position);
                ervTypes.put(position,ervType);
            }

            viewType = ervType.type;
        }
        return viewType;
    }

    @Override
    public CanRViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {


        switch (viewType) {

            case TYPE_HEADER:

                return onCreateHeaderViewHolder(parent, viewType);

            case TYPE_FOOTER:

                return onCreateFooterViewHolder(parent, viewType);


            case TYPE_GROUP:
                return onCreateGroupViewHolder(parent, viewType);

        }

        return onCreateChildViewHolder(parent, viewType);

    }

    @Override
    public void onBindViewHolder(CanRViewHolder viewHolder, int position) {

        CanHolderHelper mHolderHelper = viewHolder.getCanHolderHelper();
        mHolderHelper.setPosition(position);

        int viewType = viewHolder.getViewType();

        switch (viewType) {

            case TYPE_HEADER:

                setHeaderView(mHolderHelper, position, header);
                break;

            case TYPE_FOOTER:
                setFooterView(mHolderHelper, position, footer);

                break;

            case TYPE_GROUP:
            case TYPE_CHILD:

                ErvType ervType = ervTypes.get(position);

                if(ervType==null){
                    ervType = getItemErvType(position);
                    ervTypes.put(position,ervType);
                }


                if (ervType.type == TYPE_CHILD) {


                    setChildView(mHolderHelper, ervType.group, ervType.position, getChildItem(ervType.group, ervType.position));


                } else {

                    setGroupView(mHolderHelper, ervType.group, ervType.position, getGroupItem(ervType.group));


                }


                break;


        }


    }





    public boolean isGroupPosition(int i) {

        ErvType ervType = ervTypes.get(i);

        if(ervType==null){
            ervType = getItemErvType(i);
            ervTypes.put(i,ervType);
        }


        return ervType.type==TYPE_GROUP;
    }

    public boolean isHeaderPosition(int position) {
        return header != null && position == 0;
    }


    public boolean isFooterPosition(int position) {
        int lastPosition = getItemCount() - 1;
        return footer != null && position == lastPosition;
    }



    public int getSpanIndex(int position, int spanCount){

        ErvType ervType = ervTypes.get(position);

        if(ervType==null){
            ervType = getItemErvType(position);
            ervTypes.put(position,ervType);
        }

        if(ervType.type==TYPE_CHILD){

            return ervType.position%spanCount;
        }

        return  0;

    }


    protected abstract void setChildView(CanHolderHelper helper, int group, int position, C bean);

    protected abstract void setGroupView(CanHolderHelper helper, int group, int position, G bean);

    protected abstract void setHeaderView(CanHolderHelper helper, int position, H bean);

    protected abstract void setFooterView(CanHolderHelper helper, int position, F bean);


    @Override
    public  void onViewRecycled(CanRViewHolder holder) {


        int viewType = holder.getViewType();

        switch (viewType) {

            case TYPE_HEADER:

                onHeaderViewRecycled(holder);

                break;

            case TYPE_FOOTER:
                onFooterViewRecycled(holder);

                break;

            case TYPE_GROUP:
                onGroupViewRecycled(holder);
                break;
            case TYPE_CHILD:


                onChildViewRecycled(holder);

                break;


        }
    }

    protected void onHeaderViewRecycled(CanRViewHolder holder) {
    }


    protected void onFooterViewRecycled(CanRViewHolder holder) {
    }

    protected void onChildViewRecycled(CanRViewHolder holder) {
    }


    protected void onGroupViewRecycled(CanRViewHolder holder) {
    }


    /**
     * 计算正确的group和position
     *
     * @param i position
     * @return 一个计算好的group和position
     */
    public ErvType getItemErvType(int i) {


        if (header != null) {

            i -= 1;
        }

        for (int group = 0; group < getGroupItemCount(); group++) {



            if (i >= 1) {

                i -= 1;

                if (i < getChildItemCount(group)) {


                    return new ErvType(TYPE_CHILD, group, i);
                }

                i -= getChildItemCount(group);
                continue;

            }

            if (i < 1) {

                return new ErvType(TYPE_GROUP, group, i);
            }


        }


        return new ErvType(TYPE_CHILD, 0, i);
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
