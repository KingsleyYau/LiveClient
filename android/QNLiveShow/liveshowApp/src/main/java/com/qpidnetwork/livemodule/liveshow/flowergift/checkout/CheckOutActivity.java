package com.qpidnetwork.livemodule.liveshow.flowergift.checkout;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.graphics.Paint;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.widget.NestedScrollView;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnCheckOutCartGiftCallback;
import com.qpidnetwork.livemodule.httprequest.OnCreateGiftOrderCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetDeliveryListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetUserInfoCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.LSCheckoutGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.LSCheckoutItem;
import com.qpidnetwork.livemodule.httprequest.item.LSDeliveryItem;
import com.qpidnetwork.livemodule.httprequest.item.UserInfoItem;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.flowergift.FlowersMainActivity;
import com.qpidnetwork.livemodule.liveshow.flowergift.store.FlowersAnchorShopListActivity;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;
import com.qpidnetwork.qnbridgemodule.view.keyboardLayout.SoftKeyboardSizeWatchLayout;

import java.util.ArrayList;
import java.util.List;

/**
 * 购物车CheckOut定单窗口
 * @author Jagger 2019-10-9
 */
public class CheckOutActivity extends BaseActionBarFragmentActivity implements SoftKeyboardSizeWatchLayout.OnResizeListener, OnCheckOutListEventListener, View.OnTouchListener{

    //请求返回
    private final int REQ_LIST_CALLBACK = 1;
    private final int REQ_CHANGE_GIFT_SUM_CALLBACK = 2;
    private final int REQ_DEL_GIFT_CALLBACK = 3;
    private final int REQ_CREATE_ORDER = 4;
    private final int REQ_DELIVERY_LIST_CALLBACK = 5;

    private static final String ANCHOR_ID = "anchorId";
    private static final String ANCHOR_NAME = "anchorName";
    private static final String ANCHOR_IMG = "anchorImg";

    private final int MAX_EDIT_TEXT_LENGTH = 250;    //输入框最大输入长度

    //控件
    private SoftKeyboardSizeWatchLayout sl_root;
    private NestedScrollView sv_body;
    private RelativeLayout rl_bottom;
    private LinearLayout ll_empty;
    private LinearLayout llErrorContainer;
    private TextView tvName;
    private SimpleDraweeView img_anchor;
    private RecyclerView rcv_flowers;
    private CheckOutItemAdapter mAdapter;
    private TextView tv_delivery_fee, tv_offer_title, tv_offer, tv_request_limit, tv_message_limit, tv_total_price, tv_greet_pre;
    private EditText et_message, et_request;
    private LinearLayout ll_greet_pre;
    private Button btn_pay_now;
    private Button btn_continue_shop, btn_to_store;
    private Button btnRetry;

    //数据
    private String mAnchorId = "", mAnchorName = "", mAnchorImg = "";
    private List<CheckOutListItem> mList ;
    private String mOrderNumberPayNow; //已提交的订单号

    public static void lanchAct(Context context, String anchorId, String anchorName, String anchorImgUrl) {
        Intent intent = new Intent(context, CheckOutActivity.class);
        intent.putExtra(ANCHOR_ID, anchorId);
        intent.putExtra(ANCHOR_NAME, anchorName);
        intent.putExtra(ANCHOR_IMG, anchorImgUrl);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_check_out);

