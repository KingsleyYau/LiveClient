package com.qpidnetwork.livemodule.framework.canadapter;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;

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
public class CanRViewHolder extends RecyclerView.ViewHolder  {

    protected Context mContext;
    protected CanHolderHelper mHolderHelper;
    protected RecyclerView mRecyclerView;
    protected CanOnItemListener mOnItemListener;

    protected int viewType;

    public CanRViewHolder(RecyclerView recyclerView, View itemView) {
        this(recyclerView,itemView,0);
    }


    public CanRViewHolder(RecyclerView recyclerView, View itemView, int ratio) {
        super(itemView);

        if (ratio > 0) {

            ViewGroup.LayoutParams lp = itemView.getLayoutParams() == null ? new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT) : itemView.getLayoutParams();
            if (recyclerView.getLayoutManager().canScrollHorizontally()) {
                lp.width = (recyclerView.getWidth() / ratio - recyclerView.getPaddingLeft() - recyclerView.getPaddingRight());
            } else {
                lp.height = recyclerView.getHeight() / ratio - recyclerView.getPaddingTop() - recyclerView.getPaddingBottom();
            }

            itemView.setLayoutParams(lp);
        }


        this.mRecyclerView = recyclerView;
        this.mContext = mRecyclerView.getContext();
        this.mHolderHelper = CanHolderHelper.holderHelperByRecyclerView(itemView);


    }



    public CanRViewHolder setViewType(int viewType) {
        this.viewType = viewType;

        return this;
    }

    public int getViewType() {
        return viewType;
    }

    public CanHolderHelper getCanHolderHelper() {
        return mHolderHelper;
    }

    public void setOnItemListener(CanOnItemListener onItemListener) {

        this.mOnItemListener = onItemListener;

    }


}
