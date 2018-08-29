package com.qpidnetwork.anchor.liveshow.liveroom.vedio;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.anchor.utils.Log;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.List;

/**
 * Description:
 * <p>
 * Created by Harry on 2018/6/14.
 */
public class BarGiftListAdapter extends RecyclerView.Adapter {

    private List<HangOutBarGiftListItem> hangOutBarGiftItems = new ArrayList<>();
    private Context mContext;
    private final String TAG = BarGiftListAdapter.class.getSimpleName();

    public BarGiftListAdapter(Context context){
        this.mContext = context;
    }

    public void setList(List<HangOutBarGiftListItem> hangOutBarGiftItems){
        this.hangOutBarGiftItems = hangOutBarGiftItems;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        //不使用parent.getContext()以避免itemView父布局参数失效
        RecyclerView.ViewHolder viewHolder = new BarGiftViewHolder(View.inflate(mContext,R.layout.item_hangout_bargift_list,null));
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        BarGiftViewHolder barGiftViewHolder = (BarGiftViewHolder) holder;
        HangOutBarGiftListItem hangOutBarGiftListItem = hangOutBarGiftItems.get(position);
        //加载吧台礼物图片
        if(null != hangOutBarGiftListItem && !TextUtils.isEmpty(hangOutBarGiftListItem.middleImgUrl)){
            Log.d(TAG,"onBindViewHolder-position:"+position+" barGiftViewHolder.civ_barGiftImg.tag:"+barGiftViewHolder.civ_barGiftImg.getTag());
            if(null == barGiftViewHolder.civ_barGiftImg.getTag() || !barGiftViewHolder.civ_barGiftImg.getTag().toString().equals(hangOutBarGiftListItem.middleImgUrl)){
                Picasso.with(mContext.getApplicationContext())
                        .load(hangOutBarGiftListItem.middleImgUrl).noFade()
                        .error(R.drawable.ic_default_gift)
                        .memoryPolicy(MemoryPolicy.NO_CACHE)
                        .noPlaceholder()
                        .into(barGiftViewHolder.civ_barGiftImg);
                barGiftViewHolder.civ_barGiftImg.setTag(hangOutBarGiftListItem.middleImgUrl);
            }
        }else{
            Picasso.with(mContext.getApplicationContext())
                    .load(R.drawable.ic_default_gift).noFade()
                    .noPlaceholder()
                    .into(barGiftViewHolder.civ_barGiftImg);
        }
        //礼物数量
        barGiftViewHolder.tv_barGiftCount.setVisibility(hangOutBarGiftListItem.count <= 1 ? View.INVISIBLE : View.VISIBLE);
        barGiftViewHolder.tv_barGiftCount.setText(hangOutBarGiftListItem.count > 99 ?
                mContext.getResources().getString(R.string.live_gift_maxnum) :
                String.valueOf(hangOutBarGiftListItem.count));
        barGiftViewHolder.tv_barGiftCount.measure(0,0);
        //可动态修改属性值的shape
        GradientDrawable digitalHintGD = new GradientDrawable();
        digitalHintGD.setCornerRadius(90f);
        digitalHintGD.setColor(Color.parseColor("#FF7100"));
        digitalHintGD.setSize(barGiftViewHolder.tv_barGiftCount.getMeasuredHeight(), barGiftViewHolder.tv_barGiftCount.getMeasuredHeight());
        barGiftViewHolder.tv_barGiftCount.setBackgroundDrawable(digitalHintGD);
    }


    @Override
    public int getItemCount() {
        return hangOutBarGiftItems.size();
    }

    private boolean isUpdateOnItemByIndex = false;
    private int itemIndex2Update = -1;

    public void setUpdateOnItemByIndex(boolean isUpdateOnItemByIndex, int index){
        this.isUpdateOnItemByIndex = isUpdateOnItemByIndex;
        this.itemIndex2Update = index;
    }

    class BarGiftViewHolder extends RecyclerView.ViewHolder{
        public TextView tv_barGiftCount;
        public  CircleImageView civ_barGiftImg;

        public BarGiftViewHolder(View itemView) {
            super(itemView);
            tv_barGiftCount = (TextView) itemView.findViewById(R.id.tv_barGiftCount);
            civ_barGiftImg = (CircleImageView) itemView.findViewById(R.id.civ_barGiftImg);
        }
    }
}
