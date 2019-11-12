package com.qpidnetwork.livemodule.liveshow.personal.mypackage;

import android.content.Context;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.RideItem;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/**
 * Created by Hunter on 17/9/29.
 */

public class PackageRidersAdapter extends BaseAdapter{

    private Context mContext;
    private List<RideItem> mRideList;
    private OnRideButtonClickListener mListener;

    public PackageRidersAdapter(Context context, List<RideItem> rideList){
        this.mContext = context;
        this.mRideList = rideList;
    }

    /**
     * 设置事件监听
     * @param listener
     */
    public void setOnRideButtonClickListener(OnRideButtonClickListener listener){
        this.mListener = listener;
    }

    @Override
    public int getCount() {
        return mRideList.size();
    }

    @Override
    public Object getItem(int position) {
        return mRideList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return 0;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if(convertView == null){
            convertView = LayoutInflater.from(mContext).inflate(R.layout.adapter_package_rider, parent, false);
            holder = new ViewHolder(convertView);
        }else{
            holder = (ViewHolder)convertView.getTag();
        }

        //处理item固定高度
//        AbsListView.LayoutParams params = (AbsListView.LayoutParams)convertView.getLayoutParams();
//        int contentWidth = (DisplayUtil.getScreenWidth(mContext) - DisplayUtil.dip2px(mContext, 13 * 2 + 9))/2;
//        //宽度加上头部padding
//        params.height = contentWidth + DisplayUtil.dip2px(mContext, 14);
//
//        //设置图片大小
//        LinearLayout.LayoutParams photoParams = (LinearLayout.LayoutParams)holder.ivRidePhoto.getLayoutParams();
//        photoParams.height = (contentWidth * 186)/340;
//        photoParams.width = (contentWidth * 186)/340;

        final RideItem item = mRideList.get(position);

        holder.tvRideName.setText(item.name);

        //已读／未读
        if(item.isRead){
            holder.ivUnread.setVisibility(View.GONE);
        }else{
            holder.ivUnread.setVisibility(View.VISIBLE);
        }

        if(item.isUsing){
            holder.btnRide.setBackgroundResource(R.drawable.rectangle_radius6_ripple_solid_sky_blue);
            holder.btnRide.setTextColor(mContext.getResources().getColor(R.color.white));
            holder.btnRide.setText(mContext.getResources().getString(R.string.my_package_rider_riding));
        }else{
            holder.btnRide.setBackgroundResource(R.drawable.rectangle_radius6_ripple_solid_white_stroke_sky_blue);
            holder.btnRide.setTextColor(mContext.getResources().getColor(R.color.text_color_dark));
            holder.btnRide.setText(mContext.getResources().getString(R.string.my_package_rider_ride));
        }

        holder.btnRide.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mListener != null){
                    mListener.onRideClick(item);
                }
            }
        });

        //到期时间
        holder.tvRiderExpire.setText(String.format(mContext.getResources().getString(R.string.my_package_voucher_valid_time_2line),
                new SimpleDateFormat("MMM dd HH:mm" , Locale.ENGLISH).format(new Date(((long)item.startValidDate) * 1000)),
                new SimpleDateFormat("MMM dd HH:mm" , Locale.ENGLISH).format(new Date(((long)item.expDate) * 1000))));

        //礼物图片
        holder.ivRidePhoto.setImageResource(R.drawable.ic_package_rider_default);
        if(!TextUtils.isEmpty(item.photoUrl)) {
//            Picasso.with(mContext)
//                    .load(item.photoUrl)
//                    .error(R.drawable.ic_package_rider_default)
//                    .placeholder(R.drawable.ic_package_rider_default)
//                    .into(holder.ivRidePhoto);
            PicassoLoadUtil.loadUrl(holder.ivRidePhoto,item.photoUrl,R.drawable.ic_package_rider_default);
        }

        return convertView;
    }

    private class ViewHolder{

        public ViewHolder(){

        }

        public ViewHolder(View convertView){
            ivRidePhoto = (ImageView)convertView.findViewById(R.id.ivRidePhoto);
            tvRideName = (TextView)convertView.findViewById(R.id.tvRideName);
            btnRide = (Button)convertView.findViewById(R.id.btnRide);
            tvRiderExpire = (TextView)convertView.findViewById(R.id.tvRiderExpire);
            ivUnread = (ImageView)convertView.findViewById(R.id.ivUnread);
            convertView.setTag(this);
        }

        public ImageView ivRidePhoto;
        public TextView tvRideName;
        public Button btnRide;
        public TextView tvRiderExpire;
        public ImageView ivUnread;
    }

    public interface OnRideButtonClickListener{
        void onRideClick(RideItem item);
    }

}
