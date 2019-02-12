package com.qpidnetwork.livemodule.liveshow.personal.chatemoji;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.canadapter.CanAdapter;
import com.qpidnetwork.livemodule.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.livemodule.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.livemodule.httprequest.item.EmotionCategory;
import com.qpidnetwork.livemodule.httprequest.item.EmotionItem;
import com.qpidnetwork.qnbridgemodule.datacache.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpReqStatus;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.livemodule.view.ScrollLayout;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Description:自定义带Tab导航，带底部圆点导航，可以左右滑动切换页面的表情控件
 * <p>
 * Created by Harry on 2017/8/9.
 */

public class EmojiTabScrollLayout<T> extends LinearLayout {

    private Context mContext;
    private final static String TAG = EmojiTabScrollLayout.class.getSimpleName();

    private TabPageIndicator tpi_tabIndicator;
    private View ll_emojiRootView;
    private ScrollLayout sl_pagerContainer;
    private LinearLayout ll_pageIndicator;
    private TextView tv_itemUnusableTip;
    private TextView tv_reloadEmojiList;
    private View ll_emojiLoading;
    private View ll_emptyEmojiData;
    private View ll_retryLoadEmoji;
    private View fl_emojiContainer;
    private View ll_emojiContainer;

    private ViewStatusChangeListener onViewStatusChangeListener;

    /**
     * 当前选中的tab title
     */
    private String currTabTitle = "";
    //暂时封装到tab为String这一步，tab带红点的情况还是单独拿出来比较好
    /**
     * Tab title数据源
     */
    private List<String> tabTitles = new ArrayList<>();
    /**
     * Tab title同gridviewadapter 数据源的映射关系表
     */
    private Map <String,EmotionCategory> itemMap = new HashMap<>();
    /**
     * 每页展示的GridView中可显示的行数
     */
    private int lineNumbPerPage = 1;
    /**
     * 每页展示的GridView中可显示的列数
     */
    private int columnNumbPerPage = 1;
    /**
     * GridView中item的垂直间距，表情控件可不设置，默认为0
     */
    private int gridViewVerticalSpacing = 0;
    /**
     * 每个item的宽度
     */
    private int gridViewItemWidth = 0;
    /**
     * 每个item的高度
     */
    private int gridViewItemHeight = 0;
    /**
     * GridView中item的水平间距，表情控件可不设置，默认为0
     */
    private int gridViewHorizontalSpacing = 0;
    /**
     * 每页展示item的数量
     */
    private int itemNumbPerPage;
    /**
     * 每个item中表情图标的宽度
     */
    private int gridViewItemIconWidth = 0;
    /**
     * 每个item中表情图标的高度
     */
    private int gridViewItemIconHeight = 0;
    /**
     * 表情选择面板的高度
     */
    private int emojiPanelHeight = 0;
    /**
     * 底部页面指示器高度
     */
    private int pageIndicatorHeight = 0;
    /**
     * 底部页面指示器间距
     */
    private int pageIndicatorSpace = 0;
    /**
     * 底部指示器topMargin
     */
    private int pageIndicatorTopMargin = 0;
    /**
     * 底部指示器bottomMargin
     */
    private int pageIndicatorBottomMargin = 0;
    /**
     * 是否展示tab
     */
    private boolean showTabPageIndicator = true;
    /**
     * 设置表情选择面板是否自动填充父容器（避免布局修改影响到直播间已有UI效果，通过该参数来控制）
     */
    private boolean emojiPanelAutoFitWindow = false;

    /**
     * 面板[表情页]背景色  #0075E7
     */
    private int emojiBgColor = Color.parseColor("#ffffff");

    private int emojiIndicBgResId =  R.drawable.selector_emoji_indicator_live;

    public EmojiTabScrollLayout(Context context) {
        this(context, null);
    }

    public EmojiTabScrollLayout(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public EmojiTabScrollLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.mContext = context;
        View.inflate(context, R.layout.view_room_emoji,this);
        setOrientation(LinearLayout.VERTICAL);
        initParams(attrs);
        initView();
    }

