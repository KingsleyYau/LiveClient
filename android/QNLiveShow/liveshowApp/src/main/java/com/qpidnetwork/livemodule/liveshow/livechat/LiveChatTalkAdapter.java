package com.qpidnetwork.livemodule.liveshow.livechat;

import android.content.Context;
import android.graphics.Typeface;
import android.support.constraint.ConstraintLayout;
import android.support.v7.widget.RecyclerView;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.StyleSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LCPhotoInfoItem;
import com.qpidnetwork.livemodule.livechat.LCSystemLinkItem;
import com.qpidnetwork.livemodule.livechat.LCTextItem;
import com.qpidnetwork.livemodule.livechat.LCVideoItem;
import com.qpidnetwork.livemodule.livechat.LCWarningLinkItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.livemodule.livechathttprequest.LCRequestJniLiveChat;
import com.qpidnetwork.livemodule.livemessage.item.LiveMessageItem;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.livechat.downloader.LivechatVoiceDownloader;
import com.qpidnetwork.livemodule.liveshow.livechat.downloader.MagicIconImageDownloader;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.utils.ButtonUtils;
import com.qpidnetwork.livemodule.utils.CustomerHtmlTagHandler;
import com.qpidnetwork.livemodule.utils.DateUtil;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.view.MaterialProgressBar;
import com.qpidnetwork.qnbridgemodule.util.Log;

import org.jetbrains.annotations.NotNull;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

/**
 * 直播liveChat专用adapter
 * @author Jagger 2018-11-17
 */
public class LiveChatTalkAdapter extends RecyclerView.Adapter<LiveChatTalkAdapter.MessageViewHolder> {

    private static final int TYPE_DEFAULT = 99;
    private static final int TYPE_WARNING = 10;
    private static final int TYPE_SYSTEM = 11;
    private static final int TYPE_CUSTOM = 12;
    private static final int TYPE_TEXT_MSG_RECV = 13;
    private static final int TYPE_TEXT_MSG_SEND = 14;
    private static final int TYPE_TEXT_VOICE_RECV = 15;
    private static final int TYPE_TEXT_VOICE_SEND = 16;
    private static final int TYPE_TEXT_MAGIC_ICON_RECV = 17;
    private static final int TYPE_TEXT_MAGIC_ICON_SEND = 18;
    private static final int TYPE_NOTIFY = 19;
    private static final int TYPE_TEXT_PHOTO_RECV = 20;
    private static final int TYPE_TEXT_PHOTO_SEND = 21;
    private static final int TYPE_TEXT_VIDEO_RECV = 22;
    private static final int TYPE_TEXT_VIDEO_SEND = 23;

    private int IMAGEVIEW_MAX_SIZE ;

    //格式化
    SimpleDateFormat weekFormat=new SimpleDateFormat("EEEE HH:mm", Locale.ENGLISH);
    SimpleDateFormat weekBeforeDateformat=new SimpleDateFormat("yyyy/MM/dd HH:mm", Locale.ENGLISH);
    SimpleDateFormat todayDateformat=new SimpleDateFormat("HH:mm", Locale.ENGLISH);

    private Context mContext;
//    private LiveChatManager mLiveChatManager;
//    private VoicePlayerManager mVoicePlayerManager;
    private ExpressionImageGetter imageGetter;      /* 文本表情转化 */

    //列表数据
    private List<LCMessageItem> mMsgList = new ArrayList<>();

    //表情解析
    private CustomerHtmlTagHandler.Builder mBuilder;


    public LiveChatTalkAdapter(@NotNull Context context , List<LCMessageItem> list){
        mContext = context;
        mMsgList = list;
        //emoji解析
        int emojiWidth = (int)context.getResources().getDimension(R.dimen.live_size_16dp);
        int emojiHeight = (int)context.getResources().getDimension(R.dimen.live_size_16dp);
        mBuilder = new CustomerHtmlTagHandler.Builder();
        mBuilder.setContext(context)
                .setGiftImgHeight(emojiWidth)
                .setGiftImgWidth(emojiHeight);
        imageGetter = new ExpressionImageGetter(context, DisplayUtil.dip2px( context, 28), DisplayUtil.dip2px(context, 28));

        //图片最大显示宽高
        IMAGEVIEW_MAX_SIZE = (int)context.getResources().getDimension(R.dimen.live_chat_photo_default_size);
    }

    @Override
    public int getItemViewType(int position) {
        int viewType = super.getItemViewType(position);  //java.lang.RuntimeException: -1 is already used for view type Header
//        Log.i("Jagger" , "LiveChatTalkAdapter getItemViewType position:" + position);
        //在范围内
        if(position < mMsgList.size()){
            LCMessageItem item = mMsgList.get(position);
            if(item != null){
                switch (item.sendType) {
                    case Recv:
                        switch (item.msgType) {
                            case Text:
                                viewType = TYPE_TEXT_MSG_RECV;
                                break;
                            case Voice:
                                viewType = TYPE_TEXT_VOICE_RECV;
                                break;
                            case MagicIcon:
                                viewType = TYPE_TEXT_MAGIC_ICON_RECV;
                                break;
                            case Photo:
                                viewType = TYPE_TEXT_PHOTO_RECV;
                                break;
                            case Video:
                                viewType = TYPE_TEXT_VIDEO_RECV;
                                break;
                            case Warning:
                                viewType = TYPE_WARNING;
                                break;
                            case System:
                                viewType = TYPE_SYSTEM;
                                break;
                            default:
                                break;
                        }
                        break;
                    case Send:
                        switch (item.msgType) {
                            case Text:
                                viewType = TYPE_TEXT_MSG_SEND;
                                break;
                            case Warning:
                                viewType = TYPE_WARNING;
                                break;
                            case Voice:
                                viewType = TYPE_TEXT_VOICE_SEND;
                                break;
                            case MagicIcon:
                                viewType = TYPE_TEXT_MAGIC_ICON_SEND;
                                break;
                            case Photo:
                                viewType = TYPE_TEXT_PHOTO_SEND;
                                break;
                            case Video:
                                viewType = TYPE_TEXT_VIDEO_SEND;
                                break;
                            case Custom:
                                viewType = TYPE_CUSTOM;
                                break;
                            case System:
                                viewType = TYPE_SYSTEM;
                                break;
                            default:
                                break;
                        }
                        break;
                    case System:
                        switch (item.msgType) {
                            case Warning:
                                viewType = TYPE_WARNING;
                                break;
                            case System:
                                viewType = TYPE_SYSTEM;
                                break;
                            case Notify:
                                viewType = TYPE_NOTIFY;
                                break;
                            default:
                                break;
                        }
                        break;
                    case Unknow:
                        switch (item.msgType) {
                            case Warning:
                                viewType = TYPE_WARNING;
                                break;
                            case System:
                                viewType = TYPE_SYSTEM;
                                break;
                            default:
                                break;
                        }
                        break;
                    default:
                        break;
                }
            }
        }

        return viewType;
    }

