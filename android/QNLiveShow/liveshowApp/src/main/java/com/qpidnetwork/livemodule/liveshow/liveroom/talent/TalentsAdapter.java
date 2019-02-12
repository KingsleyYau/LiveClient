package com.qpidnetwork.livemodule.liveshow.liveroom.talent;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.OnGetGiftDetailCallback;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;

import java.util.List;

/**
 * 才艺列表Adapter
 * Created by Jagger on 2017/9/20.
 */

public class TalentsAdapter extends RecyclerView.Adapter<TalentsAdapter.ViewHolder> {
//    private final String TAG = "Jagger";//TalentsAdapter.class.getSimpleName();

    private final int REQUEST_GIFT_ICON_DOWNLOAD_SUCCESS = 1010;

    private Context mContext;
    private Handler mHandlerUI;
    private List<TalentInfoItem> mDatas;
    private onItemClickedListener mOnItemClickedListener;
    private int selectedPosition = -1; //默认一个参数
    private int oldPos = -1;

    /**
     * item点击事件
     * Created by Jagger on 2017/9/20.
     */
    public interface onItemClickedListener {
        void onDetailClicked(TalentInfoItem talent);
        void onSelected(TalentInfoItem talent);
    }

    public TalentsAdapter(List<TalentInfoItem> datas) {
        this.mDatas = datas;
    }

    public void setOnRequestClickedListener(onItemClickedListener l){
        mOnItemClickedListener = l;
    }

    //创建新View，被LayoutManager所调用
    @SuppressLint("HandlerLeak")
    @Override
    public ViewHolder onCreateViewHolder(ViewGroup viewGroup, int viewType) {
        mContext = viewGroup.getContext();
        View view = LayoutInflater.from(mContext).inflate(R.layout.item_live_talent,viewGroup,false);
        mHandlerUI = new Handler(){
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                switch (msg.what){
                    case REQUEST_GIFT_ICON_DOWNLOAD_SUCCESS:
                        notifyItemChanged(msg.arg1);
                        break;
                }
            }
        };

        ViewHolder vh = new ViewHolder(view);
        return vh;
    }

    //将数据与界面进行绑定的操作
    @Override
    public void onBindViewHolder(ViewHolder viewHolder, final int position) {
        final TalentInfoItem item = mDatas.get(position);
        //选中颜色
        viewHolder.itemView.setSelected(selectedPosition == position);
        if (selectedPosition == position) {
            viewHolder.mRlRoot.setBackgroundDrawable(mContext.getResources().getDrawable(R.drawable.ic_talent_list_item_selected_bg));
            viewHolder.mBtnDetail.setBackgroundResource(R.drawable.selector_live_btn_talent_details_focused);
        } else {
            viewHolder.mRlRoot.setBackgroundDrawable(mContext.getResources().getDrawable(R.color.transparent_full));
            viewHolder.mBtnDetail.setBackgroundResource(R.drawable.selector_live_btn_talent_details);
        }

        //文字
        viewHolder.mTextViewName.setText(item.talentName);
        viewHolder.mTextViewCredits.setText(mContext.getString(R.string.live_talent_gift,item.giftName));

        //礼物
        if(TextUtils.isEmpty(item.giftId)){
            viewHolder.mImgGift.setVisibility(View.GONE);
        }else{
            viewHolder.mImgGift.setVisibility(View.VISIBLE);
            String giftUrl = "";

            GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(item.giftId);
            if(giftItem != null && !TextUtils.isEmpty(giftItem.smallImgUrl)){
                giftUrl = giftItem.smallImgUrl;
            }else{
                NormalGiftManager.getInstance().getGiftDetail(item.giftId, new OnGetGiftDetailCallback() {
                    @Override
                    public void onGetGiftDetail(boolean isSuccess, int errCode, String errMsg, GiftItem giftDetail) {
                        //下载成功再刷新新界面，不然会死循环
                        if(isSuccess){
                            Message msg = new Message();
                            msg.what = REQUEST_GIFT_ICON_DOWNLOAD_SUCCESS;
                            msg.arg1 = position;
                            mHandlerUI.sendMessage(msg);
                        }
                    }
                });
            }
            viewHolder.mImgGift.setImageURI(giftUrl);
        }


        //查看详细
        viewHolder.mBtnDetail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //回调点击事件
                if(mOnItemClickedListener != null){
                    mOnItemClickedListener.onDetailClicked(item);
                }
            }
        });

        //ITEM点击
        viewHolder.itemView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                if (selectedPosition != -1) {
                    oldPos  = selectedPosition;
                }
                //选择的position赋值给参数，
                selectedPosition = position;
                if (oldPos != -1) {
                    //恢复上次点击item
                    notifyItemChanged(oldPos);
                }
                //刷新当前点击item
                notifyItemChanged(selectedPosition);

                //回调点击事件
                if(mOnItemClickedListener != null){
                    mOnItemClickedListener.onSelected(item);
                }
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
        public RelativeLayout mRlRoot;
        public TextView mTextViewName;
        public TextView mTextViewCredits;
        public TextView mBtnDetail;
        public SimpleDraweeView mImgGift;

        public ViewHolder(View view){
            super(view);
            mRlRoot = (RelativeLayout) view.findViewById(R.id.rl_itemRoot);
            mTextViewName = (TextView) view.findViewById(R.id.tv_talentName);
            mTextViewCredits = (TextView) view.findViewById(R.id.tv_talentCredits);
            mBtnDetail = (TextView) view.findViewById(R.id.tv_talentDetail);
            mImgGift = (SimpleDraweeView)view.findViewById(R.id.img_talentGift);
        }
    }
}
