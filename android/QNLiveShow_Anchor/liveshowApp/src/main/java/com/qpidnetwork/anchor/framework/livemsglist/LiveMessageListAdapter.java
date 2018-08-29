package com.qpidnetwork.anchor.framework.livemsglist;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.ViewGroup;

import java.util.List;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.functions.Consumer;

/**
 * 使用LiveMessageListView 请使用这个Adapter
 * @param <T>
 */
public abstract class LiveMessageListAdapter<T> extends RecyclerView.Adapter<ViewHolder>{


    protected Context mContext;
    protected int mLayoutId;
    protected List<T> mDatas;
    protected LayoutInflater mInflater;


    public LiveMessageListAdapter(Context context, int layoutId)
    {
        mContext = context;
        mInflater = LayoutInflater.from(context);
        mLayoutId = layoutId;

    }

    public void setDatas(List<T> datas){
        mDatas = datas;
    }

    @Override
    public ViewHolder onCreateViewHolder(final ViewGroup parent, int viewType)
    {
        ViewHolder viewHolder = ViewHolder.get(mContext, parent, mLayoutId);
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(final ViewHolder holder,final int position)
    {
//        holder.updatePosition(position);
        convert(holder, mDatas.get(position));
    }

    /**
     * 外部实现此方法 构造VIEW(等于listView的getView方法)
     * @param holder
     * @param t 列表item (泛型)
     */
    public abstract void convert(ViewHolder holder, T t);

    @Override
    public int getItemCount()
    {
        return mDatas.size();
    }
}