    @Override
    public int getItemCount() {
        return (mMsgList == null || mMsgList.size() == 0) ? 0 : mMsgList.size();
    }

    @Override
    public MessageViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
            MessageViewHolder viewHolder = null;
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        switch (viewType) {
            case TYPE_WARNING:
                viewHolder = new WarningTypeViewHolder(inflater.inflate(R.layout.item_live_chat_warning_tips, parent, false));
                break;
            case TYPE_SYSTEM:
                viewHolder = new SystemTypeViewHolder(inflater.inflate(R.layout.item_live_chat_normal_notify, parent, false));
                break;
            case TYPE_CUSTOM:
                viewHolder = new CustomTypeViewHolder(inflater.inflate(R.layout.item_live_chat_trychat_notify, parent, false));
                break;
            case TYPE_TEXT_MSG_RECV:
                viewHolder = new RecvTextTypeViewHolder(inflater.inflate(R.layout.item_live_chat_message_in, parent, false));
                break;
            case TYPE_TEXT_MSG_SEND:
                viewHolder = new SendTextTypeViewHolder(inflater.inflate(R.layout.item_live_chat_message_out, parent, false));
                break;
            case TYPE_TEXT_VOICE_RECV:
                viewHolder = new RecvVoiceViewHolder(inflater.inflate(R.layout.item_live_chat_in_voice, parent, false));
                break;
            case TYPE_TEXT_VOICE_SEND:
                viewHolder = new SendVoiceViewHolder(inflater.inflate(R.layout.item_live_chat_out_voice, parent, false));
                break;
            case TYPE_TEXT_MAGIC_ICON_RECV:
                viewHolder = new RecvMagicIconViewHolder(inflater.inflate(R.layout.item_live_chat_magicicon_in, parent, false));
                break;
            case TYPE_TEXT_MAGIC_ICON_SEND:
                viewHolder = new SendMagicIconViewHolder(inflater.inflate(R.layout.item_live_chat_magicicon_out, parent, false));
                break;
            case TYPE_NOTIFY:
                viewHolder = new NotifyTypeViewHolder(inflater.inflate(R.layout.item_live_chat_session_pause_notify, parent, false));
                break;
            case TYPE_TEXT_PHOTO_RECV:
                viewHolder = new RecvPhotoViewHolder(inflater.inflate(R.layout.item_live_chat_photo_in, parent, false));
                break;
            case TYPE_TEXT_PHOTO_SEND:
                viewHolder = new SendPhotoViewHolder(inflater.inflate(R.layout.item_live_chat_photo_out, parent, false));
                break;
            case TYPE_TEXT_VIDEO_RECV:
                viewHolder = new RecvVideoViewHolder(inflater.inflate(R.layout.item_live_chat_video_in, parent, false));
                break;
            case TYPE_TEXT_VIDEO_SEND:
                viewHolder = new SendVideoViewHolder(inflater.inflate(R.layout.item_live_chat_video_out, parent, false));
                break;
        }
        return viewHolder;
    }

    @Override
    public void onBindViewHolder(MessageViewHolder holder, int position) {
        //选项
        final LCMessageItem bean = mMsgList.get(position);

        if (holder instanceof WarningTypeViewHolder) {
            WarningTypeViewHolder warningTypeViewHolder = (WarningTypeViewHolder) holder;

            if (bean.getWarningItem() != null
                    && bean.getWarningItem().linkItem != null
                    && (bean.getWarningItem().linkItem.linkOptType == LCWarningLinkItem.LinkOptType.Rechange)) {
                String tips = bean.getWarningItem().message + " " + bean.getWarningItem().linkItem.linkMsg;
                SpannableString sp = new SpannableString(tips);
                ClickableSpan clickableSpan = new ClickableSpan() {

                    @Override
                    public void onClick(View widget) {
                        // TODO 买点
                        LiveModule.getInstance().onAddCreditClick(mContext , new NoMoneyParamsBean());
                    }
                };
                sp.setSpan(new StyleSpan(Typeface.BOLD),
                        bean.getWarningItem().message.length() + 1, tips.length(),
                        Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                sp.setSpan(clickableSpan,
                        bean.getWarningItem().message.length() + 1, tips.length(),
                        Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                warningTypeViewHolder.tvNotifyMsg.setText(sp);
                warningTypeViewHolder.tvNotifyMsg.setLinkTextColor(mContext.getResources().getColor(
                        R.color.blue_color));
                warningTypeViewHolder.tvNotifyMsg.setMovementMethod(LinkMovementMethod.getInstance());
                warningTypeViewHolder.tvNotifyMsg.setFocusable(false);
                warningTypeViewHolder.tvNotifyMsg.setClickable(false);
                warningTypeViewHolder.tvNotifyMsg.setLongClickable(false);
            } else {
                warningTypeViewHolder.tvNotifyMsg.setText(bean.getWarningItem().message);
            }
        } else if (holder instanceof SystemTypeViewHolder){
            SystemTypeViewHolder systemTypeViewHolder = (SystemTypeViewHolder) holder;

            if ((bean.getSystemItem().linkItem != null)
                    && (bean.getSystemItem().linkItem.linkOptType == LCSystemLinkItem.SystemLinkOptType.Theme_reload
                    ||bean.getSystemItem().linkItem.linkOptType == LCSystemLinkItem.SystemLinkOptType.Theme_recharge)) {
                String tips = bean.getSystemItem().message + " "
                        + bean.getSystemItem().linkItem.linkMsg;
                SpannableString sp = new SpannableString(tips);
                ClickableSpan clickableSpan = new ClickableSpan() {

                    @Override
                    public void onClick(View widget) {
                        if (bean.getSystemItem().linkItem != null){
                            if(bean.getSystemItem().linkItem.linkOptType == LCSystemLinkItem.SystemLinkOptType.Theme_reload){
//                                ((ChatActivity) mContext).loadTheme();
                            }else if(bean.getSystemItem().linkItem.linkOptType == LCSystemLinkItem.SystemLinkOptType.Theme_recharge){
//                                ((ChatActivity) mContext).renewCurrentTheme();
                            }
                        }
                    }
                };
                sp.setSpan(new StyleSpan(Typeface.BOLD),
                        bean.getSystemItem().message.length() + 1, tips.length(),
                        Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                sp.setSpan(clickableSpan,
                        bean.getSystemItem().message.length() + 1, tips.length(),
                        Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
                systemTypeViewHolder.tvNotifyMsg.setText(sp);
                systemTypeViewHolder.tvNotifyMsg.setLinkTextColor(mContext.getResources().getColor(
                        R.color.blue_color));
                systemTypeViewHolder.tvNotifyMsg.setMovementMethod(LinkMovementMethod.getInstance());
                systemTypeViewHolder.tvNotifyMsg.setFocusable(false);
                systemTypeViewHolder.tvNotifyMsg.setClickable(false);
                systemTypeViewHolder.tvNotifyMsg.setLongClickable(false);
            } else {
                systemTypeViewHolder.tvNotifyMsg.setText(bean.getSystemItem().message);
            }
        }else if (holder instanceof CustomTypeViewHolder){
            CustomTypeViewHolder customTypeViewHolder = (CustomTypeViewHolder) holder;

            customTypeViewHolder.tvNotifyMsg.setText(mContext.getString(R.string.live_chat_try_tips));
        }else if (holder instanceof RecvTextTypeViewHolder){
            RecvTextTypeViewHolder recvTextTypeViewHolder = (RecvTextTypeViewHolder) holder;

            recvTextTypeViewHolder.chat_message.setText(imageGetter.getExpressMsgHTML(bean.getTextItem().message));
        }else if (holder instanceof SendTextTypeViewHolder){
            SendTextTypeViewHolder sendTextTypeViewHolder = (SendTextTypeViewHolder) holder;

            LCTextItem textItem = bean.getTextItem();
            String text = textItem.message;
            sendTextTypeViewHolder.chat_message.setText(imageGetter.getExpressMsgHTML(text));
            if (bean.getTextItem().illegal) {
                /* 非法的，显示警告 */
                sendTextTypeViewHolder.includeWaring.setVisibility(View.VISIBLE);
                sendTextTypeViewHolder.tvNotifyMsg.setText(mContext
                        .getResources().getString(
                                R.string.live_chat_lady_illeage_message));
            }
            if (bean.statusType == LCMessageItem.StatusType.Processing) {
                sendTextTypeViewHolder.pbDownload.setVisibility(View.VISIBLE);
                sendTextTypeViewHolder.btnError.setVisibility(View.GONE);
            } else if (bean.statusType == LCMessageItem.StatusType.Fail) {
                sendTextTypeViewHolder.pbDownload.setVisibility(View.GONE);
//                sendTextTypeViewHolder.btnError.setTag(bean);
                sendTextTypeViewHolder.btnError.setVisibility(View.VISIBLE);
                sendTextTypeViewHolder.btnError.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        listener.onErrorClicked(bean);
                    }
                });
            } else {
                sendTextTypeViewHolder.pbDownload.setVisibility(View.GONE);
                sendTextTypeViewHolder.btnError.setVisibility(View.GONE);
            }
        }else if (holder instanceof RecvVoiceViewHolder){
            RecvVoiceViewHolder recvVoiceViewHolder = (RecvVoiceViewHolder)holder;

            //
            recvVoiceViewHolder.llayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    listener.onVoiceItemClick(view, bean);
                }
            });
            //
            recvVoiceViewHolder.chat_sound_time.setText(bean.getVoiceItem().timeLength + "''");
            recvVoiceViewHolder.chat_sound_time.setTag(position);
            //是否已读 add by Jagger2017-6-15
            recvVoiceViewHolder.img_isread.setVisibility(bean.getVoiceItem().isRead(mContext)?View.GONE:View.VISIBLE);
            //
            new LivechatVoiceDownloader(mContext).downloadAndPlayVoice(recvVoiceViewHolder.pbDownload, recvVoiceViewHolder.btnError, bean);
        }else if (holder instanceof SendVoiceViewHolder){
            SendVoiceViewHolder sendVoiceViewHolder = (SendVoiceViewHolder)holder;

            sendVoiceViewHolder.llayout.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    listener.onVoiceItemClick(view, bean);
                }
            });
            //
            if (bean.statusType == LCMessageItem.StatusType.Processing) {
                sendVoiceViewHolder.pbDownload.setVisibility(View.VISIBLE);
                sendVoiceViewHolder.btnError.setVisibility(View.GONE);
            } else if (bean.statusType == LCMessageItem.StatusType.Fail) {
                sendVoiceViewHolder.pbDownload.setVisibility(View.GONE);
//                sendVoiceViewHolder.btnError.setTag(bean);
                sendVoiceViewHolder.btnError.setVisibility(View.VISIBLE);
                sendVoiceViewHolder.btnError.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        listener.onErrorClicked(bean);
                    }
                });
            }else {
                sendVoiceViewHolder.pbDownload.setVisibility(View.GONE);
                sendVoiceViewHolder.btnError.setVisibility(View.GONE);
            }
            sendVoiceViewHolder.timeView.setText(bean.getVoiceItem().timeLength + "''");
