package com.qpidnetwork.livemodule.liveshow.home.menu;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.httprequest.item.LoginItem;
import com.qpidnetwork.livemodule.livechat.contact.ContactManager;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.ButtonUtils;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.livemodule.view.BadgeHelper;
import com.qpidnetwork.livemodule.view.DotView.DotView;
import com.qpidnetwork.qnbridgemodule.bean.WebSiteBean;
import com.qpidnetwork.qnbridgemodule.websitemanager.WebSiteConfigManager;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import q.rorbin.badgeview.Badge;
import q.rorbin.badgeview.QBadgeView;

/**
 * @author Jagger 2018-6-26
 * 主界面左则菜单
 */
public class DrawerAdapter extends RecyclerView.Adapter<DrawerAdapter.DrawerViewHolder> {

    private static final int TYPE_DIVIDER = 0;
    private static final int TYPE_NORMAL = 1;
    private static final int TYPE_HEADER = 2;
    private static final int TYPE_CREDITS = 3;
    private static final int TYPE_TITLE = 4;
    private static final int TYPE_WEBSITE = 5;
    private static final int TYPE_BLANK = 6;

    //item id
    public static final int ITEM_ID_MESSAGE = 1;
    public static final int ITEM_ID_MAIL = 2;
    public static final int ITEM_ID_GREETS = 3;
    public static final int ITEM_ID_SHOWTICKETS = 4;
    public static final int ITEM_ID_BOOKS = 5;
    public static final int ITEM_ID_BACKPACK = 6;
    // 2018/11/16 Hardy
    public static final int ITEM_ID_CHAT = 7;

    private Context mContext;

    //列表数据
    private List<DrawerItem> dataList;

    public DrawerAdapter(Context context) {
        mContext = context;
        //初始化菜单数据，动态添加站点信息
        dataList = new ArrayList<DrawerItem>();
        dataList.addAll(Arrays.asList(
//                new DrawerItemHeader(),
//                new DrawerItemCredits(),
//                new DrawerItemDivider(),
                new DrawerItemBlank(),
                new DrawerItemNormal(ITEM_ID_CHAT, R.drawable.ic_live_menu_item_chat, R.string.Chat),   // 2018/11/16 Hardy
                new DrawerItemNormal(ITEM_ID_MAIL, R.drawable.ic_live_menu_item_mail, R.string.live_main_drawer_menu_Mail),
                new DrawerItemNormal(ITEM_ID_GREETS, R.drawable.ic_live_menu_item_greet, R.string.live_main_drawer_menu_GreetMail),
//                new DrawerItemNormal(ITEM_ID_MESSAGE, R.drawable.ic_live_menu_item_message, R.string.live_main_drawer_menu_Message),  //私信
                new DrawerItemBlank(),
                new DrawerItemDivider(),
                new DrawerItemBlank(),
                new DrawerItemNormal(ITEM_ID_SHOWTICKETS, R.drawable.ic_live_menu_item_showtickets, R.string.live_main_drawer_menu_showtickets),
                new DrawerItemNormal(ITEM_ID_BOOKS, R.drawable.ic_live_menu_item_bookings, R.string.live_main_drawer_menu_books),
                new DrawerItemNormal(ITEM_ID_BACKPACK, R.drawable.ic_live_menu_item_backpack, R.string.live_main_drawer_menu_backpack),
                new DrawerItemBlank()
        ));
        //初始化站点信息
        List<WebSiteBean> loaclSiteSettings = WebSiteConfigManager.getInstance().getDefaultAvailableWebSettings();
        if (loaclSiteSettings != null) {
            dataList.add(new DrawerItemTypeTitle(R.string.live_main_drawer_menu_changewebsize));
            for (int i = 0; i < loaclSiteSettings.size() - 1; i++) {
                dataList.add(new DrawerItemWebSite(loaclSiteSettings.get(i)));
                dataList.add(new DrawerItemDivider());
            }
            if (loaclSiteSettings.size() > 0) {
                dataList.add(new DrawerItemWebSite(loaclSiteSettings.get(loaclSiteSettings.size() - 1)));
            }
        }
    }

