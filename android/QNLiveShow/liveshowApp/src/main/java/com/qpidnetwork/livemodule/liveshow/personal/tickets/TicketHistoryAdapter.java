package com.qpidnetwork.livemodule.liveshow.personal.tickets;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.ProgramInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.ProgramStatus;
import com.qpidnetwork.livemodule.httprequest.item.ProgramTicketStatus;
import com.qpidnetwork.livemodule.liveshow.home.CalendarAdapter;
import com.qpidnetwork.livemodule.utils.ButtonUtils;
import com.qpidnetwork.livemodule.utils.DateUtil;

import java.util.List;

/**
 * Created by Jagger on 2018/5/7.
 * 基于节目列表Adapter而处理MyTicked中History的特殊情况
 */
public class TicketHistoryAdapter extends CalendarAdapter {

    public TicketHistoryAdapter(Context context, List<ProgramInfoItem> list) {
        super(context, list);
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        if(holder instanceof ViewHolderProgramme) {
            ViewHolderProgramme viewHolder = (ViewHolderProgramme) holder;
            final ProgramInfoItem item = mList.get(position);

            viewHolder.imgCover.setImageURI(item.cover);
            viewHolder.imgAnchorAvatar.setImageURI(item.anchorAvatar);

            doUILocalRefresh(viewHolder , item);
        }
    }

    @Override
    protected void doUILocalRefresh(ViewHolderProgramme viewHolder,final ProgramInfoItem item) {
        viewHolder.tvStartTime.setText(DateUtil.getDateStr(item.startTime * 1000l, DateUtil.FORMAT_MMMDDhmm_24));
        viewHolder.tvDuration.setText(mContext.getString(R.string.live_duration_time, String.valueOf(item.duration)));
        viewHolder.tvPrice.setText(mContext.getString(R.string.live_credits, String.valueOf(item.price)));
        viewHolder.tvTitle.setText(item.showTitle);
        viewHolder.tvAnchorNickname.setText(item.anchorNickname);
        viewHolder.tvTips.setVisibility(View.GONE);
        viewHolder.btnOtherShows.setVisibility(View.GONE);

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

        //开播标识(左上角)
        viewHolder.tvOnShow.setVisibility(View.GONE);

        //按钮
        if (item.status == ProgramStatus.ProgramCancel) {
            //节目已取消(灰色)
            viewHolder.btnWatch.setButtonBackground(mContext.getResources().getColor(R.color.live_programme_list_btn_canceled));
            viewHolder.btnWatch.setButtonTitle(mContext.getString(R.string.live_programme_btn_refunded));
            viewHolder.btnWatch.setEnabled(false);
        } else {
            //节目已正常结束 (灰色)
            viewHolder.btnWatch.setButtonBackground(mContext.getResources().getColor(R.color.live_programme_list_btn_canceled));
            viewHolder.btnWatch.setButtonTitle(mContext.getString(R.string.live_programme_btn_finished));
            viewHolder.btnWatch.setEnabled(false);
        }

        //节目已退票 (灰色)
        if(item.ticketStatus == ProgramTicketStatus.Refund){
            viewHolder.btnWatch.setButtonBackground(mContext.getResources().getColor(R.color.live_programme_list_btn_canceled));
            viewHolder.btnWatch.setButtonTitle(mContext.getString(R.string.live_programme_btn_refunded));
            viewHolder.btnWatch.setEnabled(false);
        }
    }
}
