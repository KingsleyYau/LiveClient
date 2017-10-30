package com.qpidnetwork.livemodule.framework.canadapter;

import android.annotation.TargetApi;
import android.app.Activity;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.widget.RecyclerView;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.Set;


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
@TargetApi(12)
public  class CanRVFragmentAdapter extends RecyclerView.Adapter<CanRVFragmentAdapter.FragmentViewHolder> {
    private static final String TAG = "CanRVFragmentAdapter";


    private final FragmentManager mFragmentManager;
    private FragmentTransaction mCurTransaction = null;

    private Set<Integer> mIds = new HashSet<>();


    protected List<Fragment> mList;


    protected RecyclerView mRecyclerView;

    @Override
    public int getItemCount() {
        return mList.size();
    }


    public Fragment getItem(int position) {
        return mList.get(position);
    }


    public CanRVFragmentAdapter(FragmentManager fm, RecyclerView mRecyclerView, List<Fragment> mList) {
        mFragmentManager = fm;
        this.mRecyclerView = mRecyclerView;
        this.mList = new ArrayList<>();
        if (mList != null && !mList.isEmpty()) {
            this.mList.addAll(mList);
        }
    }

    public CanRVFragmentAdapter(FragmentManager fm, RecyclerView mRecyclerView) {
        mFragmentManager = fm;
        this.mRecyclerView = mRecyclerView;
        mList = new ArrayList<>();
    }


    @Override
    public void onViewRecycled(FragmentViewHolder holder) {
        if (mCurTransaction == null) {
            mCurTransaction = mFragmentManager.beginTransaction();
        }


        int tagId = genTagId(holder.getAdapterPosition());
        Fragment f = mFragmentManager.findFragmentByTag(tagId + "");
        if (f != null) {


            mCurTransaction.remove(f);
            mCurTransaction.commitAllowingStateLoss();
            mCurTransaction = null;
            mFragmentManager.executePendingTransactions();
        }
        if (holder.itemView instanceof ViewGroup) {
            ((ViewGroup) holder.itemView).removeAllViews();
        }
        super.onViewRecycled(holder);
    }

    @Override
    public final FragmentViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {


        View view = new FrameLayout(parent.getContext());
        view.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));


        int id = Math.abs(new Random().nextInt());
        if (parent.getContext() instanceof Activity) {
            while (((Activity) parent.getContext()).getWindow().getDecorView().findViewById(id) != null) {
                id = Math.abs(new Random().nextInt());
            }
        }
        view.setId(id);
        mIds.add(id);
        return new FragmentViewHolder(view);
    }

    @Override
    public final void onBindViewHolder(final FragmentViewHolder holder, int position) {
        // do nothing

        final View itemView = holder.itemView;
        ViewGroup.LayoutParams lp = itemView.getLayoutParams() == null ? new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT) : itemView.getLayoutParams();
        if (mRecyclerView.getLayoutManager().canScrollHorizontally()) {
            lp.width = mRecyclerView.getWidth() - mRecyclerView.getPaddingLeft() - mRecyclerView.getPaddingRight();
        } else {
            lp.height = mRecyclerView.getHeight() - mRecyclerView.getPaddingTop() - mRecyclerView.getPaddingBottom();
        }
    }

    protected int genTagId(int position) {
        // itemId must not be zero
        long itemId = getItemId(position);
        if (itemId == RecyclerView.NO_ID) {
            return position + 1;
        } else {
            return (int) itemId;
        }
    }

    public  void onDestroyItem(int position, Fragment fragment){}

    public class FragmentViewHolder extends RecyclerView.ViewHolder implements View.OnAttachStateChangeListener {

        public FragmentViewHolder(View itemView) {
            super(itemView);
            itemView.addOnAttachStateChangeListener(this);
        }

        @Override
        public void onViewAttachedToWindow(View v) {
            if (mCurTransaction == null) {
                mCurTransaction = mFragmentManager.beginTransaction();
            }
            final int tagId = genTagId(getLayoutPosition());
            final Fragment fragmentInAdapter = getItem(getLayoutPosition());
            if (fragmentInAdapter != null) {
                mCurTransaction.replace(itemView.getId(), fragmentInAdapter, tagId + "");
                mCurTransaction.commitAllowingStateLoss();
                mCurTransaction = null;
                mFragmentManager.executePendingTransactions();
            }
        }

        @Override
        public void onViewDetachedFromWindow(View v) {

            final int tagId = genTagId(getLayoutPosition());
            Fragment frag = mFragmentManager.findFragmentByTag(tagId + "");
            if (frag == null) {
                return;
            }
            if (mCurTransaction == null) {
                mCurTransaction = mFragmentManager.beginTransaction();
            }

            mCurTransaction.remove(frag);
            mCurTransaction.commitAllowingStateLoss();
            mCurTransaction = null;
            mFragmentManager.executePendingTransactions();
            onDestroyItem(getLayoutPosition(), frag);
        }
    }


}
