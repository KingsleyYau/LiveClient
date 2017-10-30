package com.qpidnetwork.livemodule.liveshow.personal.mypackage;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.item.VoucherItem;
import com.squareup.picasso.Picasso;

import org.w3c.dom.Text;

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
            convertView = LayoutInflater.from(mContext).inflate(R.layout.adaper_package_voucher, null);
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
        holder.civAnchor.setVisibility(View.GONE);
        holder.tvAnchorName.setVisibility(View.GONE);
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
        holder.tvExpire.setText(String.format(mContext.getResources().getString(R.string.my_package_voucher_expired_desc),
                new SimpleDateFormat("MM/dd/yyyy").format(new Date(((long)item.expDate) * 1000))));

        //试聊券图片加载
        holder.ivThumb.setImageResource(R.drawable.voucher);
        if(!TextUtils.isEmpty(item.voucherPhotoUrl)) {
            Picasso.with(mContext).load(item.voucherPhotoUrl)
                    .error(R.drawable.voucher)
                    .placeholder(R.drawable.voucher)
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
            convertView.setTag(this);
        }

        public ImageView ivThumb;
        public TextView tvDesc;
        public TextView tvSession;
        public TextView tvPerformer;
        public CircleImageView civAnchor;
        public TextView tvAnchorName;
        private TextView tvExpire;
        public ImageView ivUnread;
    }
}
