package com.qpidnetwork.livemodule.liveshow.personal.book;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.HotListItem;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomType;
import com.qpidnetwork.livemodule.httprequest.item.ScheduleInviteGiftItem;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;

import java.util.List;

import static com.qpidnetwork.livemodule.utils.DisplayUtil.getResources;

/**
 * 预约礼物列表Adapter
 * Created by Jagger on 2017/9/22.
 */

public class BoolGiftAdapter extends RecyclerView.Adapter<BoolGiftAdapter.ViewHolder> {
    private Context mContext;
    private List<GiftItem> mDatas;
    private int selectedPosition = -1; //当前选中　默认一个参数
    private int selectedPrevious = -1; //上一次选中　默认一个参数

    public BoolGiftAdapter(List<GiftItem> datas) {
        this.mDatas = datas;
    }


    //创建新View，被LayoutManager所调用
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {
        mContext = viewGroup.getContext();
        View view = LayoutInflater.from(mContext).inflate(R.layout.item_live_book_vgift_list,viewGroup,false);
        ViewHolder vh = new ViewHolder(view);
        return vh;
    }

    //将数据与界面进行绑定的操作
    @Override
    public void onBindViewHolder(ViewHolder viewHolder, final int position) {
        final GiftItem item = mDatas.get(position);
        viewHolder.itemView.setSelected(selectedPosition == position);
        //照片
        if(!TextUtils.isEmpty(item.smallImgUrl)){
//            Log.i("Jagger" , "ad url:" + item.photoUrl);

            viewHolder.mImgPhoto.setImageURI(Uri.parse(item.smallImgUrl));
            viewHolder.mImgPhoto.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    //test
                }
            });
        }

        if (selectedPosition == position) {
            viewHolder.mLlBg.setBackgroundResource(R.drawable.rectangle_rounded_angle_light_violet_bg);
        } else {
            viewHolder.mLlBg.setBackgroundResource(R.drawable.rectangle_rounded_angle_gray_bg);
        }

        viewHolder.mImgPhoto.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(onItemClickListener != null){
                    onItemClickListener.OnItemClick(item);
                }
                selectedPosition = position; //选择的position赋值给参数，
                notifyItemChanged(selectedPrevious);//还原上一次点中的item
                notifyItemChanged(selectedPosition);//刷新当前点击item
                selectedPrevious = selectedPosition;//这次选中的成为上一次点中
            }
        });

    }

    //获取数据的数量
    @Override
    public int getItemCount() {
        if(mDatas == null){
            return 0;
        }else{
            return mDatas.size();
        }

    }

    //自定义的ViewHolder，持有每个Item的的所有界面元素
    public static class ViewHolder extends RecyclerView.ViewHolder {
        public LinearLayout mLlBg;
        public SimpleDraweeView mImgPhoto;

        public ViewHolder(View view){
            super(view);
            mImgPhoto = (SimpleDraweeView) view.findViewById(R.id.img_gift);
            mLlBg = (LinearLayout) view.findViewById(R.id.ll_book_gift_bg);
        }
    }

    private OnItemClickListener onItemClickListener;

    /**
     * 定义接口，实现Recyclerview点击事件
     */
    public interface OnItemClickListener {
        void OnItemClick(GiftItem giftItem);
    }


    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {   //实现点击
        this.onItemClickListener = onItemClickListener;
    }
}