    @Override
    public int getItemViewType(int position) {
        DrawerItem drawerItem = dataList.get(position);
        if (drawerItem instanceof DrawerItemDivider) {
            return TYPE_DIVIDER;
        } else if (drawerItem instanceof DrawerItemNormal) {
            return TYPE_NORMAL;
        } else if (drawerItem instanceof DrawerItemHeader) {
            return TYPE_HEADER;
        } else if (drawerItem instanceof DrawerItemCredits) {
            return TYPE_CREDITS;
        } else if (drawerItem instanceof DrawerItemTypeTitle) {
            return TYPE_TITLE;
        } else if (drawerItem instanceof DrawerItemWebSite) {
            return TYPE_WEBSITE;
        } else if (drawerItem instanceof DrawerItemBlank) {
            return TYPE_BLANK;
        }
        return super.getItemViewType(position);
    }

    @Override
    public int getItemCount() {
        return (dataList == null || dataList.size() == 0) ? 0 : dataList.size();
    }

    @Override
    public DrawerViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        DrawerViewHolder viewHolder = null;
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        switch (viewType) {
            case TYPE_DIVIDER:
                viewHolder = new DividerViewHolder(inflater.inflate(R.layout.view_live_drawer_divider_item, parent, false));
                break;
            case TYPE_HEADER:
                viewHolder = new HeaderViewHolder(inflater.inflate(R.layout.view_live_drawer_header_item, parent, false));
                break;
            case TYPE_NORMAL:
                viewHolder = new NormalViewHolder(inflater.inflate(R.layout.view_live_drawer_normal_item, parent, false));
                break;
            case TYPE_CREDITS:
                viewHolder = new CreditsViewHolder(inflater.inflate(R.layout.view_live_drawer_normal_credits, parent, false));
                break;
            case TYPE_TITLE:
                viewHolder = new TitleViewHolder(inflater.inflate(R.layout.view_live_drawer_item_title, parent, false));
                break;
            case TYPE_WEBSITE:
                viewHolder = new WebSiteViewHolder(inflater.inflate(R.layout.view_live_drawer_item_website, parent, false));
                break;
            case TYPE_BLANK:
                viewHolder = new BlankViewHolder(inflater.inflate(R.layout.view_live_drawer_item_blank, parent, false));
                break;
        }
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(DrawerViewHolder holder, int position) {
        final DrawerItem item = dataList.get(position);
        if (holder instanceof NormalViewHolder) {
            setNormalView((NormalViewHolder) holder, (DrawerItemNormal) item);
        } else if (holder instanceof HeaderViewHolder) {
            setHeaderView((HeaderViewHolder) holder);
        } else if (holder instanceof CreditsViewHolder) {
            setCreditsView((CreditsViewHolder) holder);
        } else if (holder instanceof TitleViewHolder) {
            setTypeTitleView((TitleViewHolder) holder, (DrawerItemTypeTitle) item);
        } else if (holder instanceof WebSiteViewHolder) {
            setWebSiteView((WebSiteViewHolder) holder, (DrawerItemWebSite) item);
        } else if (holder instanceof BlankViewHolder) {

        }
    }

