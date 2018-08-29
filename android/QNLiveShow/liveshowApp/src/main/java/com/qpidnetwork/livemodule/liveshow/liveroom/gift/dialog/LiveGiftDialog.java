package com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog;

import android.app.Activity;
import android.app.Dialog;
import android.graphics.Color;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.canadapter.CanAdapter;
import com.qpidnetwork.livemodule.framework.canadapter.CanOnItemListener;
import com.qpidnetwork.livemodule.httprequest.OnGetPackageGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.OnGetSendableGiftListCallback;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.SendableGiftItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSender;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftTab;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.view.ScrollLayout;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Hunter on 18/6/28.
 */

public class LiveGiftDialog extends Dialog implements View.OnClickListener{

    private final String TAG = LiveGiftDialog.class.getSimpleName();

    private View mRootView;

    //data
    private Activity mContext;
    private RoomGiftManager mRoomGiftManager;                       //礼物数据管理类
    private GiftTab.GiftTabFlag mCurrentGifttab;                    //记录当前礼物tab
    private int mGridViewItemWidth = 0;                             //当个item的宽度
    private IMRoomInItem mIMRoomInItem;                             //存放房间信息

    //外部交互事件监听器
    private LiveGiftDialogEventListener mLiveGiftDialogEventListener;

    //Store或普通礼物列表
    private List<GiftItem> mNormalGiftItemList;                     //store对应的礼物列表
    private List<NormalGiftAdapter> mNormalGiftAdapterList;         //普通礼物adapater列表

    //背包礼物列表
    private List<PackageGiftItem> mPackageGiftItemList;             //背包对应的礼物列表
    private List<PackageGiftAdapter> mPackageGiftAdapterList;      //背包礼物adapter列表

    //多模块共用数据区
    private LiveGiftDialogHelper mLiveGiftDialogHelper;

    //连击倒计时本地配置
    private int mRepeatSendStartCount = 0;                          //倒计时起始数值
    private int mRepeatSendAnimPeriod = 0;                        //倒计时周期时长


    public LiveGiftDialog(Activity context, RoomGiftManager roomGiftManager, IMRoomInItem imRoomInitem){
        super(context, R.style.CustomTheme_LiveGiftDialog);
        mContext = context;
        this.mRoomGiftManager = roomGiftManager;
        mLiveGiftDialogHelper = new LiveGiftDialogHelper();

        this.mIMRoomInItem = imRoomInitem;
        mLiveGiftDialogHelper.updateManLevel(mIMRoomInItem.manLevel);
        mLiveGiftDialogHelper.updateRoomLevel(mIMRoomInItem.loveLevel);

        mNormalGiftItemList = new ArrayList<GiftItem>();
        mNormalGiftAdapterList = new ArrayList<NormalGiftAdapter>();

        mPackageGiftItemList = new ArrayList<PackageGiftItem>();
        mPackageGiftAdapterList = new ArrayList<PackageGiftAdapter>();


    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.d(TAG,"onCreate");
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH);

        //设置dialog窗口宽高
        WindowManager.LayoutParams layoutParams = getWindow().getAttributes();
        layoutParams.gravity=Gravity.BOTTOM;
        layoutParams.width = DisplayUtil.getScreenWidth(mContext);
        layoutParams.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        getWindow().setAttributes(layoutParams);
        mRootView = View.inflate(getContext(), R.layout.view_live_gift_dialog,null);
        setContentView(mRootView);
        initView(mRootView);
        initData();
    }

    private void initView(View rootView){
        Log.d(TAG,"initView");
        //计算设置dialog高度
        calculateAndResetGiftViewHeight(rootView);

        //设置全屏点击事件
        rootView.findViewById(R.id.fl_giftDialogRootView).setOnClickListener(this);

        //初始化选项卡
        initTabbarViews(rootView);

        //礼物列表及指示器
        initGiftListViews(rootView);

        //初始化下方操作区域
        initGiftOperateViews(rootView);

        //初始化加载中／出错／空数据处理
        initLoadingGiftStatusViews(rootView);
    }

    private void initData(){
        //初始化默认选中标签
        mCurrentGifttab = GiftTab.GiftTabFlag.STORE;

        //读取配置
        mRepeatSendStartCount = getContext().getResources().getInteger(R.integer.repeatSendStartCount);
        mRepeatSendAnimPeriod = getContext().getResources().getInteger(R.integer.repeatSendAnimPerid);

        //读取更新本地数据
        mNormalGiftItemList.addAll(mRoomGiftManager.getLocalSendableList());
        mPackageGiftItemList.addAll(mRoomGiftManager.getLoaclRoomPackageGiftList());
        resetOrInitPageIndexByRecommandId(mLiveGiftDialogHelper.getGiftTabSelectedGiftId(GiftTab.GiftTabFlag.STORE));

        //tab切换（初始化界面）
        onTabSelected(mCurrentGifttab);
    }

    /**
     * 计算被设置dialog礼物区域高度（titlebar高度 ＋ 礼物区域高度（礼物＋分页）＋ 礼物marginbottom）
     * ps：内部已经设置根据父view变化，只需设置父高度即可
     */
    private void calculateAndResetGiftViewHeight(View rootView){
        int coloum = mContext.getResources().getInteger(R.integer.gift_list_coloum);
        mGridViewItemWidth = DisplayUtil.getScreenWidth(mContext)/coloum;       //单个礼物想高度和宽度一致
        float test = mContext.getResources().getDimension(R.dimen.gift_titlebar_height);
        int dialogHeight = (int)(mContext.getResources().getDimension(R.dimen.gift_titlebar_height) + mContext.getResources().getDimension(R.dimen.gift_page_indicator_height)
                + mContext.getResources().getDimension(R.dimen.gift_area_margin_bottom) + 2 * mGridViewItemWidth);

        FrameLayout fl_giftDialogContainer = (FrameLayout)rootView.findViewById(R.id.fl_giftDialogContainer);
        FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) fl_giftDialogContainer.getLayoutParams();