//            sendVoiceViewHolder.timeView.setTag(position);
            //
            new LivechatVoiceDownloader(mContext).downloadAndPlayVoice(null, null, bean);
        }else if (holder instanceof RecvMagicIconViewHolder){
            RecvMagicIconViewHolder recvMagicIconViewHolder = (RecvMagicIconViewHolder)holder;

            recvMagicIconViewHolder.btnError.setTag(position);
            new MagicIconImageDownloader(mContext).displayMagicIconPhoto(
                    recvMagicIconViewHolder.ivMagicIconPhoto, recvMagicIconViewHolder.pbDownload, bean, recvMagicIconViewHolder.btnError);
        }else if (holder instanceof SendMagicIconViewHolder){
            SendMagicIconViewHolder sendMagicIconViewHolder = (SendMagicIconViewHolder)holder;

            new MagicIconImageDownloader(mContext).displayMagicIconPhoto(
                    sendMagicIconViewHolder.ivMagicIcon, null, bean, null);
            if (bean.statusType == LCMessageItem.StatusType.Processing) {
                sendMagicIconViewHolder.pbDownload.setVisibility(View.VISIBLE);
                sendMagicIconViewHolder.btnError.setVisibility(View.GONE);
            } else if (bean.statusType == LCMessageItem.StatusType.Fail) {
                sendMagicIconViewHolder.pbDownload.setVisibility(View.GONE);
//                sendMagicIconViewHolder.btnError.setTag(bean);
                sendMagicIconViewHolder.btnError.setVisibility(View.VISIBLE);
                sendMagicIconViewHolder.btnError.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        listener.onErrorClicked(bean);
                    }
                });
            }else {
                sendMagicIconViewHolder.pbDownload.setVisibility(View.GONE);
                sendMagicIconViewHolder.btnError.setVisibility(View.GONE);
            }
        }else if (holder instanceof NotifyTypeViewHolder){
            NotifyTypeViewHolder notifyTypeViewHolder = (NotifyTypeViewHolder) holder;

            String username = bean.fromId;
            if( LiveChatManager.getInstance().GetLadyInfoById( bean.fromId) != null){
                username = LiveChatManager.getInstance().GetLadyInfoById( bean.fromId).userName;
            }
            String sessionDesc = String.format(mContext.getString(R.string.livechat_seesion_pause_tips), username);
            notifyTypeViewHolder.tvDesc.setText(sessionDesc);
        }else if(holder instanceof RecvPhotoViewHolder){
            //接收图片
            RecvPhotoViewHolder recvPhotoViewHolder = (RecvPhotoViewHolder)holder;

            if(bean.getPhotoItem() != null){
                if(bean.getPhotoItem().charge){
                    //已付费
                    //隐藏锁
                    recvPhotoViewHolder.hideLockView();
                    //处理图片
                    if(bean.getPhotoItem().mClearLargePhotoInfo == null || bean.getPhotoItem().mClearLargePhotoInfo.statusType == LCPhotoInfoItem.StatusType.Default){
                        //download
                        LiveChatManager.getInstance().GetPhoto(bean.getUserItem().userId, bean.msgId, LCRequestJniLiveChat.PhotoSizeType.Large);
                        //显示下载
                        recvPhotoViewHolder.showLoadingView();
                    }else if(bean.getPhotoItem().mClearLargePhotoInfo.statusType == LCPhotoInfoItem.StatusType.Downloading){
                        //显示下载
                        recvPhotoViewHolder.showLoadingView();
                    }else if(bean.getPhotoItem().mClearLargePhotoInfo.statusType == LCPhotoInfoItem.StatusType.Success){
                        //显示图片
                        recvPhotoViewHolder.showPhoto(bean.getPhotoItem().mClearLargePhotoInfo.photoPath);
                        //显示描述
                        recvPhotoViewHolder.tv_des.setText(bean.getPhotoItem().photoDesc);
                        recvPhotoViewHolder.cl_des.setVisibility(View.VISIBLE);
                    }else if(bean.getPhotoItem().mClearLargePhotoInfo.statusType == LCPhotoInfoItem.StatusType.Failed){
                        //显示错误
                        recvPhotoViewHolder.showErrorView();
                        //显示描述
                        recvPhotoViewHolder.tv_des.setText(bean.getPhotoItem().photoDesc);
                        recvPhotoViewHolder.cl_des.setVisibility(View.VISIBLE);
                    }
                }else{
                    //未付费
                    //显示锁
                    recvPhotoViewHolder.showLockView();
                    //处理图片
                    if(bean.getPhotoItem().mFuzzyLargePhotoInfo == null || bean.getPhotoItem().mFuzzyLargePhotoInfo.statusType == LCPhotoInfoItem.StatusType.Default){
                        //download
                        LiveChatManager.getInstance().GetPhoto(bean.getUserItem().userId, bean.msgId, LCRequestJniLiveChat.PhotoSizeType.Large);
                        //显示下载
                        recvPhotoViewHolder.showLoadingView();
                    }else if(bean.getPhotoItem().mFuzzyLargePhotoInfo.statusType == LCPhotoInfoItem.StatusType.Downloading){
                        //显示下载
                        recvPhotoViewHolder.showLoadingView();
                    }else if(bean.getPhotoItem().mFuzzyLargePhotoInfo.statusType == LCPhotoInfoItem.StatusType.Success){
                        //显示图片
                        recvPhotoViewHolder.showPhoto(bean.getPhotoItem().mFuzzyLargePhotoInfo.photoPath);
                        //显示描述
                        recvPhotoViewHolder.tv_des.setText(bean.getPhotoItem().photoDesc);
                        recvPhotoViewHolder.cl_des.setVisibility(View.VISIBLE);
                    }else if(bean.getPhotoItem().mFuzzyLargePhotoInfo.statusType == LCPhotoInfoItem.StatusType.Failed){
                        //显示错误
                        recvPhotoViewHolder.showErrorView();
                        //显示描述
                        recvPhotoViewHolder.tv_des.setText(bean.getPhotoItem().photoDesc);
                        recvPhotoViewHolder.cl_des.setVisibility(View.VISIBLE);
                    }
                }
            }


            //去付费
            recvPhotoViewHolder.rl_lock.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
                        listener.onPhotoClick(bean);
                    }
                }
            });

            //看详细
            recvPhotoViewHolder.iv_photo.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
                        listener.onPhotoClick(bean);
                    }
                }
            });
        }else if(holder instanceof SendPhotoViewHolder){
            //发送图片
            SendPhotoViewHolder sendPhotoViewHolder = (SendPhotoViewHolder)holder;

            if(bean.getPhotoItem() != null) {
                //决定是否显示图片
                if (bean.getPhotoItem().mClearSrcPhotoInfo == null && bean.getPhotoItem().mClearLargePhotoInfo == null){
                    //历史下载大图
                    //download
                    LiveChatManager.getInstance().GetPhoto(bean.toId, bean.msgId, LCRequestJniLiveChat.PhotoSizeType.Large);
                }else if(bean.getPhotoItem().mClearLargePhotoInfo != null){
                    //优先显示大图 BUG#18560
                    if(!TextUtils.isEmpty(bean.getPhotoItem().mClearLargePhotoInfo.photoPath) && (new File(bean.getPhotoItem().mClearLargePhotoInfo.photoPath).exists())){
                        sendPhotoViewHolder.showPhoto(bean.getPhotoItem().mClearLargePhotoInfo.photoPath);
                    }else{
                        sendPhotoViewHolder.showErrorView();
                    }
                }else if(bean.getPhotoItem().mClearSrcPhotoInfo != null){
                    //发送时显示原图
                    sendPhotoViewHolder.showPhoto(bean.getPhotoItem().mClearSrcPhotoInfo.photoPath);
                }

                //根据上传状态决定是否显示相应控件
                if (bean.statusType == LCMessageItem.StatusType.Fail){
                    //发送失败
                    sendPhotoViewHolder.hideLoadingView();
                    sendPhotoViewHolder.btnError.setVisibility(View.VISIBLE);
                    sendPhotoViewHolder.btnError.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View view) {
                            listener.onErrorClicked(bean);
                        }
                    });
                }else if (bean.statusType == LCMessageItem.StatusType.Processing) {
                    //发送中
                    sendPhotoViewHolder.showLoadingView();
                }else if (bean.statusType == LCMessageItem.StatusType.Finish) {
                    //发送完成
                    sendPhotoViewHolder.hideLoadingView();
                }
            }

            //看详细
            sendPhotoViewHolder.iv_photo.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
                        listener.onPhotoClick(bean);
                    }
                }
            });

            //错误
            sendPhotoViewHolder.btnError.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
                        listener.onErrorClicked(bean);
                    }
                }
            });

        }else if(holder instanceof RecvVideoViewHolder){
            //接收视频
            RecvVideoViewHolder recvVideoViewHolder =  (RecvVideoViewHolder)holder;

            if(bean.getVideoItem() != null){
                if(bean.getVideoItem().charget){
                    //已付费
                    //隐藏锁
                    recvVideoViewHolder.hideLockView();
                }else{
                    //未付费
                    //显示锁
                    recvVideoViewHolder.showLockView();
                }

                //处理图片
                if(bean.getVideoItem().mBigPhotoDownloadStatus == LCVideoItem.VideoPhotoDownloadStatus.Default){
                    //download
                    LiveChatManager.getInstance().GetVideoPhoto(bean, LCRequestJniLiveChat.VideoPhotoType.Big);
                    //显示下载
                    recvVideoViewHolder.showLoadingView();
                }else if(bean.getVideoItem().mBigPhotoDownloadStatus == LCVideoItem.VideoPhotoDownloadStatus.Downloading){
                    //显示下载
                    recvVideoViewHolder.showLoadingView();
                }else if(bean.getVideoItem().mBigPhotoDownloadStatus == LCVideoItem.VideoPhotoDownloadStatus.Success){
                    //显示图片
                    recvVideoViewHolder.showVideoPhoto(bean.getVideoItem().bigPhotoFilePath);
                    //显示描述
                    recvVideoViewHolder.tv_des.setText(bean.getVideoItem().videoDesc);
                    recvVideoViewHolder.cl_des.setVisibility(View.VISIBLE);
                }else if(bean.getVideoItem().mBigPhotoDownloadStatus == LCVideoItem.VideoPhotoDownloadStatus.Failed){
                    //显示错误
                    recvVideoViewHolder.showErrorView();
                    //显示描述
                    recvVideoViewHolder.tv_des.setText(bean.getVideoItem().videoDesc);
                    recvVideoViewHolder.cl_des.setVisibility(View.VISIBLE);
                }
            }

            //未付费
            recvVideoViewHolder.rl_lock.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
                        listener.onVideoClick(bean);
                    }
                }
            });

            //看详细
            recvVideoViewHolder.rl_pay.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(!ButtonUtils.isFastDoubleClick(view.getId())) {
                        listener.onVideoClick(bean);
                    }
                }
            });
        }else if(holder instanceof SendVideoViewHolder){

        }
    }

    /**
     * 格式化指定时间，增加当日／昨天／一周内／一周前逻辑判断
     * @param time
     * @return
     */
    private String getDateFormatString(long time){
        String dateFormatString = "";
        DateUtil.DateTimeType timeType = DateUtil.getDateTimeType(time);
        if(timeType == DateUtil.DateTimeType.Today){
            dateFormatString = todayDateformat.format(new Date(time));
        }else if(timeType == DateUtil.DateTimeType.Yestoday){
            dateFormatString = mContext.getResources().getString(R.string.message_contactlist_dateformat_yesterday) + " " + todayDateformat.format(new Date(time));
        }else if(timeType == DateUtil.DateTimeType.InWeek){
            dateFormatString = weekFormat.format(new Date(time));
        }else if(timeType == DateUtil.DateTimeType.WeekBefore){
            dateFormatString = weekBeforeDateformat.format(new Date(time));
        }
        return dateFormatString;
    }

    /**
     * 根据图片大小比例重设宽高
     * @param simpleDraweeView
     * @param picPath
     */
    private void setImageViewSizeForLocalPic(SimpleDraweeView simpleDraweeView, String picPath){
        //取得本地图片大小
        int[] wh = new int[2];
        ImageUtil.getLocalPicSize(picPath, wh);

        //根据图片大小比例重设宽高
        int[] newWH = getPhotoNewSize(wh[0], wh[1]);
        ViewGroup.LayoutParams layoutParams = simpleDraweeView.getLayoutParams();
        layoutParams.width = newWH[0];
        layoutParams.height = newWH[1];
        simpleDraweeView.setLayoutParams(layoutParams);
    }

    /**
     * 根据图片大小 计算imageView新宽高
     * @param picWidth
     * @param picHeight
     * @return
     */
    private int[] getPhotoNewSize(int picWidth, int picHeight){
        int[] newImageViewSize = new int[2];
        int newWidth, newHeight;
        if(picWidth > picHeight){
            newWidth = IMAGEVIEW_MAX_SIZE;
            newHeight = newWidth * picHeight / picWidth;
        }else if(picHeight > picWidth){
            newHeight = IMAGEVIEW_MAX_SIZE;
            newWidth = newHeight * picWidth / picHeight;
        }else {
            newHeight = IMAGEVIEW_MAX_SIZE;
            newWidth = IMAGEVIEW_MAX_SIZE;
        }

        newImageViewSize[0] = newWidth;
        newImageViewSize[1] = newHeight;

        return newImageViewSize;
    }

    public OnItemClickListener listener;

    public void setOnItemClickListener(OnItemClickListener listener){
        this.listener = listener;
    }

    /**
     * 菜单点击事件c
     */
    public interface OnItemClickListener{
        //点击重发按钮
        void onResendClick(LiveMessageItem messageItem);
        //点击充值
        void onAddCreditClick();
        //点击错误
        void onErrorClicked(LCMessageItem lcMessageItem);
        //点击语音
        void onVoiceItemClick(View v, LCMessageItem lcMessageItem);
        //点击图片
        void onPhotoClick(LCMessageItem lcMessageItem);
        //点击图片视频
        void onVideoClick(LCMessageItem lcMessageItem);
    }

    //-------------------------item数据模型 start------------------------------

    //-------------------------item数据模型 end------------------------------


    //-------------------------ViewHolder数据模型 start--------------------------

    //ViewHolder模型
    public class MessageViewHolder extends RecyclerView.ViewHolder {

        public MessageViewHolder(View itemView) {
            super(itemView);
        }
    }

    //警告类型布局 ok
    public class WarningTypeViewHolder extends MessageViewHolder {
        public TextView tvNotifyMsg;
        public WarningTypeViewHolder(View itemView) {
            super(itemView);
            tvNotifyMsg = (TextView) itemView.findViewById(R.id.tvNotifyMsg);
        }
    }

    //系统消息类型布局 ok
    public class SystemTypeViewHolder extends MessageViewHolder {
        public TextView tvNotifyMsg;
        public SystemTypeViewHolder(View itemView) {
            super(itemView);
            tvNotifyMsg = (TextView) itemView.findViewById(R.id.tvNotifyMsg);
        }
    }

    //Custom类型布局 ok
    public class CustomTypeViewHolder extends MessageViewHolder {
        public TextView tvNotifyMsg;
        public CustomTypeViewHolder(View itemView) {
            super(itemView);
            tvNotifyMsg = (TextView) itemView.findViewById(R.id.tvNotifyMsg);
        }
    }

    //文本接收样式 ok
    public class RecvTextTypeViewHolder extends MessageViewHolder {
        public TextView chat_message;

        public RecvTextTypeViewHolder(View itemView) {
            super(itemView);
            chat_message = (TextView) itemView.findViewById(R.id.chat_message);
        }
    }

    //文本发送样式 ok
    public class SendTextTypeViewHolder extends MessageViewHolder {
        public TextView chat_message;
        public MaterialProgressBar pbDownload;
        public View includeWaring;
        public ImageButton btnError;
        public TextView tvNotifyMsg;

        public SendTextTypeViewHolder(View itemView) {
            super(itemView);
            chat_message = (TextView) itemView.findViewById(R.id.chat_message);
            pbDownload = (MaterialProgressBar) itemView.findViewById(R.id.pbDownload);
            includeWaring = itemView.findViewById(R.id.includeWaring);
            btnError = (ImageButton) itemView.findViewById(R.id.btnError);
            tvNotifyMsg = (TextView) itemView.findViewById(R.id.tvNotifyMsg);
        }
    }

    //语音接收样式 ok
    public class RecvVoiceViewHolder extends MessageViewHolder {
        public LinearLayout llayout ;
        public MaterialProgressBar pbDownload;
        public ImageButton btnError;
        public TextView chat_sound_time;
        public ImageView img_isread;

        public RecvVoiceViewHolder(View itemView) {
            super(itemView);
            llayout = (LinearLayout)itemView.findViewById(R.id.chat_sound);
            pbDownload = (MaterialProgressBar) itemView.findViewById(R.id.pbDownload);
            btnError = (ImageButton) itemView.findViewById(R.id.btnError);
            chat_sound_time = (TextView) itemView.findViewById(R.id.chat_sound_time);
            img_isread = (ImageView)itemView.findViewById(R.id.img_isread);
        }
    }

    //语音发送样式 ok
    public class SendVoiceViewHolder extends MessageViewHolder {
        public LinearLayout llayout ;
        public MaterialProgressBar pbDownload;
        public ImageButton btnError;
        public TextView timeView;

        public SendVoiceViewHolder(View itemView) {
            super(itemView);
            llayout = (LinearLayout)itemView.findViewById(R.id.chat_sound);
            pbDownload = (MaterialProgressBar) itemView.findViewById(R.id.pbDownload);
            btnError = (ImageButton) itemView.findViewById(R.id.btnError);
            timeView = (TextView) itemView.findViewById(R.id.chat_sound_time);
        }
    }

    //小高表接收样式 ok
    public class RecvMagicIconViewHolder extends MessageViewHolder {
        public MaterialProgressBar pbDownload;
        public ImageView ivMagicIconPhoto;
        public TextView chat_sound_time;
        public ImageButton btnError;

        public RecvMagicIconViewHolder(View itemView) {
            super(itemView);
            pbDownload = (MaterialProgressBar) itemView.findViewById(R.id.pbDownload);
            ivMagicIconPhoto = (ImageView)itemView.findViewById(R.id.ivMagicIcon);
            btnError = (ImageButton) itemView.findViewById(R.id.btnError);
        }
    }

    //小高表发送样式 ok
    public class SendMagicIconViewHolder extends MessageViewHolder {
        public LinearLayout llayout ;
        public MaterialProgressBar pbDownload ;
        public ImageButton btnError;
        public TextView timeView ;
        public ImageView ivMagicIcon;

        public SendMagicIconViewHolder(View itemView) {
            super(itemView);
            llayout = (LinearLayout)itemView.findViewById(R.id.chat_sound);
            pbDownload = (MaterialProgressBar) itemView.findViewById(R.id.pbDownload);
            btnError = (ImageButton) itemView.findViewById(R.id.btnError);
            timeView = (TextView) itemView.findViewById(R.id.chat_sound_time);
            ivMagicIcon = (ImageView)itemView.findViewById(R.id.ivMagicIcon);
        }
    }

    //通知样式
    public class NotifyTypeViewHolder extends MessageViewHolder {
        public TextView tvDesc;

        public NotifyTypeViewHolder(View itemView) {
            super(itemView);
            tvDesc = (TextView) itemView.findViewById(R.id.tvDesc);
        }
    }

    //分组时间描述
    public class SortedTimeTypeViewHolder extends MessageViewHolder {
        public TextView tvMessage;

        public SortedTimeTypeViewHolder(View itemView) {
            super(itemView);
            tvMessage = (TextView) itemView.findViewById(R.id.tvMessage);
        }
    }

    //图片接收样式 ok
    public class RecvPhotoViewHolder extends MessageViewHolder {
        public MaterialProgressBar pbDownload;
        public SimpleDraweeView iv_photo;
        public RelativeLayout rl_lock, rl_fail;
        public ConstraintLayout cl_des;
        public TextView tv_des;
        private boolean isLoadedPic = false;
        private String tempPath = "";

        public RecvPhotoViewHolder(View itemView) {
            super(itemView);
            pbDownload = itemView.findViewById(R.id.pbDownload);
            iv_photo = itemView.findViewById(R.id.iv_photo);
            rl_lock = itemView.findViewById(R.id.rl_lock);
            cl_des  = itemView.findViewById(R.id.cl_des);
            tv_des = itemView.findViewById(R.id.tv_des);
            rl_fail = itemView.findViewById(R.id.rl_fail);
        }

        public void showLoadingView(){
            pbDownload.setVisibility(View.VISIBLE);
            rl_fail.setVisibility(View.GONE);
            cl_des.setVisibility(View.INVISIBLE);
            hideLockView();
            resetImageView();
            tempPath = "";
        }

        public void showLockView(){
            rl_lock.setVisibility(View.VISIBLE);
        }

        public void showPhoto(String path){
            //收起菊花
            pbDownload.setVisibility(View.GONE);
            rl_fail.setVisibility(View.GONE);

            if(!tempPath.equals(path)){
                //是否已加载过此图片
                tempPath = path;
                isLoadedPic = false;
            }else{
                //标记，不重复加载
                isLoadedPic = true;
            }

            if(!isLoadedPic){
                //重设控件大小
                setImageViewSizeForLocalPic(iv_photo, path);
                //显示图片
                FrescoLoadUtil.loadFile(iv_photo, path, iv_photo.getLayoutParams().width, iv_photo.getLayoutParams().height);
            }

        }

        public void showErrorView(){
            pbDownload.setVisibility(View.GONE);
            rl_fail.setVisibility(View.VISIBLE);
            cl_des.setVisibility(View.INVISIBLE);
            hideLockView();
        }

        public void hideLockView(){
            rl_lock.setVisibility(View.GONE);
        }

        /**
         * 重置imageView,以免重用时看到上一次的缓存
         */
        private void resetImageView(){
            ViewGroup.LayoutParams layoutParams = iv_photo.getLayoutParams();
            layoutParams.width = mContext.getResources().getDimensionPixelSize(R.dimen.live_chat_photo_default_size);
            layoutParams.height = mContext.getResources().getDimensionPixelSize(R.dimen.live_chat_photo_default_size);
            iv_photo.setLayoutParams(layoutParams);

            FrescoLoadUtil.loadRes(iv_photo, R.color.black4);
        }
    }

    //图片发送样式 ok
    public class SendPhotoViewHolder extends MessageViewHolder {
        public MaterialProgressBar pbDownload;
        public ImageButton btnError;
        public SimpleDraweeView iv_photo;
        public RelativeLayout rl_fail;
        private boolean isLoadedPic = false;
        private String tempPath = "";

        public SendPhotoViewHolder(View itemView) {
            super(itemView);
            pbDownload = itemView.findViewById(R.id.pbDownload);
            btnError = itemView.findViewById(R.id.btnError);
            iv_photo = itemView.findViewById(R.id.iv_photo);
            rl_fail = itemView.findViewById(R.id.rl_fail);
        }

        public void showLoadingView(){
            pbDownload.setVisibility(View.VISIBLE);
            btnError.setVisibility(View.GONE);
            rl_fail.setVisibility(View.GONE);
        }

        public void hideLoadingView(){
            pbDownload.setVisibility(View.GONE);
        }

        public void showPhoto(String path){
            //收起菊花
            pbDownload.setVisibility(View.GONE);
            btnError.setVisibility(View.GONE);
            rl_fail.setVisibility(View.GONE);

            if(!tempPath.equals(path)){
                //是否已加载过此图片
                tempPath = path;
                isLoadedPic = false;
            }else{
                //标记，不重复加载
                isLoadedPic = true;
            }

            if(!isLoadedPic){
                //
                resetImageView();
                //重设控件大小
                setImageViewSizeForLocalPic(iv_photo, path);
                //显示图片
                FrescoLoadUtil.loadFile(iv_photo, path, iv_photo.getLayoutParams().width, iv_photo.getLayoutParams().height);
            }

        }

        /**
         * 重置imageView,以免重用时看到上一次的缓存
         */
        private void resetImageView(){
            ViewGroup.LayoutParams layoutParams = iv_photo.getLayoutParams();
            layoutParams.width = mContext.getResources().getDimensionPixelSize(R.dimen.live_chat_photo_default_size);
            layoutParams.height = mContext.getResources().getDimensionPixelSize(R.dimen.live_chat_photo_default_size);
            iv_photo.setLayoutParams(layoutParams);

            FrescoLoadUtil.loadRes(iv_photo, R.color.black4);
        }

        public void showErrorView(){
            //
            resetImageView();
            //
            rl_fail.setVisibility(View.VISIBLE);
        }
    }

    //视频接收样式 ok
    public class RecvVideoViewHolder extends MessageViewHolder {
        public MaterialProgressBar pbDownload;
        public SimpleDraweeView iv_video;
        public RelativeLayout rl_lock, rl_pay, rl_fail;
        public ConstraintLayout cl_des;
        public TextView tv_des;
        private boolean isLoadedPic = false;
        private String tempPath = "";

        public RecvVideoViewHolder(View itemView) {
            super(itemView);
            pbDownload = itemView.findViewById(R.id.pbDownload);
            iv_video = itemView.findViewById(R.id.iv_video);
            rl_lock = itemView.findViewById(R.id.rl_lock);
            rl_pay = itemView.findViewById(R.id.rl_pay);
            rl_fail = itemView.findViewById(R.id.rl_fail);
            cl_des  = itemView.findViewById(R.id.cl_des);
            tv_des = itemView.findViewById(R.id.tv_des);
        }

        public void showLoadingView(){
            pbDownload.setVisibility(View.VISIBLE);
            rl_fail.setVisibility(View.GONE);
            cl_des.setVisibility(View.INVISIBLE);
            hideLockView();
            rl_pay.setVisibility(View.GONE);
            resetImageView();
            tempPath = "";
        }

        public void showLockView(){
            rl_lock.setVisibility(View.VISIBLE);
            rl_pay.setVisibility(View.GONE);
            //蒙层
            iv_video.getHierarchy().setOverlayImage(mContext.getResources().getDrawable(R.color.live_chat_video_cover));
        }

        public void showVideoPhoto(String path){
            //收起菊花
            pbDownload.setVisibility(View.GONE);
            rl_fail.setVisibility(View.GONE);


            if(!tempPath.equals(path)){
                //是否已加载过此图片
                tempPath = path;
                isLoadedPic = false;
            }else{
                //标记，不重复加载
                isLoadedPic = true;
            }

            if(!isLoadedPic) {
                //重设控件大小
                setImageViewSizeForLocalPic(iv_video, path);
                //显示图片
                FrescoLoadUtil.loadFile(iv_video, path, iv_video.getLayoutParams().width, iv_video.getLayoutParams().height);
            }
        }

        public void showErrorView(){
            rl_fail.setVisibility(View.VISIBLE);
            cl_des.setVisibility(View.INVISIBLE);
            pbDownload.setVisibility(View.GONE);
            hideLockView();
            rl_pay.setVisibility(View.GONE);
        }

        public void hideLockView(){
            rl_lock.setVisibility(View.GONE);
            rl_pay.setVisibility(View.VISIBLE);
            //去掉蒙层
            iv_video.getHierarchy().setOverlayImage(null);
        }

        /**
         * 重置imageView,以免重用时看到上一次的缓存
         */
        private void resetImageView(){
            ViewGroup.LayoutParams layoutParams = iv_video.getLayoutParams();
            layoutParams.width = mContext.getResources().getDimensionPixelSize(R.dimen.live_chat_photo_default_size);
            layoutParams.height = mContext.getResources().getDimensionPixelSize(R.dimen.live_chat_photo_default_size);
            iv_video.setLayoutParams(layoutParams);

            FrescoLoadUtil.loadRes(iv_video, R.color.black4);
        }
    }

    //视频发送样式
    public class SendVideoViewHolder extends MessageViewHolder {
        public MaterialProgressBar pbDownload;
        public ImageButton btnError;
        public SimpleDraweeView iv_video;

        public SendVideoViewHolder(View itemView) {
            super(itemView);
            pbDownload = itemView.findViewById(R.id.pbDownload);
            btnError = itemView.findViewById(R.id.btnError);
            iv_video = itemView.findViewById(R.id.iv_video);
        }
    }

    //-------------------------ViewHolder数据模型 end--------------------------
}