    /**
     * 属性参数初始化
     * @param attrs
     */
    public void initParams(@Nullable AttributeSet attrs){
        DisplayMetrics dm = getResources().getDisplayMetrics();
        gridViewItemIconWidth = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, gridViewItemIconWidth, dm);
        gridViewItemIconHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, gridViewItemIconHeight, dm);
        gridViewItemWidth = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, gridViewItemWidth, dm);
        gridViewItemHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, gridViewItemHeight, dm);
        emojiPanelHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, emojiPanelHeight, dm);
        pageIndicatorHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, pageIndicatorHeight, dm);
        pageIndicatorSpace = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, pageIndicatorSpace, dm);
        pageIndicatorTopMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, pageIndicatorTopMargin, dm);
        pageIndicatorBottomMargin = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, pageIndicatorBottomMargin, dm);

        TypedArray a = mContext.obtainStyledAttributes(attrs, R.styleable.EmojiTabScrollLayout);
        columnNumbPerPage = a.getInteger(R.styleable.EmojiTabScrollLayout_columnNumbPerPage,columnNumbPerPage);
        lineNumbPerPage = a.getInteger(R.styleable.EmojiTabScrollLayout_lineNumbPerPage,lineNumbPerPage);
        gridViewItemIconWidth = a.getDimensionPixelSize(R.styleable.EmojiTabScrollLayout_gridViewItemIconWidth, gridViewItemIconWidth);
        gridViewItemIconHeight = a.getDimensionPixelSize(R.styleable.EmojiTabScrollLayout_gridViewItemIconHeight, gridViewItemIconHeight);
        gridViewItemWidth = a.getDimensionPixelSize(R.styleable.EmojiTabScrollLayout_gridViewItemWidth, gridViewItemWidth);
        gridViewItemHeight = a.getDimensionPixelSize(R.styleable.EmojiTabScrollLayout_gridViewItemHeight, gridViewItemHeight);
        emojiPanelHeight = a.getDimensionPixelSize(R.styleable.EmojiTabScrollLayout_emojiPanelHeight, emojiPanelHeight);
        pageIndicatorHeight = a.getDimensionPixelSize(R.styleable.EmojiTabScrollLayout_pageIndicatorHeight, pageIndicatorHeight);
        pageIndicatorSpace = a.getDimensionPixelSize(R.styleable.EmojiTabScrollLayout_pageIndicatorSpace, pageIndicatorSpace);
        pageIndicatorTopMargin = a.getDimensionPixelSize(R.styleable.EmojiTabScrollLayout_pageIndicatorTopMargin, pageIndicatorTopMargin);
        pageIndicatorBottomMargin = a.getDimensionPixelSize(R.styleable.EmojiTabScrollLayout_pageIndicatorBottomMargin, pageIndicatorBottomMargin);
        showTabPageIndicator = a.getBoolean(R.styleable.EmojiTabScrollLayout_showTabPageIndicator, showTabPageIndicator);
        emojiPanelAutoFitWindow = a.getBoolean(R.styleable.EmojiTabScrollLayout_emojiPanelAutoFitWindow, emojiPanelAutoFitWindow);
        emojiBgColor = a.getColor(R.styleable.EmojiTabScrollLayout_emojiBgColor, emojiBgColor);
        a.recycle();
    }

    private void initView(){
        Log.d(TAG,"initView");
        tpi_tabIndicator = (TabPageIndicator)findViewById(R.id.tpi_tabIndicator);
        tpi_tabIndicator.setVisibility(showTabPageIndicator ? View.VISIBLE : View.GONE);
        resetEmojiPanelColumnLineNum();
        ll_emojiRootView = findViewById(R.id.ll_emojiRootView);
        ll_emojiRootView.getLayoutParams().height = emojiPanelHeight;

        sl_pagerContainer = (ScrollLayout)findViewById(R.id.sl_pagerContainer);
        LinearLayout.LayoutParams slLp = (LayoutParams) sl_pagerContainer.getLayoutParams();
        if(emojiPanelAutoFitWindow){
            slLp.topMargin = 0;
            slLp.leftMargin = 0;
            slLp.rightMargin = 0;
        }
        sl_pagerContainer.setOnScreenChangeListener(new ScrollLayout.OnScreenChangeListener() {
            @Override
            public void onScreenChange(int currentIndex) {
                updatePageIndicStatus(currentIndex);
            }
        });
        ll_pageIndicator = (LinearLayout) findViewById(R.id.ll_pageIndicator);
        LinearLayout.LayoutParams pageIndLp = (LayoutParams) ll_pageIndicator.getLayoutParams();
        pageIndLp.height = pageIndicatorHeight;
        pageIndLp.topMargin = pageIndicatorTopMargin;
        pageIndLp.bottomMargin = pageIndicatorBottomMargin;
        tv_itemUnusableTip = (TextView) findViewById(R.id.tv_itemUnusableTip);
        tv_itemUnusableTip.setVisibility(View.GONE);
        tv_itemUnusableTip.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {

            }
        });
        ll_emojiLoading =  findViewById(R.id.ll_emojiLoading);
        ll_emojiLoading.setVisibility(View.GONE);
        ll_emptyEmojiData =  findViewById(R.id.ll_emptyEmojiData);
        ll_emptyEmojiData.setVisibility(View.GONE);
        ll_retryLoadEmoji =  findViewById(R.id.ll_retryLoadEmoji);
        fl_emojiContainer =  findViewById(R.id.fl_emojiContainer);
        fl_emojiContainer.setBackgroundDrawable(new ColorDrawable(emojiBgColor));
        ll_emojiContainer =  findViewById(R.id.ll_emojiContainer);
        tv_reloadEmojiList = (TextView) findViewById(R.id.tv_reloadEmojiList);
        ll_retryLoadEmoji.setVisibility(View.GONE);
    }

    private void resetEmojiPanelColumnLineNum() {
        if(emojiPanelAutoFitWindow){
            //默认宽度全屏
            columnNumbPerPage = DisplayUtil.getScreenWidth(mContext)/gridViewItemWidth;
            int emojiTotalHeight = doGetEmojiTotalHeight(this.emojiPanelHeight);
            if(showTabPageIndicator){
                LayoutParams tabIndLp = (LayoutParams) tpi_tabIndicator.getLayoutParams();
                emojiTotalHeight -= tabIndLp.height;
                emojiTotalHeight -= tabIndLp.bottomMargin;
            }
            lineNumbPerPage = (emojiTotalHeight)/gridViewItemHeight;
        }
        itemNumbPerPage = columnNumbPerPage*lineNumbPerPage;
    }

    private int doGetEmojiTotalHeight(int newHeight){
        return newHeight-pageIndicatorHeight-pageIndicatorTopMargin-pageIndicatorBottomMargin;
    }

    /**
     * 视图刷新
     */
    public void notifyDataChanged(){
        if(null != tabTitles && tabTitles.size()>0){
            initTabTitle();
            updatePageGridView(tabTitles.get(0));
        }
    }

    public void setEmojiIndicBgResId(int emojiIndicBgResId){
        this.emojiIndicBgResId = emojiIndicBgResId;
    }

    /**
     * 设置表情不可用时的提示文案，unusableTip为empty时标识表情可用
     * @param unusableTip
     */
    public void setUnusableTip(String unusableTip){
        Log.d(TAG,"setUnusableTip-unusableTip:"+unusableTip);
        if(TextUtils.isEmpty(unusableTip)){
            tv_itemUnusableTip.setVisibility(View.GONE);
        }else{
            tv_itemUnusableTip.setVisibility(View.VISIBLE);
            tv_itemUnusableTip.setText(unusableTip);
        }
    }

    @Override
    public void setVisibility(int visibility) {
        super.setVisibility(visibility);
        //检查数据加载状态
    }

    /**
     * 更新tabTitle下的表情列表
     * @param tabTitle
     */
    private void updatePageGridView(final String tabTitle){
        Log.d(TAG,"updatePageGridView-tabTitle:"+tabTitle);
        if(null != itemMap && itemMap.containsKey(tabTitle)){
            EmotionCategory emotionCategory = itemMap.get(tabTitle);
            sl_pagerContainer.removeAllViews();
            if(null != emotionCategory && null != emotionCategory.emotionList&& emotionCategory.emotionList.length>0){
                List<EmotionItem> emotionItems = Arrays.asList(emotionCategory.emotionList);
                GridView gridView = null;
                int pageCount = emotionItems.size()/itemNumbPerPage+ (0 == emotionItems.size()%itemNumbPerPage ? 0 : 1);
                int maxPageIndex = 0;
                for(int pageIndex = 0; pageIndex<pageCount; pageIndex++){
                    gridView = new GridView(mContext);
                    gridView.setGravity(Gravity.CENTER);
                    gridView.setStretchMode(GridView.STRETCH_COLUMN_WIDTH);
                    gridView.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
                    gridView.setNumColumns(columnNumbPerPage);
                    maxPageIndex = (pageIndex+1)*itemNumbPerPage;
                    final CanAdapter gridViewAdapter = new CanAdapter(mContext, R.layout.item_emoji_gridview) {
                        @Override
                        protected void setView(final CanHolderHelper helper, int position, Object bean) {
                            //设置layoutparams
                            ViewGroup.LayoutParams lp0 = helper.getView(R.id.rl_emojiContainer).getLayoutParams();
                            if(null != lp0){
                                lp0.width = gridViewItemWidth;
                                lp0.height = gridViewItemHeight;
                            }
                            ViewGroup.LayoutParams lp1 = helper.getView(R.id.iv_emoji).getLayoutParams();
                            if(null != lp1){
                                lp1.width = gridViewItemIconWidth;
                                lp1.height = gridViewItemIconHeight;
                            }
                            EmotionItem emotionItem = (EmotionItem)bean;
                            String localPath = FileCacheManager.getInstance().parseEmotionImgLocalPath(
                                    emotionItem.emotionId,emotionItem.emoIconUrl);
                            Log.d(TAG,"updatePageGridView-localPath:"+localPath);
                            if(SystemUtils.fileExists(localPath)){
                                helper.getImageView(R.id.iv_emoji).setImageBitmap(
                                        ImageUtil.decodeSampledBitmapFromFile(localPath,
                                                gridViewItemIconWidth, gridViewItemIconHeight));
                            }
                        }

                        @Override
                        protected void setItemListener(CanHolderHelper helper) {}
                    };

                    gridViewAdapter.setList(emotionItems.subList(itemNumbPerPage*pageIndex,
                            maxPageIndex>emotionItems.size() ? emotionItems.size() : maxPageIndex));
                    gridView.setAdapter(gridViewAdapter);
                    gridView.setSelector(android.R.color.transparent);
                    gridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
                        @Override
                        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                            if(null != onViewStatusChangeListener){
                                onViewStatusChangeListener.onGridViewItemClick(view,position,tabTitle,
                                        gridViewAdapter.getList().get(position));
                            }
                        }
                    });
                    ViewGroup.LayoutParams gridViewLp = new ViewGroup.LayoutParams(
                            ViewGroup.LayoutParams.MATCH_PARENT,ViewGroup.LayoutParams.MATCH_PARENT);
                    sl_pagerContainer.addView(gridView,gridViewLp);
                }
                updatePageIndicView(pageCount);
                updatePageIndicStatus(0);

            }else{
                //更新页面展示状态
            }
        }else{

        }
    }

    /**
     * 添加表情页下方的圆点指示器
     * @param pageCount 页数
     */
    private void updatePageIndicView(int pageCount){
        Log.d(TAG,"updatePageIndicView-pageCount:"+pageCount);
        ll_pageIndicator.removeAllViews();
        int endIndex = pageCount-1;
        View.OnClickListener onClickListener = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Integer index = (Integer)v.getTag();
                updatePageIndicStatus(index);
                sl_pagerContainer.setToScreen(index.intValue());
            }
        };
        for(int index=0; index<pageCount; index++){
            ImageView indicator = new ImageView(mContext);
            LinearLayout.LayoutParams lp_indicator = new LinearLayout.LayoutParams(pageIndicatorHeight, pageIndicatorHeight);
            lp_indicator.gravity = Gravity.CENTER;
            lp_indicator.leftMargin = 0 == index ? 0 : pageIndicatorSpace;
            lp_indicator.rightMargin = endIndex == index ? 0 : pageIndicatorSpace;
            indicator.setLayoutParams(lp_indicator);
            if(0 != emojiIndicBgResId){
                indicator.setBackgroundDrawable(mContext.getResources().getDrawable(emojiIndicBgResId));
            }
            indicator.setTag(index);
            indicator.setOnClickListener(onClickListener);
            ll_pageIndicator.addView(indicator);
        }
    }

    /**
     * 更新表情页指示器的状态
     * @param selectedIndex 当前表情页的位置
     */
    private void updatePageIndicStatus(int selectedIndex){
        Log.d(TAG,"updatePageIndicStatus-selectedIndex:"+selectedIndex);
        int childCount = ll_pageIndicator.getChildCount();
        for(int index = 0; index<childCount; index++){
            View view = ll_pageIndicator.getChildAt(index);
            if(View.VISIBLE == view.getVisibility()){
                view.setSelected(selectedIndex == index);
            }
        }
    }

    /**
     * 初始化Tab 导航
     */
    private void initTabTitle(){
        tpi_tabIndicator.setTitles(tabTitles.toArray(new String[tabTitles.size()]));
        tpi_tabIndicator.setDefaultPosition(0);
        tpi_tabIndicator.setIndicatorMode(TabPageIndicator.IndicatorMode.MODE_WEIGHT_NOEXPAND_SAME);
        tpi_tabIndicator.setOnTabClickListener(new TabPageIndicator.OnTabClickListener() {
            @Override
            public void onTabClicked(int position, String title) {
                if(!title.equals(currTabTitle)){
                    sl_pagerContainer.abortScrollAnimation();
                    currTabTitle = title;
                    updatePageGridView(currTabTitle);
                    sl_pagerContainer.setToScreen(0);
                    if(null != onViewStatusChangeListener){
                        onViewStatusChangeListener.onTabClick(position, title);
                    }
                }
            }
        });
    }

    /**
     * 设置tab导航数据源
     * @param tabTitles
     */
    public void setTabTitles(List<String> tabTitles){
        this.tabTitles.clear();
        this.tabTitles.addAll(tabTitles);
    }

    /**
     * 设置表情数据源
     * @param itemMap
     */
    public void setItemMap(Map<String,EmotionCategory> itemMap){
        this.itemMap = itemMap;
    }

    /**
     * 设置gridview最多展示的行数
     * @param lineNumbPerPage
     */
    public void setLineNumbPerPage(int lineNumbPerPage){
        this.lineNumbPerPage = lineNumbPerPage;
        invalidate();
    }

    /**
     * 设置gridView的列数
     * @param columnNumbPerPage
     */
    public void setColumnNumbPerPage(int columnNumbPerPage){
        this.columnNumbPerPage = columnNumbPerPage;
        invalidate();
    }

    /**
     * 设置girdview item之间的垂直间距
     * @param gridViewVerticalSpacing
     */
    public void setGridViewVerticalSpacing(int gridViewVerticalSpacing){
        this.gridViewVerticalSpacing = gridViewVerticalSpacing;
        invalidate();
    }

    /**
     * 设置表情面板的高度
     * @param emojiPanelHeight
     */
    public void setEmojiPanelHeight(int emojiPanelHeight){
        Log.d(TAG,"setEmojiPanelHeight-emojiPanelHeight:"+emojiPanelHeight);
        //add by Jagger 2018-9-6 因为会出现小于0的情况(黑莓手机，物理键盘)。如果新高度合理，则使用
        if (doGetEmojiTotalHeight(emojiPanelHeight) > 1){
            this.emojiPanelHeight = emojiPanelHeight;
            if(null != ll_emojiRootView){
//                ll_emojiRootView.getLayoutParams().height = emojiPanelHeight;
//                Log.d(TAG,"setEmojiPanelHeight-ll_emojiRootView.height:"+ll_emojiRootView.getLayoutParams().height);
                ViewGroup.LayoutParams layoutParams = ll_emojiRootView.getLayoutParams();
                layoutParams.height = emojiPanelHeight;

                ll_emojiRootView.setLayoutParams(layoutParams);
            }
            resetEmojiPanelColumnLineNum();
        }
    }

    /**
     * 设置girdview item之间的水平间距
     * @param gridViewHorizontalSpacing
     */
    public void setGridViewHorizontalSpacing(int gridViewHorizontalSpacing){
        this.gridViewHorizontalSpacing = gridViewHorizontalSpacing;
        invalidate();
    }

    public void setViewStatusChangedListener(ViewStatusChangeListener onViewStatusChangeListener){
        this.onViewStatusChangeListener = onViewStatusChangeListener;
    }

    public interface ViewStatusChangeListener{
        /**
         * Tab title被点击
         * @param position
         * @param title
         */
        void onTabClick(int position, String title);

        /**
         * 对gridview设置onItemClickListener
         * @param itemChildView
         * @param position
         * @param title
         * @param item
         */
        void onGridViewItemClick(View itemChildView,int position, String title, Object item);
    }
}
