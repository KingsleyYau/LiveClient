package com.qpidnetwork.anchor.liveshow.base;

import android.content.Context;
import android.support.annotation.LayoutRes;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.RecyclerView.ViewHolder;
import android.support.v7.widget.StaggeredGridLayoutManager;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.qpidnetwork.qnbridgemodule.util.ListUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by Hardy on 2018/9/19.
 * <p>
 * 1、如果需要使用加载更多控件时，重写getViewType 必须要注意调用super.getViewType
 * <p>
 * 2、如果有配合 HeaderViewRecyclerAdapter 使用，有 headView，记得设置 setHeadViewCount(headAdapter.getHeaderCount()) 方法
 * <p>
 * <p/>
 * adapter 的基类
 */
public abstract class BaseRecyclerViewAdapter<T, E extends ViewHolder> extends RecyclerView.Adapter<ViewHolder> {

    public List<T> mList;
    public Context mContext;

    private boolean hasFootView = false;
    public static final int FOOTVIEW_TYPE = 10101;

    /**
     * 2017-06-15
     * 头部 view 的数量
     * 在点击事件，获取 Item 的 position 时，要剪掉头部 view 的数量
     */
    private int headViewCount;


    public BaseRecyclerViewAdapter(Context context) {
        mContext = context;
        this.mList = new ArrayList<>();
    }

    @Override
    public final E onCreateViewHolder(ViewGroup parent, int viewType) {
//        if (viewType == FOOTVIEW_TYPE) {
//            View v = LayoutInflater.from(mContext).inflate(R.layout.item_recyclerview_loading_more, parent, false);
//            FootViewHolder holder = new FootViewHolder(v);
//            return (E) holder;
//        }

        View v = LayoutInflater.from(mContext).inflate(getLayoutId(viewType), parent, false);
        E holder = getViewHolder(v, viewType);
        initViewHolder(holder);
        return holder;
    }

    //=============== 2017/6/15 =====================
    public void setHeadViewCount(int headViewCount) {
        this.headViewCount = headViewCount;
    }

    public int getHeadViewCount() {
        return headViewCount;
    }
    //=============== 2017/6/15 =====================


    /**
     * 先设置是否有加载更多的view出现  nexturl
     *
     * @param isHas
     */
    public void setHasFootView(boolean isHas) {
        if (hasFootView && !isHas) { // 加载更多移除
            int last = getItemCount() - 1;
            if (getItemViewType(last) == FOOTVIEW_TYPE) {
                notifyItemRemoved(last);
            }
        }
        this.hasFootView = isHas;
    }

    /**
     * zy2
     * 根据 nextUrl 和
     *
     * @param nextUrl
     * @param list
     * @return
     */
    public boolean getHasFootView(String nextUrl, List<?> list) {
        boolean isHas = false;

        isHas = TextUtils.isEmpty(nextUrl) ? false : true;
        if (isHas) {
            isHas = ListUtils.isList(list);
        }

        return isHas;
    }

    //    @Override
    //    public int getItemViewType(int position) {
    //        if (super.getItemViewType(position) == FOOTVIEW_TYPE) return FOOTVIEW_TYPE;
    //        return mList.get(position).inforType;
    //    }

    /**
     * 重写
     *
     * @param position
     * @return
     */
    @Override
    public int getItemViewType(int position) {
        // 注意处理， 如果 是 最后 一个那就产生一个特定的viewType
        if (hasFootView && position == getItemCount() - 1) {
            return FOOTVIEW_TYPE;
        }
        return super.getItemViewType(position);
    }

    @Override
    public final void onBindViewHolder(ViewHolder holder, int position) {
        if (getItemViewType(position) == FOOTVIEW_TYPE) {
            return;
        }
        convertViewHolder((E) holder, mList.get(position), position);
    }


    @Override
    public int getItemCount() {
        return mList == null ? 0 : mList.size() + (hasFootView ? 1 : 0);
    }

    public boolean isValidPosition(int pos) {
        return pos >= 0 && pos < mList.size();
    }

    /**
     * 是否含有 footView
     */
    public boolean isFooter(int position) {
        return getItemViewType(position) == BaseRecyclerViewAdapter.FOOTVIEW_TYPE;
    }

    /**
     * 是否设置指定的 grid item 为整行?
     */
    protected boolean isGridItemFullSpan(int position){
        return false;
    }

    @Override
    public void onAttachedToRecyclerView(RecyclerView recyclerView) {
        super.onAttachedToRecyclerView(recyclerView);

        // 2017/5/11 底部加载更多布局，在 GridLayoutManager 中完全显示一行
        RecyclerView.LayoutManager manager = recyclerView.getLayoutManager();
        if (manager instanceof GridLayoutManager) {
            final GridLayoutManager gridManager = ((GridLayoutManager) manager);
            gridManager.setSpanSizeLookup(new GridLayoutManager.SpanSizeLookup() {
                @Override
                public int getSpanSize(int position) {
                    //                    return (isHeader(position) || isFooter(position)) ? gridManager.getSpanCount() : 1;

                    return isFooter(position) || isGridItemFullSpan(position) ? gridManager.getSpanCount() : 1;
                }
            });
        }
    }

    @Override
    public void onViewAttachedToWindow(ViewHolder holder) {
        super.onViewAttachedToWindow(holder);

        // 2017/5/11 底部加载更多布局，在 StaggeredGridLayoutManager 中完全显示一行
        ViewGroup.LayoutParams lp = holder.itemView.getLayoutParams();
        if (lp != null && lp instanceof StaggeredGridLayoutManager.LayoutParams) {
            //                && (isHeader(holder.getLayoutPosition()) || isFooter(holder.getLayoutPosition()))) {

            StaggeredGridLayoutManager.LayoutParams p = (StaggeredGridLayoutManager.LayoutParams) lp;
            p.setFullSpan(isFooter(holder.getLayoutPosition()) || isGridItemFullSpan(holder.getLayoutPosition()));
        }
    }

