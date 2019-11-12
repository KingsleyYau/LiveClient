package com.qpidnetwork.livemodule.liveshow.sayhi;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Animatable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.content.ContextCompat;
import android.support.v4.widget.NestedScrollView;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Html;
import android.text.TextUtils;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.AbstractDraweeController;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.facebook.imagepipeline.common.ResizeOptions;
import com.facebook.imagepipeline.image.ImageInfo;
import com.facebook.imagepipeline.postprocessors.IterativeBoxBlurPostProcessor;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetSayDetailCallback;
import com.qpidnetwork.livemodule.httprequest.OnReadSayHiResponseCallback;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.LSOrderType;
import com.qpidnetwork.livemodule.httprequest.item.SayHiDetailAnchorItem;
import com.qpidnetwork.livemodule.httprequest.item.SayHiDetailItem;
import com.qpidnetwork.livemodule.httprequest.item.SayHiDetailResponseListItem;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.anchor.AnchorProfileActivity;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.sayhi.adapter.SayHiResponseAdapter;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.utils.DateUtil;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.view.dialog.CommonThreeBtnTipDialog;
import com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder;

import java.util.Arrays;

import static com.qpidnetwork.livemodule.httprequest.RequestJniSayHi.SayHiDetailOperateType.Latest;
import static com.qpidnetwork.livemodule.utils.DateUtil.FORMAT_SHOW_MONTH_YEAR_DATE;

/**
 * Created by Oscar 2019 5 29
 * SayHi 详情界面
 */