        initUI();
        initData();
        setOnClicked();
    }

    @Override
    protected void onResume() {
        super.onResume();
        if(!TextUtils.isEmpty(mOrderNumberPayNow)){
            // 已支付过，则判断是否支付成功，成功就去支付列表
            getDeliveryList();
        }else {
            // 未支付过，刷新数据
            getCheckOutData();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //解绑监听器，防止泄漏
        if (sl_root != null) {
            sl_root.removeOnResizeListener(this);
        }
    }

    /**
     * 初始化各种 View
     */
    private void initUI() {

        //自定义Title
        View titleView = LayoutInflater.from(mContext).inflate(R.layout.layout_checkout_title, null);
        setCustomTitleView(titleView);
        tvName = findViewById(R.id.tvName);
        img_anchor = findViewById(R.id.img_anchor);

        //Body
        sl_root = findViewById(R.id.sl_root);
        sl_root.addOnResizeListener(this);
        rcv_flowers = findViewById(R.id.rcv_flowers);
        tv_delivery_fee = findViewById(R.id.tv_delivery_fee);
        tv_offer_title = findViewById(R.id.tv_offer_title);
        tv_offer = findViewById(R.id.tv_offer);
        tv_message_limit = findViewById(R.id.tv_message_limit);
        tv_request_limit = findViewById(R.id.tv_request_limit);
        sv_body = findViewById(R.id.sv_body);
        rl_bottom = findViewById(R.id.rl_bottom);
        ll_empty = findViewById(R.id.ll_empty);
        llErrorContainer = findViewById(R.id.llErrorContainer);
        tv_total_price = findViewById(R.id.tv_total_price);
        ll_greet_pre = findViewById(R.id.ll_greet_pre);
        tv_greet_pre = findViewById(R.id.tv_greet_pre);
        tv_greet_pre.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);
        et_message = findViewById(R.id.et_message);
        et_message.setOnTouchListener(this);
        et_message.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                int leftLength = MAX_EDIT_TEXT_LENGTH - s.length() ;
                tv_message_limit.setText(String.valueOf(leftLength));
            }
        });
        et_request = findViewById(R.id.et_request);
        et_request.setOnTouchListener(this);
        et_request.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                int leftLength = MAX_EDIT_TEXT_LENGTH - s.length() ;
                tv_request_limit.setText(String.valueOf(leftLength));
            }
        });

        btn_pay_now = findViewById(R.id.btn_pay_now);
        btn_continue_shop = findViewById(R.id.btn_continue_shop);
        btn_to_store = findViewById(R.id.btn_to_store);
        btnRetry = findViewById(R.id.btnRetry);
    }

    /**
     * 初始化本地数据
     */
    private void initData() {
        //传入的参数
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(ANCHOR_ID)){
                mAnchorId = bundle.getString(ANCHOR_ID);
            }
            if(bundle.containsKey(ANCHOR_NAME)){
                String anchorName = bundle.getString(ANCHOR_NAME);
                mAnchorName = anchorName;
                tvName.setText(anchorName);
            }
            if(bundle.containsKey(ANCHOR_IMG)){
                String anchorImg = bundle.getString(ANCHOR_IMG);
                mAnchorImg = anchorImg;
                FrescoLoadUtil.loadUrl(mContext, img_anchor, anchorImg, mContext.getResources().getDimensionPixelSize(R.dimen.my_cart_anchor_img_size), R.color.black4, true);
            }

            if(TextUtils.isEmpty(mAnchorName) || TextUtils.isEmpty(mAnchorImg)){
                getAnchorData();
            }
        }

        //列表数据
        LinearLayoutManager manager = new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false);
        rcv_flowers.setLayoutManager(manager);
        rcv_flowers.setNestedScrollingEnabled(false);   // 将滑动事件交给外层 view 处理，解决滑动冲突

        mList = new ArrayList<>();
        mAdapter = new CheckOutItemAdapter(mContext, mList, mAnchorId);
        mAdapter.setOnEventListener(this);
        rcv_flowers.setAdapter(mAdapter);
    }

    /**
     * 点击事件
     */
    private void setOnClicked(){
        btn_pay_now.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
            if(et_message.length() == 0){
                showErrorTipsDialog(getString(R.string.checkout_create_error_tip1));
                return;
            }

            sendCreateOrder();
            }
        });

        btn_continue_shop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                FlowersAnchorShopListActivity.startAct(mContext, mAnchorId, mAnchorName, mAnchorImg);
                finish();
            }
        });

        btn_to_store.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                FlowersMainActivity.startAct(mContext);
                finish();
            }
        });

        ll_greet_pre.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // 礼品卡
                if(et_message.length() == 0){
                    showErrorTipsDialog(getString(R.string.checkout_create_error_tip1));
                    return;
                }
                GreetingPreviewActivity.lanchAct(mContext, et_message.getText().toString(), LoginManager.getInstance().getLoginItem().nickName);
            }
        });

        btnRetry.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                getCheckOutData();
            }
        });
    }

    /**
     * 取 定单数据
     */
    private void getCheckOutData(){
        showProgressDialog("");
        //定单数据
        LiveRequestOperator.getInstance().CheckOutCartGift(mAnchorId, new OnCheckOutCartGiftCallback() {
            @Override
            public void onCheckOutCartGift(boolean isSuccess, int errCode, String errMsg, LSCheckoutItem checkoutItem) {
            HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, checkoutItem);
            Message msg = Message.obtain();
            msg.what = REQ_LIST_CALLBACK;
            msg.obj = response;
            sendUiMessage(msg);
            }
        });
    }

    /**
     * 取 主播信息
     */
    private void getAnchorData(){
        LiveRequestOperator.getInstance().GetUserInfo(mAnchorId, new OnGetUserInfoCallback() {
            @Override
            public void onGetUserInfo(boolean isSuccess, int errCode, String errMsg, final UserInfoItem userItem) {
            if (isSuccess) {
                sl_root.post(new Runnable() {
                    @Override
                    public void run() {
                        if(userItem != null){
                            mAnchorName = userItem.nickName;
                            tvName.setText(mAnchorName);

                            mAnchorImg = userItem.photoUrl;
                            FrescoLoadUtil.loadUrl(mContext, img_anchor, mAnchorImg, mContext.getResources().getDimensionPixelSize(R.dimen.my_cart_anchor_img_size), R.color.black4, true);
                        }
                    }
                });
            }
            }
        });
    }

    /**
     * 取 订单列表数据
     */
    private void getDeliveryList(){
        showProgressDialog("");
        // 订单数据
        LiveRequestOperator.getInstance().GetDeliveryList(new OnGetDeliveryListCallback() {
            @Override
            public void onGetDeliveryList(boolean isSuccess, int errCode, String errMsg, LSDeliveryItem[] DeliveryList) {
                //回调界面
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, DeliveryList);
                Message msg = Message.obtain();
                msg.what = REQ_DELIVERY_LIST_CALLBACK;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    /**
     * 生成 定单
     */
    private void sendCreateOrder(){
        showProgressDialog("");
        LiveRequestOperator.getInstance().CreateGiftOrder(mAnchorId, et_message.getText().toString(), et_request.getText().toString(), new OnCreateGiftOrderCallback() {
            @Override
            public void onCreateGiftOrder(boolean isSuccess, int errCode, String errMsg, String orderNumber) {
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, orderNumber);
                Message msg = Message.obtain();
                msg.what = REQ_CREATE_ORDER;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        HttpRespObject response = (HttpRespObject) msg.obj;
        switch (msg.what) {
            case REQ_LIST_CALLBACK:
                hideProgressDialog();
                if(response.isSuccess){
                    if(response.data != null){
                        mList.clear();

                        LSCheckoutItem checkoutItem = (LSCheckoutItem)response.data;

                        if(checkoutItem.giftList != null && checkoutItem.giftList.length > 0){
                            //有礼品
                            sv_body.setVisibility(View.VISIBLE);
                            rl_bottom.setVisibility(View.VISIBLE);
                            ll_empty.setVisibility(View.GONE);
                            llErrorContainer.setVisibility(View.GONE);

                            //处理礼品
                            for(int i = 0; i < checkoutItem.giftList.length; i++){
                                LSCheckoutGiftItem lsCheckoutGiftItem = checkoutItem.giftList[i];

                                CheckOutListItem checkOutListItem = new CheckOutListItem();
                                checkOutListItem.type = CheckOutListItem.Type.Gift;
                                checkOutListItem.giftItem = lsCheckoutGiftItem;
                                mList.add(checkOutListItem);
                            }

                            //处理卡
                            if(checkoutItem.greetingCard != null && !TextUtils.isEmpty(checkoutItem.greetingCard.giftId)){
                                CheckOutListItem checkOutListItem = new CheckOutListItem();
                                checkOutListItem.type = CheckOutListItem.Type.Card;
                                checkOutListItem.cardItem = checkoutItem.greetingCard;
                                mList.add(checkOutListItem);
                            }else{
                                ll_greet_pre.setVisibility(View.GONE);
                            }
                            mAdapter.notifyDataSetChanged();

                            //价钱
                            tv_delivery_fee.setText( mContext.getString(R.string.my_cart_price, ApplicationSettingUtil.formatCoinValue(checkoutItem.deliveryPrice)));
                            if(checkoutItem.holidayPrice < 0){
                                //先转为正数
                                checkoutItem.holidayPrice = checkoutItem.holidayPrice*-1;
                            }
                            tv_offer.setText( "-" + mContext.getString(R.string.my_cart_price, ApplicationSettingUtil.formatCoinValue(checkoutItem.holidayPrice)));
                            tv_total_price.setText( mContext.getString(R.string.my_cart_price, ApplicationSettingUtil.formatCoinValue(checkoutItem.totalPrice)));
                        }else{
                            //空数据页
                            sv_body.setVisibility(View.GONE);
                            rl_bottom.setVisibility(View.GONE);
                            ll_empty.setVisibility(View.VISIBLE);
                            llErrorContainer.setVisibility(View.GONE);
                        }

                    }
                }else {
                    //错误页
                    if(mList.size() > 0){
                        ToastUtil.showToast(mContext, response.errMsg);
                    }else{
                        sv_body.setVisibility(View.GONE);
                        rl_bottom.setVisibility(View.GONE);
                        ll_empty.setVisibility(View.GONE);
                        llErrorContainer.setVisibility(View.VISIBLE);
                    }
                }
                break;
            case REQ_DEL_GIFT_CALLBACK:
            case REQ_CHANGE_GIFT_SUM_CALLBACK:
                if(response.isSuccess) {
                    getCheckOutData();
                }else{
                    ToastUtil.showToast(mContext, response.errMsg);
                }
                break;
            case REQ_CREATE_ORDER:
                hideProgressDialog();
                if(response.isSuccess){
                    // 去给钱
                    String orderNumber = (String)response.data;
                    LiveModule.getInstance().onAddCreditClick(mContext, new NoMoneyParamsBean(orderNumber));
                    mOrderNumberPayNow = orderNumber;
                }else{
                    showErrorTipsDialog(response.errMsg);
                }
                break;
            case REQ_DELIVERY_LIST_CALLBACK:
                hideProgressDialog();
                if(!TextUtils.isEmpty(mOrderNumberPayNow)){
                    LSDeliveryItem[] deliveryItems = (LSDeliveryItem[])response.data;
                    if(deliveryItems != null){
                        for(LSDeliveryItem deliveryItem: deliveryItems){
                            if(deliveryItem.orderNumber.equals(mOrderNumberPayNow)){
                                //去订单列表
                                String url = LiveUrlBuilder.createFlowersMainList(FlowersMainActivity.LIST_TYPE_DELIVERY);
                                AppUrlHandler appUrlHandler = new AppUrlHandler(mContext);
                                appUrlHandler.urlHandle(url);

                                finish();
                                return;
                            }
                        }
                    }
                }
                break;
        }
    }

    /**
     * 只带OK按钮的错误提示Dialog
     * @param msg
     */
    private void showErrorTipsDialog(String msg){
        AlertDialog.Builder builder = new AlertDialog.Builder(this)
                .setMessage(msg)
                .setCancelable(true)
                .setPositiveButton(getResources().getString(R.string.common_btn_ok), new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {
                        //点击
                    }
                });
        if (isActivityVisible()) {
            builder.create().show();
        }
    }

    /**
     * EditText竖直方向是否可以滚动
     *
     * @param editText 需要判断的EditText
     * @return true：可以滚动   false：不可以滚动
     */
    private boolean canVerticalScroll(EditText editText) {
        //滚动的距离
        int scrollY = editText.getScrollY();
        //控件内容的总高度
        int scrollRange = editText.getLayout().getHeight();
        //控件实际显示的高度
        int scrollExtent = editText.getHeight() - editText.getCompoundPaddingTop() - editText.getCompoundPaddingBottom();
        //控件内容总高度与实际显示高度的差值
        int scrollDifference = scrollRange - scrollExtent;

        if (scrollDifference == 0) {
            return false;
        }

        return (scrollY > 0) || (scrollY < scrollDifference - 1);
    }

    @Override
    public boolean onTouch(View view, MotionEvent motionEvent) {
        //触摸的是EditText并且当前EditText可以滚动则将事件交给EditText处理；否则将事件交由其父类处理
        if ((view.getId() == R.id.et_message && canVerticalScroll(et_message))
            || (view.getId() == R.id.et_request && canVerticalScroll(et_request))) {
            view.getParent().requestDisallowInterceptTouchEvent(true);//告诉父view，我的事件自己处理
            if (motionEvent.getAction() == MotionEvent.ACTION_UP) {
                view.getParent().requestDisallowInterceptTouchEvent(false);//告诉父view，你可以处理了
            }
        }
        return false;
    }

    @Override
    public void OnSoftPop(int height) {
        rl_bottom.setVisibility(View.GONE);
    }

    @Override
    public void OnSoftClose() {
        rl_bottom.setVisibility(View.VISIBLE);

        // sl_root布局中加入android:focusable="true" android:focusableInTouchMode="true"，
        // 配合MyCartItemAdapter中EditText焦点改变事件，判断是否输入完成
        sl_root.requestFocus();
    }

    @Override
    public void onChangeGiftSum(String anchorId, LSCheckoutGiftItem giftItem, int newSum) {
        LiveRequestOperator.getInstance().ChangeCartGiftNumber(anchorId, giftItem.giftId, newSum, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
            HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, null);
            Message msg = Message.obtain();
            msg.what = REQ_CHANGE_GIFT_SUM_CALLBACK;
            msg.obj = response;
            sendUiMessage(msg);
            }
        });
    }

    @Override
    public void onDelGift(String anchorId, LSCheckoutGiftItem giftItem) {
        LiveRequestOperator.getInstance().RemoveCartGift(anchorId, giftItem.giftId, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
            HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, null);
            Message msg = Message.obtain();
            msg.what = REQ_DEL_GIFT_CALLBACK;
            msg.obj = response;
            sendUiMessage(msg);
            }
        });
    }
}
