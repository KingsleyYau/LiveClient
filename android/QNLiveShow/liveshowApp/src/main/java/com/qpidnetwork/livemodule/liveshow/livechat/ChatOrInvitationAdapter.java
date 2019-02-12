package com.qpidnetwork.livemodule.liveshow.livechat;

import android.content.Context;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.livechat.LCUserItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechat.contact.ContactBean;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.livemodule.view.BadgeHelper;

import q.rorbin.badgeview.Badge;
import q.rorbin.badgeview.QBadgeView;

/**
 * Created by Hardy on 2018/11/17.
 * 参照 MessageContactAdapter
 */
public class ChatOrInvitationAdapter extends UpdateableAdapter<ContactBean> {

    private Context context;

    //表情解析
    private ExpressionImageGetter imageGetter;

    private OnItemClickListener onItemClickListener;

    private int mCurViewType;
    private int scaleWH;

    public ChatOrInvitationAdapter(Context context) {
        this.context = context;

//        //emoji解析
        int emojiWidth = (int) context.getResources().getDimension(R.dimen.live_size_16dp);
        int emojiHeight = (int) context.getResources().getDimension(R.dimen.live_size_16dp);
        imageGetter = new ExpressionImageGetter(context, emojiWidth, emojiHeight);

        // 50dp
        scaleWH = DisplayUtil.dip2px(context, 50);
    }

    public void setOnItemClickListener(OnItemClickListener onItemClickListener) {
        this.onItemClickListener = onItemClickListener;
    }

    public void setViewType(int mCurViewType) {
        this.mCurViewType = mCurViewType;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if (convertView == null) {
            convertView = LayoutInflater.from(context).inflate(R.layout.adapter_chat_or_invitation, parent, false);
            holder = new ViewHolder(context, convertView);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        final ContactBean item = getItem(position);

        PicassoLoadUtil.loadUrl(holder.civAnchor, item.photoURL, R.drawable.ic_default_photo_woman, scaleWH, scaleWH);

        holder.tvName.setText(item.userName);

        //设置最后一条消息并支持表情显示
        if (TextUtils.isEmpty(item.msgHint)) {
            holder.mLLDesc.setVisibility(View.GONE);
            holder.tvDesc.setText("");
        } else {
            holder.mLLDesc.setVisibility(View.VISIBLE);
            holder.tvDesc.setText(imageGetter.getExpressMsgHTML(item.msgHint));
        }

        LCUserItem lhUserItem = LiveChatManager.getInstance().GetUserWithId(item.userId);
        if (mCurViewType == ChatOrInvitationListFragment.VIEW_TYPE_INVITATION_LIST) {
            holder.badgeUnread.setBadgeNumber(0);
            holder.ivInChat.setVisibility(View.GONE);
            holder.ivOnline.setVisibility(View.GONE);
        } else {
            holder.badgeUnread.setBadgeNumber(item.unreadCount > 0 ? item.unreadCount : 0);
            holder.ivInChat.setVisibility((lhUserItem != null && lhUserItem.isOnline()
                    && lhUserItem.isInSession()) ? View.VISIBLE : View.GONE);
            holder.ivOnline.setVisibility((lhUserItem != null && lhUserItem.isOnline()) ? View.VISIBLE : View.GONE);
        }

        holder.rlItemRoot.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (onItemClickListener != null) {
                    onItemClickListener.onItemClick(position, item);
                }
            }
        });

        return convertView;
    }


    public interface OnItemClickListener {
        void onItemClick(int position, ContactBean item);
    }


    private class ViewHolder {
        public LinearLayout rlItemRoot;
        public CircleImageView civAnchor;
        public View ivOnline;
        public TextView tvName;
        public ImageView ivInChat;
        public TextView tvDate;
        public TextView tvDesc;
        public View viewDivider;
        public Badge badgeUnread;
        public View mLLDesc;

        public ViewHolder() {

        }

        public ViewHolder(Context context, View convertView) {
            rlItemRoot = (LinearLayout) convertView.findViewById(R.id.rlItemRoot);
            civAnchor = (CircleImageView) convertView.findViewById(R.id.civAnchor);
            ivOnline = convertView.findViewById(R.id.ivOnline);
            tvName = (TextView) convertView.findViewById(R.id.tvName);
            ivInChat = (ImageView) convertView.findViewById(R.id.ivFavoriate);
            tvDate = (TextView) convertView.findViewById(R.id.tvDate);
            tvDesc = (TextView) convertView.findViewById(R.id.tvDesc);
            viewDivider = (View) convertView.findViewById(R.id.viewDivider);

            // hardy
            tvDate.setVisibility(View.GONE);
            mLLDesc = convertView.findViewById(R.id.llDesc);

//            //初始化未读数目
//            LinearLayout llDesc = (LinearLayout) convertView.findViewById(R.id.llDesc);
            LinearLayout llContent = convertView.findViewById(R.id.ll_content_view);
            badgeUnread = new QBadgeView(context).bindTarget(llContent);
            badgeUnread.setBadgeNumber(0);
            badgeUnread.setBadgeGravity(Gravity.CENTER | Gravity.END);
            BadgeHelper.setBaseStyle(context, badgeUnread, context.getResources().getDimensionPixelSize(R.dimen.live_main_top_menu_badge_txt_size_max));
            convertView.setTag(this);
        }
    }
}