public class SayHiDetailsActivity
        extends BaseActionBarFragmentActivity {


    private static final String KEY_SAY_HI_ID = "KEY_SAY_HI_ID";
    private static final String KEY_RESPONSE_ID = "KEY_RESPONSE_ID";
    private static final String KEY_LADY_AVATAR = "KEY_LADY_AVATAR";
    private static final String KEY_LADY_NAME = "KEY_LADY_NAME";
    private static final String KEY_LADY_AGE = "KEY_LADY_AGE";


    private static final int MESSAGE_LOAD_SAY_HI_DETAIL_SUCCESS = 0x6;
    private static final int MESSAGE_LOAD_SAY_HI_DETAIL_FAIL = 0x7;
    private static final int MESSAGE_LOAD_SAY_HI_RESPONSE_SUCCESS = 0x8;
    private static final int MESSAGE_LOAD_SAY_HI_RESPONSE_FAIL = 0x9;
    private static final int MESSAGE_LOAD_SAY_HI_RESPONSE_NEED_BUY = 0x10;

    /**
     *
     * @param context
     * @param avatar 头像
     * @param name
     * @param age
     * @param sayHiId
     * @param responseId
     */
    public static void launch(Context context,
                              String avatar,
                              String name,
                              int age,
                              String sayHiId,
                              String responseId) {
        Intent intent = new Intent(context, SayHiDetailsActivity.class);
        intent.putExtra(KEY_SAY_HI_ID, sayHiId);
        intent.putExtra(KEY_RESPONSE_ID, responseId);
        intent.putExtra(KEY_LADY_AVATAR, avatar);
        intent.putExtra(KEY_LADY_NAME, name);
        intent.putExtra(KEY_LADY_AGE, age);
        context.startActivity(intent);
    }

    public static void launch(Context context,
                              String sayHiId,
                              String responseId) {
        launch(context, "", "", 0, sayHiId, responseId);
    }


    public static void launch(Context context, String sayHiId) {
        launch(context, "", "", 0, sayHiId, "");
    }

    private TextView sendInfo;
    private TextView sayHiDateTx;
    private SimpleDraweeView ladyAvatar;
    private SimpleDraweeView backgroundImg;
    private TextView myNoteBtn;
    private TextView responseTitle;
    private TextView responseContent;
    private TextView ladyName;
    private TextView responseInfo;
    private TextView emptyTipsView;
    private SimpleDraweeView responseImg;
    private TextView freeTip;
    private TextView buyTipsTitle;
    private TextView addCreditsBtn;
    private TextView buyPostBtn;

    private View replyMaxBtn;
    private View replyMinBtn;
    private View resContentArea;
    private View responseDetail;
    private View buyTipsView;
    private View errorView;
    private RecyclerView refreshRecyclerView;
    private SayHiResponseAdapter sayHiResponseAdapter;
    private NestedScrollView mainScrollview;

    // 2019/6/10 Hardy
    private View mLLContentView;

    private String sayHiId = "";
    private String responseId = "";
    private String currentImageUlr = "";
    private SayHiDetailItem detailItem;

    private CommonThreeBtnTipDialog commonThreeBtnTipDialog;
    private LocalPreferenceManager localPreferenceManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_say_hi_details);
        initTitle();
        initView();
        initData();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (needRefreshPoint) {
            loadResponseDetail(responseId);
            needRefreshPoint = false;
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (commonThreeBtnTipDialog != null) {
            commonThreeBtnTipDialog.destroy();
            commonThreeBtnTipDialog = null;
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);
        hideProgressDialog();

        switch (msg.what) {

            case MESSAGE_LOAD_SAY_HI_DETAIL_SUCCESS:
                SayHiDetailItem detailItem = (SayHiDetailItem) msg.obj;
                handleSayHiDetailSuccess(detailItem);
                break;
            case MESSAGE_LOAD_SAY_HI_DETAIL_FAIL:
                handleSayHiDetailFail();
                break;
            case MESSAGE_LOAD_SAY_HI_RESPONSE_SUCCESS:
                SayHiDetailResponseListItem responseListItem = (SayHiDetailResponseListItem) msg.obj;
                handleLoadResponseDetailSuccess(responseListItem);
                break;
            case MESSAGE_LOAD_SAY_HI_RESPONSE_FAIL:
                handleSayHiResponseDetailFail();
                break;
            case MESSAGE_LOAD_SAY_HI_RESPONSE_NEED_BUY:
                handleSayhiResponseShowBuyView();
                break;
        }
    }


    /**
     * 初始化界面
     */
    private void initView() {

        mainScrollview = findViewById(R.id.mainScrollview);
        responseDetail = findViewById(R.id.response_detail_view);
        sendInfo = findViewById(R.id.sendInfo);
        sayHiDateTx = findViewById(R.id.sayHiDateTx);
        ladyAvatar = findViewById(R.id.ladyAvatar);
        backgroundImg = findViewById(R.id.backgroundImg);
        responseContent = findViewById(R.id.responseContent);
        responseImg = findViewById(R.id.responseImg);
        freeTip = findViewById(R.id.freeTip);
        replyMaxBtn = findViewById(R.id.reply_max_btn);
        replyMinBtn = findViewById(R.id.reply_min_btn);
        ladyName = findViewById(R.id.ladyName);

        responseInfo = findViewById(R.id.responseInfo);
        resContentArea = findViewById(R.id.resContentArea);
        emptyTipsView = findViewById(R.id.emptyTipsView);
        buyTipsView = findViewById(R.id.buyTipsView);
        buyTipsTitle = findViewById(R.id.buy_tis_title);
        addCreditsBtn = findViewById(R.id.add_credits_btn);
        errorView = findViewById(R.id.errorView);
        myNoteBtn = findViewById(R.id.noteBtn);
        buyPostBtn = findViewById(R.id.buy_post_btn);

        // 2019/6/10 Hardy
        mLLContentView = findViewById(R.id.act_say_hi_detail_ll_content);

        responseTitle = findViewById(R.id.response_title);
        refreshRecyclerView = findViewById(R.id.say_hi_response_list);
        LinearLayoutManager manager = new LinearLayoutManager(mContext);
        refreshRecyclerView.setLayoutManager(manager);
        refreshRecyclerView.setNestedScrollingEnabled(false);
        sayHiResponseAdapter = new SayHiResponseAdapter(mContext);
        refreshRecyclerView.setAdapter(sayHiResponseAdapter);
        sayHiResponseAdapter.setOnItemClickListener(
                new BaseRecyclerViewAdapter.OnItemClickListener() {
                    @Override
                    public void onItemClick(View v, int position) {

                        SayHiDetailResponseListItem item = sayHiResponseAdapter.getItemBean(position);
                        responseId = item.responseId;

                        if (!item.isFree && !item.hasRead) {

                            if (getLocalPreferenceManager().hasShowSayHiListResponse()) {
                                loadResponseDetail(item.responseId);
                            } else {
                                showAskReadDialog();
                            }

                        } else {
                            setResponseItem(item);
                        }
                    }
                });

        replyMaxBtn.setOnClickListener(this);
        replyMinBtn.setOnClickListener(this);
        myNoteBtn.setOnClickListener(this);
        ladyAvatar.setOnClickListener(this);
        responseImg.setOnClickListener(this);

        buyPostBtn.setOnClickListener(buyViewListener);
        addCreditsBtn.setOnClickListener(buyViewListener);

    }


    private boolean needRefreshPoint = false;
    private View.OnClickListener buyViewListener = new View.OnClickListener() {
        @Override
        public void onClick(View v) {

            needRefreshPoint = true;
            NoMoneyParamsBean paramsBean = new NoMoneyParamsBean();
            paramsBean.clickFrom = "B32";
            if (v.getId() == R.id.buy_post_btn) {
                paramsBean.orderType = LSOrderType.stamp;
            }
            LiveModule.getInstance().onAddCreditClick(mContext, paramsBean);
        }
    };

    @Override
    public void onClick(View view) {
        super.onClick(view);
        int id = view.getId();
        if (id == R.id.noteBtn) {
            if (detailItem != null) {

                SayHiDetailAnchorItem item = detailItem.detail;
                SayHiNoteActivity.luanch(
                        mContext,
                        item.imgUrl,
                        item.nickName,
                        item.text
                );
            }
        } else if (id == R.id.reply_max_btn
                || id == R.id.reply_min_btn) {
            //TODO 回复界面跳转
            if (detailItem != null && detailItem.detail != null) {
                String sendMailUrl = LiveUrlBuilder.createSendMailActivityUrlFromSayHi(detailItem.detail.anchorId, responseId);
                new AppUrlHandler(mContext).urlHandle(sendMailUrl);
            }

            //点击发送按钮
            onAnalyticsEvent(getResources().getString(R.string.Live_SayHi_Category),
                    getResources().getString(R.string.Live_SayHi_Action_Reply_Click),
                    getResources().getString(R.string.Live_SayHi_Label_Reply_Click));


        } else if (id == R.id.ladyAvatar) {
            //TODO 点击头像处理
            if (detailItem != null && detailItem.detail != null) {
                AnchorProfileActivity.launchAnchorInfoActivty(mContext,
                        mContext.getResources().getString(R.string.live_webview_anchor_profile_title),
                        detailItem.detail.anchorId, false, AnchorProfileActivity.TagType.Album);
            }
        } else if (id == R.id.responseImg) {
            SayHiPhotoDetailActivity.luanch(mContext, currentImageUlr);
        }
    }


    /**
     * 打开阅读询问资费的dialog
     */
    private void showAskReadDialog() {
        if (commonThreeBtnTipDialog != null) {
            commonThreeBtnTipDialog.destroy();
        }
        commonThreeBtnTipDialog = new CommonThreeBtnTipDialog(mContext) {
            @Override
            public void onClickOK() {
                loadResponseDetail(responseId);
            }

            @Override
            public void onClickCancel() {

            }

            @Override
            public void onClickDontAsk() {
                // 记录，下次点击不再弹出询问窗口
                getLocalPreferenceManager().saveHasShowSayHiListResponse(true);
                loadResponseDetail(responseId);
            }
        };
        commonThreeBtnTipDialog.show();
    }


    private LocalPreferenceManager getLocalPreferenceManager() {
        if (localPreferenceManager == null) {
            localPreferenceManager = new LocalPreferenceManager(mContext);
        }
        return localPreferenceManager;
    }

    /**
     * 初始化Title
     */
    private void initTitle() {
        //title处理
        setTitle(getString(R.string.say_hi_detail_title), R.color.theme_default_black);
    }


    /**
     * 读取sayhi详情接口
     */
    private void loadSayHiDetail() {

        showProgressDialogBgTranslucent("");
        LiveRequestOperator.getInstance().GetSayHiDetail(sayHiId, Latest, new OnGetSayDetailCallback() {
            @Override
            public void onGetSayDetail(boolean isSuccess,
                                       int errCode,
                                       String errMsg,
                                       SayHiDetailItem sayHiDetailItem) {
                if (isSuccess) {
                    sendLoadSayHiDetailSuccess(sayHiDetailItem);
                } else {
                    sendLoadSayHiDetailFail();
                }

            }
        });
    }

    private void sendLoadSayHiDetailSuccess(SayHiDetailItem sayHiDetailItem) {

        Message message = new Message();
        message.what = MESSAGE_LOAD_SAY_HI_DETAIL_SUCCESS;
        message.obj = sayHiDetailItem;
        sendUiMessage(message);
    }


    private void sendLoadSayHiDetailFail() {

        Message message = new Message();
        message.what = MESSAGE_LOAD_SAY_HI_DETAIL_FAIL;
        sendUiMessage(message);
    }


    private SayHiDetailResponseListItem findCurrentResponse(SayHiDetailItem sayHiDetailItem) {

        SayHiDetailResponseListItem[] items = sayHiDetailItem.responseList;
        SayHiDetailResponseListItem item = null;
        if (items != null) {

            for (int i = 0; i < items.length; i++) {
                SayHiDetailResponseListItem tmp = items[i];
                if (tmp.isFree
                        || tmp.responseId.equals(responseId)) {
                    if (TextUtils.isEmpty(responseId)) {
                        item = tmp;
                        responseId = tmp.responseId;
                    }
                    break;
                }
            }
        }
        return item;
    }

    private void handleSayHiDetailSuccess(SayHiDetailItem sayHiDetailItem) {
        detailItem = sayHiDetailItem;
        handleSayHiHeader(detailItem);

        SayHiDetailResponseListItem[] items = sayHiDetailItem.responseList;
        if (items == null || items.length <= 0) {
            emptyTipsView.setVisibility(View.VISIBLE);
            emptyTipsView.setText(
                    getString(R.string.say_hi_detail_empty_tips,
                            detailItem.detail.nickName));
        } else {
            SayHiDetailResponseListItem item = findCurrentResponse(sayHiDetailItem);
            if (item == null
                    || !item.hasRead) {
                loadResponseDetail(responseId);
            } else {
                handleSayHiDetailItem(detailItem);
                handleResponseList(detailItem);
            }
        }
    }


    private void handleSayHiDetailFail() {
        responseDetail.setVisibility(View.GONE);
        resContentArea.setVisibility(View.GONE);
        buyTipsView.setVisibility(View.GONE);
        errorView.setVisibility(View.VISIBLE);
        errorView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                errorView.setVisibility(View.GONE);
                loadSayHiDetail();
            }
        });
    }

    private void handleSayhiResponseShowBuyView() {
        mainScrollview.scrollTo(0, 0);
        if (detailItem != null) {
            handleSayHiDetailItem(detailItem);
            handleResponseList(detailItem);
        }

        String title = getString(R.string.say_hi_detail_buy_tips_title, detailItem.detail.nickName);
        buyTipsTitle.setText(title);
        addCreditsBtn.setText(Html.fromHtml(getResources().getString(R.string.say_hi_detail_add_credits_title)));

        buyTipsView.setVisibility(View.VISIBLE);
        replyMinBtn.setVisibility(View.GONE);
        resContentArea.setVisibility(View.GONE);
    }

    private void handleSayHiResponseDetailFail() {
        mainScrollview.scrollTo(0, 0);

        if (detailItem != null) {
            handleSayHiDetailItem(detailItem);
        }

        sayHiResponseAdapter.setSelected(responseId);
        sayHiResponseAdapter.notifyDataSetChanged();
        errorView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                errorView.setVisibility(View.GONE);
                loadResponseDetail(responseId);
            }
        });

        resContentArea.setVisibility(View.GONE);
        buyTipsView.setVisibility(View.GONE);
        errorView.setVisibility(View.VISIBLE);

    }

    /**
     * 读取回复列表接口
     */
    private void loadResponseDetail(final String responseId) {

        loadResponse(responseId, new OnReadSayHiResponseCallback() {
            @Override
            public void onReadSayHiResponse(boolean isSuccess, int errCode, String errMsg,
                                            SayHiDetailResponseListItem item) {
                if (isSuccess) {
                    sendLoadResponseDetailSuccess(item);
                } else {
                    switch (HttpLccErrType.values()[errCode]) {
                        case HTTP_LCC_ERR_SAYHI_READ_NO_CREDIT:
                            sendLoadResponseDetailNeedBuy();
                            break;
                        default:
                            sendLoadResponseDetailFail();
                            break;
                    }
                }
            }
        });
    }

    private void sendLoadResponseDetailNeedBuy() {
        Message message = new Message();
        message.what = MESSAGE_LOAD_SAY_HI_RESPONSE_NEED_BUY;
        sendUiMessage(message);
    }

    private void sendLoadResponseDetailFail() {
        Message message = new Message();
        message.what = MESSAGE_LOAD_SAY_HI_RESPONSE_FAIL;
        sendUiMessage(message);
    }

    private void sendLoadResponseDetailSuccess(SayHiDetailResponseListItem item) {

        Message message = new Message();
        message.what = MESSAGE_LOAD_SAY_HI_RESPONSE_SUCCESS;
        message.obj = item;
        sendUiMessage(message);
    }

    private void handleLoadResponseDetailSuccess(SayHiDetailResponseListItem item) {
        SayHiDetailResponseListItem[] items = detailItem.responseList;
        SayHiDetailResponseListItem i = getCurrentResponse(responseId, items);
        if (i != null) {
            i.update(item);
            handleSayHiDetailItem(detailItem);
            handleResponseList(detailItem);
        }
        mainScrollview.scrollTo(0, 0);
    }

    private void loadResponse(String responseId,
                              OnReadSayHiResponseCallback callback) {
        showProgressDialogBgTranslucent("");
        LiveRequestOperator.getInstance().ReadSayHiResponse(sayHiId,
                responseId, callback);

    }

    /**
     * 处理头部UI
     * @param detailItem
     */
    private void handleSayHiHeader(SayHiDetailItem detailItem) {
        SayHiDetailAnchorItem anchorItem = detailItem.detail;
        //详情头部区域信息 ---- start ----
        setName(anchorItem.nickName, anchorItem.age);
        String date = DateUtil.getDateStr(anchorItem.sendTime * 1000L, FORMAT_SHOW_MONTH_YEAR_DATE);
        sayHiDateTx.setText(date);
        int iconWh = DisplayUtil.dip2px(mContext, 64);
        FrescoLoadUtil.loadUrl(mContext, ladyAvatar, anchorItem.avatar, iconWh, R.drawable.ic_default_photo_woman_rect,
                true, mContext.getResources().getDimensionPixelSize(R.dimen.live_size_2dp), ContextCompat.getColor(mContext, R.color.white));

        if (!TextUtils.isEmpty(anchorItem.imgUrl)) {
            Uri uri = Uri.parse(anchorItem.imgUrl);
            int bgWh = DisplayUtil.dip2px(mContext, 106);
            ImageRequest requestBlur = ImageRequestBuilder.newBuilderWithSource(uri)
                    .setResizeOptions(new ResizeOptions(bgWh, bgWh)) //压缩、裁剪图片
                    .setPostprocessor(new IterativeBoxBlurPostProcessor(2, 20))    //迭代次数，越大越魔化。 //模糊图半径，必须大于0，越大越模糊。
                    .build();
            AbstractDraweeController controllerBlur = Fresco.newDraweeControllerBuilder()
                    .setOldController(backgroundImg.getController())
                    .setImageRequest(requestBlur)
                    .build();
            backgroundImg.setController(controllerBlur);
        }
        //详情头部区域信息 ---- end ----
    }

    /**
     * 处理SayHi详情数据
     *
     * @param detailItem
     */
    private void handleSayHiDetailItem(SayHiDetailItem detailItem) {

        SayHiDetailAnchorItem anchorItem = detailItem.detail;
        //详情中部区域信息 ---- start ----
        ladyName.setText(anchorItem.nickName);
        SayHiDetailResponseListItem[] listItems = detailItem.responseList;
        SayHiDetailResponseListItem item = getCurrentResponse(responseId, listItems);
        if (item != null) {
            String responseDate = DateUtil.getDateStr(item.responseTime * 1000L, FORMAT_SHOW_MONTH_YEAR_DATE);
            String respInfo = getString(R.string.say_hi_detail_response_info, item.responseId, responseDate);
            responseInfo.setText(respInfo);
            responseDetail.setVisibility(View.VISIBLE);
        }
        //详情中部区域信息 ---- end ----


    }

    private void handleResponseList(SayHiDetailItem detailItem) {

        SayHiDetailResponseListItem[] listItems = detailItem.responseList;
        SayHiDetailAnchorItem anchorItem = detailItem.detail;
        int unreadNum = 0;
        if (listItems != null && listItems.length > 0) {
            SayHiDetailResponseListItem item = listItems[0];
            if (listItems.length > 1) {
                for (int i = 0; i < listItems.length; i++) {
                    SayHiDetailResponseListItem it = listItems[i];

                    if (it.responseId.equals(this.responseId)) {
                        if (it.isFree){
                            it.hasRead = true;
                        }
                        item = it;
                    }
                    if (!it.hasRead) {
                        unreadNum++;
                    }
                }
                responseTitle.setVisibility(View.VISIBLE);
                refreshRecyclerView.setVisibility(View.VISIBLE);

                // 2019/6/10 Hardy  设置内容区域的阴影效果，需要配合 background 属性
                mLLContentView.setBackgroundResource(R.drawable.bg_say_hi_detail_blue_gradient);

                responseTitle.setText(Html.fromHtml(getResources().getString(
                        R.string.say_hi_detail_reply_response_title,
                        anchorItem.nickName,
                        unreadNum,
                        anchorItem.responseNum)));
                sayHiResponseAdapter.setSelected(this.responseId);
                sayHiResponseAdapter.setResponseAvatar(anchorItem.avatar);
                sayHiResponseAdapter.setData(Arrays.asList(listItems));
            } else {
                responseTitle.setVisibility(View.GONE);
                refreshRecyclerView.setVisibility(View.GONE);

                // 2019/6/10 Hardy  设置内容区域的阴影效果，需要配合 background 属性
                mLLContentView.setBackground(null);
            }
            int isFree = item.isFree ? View.VISIBLE : View.GONE;
            freeTip.setVisibility(isFree);
            responseContent.setText(item.content);


            if (item.hasImg) {
                responseImg.setVisibility(View.VISIBLE);
                adjustContentImage(item.imgUrl);
            } else {
                responseImg.setVisibility(View.GONE);
            }
            replyMaxBtn.setVisibility(View.VISIBLE);
            replyMinBtn.setVisibility(View.VISIBLE);
            responseDetail.setVisibility(View.VISIBLE);
            resContentArea.setVisibility(View.VISIBLE);
            buyTipsView.setVisibility(View.GONE);
        } else {
            emptyTipsView.setVisibility(View.VISIBLE);
            emptyTipsView.setText(getString(R.string.say_hi_detail_empty_tips, anchorItem.nickName));
        }
    }

    private void setResponseItem(SayHiDetailResponseListItem item) {
        handleLoadResponseDetailSuccess(item);
        sayHiResponseAdapter.setSelected(this.responseId);
        sayHiResponseAdapter.notifyReplaceItem(item);
        mainScrollview.scrollTo(0, 0);
    }

    /**
     * 适配回复内容图片高度
     *
     * @param imageUrl
     */
    private void adjustContentImage(String imageUrl) {
        currentImageUlr = imageUrl;
        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setOldController(responseImg.getController())
                .setControllerListener(new BaseControllerListener<ImageInfo>() {

                    @Override
                    public void onFinalImageSet(String s,
                                                ImageInfo imageInfo,
                                                Animatable animatable) {
                        int w = imageInfo.getWidth();
                        int h = imageInfo.getHeight();
                        int sw = DisplayUtil.getScreenWidth(mContext);
                        float scale = (w * 1f) / (sw * 0.9f);
                        float sh = h / scale;

                        LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) responseImg.getLayoutParams();
                        params.width = (int) (sw * 0.9f);
                        params.height = (int) (sh);
                        responseImg.setLayoutParams(params);

                    }
                }).setUri(Uri.parse(imageUrl))
                .build();
        responseImg.setController(controller);
    }

    /**
     * 主播名年龄
     * @param nickName
     * @param age
     */
    private void setName(String nickName, int age){
        if (!TextUtils.isEmpty(nickName) && age > 0) {
            String info = getString(R.string.say_hi_detail_send_info, nickName, age);
            sendInfo.setText(info);
        }
    }

    /**
     * 初始化数据
     */
    private void initData() {

        Intent data = getIntent();
        sayHiId = data.getStringExtra(KEY_SAY_HI_ID);
        responseId = data.getStringExtra(KEY_RESPONSE_ID);
        String name = data.getStringExtra(KEY_LADY_NAME);
        String avatar = data.getStringExtra(KEY_LADY_AVATAR);
        int age = data.getIntExtra(KEY_LADY_AGE, -1);
        setName(name, age);
        if (!TextUtils.isEmpty(avatar)) {
            int iconWh = DisplayUtil.dip2px(mContext, 64);
            FrescoLoadUtil.loadUrl(mContext, ladyAvatar, avatar, iconWh, R.drawable.ic_default_photo_woman_rect,
                    true, mContext.getResources().getDimensionPixelSize(R.dimen.live_size_2dp), ContextCompat.getColor(mContext, R.color.white));
        }

        if (!TextUtils.isEmpty(sayHiId)) {
            loadSayHiDetail();
        }
    }

    private SayHiDetailResponseListItem getCurrentResponse(String responseId,
                                                           SayHiDetailResponseListItem[] items) {

        SayHiDetailResponseListItem i = null;
        if (items != null) {
            for (SayHiDetailResponseListItem item : items) {

                if (item.responseId.equals(responseId)) {
                    i = item;
                    break;
                }
            }
        }
        return i;
    }


}
