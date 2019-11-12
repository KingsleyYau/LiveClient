package com.qpidnetwork.livemodule.liveshow.personal.mycontact;

import android.content.Context;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.AnchorOnlineStatus;
import com.qpidnetwork.livemodule.httprequest.item.ContactItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.utils.HotItemStyleManager;

/**
 * Created by Hardy on 2019/8/9.
 */
public class MyContactsAdapter extends BaseRecyclerViewAdapter<ContactItem, MyContactsAdapter.MyContactsViewHolder> {

    private int iconWh;

    public MyContactsAdapter(Context context) {
        super(context);

        iconWh = context.getResources().getDimensionPixelSize(R.dimen.live_size_40dp);
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_my_contact;
    }

    @Override
    public MyContactsViewHolder getViewHolder(View itemView, int viewType) {
        return new MyContactsViewHolder(itemView);
    }

    @Override
    public void initViewHolder(final MyContactsViewHolder holder) {
        holder.setIconWh(iconWh);

        holder.mIvIcon.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (iMyContactsOperateListener != null) {
                    iMyContactsOperateListener.onClickIcon(getPosition(holder));
                }
            }
        });

        holder.mLlContent.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (iMyContactsOperateListener != null) {
                    iMyContactsOperateListener.onClickItem(getPosition(holder));
                }
            }
        });

        holder.mIvFunLeft.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (iMyContactsOperateListener != null) {
                    iMyContactsOperateListener.onClickFunClick(getPosition(holder), holder.getBtnLeftFunEnum());
                }
            }
        });

        holder.mIvFunRight.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (iMyContactsOperateListener != null) {
                    iMyContactsOperateListener.onClickFunClick(getPosition(holder), holder.getBtnRightFunEnum());
                }
            }
        });
    }

    @Override
    public void convertViewHolder(MyContactsViewHolder holder, ContactItem data, int position) {
        holder.setData(data, position);
    }


    private IMyContactsOperateListener iMyContactsOperateListener;

    public void setMyContactsOperateListener(IMyContactsOperateListener iMyContactsOperateListener) {
        this.iMyContactsOperateListener = iMyContactsOperateListener;
    }

    public interface IMyContactsOperateListener {
        void onClickIcon(int pos);

        void onClickItem(int pos);

        void onClickFunClick(int pos, MyContactsFunEnum myContactsFunEnum);
    }


    /**
     * ViewHolder
     */
    static class MyContactsViewHolder extends BaseViewHolder<ContactItem> {

        private View mLlContent;
        private View mOnline;
        private SimpleDraweeView mIvIcon;
        private TextView mTvName;
        private TextView mTvLive;
        private TextView mTvTime;
        private ImageView mIvFunLeft;
        private ImageView mIvFunRight;

        private int iconWh;

        public MyContactsViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            mLlContent = f(R.id.item_my_contact_ll_content);
            mIvIcon = f(R.id.item_my_contact_iv_icon);
            mOnline = f(R.id.item_my_contact_online);
            mTvName = f(R.id.item_my_contact_tv_name);
            mTvLive = f(R.id.item_my_contact_tv_live);
            mTvTime = f(R.id.item_my_contact_tv_time);
            mIvFunLeft = f(R.id.item_my_contact_iv_fun_left);
            mIvFunRight = f(R.id.item_my_contact_iv_fun_right);
        }

        @Override
        public void setData(ContactItem data, int position) {
            FrescoLoadUtil.loadUrl(context, mIvIcon, data.avatarImg, iconWh,
                    R.drawable.ic_default_photo_woman, true);

            mTvName.setText(data.nickName);

            mTvLive.setVisibility(HotItemStyleManager.isLiveIng(data.roomType) ?
                    View.VISIBLE : View.GONE);

            mTvTime.setText(data.lastContactTimeString);

            // 设置默认隐藏
            mIvFunLeft.setVisibility(View.GONE);
            mIvFunRight.setVisibility(View.GONE);
            if (data.onlineStatus == AnchorOnlineStatus.Online) {
                // 在线
                mOnline.setVisibility(View.VISIBLE);

                if (data.priv != null && data.priv.isHasOneOnOneAuth) {
                    setBtnType(mIvFunLeft, MyContactsFunEnum.ONE_ON_ONE);
                    setBtnType(mIvFunRight, MyContactsFunEnum.CHAT);
                } else {
                    setBtnType(mIvFunLeft, MyContactsFunEnum.CHAT);
                    setBtnType(mIvFunRight, MyContactsFunEnum.MAIL);
                }
            } else {
                // 离线
                mOnline.setVisibility(View.GONE);

                setBtnType(mIvFunLeft, MyContactsFunEnum.MAIL);
                if (data.priv != null && data.priv.isHasBookingAuth) {
                    setBtnType(mIvFunRight, MyContactsFunEnum.BOOKING);
                } else {
                    mIvFunRight.setVisibility(View.GONE);
                }
            }
        }

        private void setBtnType(ImageView iv, MyContactsFunEnum type) {
            iv.setVisibility(View.VISIBLE);
            iv.setTag(type);

            switch (type) {
                case ONE_ON_ONE:
                    iv.setImageResource(R.drawable.ic_live_circle_one_on_one);
                    break;

                case CHAT:
                    iv.setImageResource(R.drawable.ic_live_circle_chat);
                    break;

                case MAIL:
                    iv.setImageResource(R.drawable.ic_live_circle_mail);
                    break;

                case BOOKING:
                    iv.setImageResource(R.drawable.ic_live_circle_book);
                    break;
            }
        }

        public MyContactsFunEnum getBtnLeftFunEnum() {
            return (MyContactsFunEnum) mIvFunLeft.getTag();
        }

        public MyContactsFunEnum getBtnRightFunEnum() {
            return (MyContactsFunEnum) mIvFunRight.getTag();
        }

        public void setIconWh(int iconWh) {
            this.iconWh = iconWh;
        }
    }


}
