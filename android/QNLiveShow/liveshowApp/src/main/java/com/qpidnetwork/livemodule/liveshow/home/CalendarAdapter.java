package com.qpidnetwork.livemodule.liveshow.home;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.drawable.Drawable;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.ProgramInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.ProgramStatus;
import com.qpidnetwork.livemodule.httprequest.item.ProgramTicketStatus;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.utils.ButtonUtils;
import com.qpidnetwork.livemodule.utils.DateUtil;
import com.qpidnetwork.livemodule.view.ButtonRaised;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Jagger on 2018/4/23.
 */
public class CalendarAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    //开播前剩余时间(秒)
    protected final int SEC_PROGRAMME_START = 0;
    //开播前倒数时间(秒)
    protected final int SEC_PROGRAMME_COUNTDOWN = 30 * 60 ;

    //变量
    protected List<ProgramInfoItem> mList = new ArrayList<>();
    protected Context mContext;
    protected OnItemClickedListener mOnItemClickedListener;

    /**
     * 设置票据事件监听器
     */
    public void setOnTicketEventListener(OnItemClickedListener mOnItemClickedListener) {
        this.mOnItemClickedListener = mOnItemClickedListener;
    }

    /**
     * 票据事件监听器
     */
    public interface OnItemClickedListener {
        void onDetailClicked(ProgramInfoItem programInfoItem);
        void onWatchClicked(ProgramInfoItem programInfoItem);
        void onGetTicketClicked(ProgramInfoItem programInfoItem);
    }

    @SuppressLint("HandlerLeak")
    public CalendarAdapter(Context context, List<ProgramInfoItem> list){
        mContext = context;
        mList = list;
    }

    @Override
    public int getItemViewType(int position) {
        // TODO Auto-generated method stub
        //判断ITEM类别 加载不同VIEW HOLDER
        ProgramInfoItem item = mList.get(position);
        return item.type;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        if(viewType == ProgramInfoItem.TYPE.Introduction.ordinal()){
            //Introduction
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.view_live_calendar_list_header, parent, false);
            return new ViewHolderIntroduction(view);
        }else{
            //programme
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_live_calendar_list, parent, false);
            return new ViewHolderProgramme(view);
        }
    }

    /**
     * 局部刷新
     * @param holder
     * @param position
     * @param payloads
     */
    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position, List<Object> payloads) {
        //防止out of index
        if(position < 0 || position > mList.size()-1){
            return;
        }

        if(payloads.isEmpty()){
            onBindViewHolder(holder, position);
        }else{
            if(holder instanceof ViewHolderProgramme) {
                ViewHolderProgramme viewHolder = (ViewHolderProgramme) holder;
                final ProgramInfoItem item = mList.get(position);

                //局部刷新的UI
                doUILocalRefresh(viewHolder, item);
            }
        }

    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        if(holder instanceof ViewHolderProgramme) {
            ViewHolderProgramme viewHolder = (ViewHolderProgramme) holder;

            final ProgramInfoItem item = mList.get(position);

            viewHolder.imgCover.setImageURI(item.cover);
            viewHolder.tvStartTime.setText(DateUtil.getDateStr(item.startTime*1000l, DateUtil.FORMAT_MMMDDhmm_24));
            viewHolder.tvDuration.setText(mContext.getString(R.string.live_duration_time, String.valueOf(item.duration)));
            viewHolder.tvPrice.setText(mContext.getString(R.string.live_credits, String.valueOf(item.price)));
            viewHolder.imgAnchorAvatar.setImageURI(item.anchorAvatar);
            viewHolder.tvTitle.setText(item.showTitle);
            viewHolder.tvAnchorNickname.setText(item.anchorNickname);

            //整个点击(打开详细)
            viewHolder.llRootView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if(!ButtonUtils.isFastDoubleClick(v.getId())) {
                        doOpenDetail(item);
                    }
                }
            });

            //是否关注
            if (item.isHasFollow) {
                viewHolder.imgFollow.setImageResource(R.drawable.ic_live_programme_follow);
            } else {
                viewHolder.imgFollow.setImageResource(R.drawable.ic_live_programme_unfollow);
            }

            //局部刷新的UI
            doUILocalRefresh(viewHolder, item);

        }else if(holder instanceof  ViewHolderIntroduction){
            ViewHolderIntroduction viewHolder = (ViewHolderIntroduction) holder;

            ProgramInfoItem item = mList.get(position);

            viewHolder.tvDes.setText(item.des);
        }

    }

    /**
     * 局部UI刷新
     * （用于定时器刷新节目开始倒计时， 只刷新部分UI）
     * @param viewHolder
     * @param item
     */
    protected void doUILocalRefresh(ViewHolderProgramme viewHolder ,final ProgramInfoItem item){
        //开播标识(左上角)
        //按钮
        if (item.status == ProgramStatus.VerifyPass) {
            //准备开始,开始中 (绿色)
            if (item.leftSecToEnter <= SEC_PROGRAMME_START) {
                //开播中
                viewHolder.tvOnShow.setText(mContext.getString(R.string.live_programme_on_show));
                Drawable drawableLeft = mContext.getResources().getDrawable(R.drawable.ic_live_programme_onshow);
                // 这一步必须要做，否则不会显示。
                drawableLeft.setBounds(0,
                        0,
                        mContext.getResources().getDimensionPixelSize(R.dimen.live_size_14dp),
                        mContext.getResources().getDimensionPixelSize(R.dimen.live_size_14dp));// 设置图片宽高
                viewHolder.tvOnShow.setCompoundDrawables(drawableLeft , null , null , null);
                viewHolder.tvOnShow.setVisibility(View.VISIBLE);

                viewHolder.btnWatch.setButtonBackground(mContext.getResources().getColor(R.color.live_programme_list_btn_watch));
                viewHolder.btnWatch.setButtonTitle(mContext.getString(R.string.live_programme_btn_watch_now));
                viewHolder.btnWatch.setEnabled(true);
                viewHolder.btnWatch.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if(!ButtonUtils.isFastDoubleClick(v.getId())) {
                            doWatchNow(item);
                        }
                    }
                });

                viewHolder.btnOtherShows.setVisibility(View.GONE);

                //已购票提示
                if (item.ticketStatus == ProgramTicketStatus.Buy) {
                    viewHolder.tvTips.setText(mContext.getString(R.string.live_programme_reserved));
                    viewHolder.tvTips.setVisibility(View.VISIBLE);
                }else {
                    viewHolder.tvTips.setVisibility(View.GONE);
                }
            } else {
                //未开始
                if (item.leftSecToStart <= SEC_PROGRAMME_COUNTDOWN) {
                    //开播前30分钟
                    viewHolder.tvOnShow.setText(mContext.getString(
                            R.string.live_programme_on_show_countdown,
                            String.valueOf(item.leftSecToStart / 60 == 0 ? 1 : (item.leftSecToStart / 60) + (item.leftSecToStart % 60 == 0 ? 0:1))//余0不加1
                    ));
                    Drawable drawableLeft = mContext.getResources().getDrawable(R.drawable.ic_live_programme_countdown);
                    // 这一步必须要做，否则不会显示。
                    drawableLeft.setBounds(0,
                            0,
                            mContext.getResources().getDimensionPixelSize(R.dimen.live_size_14dp),
                            mContext.getResources().getDimensionPixelSize(R.dimen.live_size_14dp));// 设置图片宽高
                    viewHolder.tvOnShow.setCompoundDrawables(drawableLeft, null, null, null);
                    viewHolder.tvOnShow.setVisibility(View.VISIBLE);
                }else {
                    //开播剩余时间>30分钟
                    viewHolder.tvOnShow.setVisibility(View.GONE);
                }

                if (item.ticketStatus == ProgramTicketStatus.Buy) {
                    //未开始,已购票 (淡橙色)
                    viewHolder.btnWatch.setButtonBackground(mContext.getResources().getColor(R.color.live_programme_list_btn_reserved));
                    viewHolder.btnWatch.setButtonTitle(mContext.getString(R.string.live_programme_btn_reserved));
                    viewHolder.btnWatch.setEnabled(false);

                    viewHolder.btnOtherShows.setVisibility(View.GONE);

                    viewHolder.tvTips.setVisibility(View.GONE);
                } else {
                    if (!item.isTicketFull) {
                        //未开始,可购票 (橙色)
                        viewHolder.btnWatch.setButtonBackground(mContext.getResources().getColor(R.color.live_programme_list_btn_get_ticket));
                        viewHolder.btnWatch.setButtonTitle(mContext.getString(R.string.live_programme_btn_get_ticket));
                        viewHolder.btnWatch.setEnabled(true);
                        viewHolder.btnWatch.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                if(!ButtonUtils.isFastDoubleClick(v.getId())) {
                                    doGetTicket(item);
                                }
                            }
                        });

                        viewHolder.btnOtherShows.setVisibility(View.GONE);

                        viewHolder.tvTips.setVisibility(View.GONE);
                    } else {
                        //未开始,没票卖 (灰色)
                        viewHolder.btnWatch.setButtonBackground(mContext.getResources().getColor(R.color.live_programme_list_btn_canceled));
                        viewHolder.btnWatch.setButtonTitle(mContext.getString(R.string.live_programme_btn_no_tickets_left));
                        viewHolder.btnWatch.setEnabled(false);

                        viewHolder.btnOtherShows.setVisibility(View.VISIBLE);
                        viewHolder.btnOtherShows.setOnClickListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                if(!ButtonUtils.isFastDoubleClick(v.getId())) {
                                    doToOtherShows(item);
                                }
                            }
                        });

                        viewHolder.tvTips.setVisibility(View.GONE);
                    }
                }
            }
        } else {
            //主播失约, 节目被取消 (灰色)
            viewHolder.btnWatch.setButtonBackground(mContext.getResources().getColor(R.color.live_programme_list_btn_canceled));
            viewHolder.btnWatch.setButtonTitle(mContext.getString(R.string.live_programme_btn_cancelled));
            viewHolder.btnWatch.setEnabled(false);

            viewHolder.tvOnShow.setVisibility(View.GONE);
            viewHolder.btnOtherShows.setVisibility(View.GONE);

            if(item.ticketStatus == ProgramTicketStatus.Refund){
                //已退票
                viewHolder.tvTips.setText(mContext.getString(R.string.live_programme_refunded));
                viewHolder.tvTips.setVisibility(View.VISIBLE);
            }else {
                viewHolder.tvTips.setVisibility(View.GONE);
            }
        }
    }

    @Override
    public int getItemCount() {
        return mList.size();
    }

    /**
     * 节目View
     */
    protected static class ViewHolderProgramme extends RecyclerView.ViewHolder {
        public LinearLayout llRootView;
        public SimpleDraweeView imgCover , imgAnchorAvatar;
        public TextView tvOnShow , tvStartTime , tvDuration , tvPrice, tvTitle, tvAnchorNickname , tvTips;
        public ImageView imgFollow;
        public ButtonRaised btnWatch, btnOtherShows;

        public ViewHolderProgramme(View itemView) {
            super(itemView);
            llRootView = (LinearLayout)itemView.findViewById(R.id.ll_root);
            imgCover = (SimpleDraweeView)itemView.findViewById(R.id.img_cover);
            tvOnShow = (TextView)itemView.findViewById(R.id.tv_on_show);
            tvStartTime = (TextView)itemView.findViewById(R.id.tv_start_time);
            tvDuration = (TextView)itemView.findViewById(R.id.tv_duration);
            tvPrice = (TextView)itemView.findViewById(R.id.tv_price);
            imgFollow = (ImageView)itemView.findViewById(R.id.img_follow);
            btnWatch = (ButtonRaised)itemView.findViewById(R.id.btn_watch);
            imgAnchorAvatar = (SimpleDraweeView)itemView.findViewById(R.id.img_room_logo);
            tvTitle = (TextView)itemView.findViewById(R.id.tv_room_title);
            tvAnchorNickname = (TextView)itemView.findViewById(R.id.tv_anchor_name);
            tvTips  = (TextView)itemView.findViewById(R.id.tv_tips);
            btnOtherShows = (ButtonRaised)itemView.findViewById(R.id.btn_other_shows);
        }
    }

    /**
     * 介绍View
     */
    protected static class ViewHolderIntroduction extends RecyclerView.ViewHolder {
        public TextView tvDes;

        public ViewHolderIntroduction(View itemView){
            super(itemView);
            tvDes = (TextView)itemView.findViewById(R.id.tv_introduction_des);
        }
    }

    /**
     * 点击详情响应
     */
    protected void doOpenDetail(ProgramInfoItem item){
        if(mOnItemClickedListener != null){
            mOnItemClickedListener.onDetailClicked(item);
        }
    }

    /**
     * 点击Watch响应
     */
    protected void doWatchNow(ProgramInfoItem item){
        if(mOnItemClickedListener != null){
            mOnItemClickedListener.onWatchClicked(item);
        }
    }

    /**
     * 购票
     */
    protected void doGetTicket(final ProgramInfoItem item){
        if(mOnItemClickedListener != null){
            mOnItemClickedListener.onGetTicketClicked(item);
        }
    }

    /**
     * 跳转主播资料页
     */
    protected void doToOtherShows(ProgramInfoItem item){
      AnchorProfileActivity.launchAnchorInfoActivty(mContext,
                mContext.getResources().getString(R.string.live_webview_anchor_profile_title),
                item.anchorId,
                false,
                AnchorProfileActivity.TagType.MyCalendar);
    }
}
