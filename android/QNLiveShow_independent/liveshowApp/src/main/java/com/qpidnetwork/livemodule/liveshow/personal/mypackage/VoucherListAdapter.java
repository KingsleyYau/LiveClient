package com.qpidnetwork.livemodule.liveshow.personal.mypackage;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.item.VoucherItem;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.squareup.picasso.Picasso;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/**
 * Created by Hunter on 17/9/28.
 */

public class VoucherListAdapter extends BaseAdapter {

    private Context mContext;
    private List<VoucherItem> mVoucherList;

    public VoucherListAdapter(Context context, List<VoucherItem> dataList){
        this.mContext = context;
        this.mVoucherList = dataList;
    }

    @Override
    public int getCount() {
        return mVoucherList.size();
    }

    @Override
    public Object getItem(int position) {
        return mVoucherList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        VoucherViewHolder holder;
        if(convertView == null){
            convertView = LayoutInflater.from(mContext).inflate(R.layout.adaper_package_voucher, parent, false);    //android:layout_above 无效的解决办法:不能使用 不能使用
            holder = new VoucherViewHolder(convertView);
        }else{
            holder = (VoucherViewHolder)convertView.getTag();
        }

        VoucherItem item = mVoucherList.get(position);

        //已读／未读
        if(item.isRead){
            holder.ivUnread.setVisibility(View.GONE);
        }else{
            holder.ivUnread.setVisibility(View.VISIBLE);
        }

        holder.tvDesc.setText(item.voucherDesc);

        //适用直播类型
        String schemeDesc = "";
        switch (item.useScheme){
            case Any:{
                schemeDesc = mContext.getResources().getString(R.string.my_package_voucher_nolimit_session);
            }break;
            case Private:{
                schemeDesc = mContext.getResources().getString(R.string.my_package_voucher_private_session);
            }break;
            case Public:{
                schemeDesc = mContext.getResources().getString(R.string.my_package_voucher_public_session);
            }break;
        }
        holder.tvSession.setText(schemeDesc);

        //适用主播类型
        LinearLayout.LayoutParams llUseLimitParams = (LinearLayout.LayoutParams)holder.llUseLimit.getLayoutParams();
        holder.civAnchor.setVisibility(View.GONE);
        holder.tvAnchorName.setVisibility(View.GONE);
        llUseLimitParams.topMargin = DisplayUtil.dip2px(mContext, 42);  //默认42，当和指定主播时，调整为13
        String useRoleDesc = "";
        switch (item.useRole){
            case Any:{
                useRoleDesc = mContext.getResources().getString(R.string.my_package_voucher_nolimit_performer);
            }break;
            case NeverLive:{
                useRoleDesc = mContext.getResources().getString(R.string.my_package_voucher_new_performer);
            }break;
            case SpecialAnchor:{
                useRoleDesc = mContext.getResources().getString(R.string.my_package_voucher_special_performer);
                llUseLimitParams.topMargin = DisplayUtil.dip2px(mContext, 13);
                holder.civAnchor.setVisibility(View.VISIBLE);
                holder.tvAnchorName.setVisibility(View.VISIBLE);
                holder.tvAnchorName.setText(item.anchorNickname);
                holder.civAnchor.setImageResource(R.drawable.ic_default_photo_woman);
                if(!TextUtils.isEmpty(item.anchorPhotoUrl)) {
                    Picasso.with(mContext).load(item.anchorPhotoUrl)
                            .error(R.drawable.ic_default_photo_woman)
                            .placeholder(R.drawable.ic_default_photo_woman)
                            .into(holder.civAnchor);
                }
            }break;
        }
        holder.tvPerformer.setText(useRoleDesc);

        //到期时间
        holder.tvExpire.setText(String.format(mContext.getResources().getString(R.string.my_package_voucher_valid_time_1line),
                new SimpleDateFormat("MMM dd HH:mm" , Locale.ENGLISH).format(new Date(((long)item.startValidDate) * 1000)),
                new SimpleDateFormat("MMM dd HH:mm" , Locale.ENGLISH).format(new Date(((long)item.expDate) * 1000))));

        //试聊券图片加载
        holder.ivThumb.setImageResource(R.drawable.bg_covermanager_tran);
        if(!TextUtils.isEmpty(item.voucherPhotoUrlMobile)) {
            Picasso.with(mContext).load(item.voucherPhotoUrlMobile)
                    .error(R.drawable.bg_covermanager_tran)
                    .placeholder(R.drawable.bg_covermanager_tran)
                    .into(holder.ivThumb);
        }

        return convertView;
    }

    private class VoucherViewHolder{

        public VoucherViewHolder(){

        }

        public VoucherViewHolder(View convertView){
            ivThumb = (ImageView)convertView.findViewById(R.id.ivThumb);
            tvDesc = (TextView)convertView.findViewById(R.id.tvDesc);
            tvSession = (TextView)convertView.findViewById(R.id.tvSession);
            tvPerformer = (TextView)convertView.findViewById(R.id.tvPerformer);
            civAnchor = (CircleImageView)convertView.findViewById(R.id.civAnchor);
            tvAnchorName = (TextView)convertView.findViewById(R.id.tvAnchorName);
            tvExpire = (TextView)convertView.findViewById(R.id.tvExpire);
            ivUnread = (ImageView)convertView.findViewById(R.id.ivUnread);
            llUseLimit = (LinearLayout)convertView.findViewById(R.id.llUseLimit);
            convertView.setTag(this);
        }

        public ImageView ivThumb;
        public TextView tvDesc;
        public TextView tvSession;
        public TextView tvPerformer;
        public CircleImageView civAnchor;
        public TextView tvAnchorName;
        public TextView tvExpire;
        public ImageView ivUnread;
        public LinearLayout llUseLimit;     //用于是否限定主播时高度调整
    }
}