//        params.width = FrameLayout.LayoutParams.MATCH_PARENT;
        params.width = DisplayUtil.getScreenWidth(mContext);
        params.height = dialogHeight;
        params.gravity = Gravity.BOTTOM;
        fl_giftDialogContainer.setLayoutParams(params);
    }

    /**
     * 显示礼物列表
     * @param recommandGiftId  指定的推荐礼物id
     */
    public void show(String recommandGiftId){
        super.show();
        //dialog是否创建即是否走过onCreate
        if(sl_giftPagerContainer != null){
            boolean isStoreListUpdate = false;
            boolean isPackageListUpdate = false;
            List<GiftItem> localSendableList = mRoomGiftManager.getLocalSendableList();
            List<PackageGiftItem> localPackagelist = mRoomGiftManager.getLoaclRoomPackageGiftList();
            if(mNormalGiftItemList.size() != localSendableList.size()){
                //普通礼物列表更新
                mNormalGiftItemList.clear();
                mNormalGiftItemList.addAll(localSendableList);
                isStoreListUpdate = true;
            }

            if(mPackageGiftItemList.size() != localPackagelist.size()){
                //背包礼物更新
                mPackageGiftItemList.clear();
                mPackageGiftItemList.addAll(localPackagelist);
                isPackageListUpdate = true;
            }

            //根据推荐重置页码
            if(!TextUtils.isEmpty(recommandGiftId)) {
                resetOrInitPageIndexByRecommandId(recommandGiftId);
            }

            if(mCurrentGifttab == GiftTab.GiftTabFlag.STORE){
                if(isStoreListUpdate){
                    //数据改变，直接重构即可
                    onTabSelected(GiftTab.GiftTabFlag.STORE);
                }else{
                    //刷新是为了防止推荐导致页数改变
                    if(!TextUtils.isEmpty(recommandGiftId)) {
                        //推荐进入刷新，否则不刷新
                        if (mNormalGiftAdapterList.size() > 0) {
                            int pageIndex = mLiveGiftDialogHelper.getGiftTabSelectedPageIndex(GiftTab.GiftTabFlag.STORE);
                            if (pageIndex < mNormalGiftAdapterList.size()) {
                                sl_giftPagerContainer.setToScreen(pageIndex);
                                updateIndicatorStatus(pageIndex);
                            }
                            notifyGiftListDataChange();
                        }
                    }
                }
            }else if(mCurrentGifttab == GiftTab.GiftTabFlag.BACKPACK){
                if(!TextUtils.isEmpty(recommandGiftId)){
                    //推荐进入，直接切换
                    onTabSelected(GiftTab.GiftTabFlag.STORE);
                }else if(isPackageListUpdate){
                    //刷新背包列表
                    onTabSelected(GiftTab.GiftTabFlag.BACKPACK);
                }
            }
        }
        if(!TextUtils.isEmpty(recommandGiftId)){
            //设置默认选中礼物
            onGiftItemSelected(recommandGiftId, false);
        }
    }

    /**
     * 更新当前选中页
     * @param giftId
     */
    private void resetOrInitPageIndexByRecommandId(String giftId){
        int giftNumPerPage = mContext.getResources().getInteger(R.integer.gift_list_row) * mContext.getResources().getInteger(R.integer.gift_list_coloum);
        if(!TextUtils.isEmpty(giftId) && mNormalGiftItemList != null && mNormalGiftItemList.size() > 0){
            int currentIndex = getCurrentPageIndexByGiftIdForStore(giftId, giftNumPerPage);
            mLiveGiftDialogHelper.updateGiftTabPageIndex(GiftTab.GiftTabFlag.STORE, currentIndex);
        }
    }

    /**
     * 更新直播间信息（目前主要是用户等级改变或房间亲密度改变）
     * @param imRoomInItem
     */
    public void updateRoomInfo(IMRoomInItem imRoomInItem){
        //更新本地信息及模块共享内存区
        this.mIMRoomInItem = imRoomInItem;
        mLiveGiftDialogHelper.updateManLevel(mIMRoomInItem.manLevel);
        mLiveGiftDialogHelper.updateRoomLevel(mIMRoomInItem.loveLevel);

        //不可见也必须刷新，否则每次show都必须重建
//        if(isShowing()){
            notifyGiftListDataChange();
//        }

    }

    /**
     * 礼物发送失败通知
     */
    public void notifyGiftSentFailed(){
        //停止连击动画
        stopRepeatSendGift();
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if (i == R.id.tv_reloadGiftList) {
            if(mCurrentGifttab == GiftTab.GiftTabFlag.STORE){
                getNormalGiftList();
            }else if(mCurrentGifttab == GiftTab.GiftTabFlag.BACKPACK){
                getPackageGiftList();
            }
        } else if (i == R.id.ll_userBalance) {
            //GA统计点击查看个人点数
            if(mLiveGiftDialogEventListener != null){
                mLiveGiftDialogEventListener.onAudiencBalanceClick(mRootView);
            }
            if(mContext instanceof AnalyticsFragmentActivity){
                ((AnalyticsFragmentActivity)mContext).onAnalyticsEvent(mContext.getResources().getString(R.string.Live_Broadcast_Category),
                        mContext.getResources().getString(R.string.Live_Broadcast_Action_MyBalance),
                        mContext.getResources().getString(R.string.Live_Broadcast_Label_MyBalance));
            }
        } else if (i == R.id.fl_giftDialogRootView) {
            //全屏点击，收起dialog
            dismiss();
        } else if (i == R.id.ll_repeatSendAnim) {
            sendGift(true);
        } else if (i == R.id.tv_sendGift) {
            //修复不可发送的礼物也会调发送礼物接口的bug
            if(tv_sendGift.isEnabled()){
                sendGift(false);
            }
        } else if (i == R.id.ll_countChooser) {
            //请求数据失败即非礼物展示状态时不可点击
            if (checkCanShowCounter()) {
                boolean isShowing = lv_giftCount.getVisibility() == View.VISIBLE;
                showGiftCounterList(!isShowing);
            }

        }
    }

    /***************************************** 礼物列表分页管理 *******************************************/
    //tabBar
    private View ll_storeGiftTab;
    private ImageView iv_StoreGiftTab;
    private TextView tv_StoreGiftTab;
    private View ll_PkgGiftTab;
    private ImageView iv_PkgGiftTab;
    private TextView tv_PkgGiftTab;

    /**
     * 初始化选项卡
     */
    private void initTabbarViews(View rootView){
        //tabBar
        ll_storeGiftTab = rootView.findViewById(R.id.ll_StoreGiftTab);
        iv_StoreGiftTab = (ImageView) rootView.findViewById(R.id.iv_StoreGiftTab);
        tv_StoreGiftTab = (TextView) rootView.findViewById(R.id.tv_StoreGiftTab);
        ll_PkgGiftTab = rootView.findViewById(R.id.ll_PkgGiftTab);
        iv_PkgGiftTab = (ImageView) rootView.findViewById(R.id.iv_PkgGiftTab);
        tv_PkgGiftTab = (TextView) rootView.findViewById(R.id.tv_PkgGiftTab);

        ll_storeGiftTab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //点击背包
                onTabSelected(GiftTab.GiftTabFlag.STORE);
            }
        });

        ll_PkgGiftTab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                //点击背包
                onTabSelected(GiftTab.GiftTabFlag.BACKPACK);
            }
        });
    }

    /**
     * tab切换
     * @param giftTab
     */
    private void onTabSelected(GiftTab.GiftTabFlag giftTab){
        mCurrentGifttab = giftTab;
        //禁用切换动画
        sl_giftPagerContainer.abortScrollAnimation();
        //修改tabbar样式
        updateGiftTabStyle(giftTab);
        //关闭数目选中及发送可点击
        setSendGiftBtnEnable(false);
        //重置连击及数目选择框
        resetRepeatOrChooserStatus();
        //切换礼物界面并刷新界面
        onCurrentTabViewsRefresh(giftTab);
    }

    /**
     * 根据当前刷新状态及数据刷新显示界面
     * @param giftTab
     */
    private void onCurrentTabViewsRefresh(GiftTab.GiftTabFlag giftTab){
        //隐藏错误页面，防止共用错误页导致显示错误
        hideStatusPages();
        //重置所有view，等待重新刷新，防止由于本地无数据导致，切换时错误页下面仍然是其他tab页面
        sl_giftPagerContainer.removeAllViews();
        if(giftTab == GiftTab.GiftTabFlag.STORE){
            if(mNormalGiftItemList != null && mNormalGiftItemList.size() > 0){
                createOrResetStoreGiftViews();
            }else{
                getNormalGiftList();
            }
        }else if(giftTab == GiftTab.GiftTabFlag.BACKPACK){
            if(mPackageGiftItemList != null && mPackageGiftItemList.size() > 0){
                createOrResetPackageGiftViews();
            }else{
                getPackageGiftList();
            }
        }
    }

    /**
     * tabbar 切换同步修改样式
     * @param giftTab
     */
    private void updateGiftTabStyle(GiftTab.GiftTabFlag giftTab) {
        ll_storeGiftTab.setBackgroundColor(giftTab == GiftTab.GiftTabFlag.BACKPACK ?
                Color.BLACK : Color.parseColor("#2b2b2b"));
        iv_StoreGiftTab.setImageDrawable(mContext.getResources().getDrawable(
                giftTab == GiftTab.GiftTabFlag.STORE ?
                        R.drawable.ic_gifttab_store_selected : R.drawable.ic_gifttab_store_unselected));
        tv_StoreGiftTab.setTextColor(Color.parseColor(giftTab == GiftTab.GiftTabFlag.STORE ?
                "#f7cd3a" : "#59ffffff"));
        ll_PkgGiftTab.setBackgroundColor(giftTab == GiftTab.GiftTabFlag.STORE ?
                Color.BLACK : Color.parseColor("#2b2b2b"));
        iv_PkgGiftTab.setImageDrawable(mContext.getResources().getDrawable(
                giftTab == GiftTab.GiftTabFlag.BACKPACK ?
                        R.drawable.ic_gifttab_pkg_selected : R.drawable.ic_gifttab_pkg_unselected));
        tv_PkgGiftTab.setTextColor(Color.parseColor(giftTab == GiftTab.GiftTabFlag.BACKPACK ?
                "#f7cd3a" : "#59ffffff"));
    }

    /***************************************** 礼物及分页展示区域 *******************************************/
    //礼物展示滚动列表
    private ScrollLayout sl_giftPagerContainer;
    //indicator
    private LinearLayout ll_indicator;

    /**
     * 初始化礼物展示区域
     */
    private void initGiftListViews(View rootView){
        //礼物展示滚动列表
        sl_giftPagerContainer = (ScrollLayout) rootView.findViewById(R.id.sl_giftPagerContainer);
        sl_giftPagerContainer.setOnScreenChangeListener(new ScrollLayout.OnScreenChangeListener() {
            @Override
            public void onScreenChange(int currentIndex) {
                //礼物页面滚动事件
                updateIndicatorStatus(currentIndex);
            }
        });
        ll_indicator = (LinearLayout) rootView.findViewById(R.id.ll_indicator);
    }

    /**
     * 更新指示器状态
     * @param selectedIndex 当前礼物页索引
     */
    private void updateIndicatorStatus(int selectedIndex){
        mLiveGiftDialogHelper.updateGiftTabPageIndex(mCurrentGifttab, selectedIndex);
        int pageCount = ll_indicator.getChildCount();
        for(int index = 0; index<pageCount; index++){
            View view = ll_indicator.getChildAt(index);
            if(null != view && View.VISIBLE == view.getVisibility()){
                view.setSelected(selectedIndex == index);
            }
        }
    }

    /**
     * 生成普通礼物列表滚动列表，并初始化数据
     */
    private void createOrResetStoreGiftViews(){
        //每页礼物数目
        int giftNumPerPage = mContext.getResources().getInteger(R.integer.gift_list_row) * mContext.getResources().getInteger(R.integer.gift_list_coloum);
        int pageCount = (mNormalGiftItemList.size()/giftNumPerPage)+ (0 == mNormalGiftItemList.size()%giftNumPerPage ? 0 : 1);


        //更新方式为删除旧的所有view
        sl_giftPagerContainer.removeAllViews();
        mNormalGiftAdapterList.clear();

        for(int index=0 ; index < pageCount; index++){
            GridView gridView = (GridView) View.inflate(mContext, R.layout.item_simple_gridview_1,null);
            int maxPagePosition = giftNumPerPage*(index+1);
            List<GiftItem> subPackageList = mNormalGiftItemList.subList(giftNumPerPage * index, maxPagePosition< mNormalGiftItemList.size() ? maxPagePosition : mNormalGiftItemList.size());
            final NormalGiftAdapter<GiftItem> giftAdapter = new NormalGiftAdapter(mContext, mLiveGiftDialogHelper, subPackageList);
            giftAdapter.setItemWidth(mGridViewItemWidth);
            giftAdapter.setOnItemListener(new CanOnItemListener(){
                @Override
                public void onItemChildClick(View view, int position) {
                    GiftItem selectedGiftItem = (GiftItem) giftAdapter.getList().get(position);
                    onGiftItemSelected(selectedGiftItem.id, true);
                }
            });
            gridView.setAdapter(giftAdapter);
            mNormalGiftAdapterList.add(giftAdapter);
            gridView.setNumColumns(getContext().getResources().getInteger(R.integer.gift_list_coloum));// 每行显示几个
            gridView.setColumnWidth(mGridViewItemWidth);
            gridView.setStretchMode(GridView.STRETCH_COLUMN_WIDTH);
            ViewGroup.LayoutParams gridViewLp = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, mGridViewItemWidth * 2);
            sl_giftPagerContainer.addView(gridView,gridViewLp);
        }

        //创建指示器
        createIndicatorView(pageCount);

        //滚动到当前页
        int currentIndex = mLiveGiftDialogHelper.getGiftTabSelectedPageIndex(GiftTab.GiftTabFlag.STORE);
        if(currentIndex < mNormalGiftAdapterList.size()) {
            sl_giftPagerContainer.setToScreen(currentIndex);
            updateIndicatorStatus(currentIndex);
        }else{
            mLiveGiftDialogHelper.updateGiftTabPageIndex(GiftTab.GiftTabFlag.STORE, 0);
        }

        //设置默认选中
        String selectedGiftId = mLiveGiftDialogHelper.getGiftTabSelectedGiftId(GiftTab.GiftTabFlag.STORE);
        if(TextUtils.isEmpty(selectedGiftId)){
            //未设置默认取第一个
            selectedGiftId = mNormalGiftItemList.get(0).id;
        }
        onGiftItemSelected(selectedGiftId, false);
    }

    /**
     * 生成背包礼物列表滚动列表，并初始化数据
     */
    private void createOrResetPackageGiftViews(){
        //每页礼物数目
        int giftNumPerPage = mContext.getResources().getInteger(R.integer.gift_list_row) * mContext.getResources().getInteger(R.integer.gift_list_coloum);
        int pageCount = (mPackageGiftItemList.size()/giftNumPerPage)+ (0 == mPackageGiftItemList.size()%giftNumPerPage ? 0 : 1);

        //更新方式为删除旧的所有view
        sl_giftPagerContainer.removeAllViews();
        mPackageGiftAdapterList.clear();

        for(int index=0 ; index < pageCount; index++){
            GridView gridView = (GridView) View.inflate(mContext, R.layout.item_simple_gridview_1,null);
            int maxPagePosition = giftNumPerPage*(index+1);
            List<PackageGiftItem> subPackageList = mPackageGiftItemList.subList(giftNumPerPage * index, maxPagePosition< mPackageGiftItemList.size() ? maxPagePosition : mPackageGiftItemList.size());
            final PackageGiftAdapter<PackageGiftItem> giftAdapter = new PackageGiftAdapter(mContext, mLiveGiftDialogHelper, mRoomGiftManager, subPackageList);
            giftAdapter.setItemWidth(mGridViewItemWidth);
            giftAdapter.setOnItemListener(new CanOnItemListener(){
                @Override
                public void onItemChildClick(View view, int position) {
                    PackageGiftItem selectedGiftItem = (PackageGiftItem) giftAdapter.getList().get(position);
                    onGiftItemSelected(selectedGiftItem.giftId, true);
                }
            });
            gridView.setAdapter(giftAdapter);
            mPackageGiftAdapterList.add(giftAdapter);
            gridView.setNumColumns(getContext().getResources().getInteger(R.integer.gift_list_coloum));// 每行显示几个
            gridView.setColumnWidth(mGridViewItemWidth);
            gridView.setStretchMode(GridView.STRETCH_COLUMN_WIDTH);
            ViewGroup.LayoutParams gridViewLp = new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, mGridViewItemWidth * 2);
            sl_giftPagerContainer.addView(gridView,gridViewLp);
        }

        //创建指示器
        createIndicatorView(pageCount);

        //滚动到当前页
        int currentIndex = mLiveGiftDialogHelper.getGiftTabSelectedPageIndex(GiftTab.GiftTabFlag.BACKPACK);
        if(currentIndex < mPackageGiftAdapterList.size()) {
            sl_giftPagerContainer.setToScreen(currentIndex);
            updateIndicatorStatus(currentIndex);
        }else{
            mLiveGiftDialogHelper.updateGiftTabPageIndex(GiftTab.GiftTabFlag.BACKPACK, 0);
        }

        //设置默认选中
        String selectedGiftId = mLiveGiftDialogHelper.getGiftTabSelectedGiftId(GiftTab.GiftTabFlag.BACKPACK);
        if(TextUtils.isEmpty(selectedGiftId)){
            //未设置默认取第一个
            selectedGiftId = mPackageGiftItemList.get(0).giftId;
        }
        onGiftItemSelected(selectedGiftId, false);
    }

    /**
     * 更新指示器图标数量展示，当礼物数量发生变动的时候调用
     * @param pageCount 礼物页数
     */
    private void createIndicatorView(int pageCount){
        ll_indicator.removeAllViews();
        int endIndex = pageCount-1;
        int indicatorWidth = DisplayUtil.dip2px(mContext,6f);
        int indicatorMargin = DisplayUtil.dip2px(mContext,4f);
        for(int index=0; index<pageCount; index++){
            ImageView indicator = new ImageView(getContext());
            LinearLayout.LayoutParams lp_indicator =
                    new LinearLayout.LayoutParams(indicatorWidth, indicatorWidth);
            lp_indicator.gravity = Gravity.CENTER;
            lp_indicator.leftMargin = 0 == index ? 0 : indicatorMargin;//px 需要转换成dip单位
            lp_indicator.rightMargin = endIndex == index ? 0 : indicatorMargin;
            indicator.setLayoutParams(lp_indicator);
            indicator.setBackgroundDrawable(mContext.getResources().getDrawable(R.drawable.selector_page_indicator));
            indicator.setTag(index);
            indicator.setOnClickListener(new View.OnClickListener(){
                @Override
                public void onClick(View v) {
                    Integer index = (Integer)v.getTag();
                    sl_giftPagerContainer.setToScreen(index.intValue());
                }
            });
            ll_indicator.addView(indicator);
        }
    }

    /**
     * 根据giftId获取当前选中页
     * @param giftId
     * @return
     */
    private int getCurrentPageIndexByGiftIdForStore(String giftId, int giftPerPage){
        int pageIndex = 0;
        if(giftPerPage > 0) {
            int indexInArray = -1;
            for (int i = 0; i < mNormalGiftItemList.size(); i++) {
                String tempGiftId = mNormalGiftItemList.get(i).id;
                if (!TextUtils.isEmpty(tempGiftId)
                        && tempGiftId.equals(giftId)) {
                    indexInArray = i;
                    break;
                }
            }
            pageIndex = (indexInArray + 1) / giftPerPage + ((indexInArray+1)%giftPerPage > 0 ? 1:0) - 1;
        }
        return pageIndex;
    }

    /**
     * 礼物列表单个选中
     * @param giftId
     * @param isUserOperate  是否用户选中
     */
    public void onGiftItemSelected(String giftId, boolean isUserOperate){
        //判断是否选中改变，需更改状态
        boolean isSelectChanged = false;
        String oldSelectedGiftId = mLiveGiftDialogHelper.getGiftTabSelectedGiftId(mCurrentGifttab);
        if(TextUtils.isEmpty(oldSelectedGiftId)||(!TextUtils.isEmpty(giftId)
                && !giftId.equals(oldSelectedGiftId))){
            isSelectChanged = true;
        }
        if(isSelectChanged){
            //更改可选数量
            final List<Integer> numList = getGiftNumList(giftId);
            resetGiftCounterData(numList);

            //重置右下角状态及连击状态
            resetRepeatOrChooserStatus();

            //更新最后选中礼物id
            mLiveGiftDialogHelper.updateGiftTabSelectedGiftId(mCurrentGifttab, giftId);

            //通知界面数据改变刷新（主要处理选中状态）
            notifyGiftListDataChange();
        }

        //点击时检测礼物是否可发送，被页面提示
        checkGiftSendable(giftId, isUserOperate);
    }

    /**
     * 通知更新所有礼物的状态（尤其切换可能多页之间切换）
     */
    public void notifyGiftListDataChange(){
        if(mCurrentGifttab == GiftTab.GiftTabFlag.STORE){
            for(CanAdapter adapter : mNormalGiftAdapterList){
                adapter.notifyDataSetChanged();
            }
        }else{
            for(CanAdapter adapter : mPackageGiftAdapterList){
                adapter.notifyDataSetChanged();
            }
        }
    }

    /**
     * 获取位置position对应的礼物的可发送数量数组
     * @return
     */
    private List<Integer> getGiftNumList(String giftId){
        List<Integer> numList = new ArrayList<Integer>();
        GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(giftId);
        if(giftItem != null && (giftItem.giftChooser != null)) {
            for (Integer num : giftItem.giftChooser) {
                numList.add(num);
            }
        }
        return numList;
    }

    /**
     * 点击礼物，礼物不满足用户level或亲密度等不可发送时toast提示
     * @param giftId
     * @param isUserOperate
     */
    private void checkGiftSendable(String giftId, boolean isUserOperate){
        String msg = "";
        GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(giftId);
        if(giftItem != null){
            if(!mRoomGiftManager.checkGiftSendable(giftId)){
                //当前礼物不在可发送列表
                msg = mContext.getResources().getString(R.string.liveroom_gift_pack_notsendable);
            }else{
                //可发送，检测亲密度及等级
                if(giftItem.levelLimit > mIMRoomInItem.manLevel){
                    msg = mContext.getResources().getString(R.string.liveroom_gift_user_levellimit,String.valueOf(giftItem.levelLimit));
                }else if(giftItem.lovelevelLimit > mIMRoomInItem.loveLevel){
                    msg = mContext.getResources().getString(R.string.liveroom_gift_intimacy_levellimit,String.valueOf(giftItem.lovelevelLimit));
                }
            }
        }
        if(!TextUtils.isEmpty(msg)){
            //用户手动点击选中礼物才需要弹出提示
            if(isUserOperate && mLiveGiftDialogEventListener != null){
                mLiveGiftDialogEventListener.onShowToastTipsNotify(msg);
            }
            setSendGiftBtnEnable(false);
        }else{
            setSendGiftBtnEnable(true);
        }
    }

    /***************************************** 礼物数目选择及发送区域 *******************************************/

    //礼物发送数目选择
    private View ll_countChooser;
    private ListView lv_giftCount;
    private TextView tv_giftCount;
    private ImageView iv_countIndicator;

    //发送按钮及连击按钮
    private TextView tv_sendGift;
    private LinearLayout ll_repeatSendAnim;
    private TextView tv_timeCount;

    //数目选择listview adapter
    private GiftCountSelectorAdapter giftCountSelectorAdapter;
    //连击倒计时定时器
    private GiftRepeatSendTimerManager timerManager;

    /**
     * 初始化操作控制区域
     * @param rootView
     */
    private void initGiftOperateViews(View rootView){
        //数目选择区域
        ll_countChooser = rootView.findViewById(R.id.ll_countChooser);
        tv_giftCount = (TextView) rootView.findViewById(R.id.tv_giftCount);
        iv_countIndicator = (ImageView) rootView.findViewById(R.id.iv_countIndicator);
        //弹出数目选选择列表
        lv_giftCount = (ListView) rootView.findViewById(R.id.lv_giftCount);
        giftCountSelectorAdapter = new GiftCountSelectorAdapter(mContext,
                R.layout.item_simple_list_gift_count);
        lv_giftCount.setAdapter(giftCountSelectorAdapter);
        lv_giftCount.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                giftCountSelectorAdapter.notifyDataSetChanged();
                return false;
            }
        });
        lv_giftCount.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                //harry确定为解决点击item效果
                giftCountSelectorAdapter.notifyDataSetChanged();
                return false;
            }
        });
        //设置数目选中点击事件
        giftCountSelectorAdapter.setOnItemListener(new CanOnItemListener(){
            @Override
            public void onItemChildClick(View view, int position) {
                updateGiftCountSelected(position);
            }
        });
        lv_giftCount.setVisibility(View.GONE);

        //发送逻辑
        tv_sendGift = (TextView) rootView.findViewById(R.id.tv_sendGift);
        ll_repeatSendAnim = (LinearLayout) rootView.findViewById(R.id.ll_repeatSendAnim);
        tv_timeCount = (TextView) rootView.findViewById(R.id.tv_timeCount);

        //点击选择礼物数目
        ll_countChooser.setOnClickListener(this);
        tv_sendGift.setOnClickListener(this);
        ll_repeatSendAnim.setOnClickListener(this);
        //设置my balance点击事件
        rootView.findViewById(R.id.ll_userBalance).setOnClickListener(this);

        //默认发送按钮不可点击
        setSendGiftBtnEnable(false);
    }

    /**
     * 检测是否可以展示chooser列表
     * @return
     */
    private boolean checkCanShowCounter(){
        boolean canShow = false;
        if(mCurrentGifttab == GiftTab.GiftTabFlag.STORE){
            if(mNormalGiftItemList != null && mNormalGiftItemList.size() > 0){
                canShow = true;
            }
        }else if(mCurrentGifttab == GiftTab.GiftTabFlag.BACKPACK){
            if(mPackageGiftItemList != null && mPackageGiftItemList.size() > 0){
                canShow = true;
            }
        }
        return canShow;
    }

    /**
     * 点击显示可选数目列表
     */
    private void showGiftCounterList(boolean isVisible){
        iv_countIndicator.setSelected(!isVisible);
        giftCountSelectorAdapter.notifyDataSetChanged();
        lv_giftCount.setVisibility(isVisible?View.VISIBLE:View.GONE);
    }

    /**
     * 点击礼物切换或初始化时，设置可选数目
     * @param numList
     */
    private void resetGiftCounterData(List<Integer> numList){
        giftCountSelectorAdapter.setList(numList);
        //默认选中第一个
        updateGiftCountSelected(0);
    }

    /**
     *
     * @param position 选中位置
     */
    private void updateGiftCountSelected(int position){
        //更新选中位置，并重画
        giftCountSelectorAdapter.setSelectedPosition(position);
        //选中后，隐藏listview
        lv_giftCount.setVisibility(View.GONE);
        //更新选中数目及图标状态
        iv_countIndicator.setSelected(true);
        tv_giftCount.setText(String.valueOf(giftCountSelectorAdapter.getList().get(position)));
    }

    /**
     * 设置礼物发送按钮状态
     * @param enabled
     */
    private void setSendGiftBtnEnable(boolean enabled){
        //解决TextView、EditView、Button使用setBackgroundDrawable或setBackgroundResource则xml中设置的Padding失效
        int _pL = tv_sendGift.getPaddingLeft();
        int _pT = tv_sendGift.getPaddingTop();
        int _pR = tv_sendGift.getPaddingRight();
        int _pB = tv_sendGift.getPaddingBottom();
        tv_sendGift.setBackgroundDrawable(mContext.getResources().getDrawable(
                enabled ?R.drawable.selector_live_buttom_gift_send :R.drawable.bg_live_buttom_gift_send_unusable));
        tv_sendGift.setPadding(_pL, _pT, _pR, _pB);

        tv_sendGift.setEnabled(enabled);
        tv_sendGift.setTextColor(enabled ? mContext.getResources().getColor(R.color.custom_dialog_txt_color_simple) : Color.WHITE);
        ll_countChooser.setBackgroundDrawable(mContext.getResources().getDrawable(
                enabled ? R.drawable.bg_live_buttom_gift_count_chooser_usuable :  R.drawable.bg_live_buttom_gift_count_chooser_unusuable
        ));
    }

    /**
     * 开启连击礼物状态
     */
    private void startRepeatSendGift(){
        //启动连击界面
        updateRepeatAnimationStatus(false);

        //启动连击定时器
        startRepeatCountTask(mRepeatSendStartCount);
    }

    /**
     * 停止链接状态
     */
    private void stopRepeatSendGift(){
        //界面刷新
        updateRepeatAnimationStatus(true);

        //停止定时器
        if(null != timerManager && timerManager.isRunning()){
            timerManager.stop();
        }
    }

    /**
     * 连击状态改变界面处理
     * @param isStop 启动或停止
     */
    private void updateRepeatAnimationStatus(boolean isStop){
        ll_repeatSendAnim.setVisibility(isStop?View.GONE:View.VISIBLE);
        tv_sendGift.setVisibility(isStop?View.VISIBLE:View.INVISIBLE);
        ll_countChooser.setVisibility(isStop?View.VISIBLE:View.GONE);
        lv_giftCount.setVisibility(View.GONE);
    }

    /**
     * 启动倒计时
     * @param startCount
     */
    private void startRepeatCountTask(int startCount){
        if(null == timerManager){
            timerManager = new GiftRepeatSendTimerManager();
            timerManager.setOnTimerTaskExecuteListener(onTimerTaskExecuteListener);
        }

        timerManager.start(startCount, mRepeatSendAnimPeriod);
    }

    /**
     * 定时器监听器
     */
    private OnTimerTaskExecuteListener onTimerTaskExecuteListener = new OnTimerTaskExecuteListener() {
        @Override
        public void onTaskExecute(final int executeCount) {
            mContext.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    //记录最后一次显示
                    if (null != tv_timeCount) {
                        tv_timeCount.setText(String.valueOf(executeCount));
                    }
                }
            });
        }

        @Override
        public void onTaskEnd() {
            //连送通道关闭
            mContext.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    stopRepeatSendGift();
                }
            });
        }
    };

    /**
     * 重置为出事状态
     */
    private void resetRepeatOrChooserStatus(){
        //隐藏数目选择状态
        showGiftCounterList(false);
        //停止连击状态
        stopRepeatSendGift();
    }

    /***************************************** 列表加载中／无数据／加载出错页面 *******************************************/
    private LinearLayout llStatusLayout;
    private ProgressBar pbLoading;              //加载中进度条
    private ImageView ivStatus;                 //空数据等上方图片提示
    private TextView tvDesc;                    //文本描述
    private TextView tv_reloadGiftList;         //reload等操作按钮

    /**
     * 初始化加载状态展示模块（设计上整体居中）
     * @param rootView
     */
    private void initLoadingGiftStatusViews(View rootView){
        llStatusLayout = (LinearLayout) rootView.findViewById(R.id.llStatusLayout);
        pbLoading = (ProgressBar) rootView.findViewById(R.id.pbLoading);
        ivStatus = (ImageView) rootView.findViewById(R.id.ivStatus);
        tvDesc = (TextView) rootView.findViewById(R.id.tvDesc);
        tv_reloadGiftList = (TextView) rootView.findViewById(R.id.tv_reloadGiftList);
    }

    /**
     * 刷新当前store礼物列表
     */
    private void getNormalGiftList(){
        showLoadingProgress();
        mRoomGiftManager.getSendableGiftList(new OnGetSendableGiftListCallback() {
            @Override
            public void onGetSendableGiftList(final boolean isSuccess, int errCode, String errMsg, final SendableGiftItem[] giftIds) {
                mContext.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if(mCurrentGifttab == GiftTab.GiftTabFlag.STORE) {
                            if (isSuccess) {
                                List<GiftItem> localGiftList = mRoomGiftManager.getLocalSendableList();
                                //加载成功
                                if (localGiftList == null || localGiftList.size() == 0) {
                                    showGiftEmptyTips(GiftTab.GiftTabFlag.STORE);
                                } else {
                                    //加载成功且返回列表（列表未过滤是否包含详情详情）不为空
                                    hideStatusPages();
                                    mNormalGiftItemList.clear();
                                    mNormalGiftItemList.addAll(localGiftList);
                                    resetOrInitPageIndexByRecommandId(mLiveGiftDialogHelper.getGiftTabSelectedGiftId(GiftTab.GiftTabFlag.STORE));

                                    //初始化选中第一页第一个礼物
                                    createOrResetStoreGiftViews();
                                }
                            } else {
                                //加载失败，错误页
                                showLoadingFailedTips();
                            }
                        }
                    }
                });
            }
        });
    }

    /**
     * 刷新当前package礼物列表
     */
    private void getPackageGiftList(){
        showLoadingProgress();
        mRoomGiftManager.getPackageGiftItems(new OnGetPackageGiftListCallback() {
            @Override
            public void onGetPackageGiftList(final boolean isSuccess, int errCode, String errMsg, final PackageGiftItem[] packageGiftList, int totalCount) {
                mContext.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        if(mCurrentGifttab == GiftTab.GiftTabFlag.BACKPACK) {
                            if (isSuccess) {
                                //加载成功
                                List<PackageGiftItem> localPackageList = mRoomGiftManager.getLoaclRoomPackageGiftList();
                                if (localPackageList == null || localPackageList.size() == 0) {
                                    showGiftEmptyTips(GiftTab.GiftTabFlag.BACKPACK);
                                } else {
                                    //加载成功且返回列表（列表未过滤可发送及详情）不为空
                                    hideStatusPages();
                                    mPackageGiftItemList.clear();
                                    mPackageGiftItemList.addAll(localPackageList);
                                    createOrResetPackageGiftViews();
                                }
                            } else {
                                //加载失败，错误页
                                showLoadingFailedTips();
                            }
                        }
                    }
                });
            }
        });
    }

    /**
     * 显示加载中
     */
    private void showLoadingProgress(){
        llStatusLayout.setVisibility(View.VISIBLE);
        pbLoading.setVisibility(View.VISIBLE);
        ivStatus.setVisibility(View.GONE);
        tvDesc.setText(mContext.getResources().getString(R.string.tip_loading));
        tv_reloadGiftList.setVisibility(View.GONE);
    }

    /**
     * 显示空数据页
     */
    private void showGiftEmptyTips(GiftTab.GiftTabFlag giftTab){
        llStatusLayout.setVisibility(View.VISIBLE);
        pbLoading.setVisibility(View.GONE);
        ivStatus.setVisibility(View.VISIBLE);
        ivStatus.setImageResource(R.drawable.ic_view_data_sosad);
        if(giftTab == GiftTab.GiftTabFlag.STORE){
            tvDesc.setText(R.string.liveroom_gift_store_empty);
        }else{
            tvDesc.setText(R.string.liveroom_gift_pack_empty);
        }
        tv_reloadGiftList.setVisibility(View.GONE);

        //无数据按钮不可点击
        setSendGiftBtnEnable(false);
    }

    /**
     * 显示加载列表失败页面
     */
    private void showLoadingFailedTips(){
        llStatusLayout.setVisibility(View.VISIBLE);
        pbLoading.setVisibility(View.GONE);
        ivStatus.setVisibility(View.VISIBLE);
        ivStatus.setImageResource(R.drawable.ic_view_data_sosad);
        tvDesc.setText(mContext.getResources().getString(R.string.tip_failed_to_load));
        tv_reloadGiftList.setVisibility(View.VISIBLE);
    }

    /**
     * 加载成功，隐藏状态页
     */
    private void hideStatusPages(){
        llStatusLayout.setVisibility(View.GONE);
    }


    /***************************************** 礼物发送逻辑 *******************************************/

    /**
     * 点击发送按钮或连击按钮
     */
    private void sendGift(boolean isRepeat){
        //变为连击状态
        startRepeatSendGift();

        //获取礼物相关信息
        String giftId = mLiveGiftDialogHelper.getGiftTabSelectedGiftId(mCurrentGifttab);
        GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(giftId);
        String numStr = tv_giftCount.getText().toString();
        if(giftItem != null && !TextUtils.isEmpty(numStr)){
            int sendNum = Integer.valueOf(numStr);
            if(mCurrentGifttab == GiftTab.GiftTabFlag.STORE){
                double reqCoins = giftItem.credit * sendNum;
                //礼物首次发送，需要本地校验下金币数量是否充足
                double localCoins = LiveRoomCreditRebateManager.getInstance().getCredit();
                if(!isRepeat && localCoins < reqCoins){
                    //停止连击状态
                    stopRepeatSendGift();

                    //连击中不本地判断是否点数足够
                    if(mLiveGiftDialogEventListener != null){
                        mLiveGiftDialogEventListener.onNoEnoughMoneyTips();
                    }
                }else{
                    GiftSender.getInstance().sendStoreGift(giftItem, isRepeat, sendNum, null);
                }
            }else if(mCurrentGifttab == GiftTab.GiftTabFlag.BACKPACK){
                PackageGiftItem packageGiftItem = mRoomGiftManager.getLocalPackageItem(giftId);
                if(packageGiftItem != null){
                    if(packageGiftItem.num < sendNum){
                        //数量不足，提示不发送
                        //停止连击状态
                        stopRepeatSendGift();
                    }else{
                        //数量足够，发送礼物
                        GiftSender.getInstance().sendBackpackGift(giftItem, isRepeat, sendNum, packageGiftItem.num, null);
                        //更新本地
                        int leftCount = packageGiftItem.num - sendNum;
                        if(leftCount > 0){
                            packageGiftItem.num = leftCount;
                            //更新界面
                            int pageIndex = mLiveGiftDialogHelper.getGiftTabSelectedPageIndex(mCurrentGifttab);
                            if(mPackageGiftAdapterList != null && pageIndex < mPackageGiftAdapterList.size()){
                                mPackageGiftAdapterList.get(pageIndex).notifyDataSetChanged();
                            }
                        }else{
                            //发送完了，从dialog本地列表删除指定礼物
                            mPackageGiftItemList.remove(packageGiftItem);
                            //本地缓存同步删除
                            mRoomGiftManager.removeLocalPackageItem(giftId);
                            //由于删除礼物导致界面重构
                            if(mPackageGiftItemList.size() > 0) {
                                mLiveGiftDialogHelper.updateGiftTabPageIndex(mCurrentGifttab, 0);
                                //清空默认选中
                                mLiveGiftDialogHelper.updateGiftTabSelectedGiftId(mCurrentGifttab, "");
                                createOrResetPackageGiftViews();
                            }else{
                                showGiftEmptyTips(mCurrentGifttab);
                            }
                        }
                    }
                }
            }
        }
    }

    //----------------OnOutSideTouchEventListener------------------------------------------------------

    @Override
    public void onBackPressed() {
        super.onBackPressed();
        Log.d(TAG,"onBackPressed");
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        Log.d(TAG,"onTouchEvent-event.action:"+event.getAction());
        if (MotionEvent.ACTION_OUTSIDE == event.getAction()) {
            dismiss();
            return true;
        }

        return super.onTouchEvent(event);
    }


    /***************************************** 外部交互接口 *******************************************/
    public interface LiveGiftDialogEventListener{
        //通知外面需要弹toast提示
        public void onShowToastTipsNotify(String message);
        //发送礼物信用点不足通知
        public void onNoEnoughMoneyTips();
        //点击查看个人资料
        public void onAudiencBalanceClick(View rootView);
    }

    /**
     * 设置事件监听器
     * @param listener
     */
    public void setLiveGiftDialogEventListener(LiveGiftDialogEventListener listener){
        mLiveGiftDialogEventListener = listener;
    }

    /**
     * 资源回收
     */
    public void onDestroy(){
        //dialog显示过
        if(sl_giftPagerContainer != null){
            stopRepeatSendGift();
        }
    }
}
