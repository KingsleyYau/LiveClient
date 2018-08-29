package com.qpidnetwork.anchor.liveshow.personal.shows;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.httprequest.item.LoginItem;
import com.qpidnetwork.anchor.httprequest.item.ProgramInfoItem;
import com.qpidnetwork.anchor.httprequest.item.ProgramStatus;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.anchor.utils.DateUtil;
import com.qpidnetwork.anchor.view.ButtonRaised;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Jagger on 2018/4/23.
 */
public class ShowsAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    //开播前剩余时间(秒)
    private final int SEC_PROGRAMME_START = 0;
    //开播前倒数时间(秒)
    private final int SEC_PROGRAMME_COUNTDOWN = 30 * 60 ;


    private List<ProgramInfoItem> mList = new ArrayList<>();
    private Context mContext;
    private OnItemClickedListener mOnItemClickedListener;

    /**
     * 点击事件
     */
    public interface OnItemClickedListener{
        void onDetailClicked(ProgramInfoItem programInfoItem);
        void onStartShowClicked(ProgramInfoItem programInfoItem);
    }

    public ShowsAdapter(Context context, List<ProgramInfoItem> list){
        mContext = context;
        mList = list;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            //programme
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_live_calendar_list, parent, false);
            return new ViewHolderProgramme(view);
//        }
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
        ViewHolderProgramme viewHolder = (ViewHolderProgramme) holder;

        final ProgramInfoItem item = mList.get(position);

        viewHolder.imgCover.setImageURI(item.cover);
        viewHolder.tvStartTime.setText(DateUtil.getDateStr(item.startTime*1000l, DateUtil.FORMAT_MMMDDhmm_24));
        viewHolder.tvDuration.setText(mContext.getString(R.string.live_duration_time, String.valueOf(item.duration)));
        viewHolder.tvPrice.setText(String.valueOf(item.ticketNum));
        viewHolder.tvTitle.setText(item.showTitle);

        //读取主播个人信息
        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        if(loginItem != null){
            viewHolder.tvAnchorNickname.setText(loginItem.nickName);
            if(!TextUtils.isEmpty(loginItem.photoUrl))
            viewHolder.imgAnchorAvatar.setImageURI(loginItem.photoUrl);
        }else{
            viewHolder.tvAnchorNickname.setText("");
            viewHolder.imgAnchorAvatar.setImageResource(R.drawable.ic_default_photo_woman);
        }

        //整个点击(打开详细)
        viewHolder.llRootView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mOnItemClickedListener != null){
                    mOnItemClickedListener.onDetailClicked(item);
                }
            }
        });

        //局部刷新的UI
        doUILocalRefresh(viewHolder, item);
    }

    /**
     * 局部UI刷新
     * （用于定时器刷新节目开始倒计时， 只刷新部分UI）
     * @param viewHolder
     * @param item
     */
    private void doUILocalRefresh(ViewHolderProgramme viewHolder ,final ProgramInfoItem item){

        //开播标识(左上角)
        //按钮
        if (item.status == ProgramStatus.VerifyPass) {
            //节目有效
            if (item.leftSecToEnter <= SEC_PROGRAMME_START) {
                //开播中
                viewHolder.tvOnShow.setText(mContext.getString(R.string.live_programme_on_show));
                Drawable drawableLeft = mContext.getResources().getDrawable(R.drawable.ic_live_programme_onshow);
                // 这一步必须要做，否则不会显示。
                drawableLeft.setBounds(0,
                        0,
                        mContext.getResources().getDimensionPixelSize(R.dimen.live_size_14dp),
                        mContext.getResources().getDimensionPixelSize(R.dimen.live_size_14dp));// 设置图片宽高
                viewHolder.tvOnShow.setCompoundDrawables(drawableLeft, null, null, null);
                viewHolder.tvOnShow.setVisibility(View.VISIBLE);

                viewHolder.btnWatch.setButtonBackground(mContext.getResources().getColor(R.color.live_programme_list_btn_start_show));
                viewHolder.btnWatch.setButtonTitle(mContext.getString(R.string.live_programme_btn_start_show));
                viewHolder.btnWatch.setEnabled(true);
                viewHolder.btnWatch.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        if(mOnItemClickedListener != null){
                            mOnItemClickedListener.onStartShowClicked(item);
                        }
                    }
                });
            } else {
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

                viewHolder.btnWatch.setButtonBackground(mContext.getResources().getColor(R.color.live_programme_list_btn_canceled));
                viewHolder.btnWatch.setButtonTitle(mContext.getString(R.string.live_programme_btn_start_show));
                viewHolder.btnWatch.setEnabled(false);
            }
        } else if(item.status == ProgramStatus.ProgramEnd) {
            //节目正常结束
            viewHolder.tvOnShow.setVisibility(View.GONE);

            viewHolder.btnWatch.setButtonBackground(mContext.getResources().getColor(R.color.live_programme_list_btn_canceled));
            viewHolder.btnWatch.setButtonTitle(mContext.getString(R.string.live_programme_btn_finished));
            viewHolder.btnWatch.setEnabled(false);
        }else {
            viewHolder.tvOnShow.setVisibility(View.GONE);

            viewHolder.btnWatch.setButtonBackground(mContext.getResources().getColor(R.color.live_programme_list_btn_canceled));
            viewHolder.btnWatch.setButtonTitle(mContext.getString(R.string.live_programme_btn_cancelled));
            viewHolder.btnWatch.setEnabled(false);
        }
    }

    @Override
    public int getItemCount() {
        return mList.size();
    }

    /**
     * 节目View
     */
    static class ViewHolderProgramme extends RecyclerView.ViewHolder {
        public LinearLayout llRootView;
        public SimpleDraweeView imgCover , imgAnchorAvatar;
        public TextView tvOnShow , tvStartTime , tvDuration , tvPrice, tvTitle, tvAnchorNickname;
        public ButtonRaised btnWatch;

        public ViewHolderProgramme(View itemView) {
            super(itemView);
            llRootView = (LinearLayout)itemView.findViewById(R.id.ll_root);
            imgCover = (SimpleDraweeView)itemView.findViewById(R.id.img_cover);
            tvOnShow = (TextView)itemView.findViewById(R.id.tv_on_show);
            tvStartTime = (TextView)itemView.findViewById(R.id.tv_start_time);
            tvDuration = (TextView)itemView.findViewById(R.id.tv_duration);
            tvPrice = (TextView)itemView.findViewById(R.id.tv_price);
            btnWatch = (ButtonRaised)itemView.findViewById(R.id.btn_show);
            imgAnchorAvatar = (SimpleDraweeView)itemView.findViewById(R.id.img_room_logo);
            tvTitle = (TextView)itemView.findViewById(R.id.tv_room_title);
            tvAnchorNickname = (TextView)itemView.findViewById(R.id.tv_anchor_name);
        }
    }

    /**
     *
     * @param mOnItemClickedListener
     */
    public void setOnItemClickedListener(OnItemClickedListener mOnItemClickedListener) {
        this.mOnItemClickedListener = mOnItemClickedListener;
    }
}
