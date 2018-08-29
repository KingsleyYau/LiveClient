package com.qpidnetwork.anchor.liveshow.liveroom.vedio;

import android.content.Context;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.widget.recycleview.DividerItemDecoration;
import com.qpidnetwork.anchor.utils.Log;

import java.util.ArrayList;
import java.util.List;

/**
 * Description:
 * <p>
 * Created by Harry on 2018/6/14.
 */
public class HangOutBarGiftListManager {

    private RecyclerView rlv_barGiftList;
    private BarGiftListAdapter barGiftAdapter;
    private Context mContext;
    private List<HangOutBarGiftListItem> hangOutBarGiftItems = new ArrayList<>();

    private final String TAG = HangOutBarGiftListManager.class.getSimpleName();

    public HangOutBarGiftListManager(Context context,  RecyclerView rlv_barGiftList){
        this.mContext = context;
        this.rlv_barGiftList = rlv_barGiftList;
        //水平布局
        rlv_barGiftList.setLayoutManager(new LinearLayoutManager(context,LinearLayoutManager.HORIZONTAL,false));
        //添加分割线
        rlv_barGiftList.addItemDecoration(new DividerItemDecoration(context,
                LinearLayoutManager.HORIZONTAL,R.drawable.hangout_bargift_list_divider));
        //itemLayoutId布局
        barGiftAdapter = new BarGiftListAdapter(mContext);
        barGiftAdapter.setList(this.hangOutBarGiftItems);
        this.rlv_barGiftList.setAdapter(barGiftAdapter);
    }

    public void setBarGiftList(List<HangOutBarGiftListItem> hangOutBarGiftItems){
        this.hangOutBarGiftItems.clear();
        synchronized (this.hangOutBarGiftItems){
            this.hangOutBarGiftItems.addAll(hangOutBarGiftItems);
            barGiftAdapter.notifyDataSetChanged();
        }
    }

    public void clear(){
        synchronized (this.hangOutBarGiftItems){
            if(null != hangOutBarGiftItems){
                this.hangOutBarGiftItems.clear();
            }
            barGiftAdapter.notifyDataSetChanged();
        }
    }

    public void release(){
        synchronized (this.hangOutBarGiftItems){
            if(null != hangOutBarGiftItems){
                this.hangOutBarGiftItems.clear();
            }
        }
    }

    /**
     * 更新吧台礼物列表条目
     * @param hangOutBarGiftItem
     */
    public void updateBarGiftList(HangOutBarGiftListItem hangOutBarGiftItem){
        Log.d(TAG,"updateBarGiftList-hangOutBarGiftItem:"+hangOutBarGiftItem);
        if(null == hangOutBarGiftItems){
            hangOutBarGiftItems = new ArrayList<>();
        }
        synchronized (this.hangOutBarGiftItems){
            HangOutBarGiftListItem item = null;
            boolean hasUpdated = false;
            int index=0;
            for(; index<this.hangOutBarGiftItems.size(); index++){
                item = this.hangOutBarGiftItems.get(index);
                if(item.giftId.equals(hangOutBarGiftItem.giftId)){
                    item.count+=hangOutBarGiftItem.count;
                    hasUpdated = true;
                    break;
                }
            }
            if(!hasUpdated){
                hangOutBarGiftItems.add(hangOutBarGiftItem);
                barGiftAdapter.notifyItemRangeChanged(hangOutBarGiftItems.size()-1,1);
            }else{
                barGiftAdapter.setUpdateOnItemByIndex(true,index);
                barGiftAdapter.notifyItemChanged(index);
            }

        }
    }
}