    private void setWebSiteView(WebSiteViewHolder holder, final DrawerItemWebSite item) {
        if (item.mWebSiteBean.getSiteDrawable() != null) {
            holder.civ_hostIcon.setImageDrawable(item.mWebSiteBean.getSiteDrawable());
        }
        holder.tv_hostDes.setText(item.mWebSiteBean.getSiteDesc());
        holder.tv_hostName.setText(item.mWebSiteBean.getSiteName());
        holder.root.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (listener != null && !ButtonUtils.isFastDoubleClick(v.getId())) {
                    listener.onWebSiteChoose(item.mWebSiteBean);
                }
            }
        });
    }

    private void setTypeTitleView(TitleViewHolder holder, DrawerItemTypeTitle item) {
        holder.tv_typeTitle.setText(mContext.getResources().getString(item.titleRes));
    }

    private void setCreditsView(CreditsViewHolder holder) {
        LiveRoomCreditRebateManager liveRoomCreditRebateManager = LiveRoomCreditRebateManager.getInstance();
        String currCredits = ApplicationSettingUtil.formatCoinValue(liveRoomCreditRebateManager.getCredit());
        holder.tv_currCredits.setText(mContext.getResources().getString(R.string.left_menu_credits_balance, currCredits));
        View.OnClickListener onClickListener = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null && !ButtonUtils.isFastDoubleClick(v.getId())) {
                    listener.onAddCreditsClicked();
                }
            }
        };
        holder.tv_addCredits.setOnClickListener(onClickListener);
        holder.ll_addCredit.setOnClickListener(onClickListener);
    }

    private void setNormalView(NormalViewHolder holder, DrawerItemNormal item) {
        //选项
        final DrawerItemNormal itemNormal = item;
        holder.iv_itemIcon.setImageDrawable(mContext.getResources().getDrawable(itemNormal.iconRes));
        holder.tv_itemTitle.setText(itemNormal.titleRes);
        switch (item.id) {
            case ITEM_ID_SHOWTICKETS:
            case ITEM_ID_BOOKS:
            case ITEM_ID_BACKPACK: {
                holder.badge.setBadgeNumber(0);
                if (itemNormal.unreadNum > 0) {
                    //显示红点
                    holder.dv_digitalHint.setVisibility(View.VISIBLE);
                    holder.dv_digitalHint.setText("");
                } else {
                    holder.dv_digitalHint.setVisibility(View.GONE);
                }
            }
            break;

            // 2018/11/16 Hardy
            case ITEM_ID_CHAT: {
                holder.dv_digitalHint.setVisibility(View.GONE);
                holder.badge.setBadgeNumber(0);

                if (itemNormal.unreadNum > 0) {
                    holder.badge.setBadgeNumber(itemNormal.unreadNum);
                } else {
                    holder.badge.setBadgeNumber(0);

                    int inviteSize = ContactManager.getInstance().getInviteListSize();
                    if (inviteSize > 0) {
                        //显示红点
                        holder.dv_digitalHint.setVisibility(View.VISIBLE);
                        holder.dv_digitalHint.setText("");
                    } else {
                        holder.dv_digitalHint.setVisibility(View.GONE);
                    }
                }
            }
            break;

            case ITEM_ID_MESSAGE:
            case ITEM_ID_MAIL:
            case ITEM_ID_GREETS: {
                holder.dv_digitalHint.setVisibility(View.GONE);
                if (itemNormal.unreadNum > 0) {
                    //显示红点
                    holder.badge.setBadgeNumber(itemNormal.unreadNum);
                } else {
                    holder.badge.setBadgeNumber(0);
                }
            }
            break;
        }

        holder.view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null && !ButtonUtils.isFastDoubleClick(v.getId())) {
                    listener.itemClick(itemNormal);
                }
            }
        });
    }

    private void setHeaderView(HeaderViewHolder holder) {
        LoginItem loginItem = LoginManager.getInstance().getLoginItem();
        if (null != loginItem) {
//            Picasso.with(mContext).load(loginItem.photoUrl)
//                    .error(R.drawable.ic_default_photo_man)
//                    .memoryPolicy(MemoryPolicy.NO_CACHE)
//                    .noPlaceholder()
//                    .into(holder.civ_userPhoto);
            PicassoLoadUtil.loadUrlNoMCache(holder.civ_userPhoto, loginItem.photoUrl,
                    R.drawable.ic_default_photo_man);

            holder.tv_userName.setText(loginItem.nickName);
            holder.tv_userId.setText(loginItem.userId);
            holder.iv_userLevel.setImageDrawable(DisplayUtil.getLevelDrawableByResName(mContext, loginItem.level));
        }

        holder.civ_userPhoto.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (listener != null && !ButtonUtils.isFastDoubleClick(view.getId())) {
                    listener.onShowMyProfileClicked();
                }
            }
        });
        holder.iv_userLevel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null && !ButtonUtils.isFastDoubleClick(v.getId())) {
                    listener.onShowLevelDetailClicked();
                }
            }
        });
        holder.ll_changeWebSite.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if (listener != null && !ButtonUtils.isFastDoubleClick(view.getId())) {
                    listener.onChangeWebsiteClicked();
                }
            }
        });
    }

    public OnItemClickListener listener;

    public void setOnItemClickListener(OnItemClickListener listener) {
        this.listener = listener;
    }

    /**
     * 菜单点击事件
     */
    public interface OnItemClickListener {
        /**
         * item点击事件
         *
         * @param drawerItemNormal
         */
        void itemClick(DrawerItemNormal drawerItemNormal);

        /**
         * 特殊事件---换站
         */
        void onChangeWebsiteClicked();

        /**
         * 特殊事件--打开个人资料
         */
        void onShowMyProfileClicked();

        /**
         * 特殊事件-充值Credits
         */
        void onAddCreditsClicked();

        /**
         * 特殊事件-展示等级说明页面
         */
        void onShowLevelDetailClicked();

        /**
         * 选择指定站点换站
         *
         * @param webSiteBean
         */
        void onWebSiteChoose(WebSiteBean webSiteBean);
    }

    /**
     * 某个ITEM显示未读数
     *
     * @param itemId
     * @param num    0则标识没有未读红点消失 | >0则标识有未读 |""则标识仅显示红点
     */
    public void showUnReadNum(int itemId, int num) {
        for (int i = 0; i < dataList.size(); i++) {
            if (dataList.get(i) instanceof DrawerItemNormal) {
                if (((DrawerItemNormal) dataList.get(i)).id == itemId) {
                    ((DrawerItemNormal) dataList.get(i)).unreadNum = num;
                    notifyItemChanged(i);
                    return;
                }
            }
        }
    }

    public void updateHeaderView() {
        if (null == dataList) {
            return;
        }
        for (int i = 0; i < dataList.size(); i++) {
            if (dataList.get(i) instanceof DrawerItemHeader) {
                notifyItemChanged(i);
                return;
            }
        }
    }

    public void updateCreditsView() {
        if (null == dataList) {
            return;
        }
        for (int i = 0; i < dataList.size(); i++) {
            if (dataList.get(i) instanceof DrawerItemCredits) {
                notifyItemChanged(i);
                return;
            }
        }
    }


    //-------------------------item数据模型------------------------------
    // drawerlayout item统一的数据模型
    public interface DrawerItem {
    }

    //有图片和文字的item
    public class DrawerItemNormal implements DrawerItem {
        public int id = -1;
        public int iconRes;
        public int titleRes;
        public int unreadNum;

        public DrawerItemNormal(int id, int iconRes, int titleRes) {
            this.id = id;
            this.iconRes = iconRes;
            this.titleRes = titleRes;
            this.unreadNum = 0;
        }

    }

    //分割线item
    public class DrawerItemDivider implements DrawerItem {
        public DrawerItemDivider() {
        }
    }

    //分割线item
    public class DrawerItemTypeTitle implements DrawerItem {

        public int titleRes;

        public DrawerItemTypeTitle(int titleRes) {
            this.titleRes = titleRes;
        }

    }

    public class DrawerItemBlank implements DrawerItem {
        public DrawerItemBlank() {
        }
    }

    public class DrawerItemWebSite implements DrawerItem {

        public WebSiteBean mWebSiteBean;

        public DrawerItemWebSite(WebSiteBean webSiteBean) {
            this.mWebSiteBean = webSiteBean;
        }

    }

    //头部item
    public class DrawerItemHeader implements DrawerItem {
        public DrawerItemHeader() {
        }
    }

    //头部item
    public class DrawerItemCredits implements DrawerItem {
        public DrawerItemCredits() {
        }
    }

    //----------------------------------ViewHolder数据模型---------------------------
    //抽屉ViewHolder模型
    public class DrawerViewHolder extends RecyclerView.ViewHolder {
        public DrawerViewHolder(View itemView) {
            super(itemView);
        }
    }

    //有图标有文字ViewHolder
    public class NormalViewHolder extends DrawerViewHolder {
        public View view;
        public TextView tv_itemTitle;
        public ImageView iv_itemIcon;
        public Badge badge;
        public DotView dv_digitalHint;

        public NormalViewHolder(View itemView) {
            super(itemView);
            view = itemView;
            tv_itemTitle = (TextView) itemView.findViewById(R.id.tv_itemTitle);
            iv_itemIcon = (ImageView) itemView.findViewById(R.id.iv_itemIcon);
            //带数字的未读效果用QBadgeView来实现
            badge = new QBadgeView(mContext).bindTarget(itemView.findViewById(R.id.tv_itemTitle));
            badge.setBadgeNumber(0);  //先隐藏, 因为初始化时取不到准确的坐标,会在右上角先显示一个图标,不好看
            badge.setBadgeGravity(Gravity.END | Gravity.CENTER_VERTICAL);
            BadgeHelper.setBaseStyle(mContext, badge);
            //QBadgeView的红点效果太大了，因此仅红点显示效果用DotView来实现
            dv_digitalHint = (DotView) itemView.findViewById(R.id.dv_digitalHint);
            dv_digitalHint.setVisibility(View.GONE);
            dv_digitalHint.setBackgroundDrawable(mContext.getResources().getDrawable(R.drawable.bg_live_menu_unread));
        }
    }

    //分割线ViewHolder
    public class DividerViewHolder extends DrawerViewHolder {
        public DividerViewHolder(View itemView) {
            super(itemView);
        }
    }

    //头部ViewHolder
    public class HeaderViewHolder extends DrawerViewHolder {

        public CircleImageView civ_userPhoto;
        public TextView tv_userName;
        public TextView tv_userId;
        public View ll_userInfo;
        public View ll_changeWebSite;
        public TextView tv_currWebSite;
        public ImageView iv_userLevel;

        public HeaderViewHolder(View itemView) {
            super(itemView);

            civ_userPhoto = (CircleImageView) itemView.findViewById(R.id.civ_userPhoto);
            tv_userName = (TextView) itemView.findViewById(R.id.tv_userName);
            tv_userId = (TextView) itemView.findViewById(R.id.tv_userId);
            iv_userLevel = (ImageView) itemView.findViewById(R.id.iv_userLevel);
            tv_currWebSite = (TextView) itemView.findViewById(R.id.tv_currWebSite);
            ll_changeWebSite = itemView.findViewById(R.id.ll_changeWebSite);
            ll_userInfo = itemView.findViewById(R.id.ll_userInfo);
        }
    }

    public class CreditsViewHolder extends DrawerViewHolder {
        public View ll_addCredit;
        public TextView tv_currCredits;
        public TextView tv_addCredits;

        public CreditsViewHolder(View itemView) {
            super(itemView);
            tv_currCredits = (TextView) itemView.findViewById(R.id.tv_currCredits);
            tv_addCredits = (TextView) itemView.findViewById(R.id.tv_addCredits);
            ll_addCredit = itemView.findViewById(R.id.ll_addCredit);
        }
    }

    public class TitleViewHolder extends DrawerViewHolder {

        public TextView tv_typeTitle;

        public TitleViewHolder(View itemView) {
            super(itemView);
            tv_typeTitle = (TextView) itemView.findViewById(R.id.tv_typeTitle);
        }
    }

    public class WebSiteViewHolder extends DrawerViewHolder {

        public LinearLayout root;
        public CircleImageView civ_hostIcon;
        public TextView tv_hostName;
        public TextView tv_hostDes;

        public WebSiteViewHolder(View itemView) {
            super(itemView);
            root = (LinearLayout) itemView.findViewById(R.id.root);
            civ_hostIcon = (CircleImageView) itemView.findViewById(R.id.civ_hostIcon);
            tv_hostName = (TextView) itemView.findViewById(R.id.tv_hostName);
            tv_hostDes = (TextView) itemView.findViewById(R.id.tv_hostDes);
        }
    }

    public class BlankViewHolder extends DrawerViewHolder {
        public BlankViewHolder(View itemView) {
            super(itemView);
        }
    }
}
