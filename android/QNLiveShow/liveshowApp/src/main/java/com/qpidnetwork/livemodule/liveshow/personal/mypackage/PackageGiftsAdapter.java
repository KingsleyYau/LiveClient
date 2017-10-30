package com.qpidnetwork.livemodule.liveshow.personal.mypackage;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.squareup.picasso.Picasso;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/**
 * Created by Hunter on 17/9/29.
 */

public class PackageGiftsAdapter extends BaseAdapter{

    private Context mContext;
    private List<PackageGiftItem> mPackageGiftList;
    private NormalGiftManager mNormalGiftManager;

    public PackageGiftsAdapter(Context context, List<PackageGiftItem> giftList){
        this.mContext = context;
        mPackageGiftList = giftList;
        mNormalGiftManager = NormalGiftManager.getInstance();
    }

    @Override
    public int getCount() {
        return mPackageGiftList.size();
    }

    @Override
    public Object getItem(int position) {
        return mPackageGiftList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        ViewHolder holder;
        if(convertView == null){
            convertView = LayoutInflater.from(mContext).inflate(R.layout.adapter_package_gifts, parent, false);
            holder = new ViewHolder(convertView);
        }else{
            holder = (ViewHolder)convertView.getTag();
        }

        //处理item固定高度
        AbsListView.LayoutParams params = (AbsListView.LayoutParams)convertView.getLayoutParams();
        params.height = (DisplayUtil.getScreenWidth(mContext) - DisplayUtil.dip2px(mContext, 14 * 4))/3;

        LinearLayout.LayoutParams photoParams = (LinearLayout.LayoutParams)holder.ivGiftPhoto.getLayoutParams();
        photoParams.height = (params.height * 3)/5;
        photoParams.width = (params.height * 3)/5;

        PackageGiftItem item = mPackageGiftList.get(position);
        GiftItem giftItem = mNormalGiftManager.getLocalGiftDetail(item.giftId);

        //已读／未读
        if(item.isRead){
            holder.ivUnread.setVisibility(View.GONE);
        }else{
            holder.ivUnread.setVisibility(View.VISIBLE);
        }

        if(giftItem != null) {
            holder.tvGiftName.setText(giftItem.name);
        }else{
            holder.tvGiftName.setText(item.giftId);
        }

        //礼物数目
        if(item.num > 0){
            holder.tvGiftNum.setVisibility(View.VISIBLE);
            if(item.num >= 10){
                holder.tvGiftNum.setTextSize(8);
                if(item.num >= 100){
                    holder.tvGiftNum.setText(String.valueOf(99));
                }else{
                    holder.tvGiftNum.setText(String.valueOf(item.num));
                }
            }else{
                holder.tvGiftNum.setTextSize(11);
                holder.tvGiftNum.setText(String.valueOf(item.num));
            }
        }else{
            holder.tvGiftNum.setVisibility(View.GONE);
        }

        //到期时间
        holder.tvGiftExpire.setText(String.format(mContext.getResources().getString(R.string.my_package_gift_expired_desc),
                new SimpleDateFormat("MM/dd/yyyy").format(new Date(((long)item.expiredDate) * 1000))));

        //礼物图片
        holder.ivGiftPhoto.setImageResource(R.drawable.ic_live_buttom_gift_freepublic);
        if(giftItem != null && !TextUtils.isEmpty(giftItem.middleImgUrl)) {
            Picasso.with(mContext).load(giftItem.middleImgUrl)
                    .error(R.drawable.ic_live_buttom_gift_freepublic)
                    .placeholder(R.drawable.ic_live_buttom_gift_freepublic)
                    .into(holder.ivGiftPhoto);
        }

        return convertView;
    }

    private class ViewHolder{

        public ViewHolder(){

        }

        public ViewHolder(View convertView){
            ivGiftPhoto = (ImageView)convertView.findViewById(R.id.ivGiftPhoto);
            tvGiftName = (TextView)convertView.findViewById(R.id.tvGiftName);
            tvGiftExpire = (TextView)convertView.findViewById(R.id.tvGiftExpire);
            tvGiftNum = (TextView)convertView.findViewById(R.id.tvGiftNum);
            ivUnread = (ImageView)convertView.findViewById(R.id.ivUnread);
            convertView.setTag(this);
        }

        public ImageView ivGiftPhoto;
        public TextView tvGiftName;
        public TextView tvGiftExpire;
        public TextView tvGiftNum;
        public ImageView ivUnread;
    }
}