    /**
     * set a new data
     *
     * @param list
     */
    public void setData(List<T> list) {
        this.mList.clear();
        if (ListUtils.isList(list)) {
            this.mList.addAll(list);
        }
        this.notifyDataSetChanged();
    }

    /**
     * add a new data list to last position
     *
     * @param list
     */
    public void addData(List<T> list) {
        addData(this.mList.size(), list);
    }

    /**
     * add a new data list to position
     *
     * @param list
     */
    public void addData(int position, List<T> list) {
        if (ListUtils.isList(list)) {
            this.mList.addAll(position, list);
            this.notifyDataSetChanged();
        }
    }

    /**
     * add a new data to position
     *
     * @param position
     * @param bean
     */
    public void addData(int position, T bean) {
        if (bean != null) {
            this.mList.add(position, bean);
            this.notifyItemInserted(position);
        }
    }

    /**
     * add a new data
     *
     * @param bean
     */
    public void addData(T bean) {
        if (bean != null) {
            this.mList.add(this.mList.size(), bean);
            this.notifyItemInserted(this.mList.size()-1);
        }
    }

    /**
     * set ? add ?
     *
     * @param list
     * @param isLoadMore
     */
    public void updateData(List<T> list, boolean isLoadMore) {
        if (isLoadMore) {
            addData(list);
        } else {
            setData(list);
        }
    }


    /**
     * 批量删除连续位置
     * @param startPostion
     * @param count
     */
    public void removeRange(int startPostion, int count){
        if(isValidPosition(startPostion)){
            List<T> dataList = new ArrayList<T>();
            int endPostion = mList.size() > (startPostion + count) ? (startPostion + count):mList.size();
            for (int i = startPostion; i < endPostion; i++) {
                dataList.add(mList.get(i));
            }
            mList.removeAll(dataList);

            this.notifyItemRangeRemoved(startPostion, count);
        }
    }

    /**
     * remove effective position data
     *
     * @param pos
     */
    public void removeItem(int pos) {
        if (isValidPosition(pos)) {
            mList.remove(pos);
            this.notifyItemRemoved(pos);
        }
    }

    /**
     * 清空
     */
    public void removeAll(){
        mList.clear();
        this.notifyDataSetChanged();
    }

    /**
     * swap list position
     *
     * @param fromPosition
     * @param toPosition
     * @return remove success or failed
     */
    public boolean removeItem(int fromPosition, int toPosition) {
        return removeItem(this, mList, fromPosition, toPosition);
    }

    public static boolean removeItem(RecyclerView.Adapter adapter, List mList, int fromPosition, int toPosition) {
        if (ListUtils.isValidPosition(mList, fromPosition) && ListUtils.isValidPosition(mList, toPosition)) {
            // 如果相等，则直接返回，不进行操作
            if (fromPosition == toPosition) {
                return false;
            }

            if (fromPosition < toPosition) {
                for (int i = fromPosition; i < toPosition; i++) {
                    Collections.swap(mList, i, i + 1);
                }
            } else {
                for (int i = fromPosition; i > toPosition; i--) {
                    Collections.swap(mList, i, i - 1);
                }
            }

            adapter.notifyItemMoved(fromPosition, toPosition);

            return true;
        }

        return false;
    }

    /**
     * change position data
     *
     * @param pos
     */
    public void changedItem(int pos) {
        if (isValidPosition(pos)) {
            this.notifyItemChanged(pos);
        }
    }

    /**
     * according to holder to get item position
     *
     * @param holder
     * @return
     */
    public int getPosition(E holder) {
        //        return holder == null ? 0 : holder.getLayoutPosition();
        // 2017/6/15
        return holder == null ? 0 : holder.getLayoutPosition() - getHeadViewCount();
    }

    /**
     * get item data bean
     *
     * @param pos
     * @return
     */
    public T getItemBean(int pos) {
        if (isValidPosition(pos)) {
            return mList.get(pos);
        }
        return null;
    }

    /**
     * get data list
     *
     * @return
     */
    public List<T> getList() {
        return mList;
    }

    /**
     * item layout id
     *
     * @param viewType
     * @return
     */
    @LayoutRes
    public abstract int getLayoutId(int viewType);

    /**
     * get a new holder
     *
     * @param itemView
     * @param viewType
     * @return
     */
    public abstract E getViewHolder(View itemView, int viewType);

    /**
     * init some thing. ex: click event
     *
     * @param holder
     */
    public abstract void initViewHolder(E holder);

    /**
     * set holder data
     *
     * @param holder
     * @param data
     * @param position
     */
    public abstract void convertViewHolder(E holder, T data, int position);


    //======================   interface     ==========================
    protected OnItemClickListener mOnItemClickListener;
    protected OnItemLongClickListener mOnItemLongClickListener;

    public void setOnItemClickListener(OnItemClickListener mOnItemClickListener) {
        this.mOnItemClickListener = mOnItemClickListener;
    }

    public void setOnItemLongClickListener(OnItemLongClickListener mOnItemLongClickListener) {
        this.mOnItemLongClickListener = mOnItemLongClickListener;
    }

    public interface OnItemClickListener {
        void onItemClick(View v, int position);
    }

    public interface OnItemLongClickListener {
        void onItemLongClick(View v, int position);
    }
    //=================================================================


    class FootViewHolder extends ViewHolder {

        public FootViewHolder(View itemView) {
            super(itemView);
        }
    }
}
