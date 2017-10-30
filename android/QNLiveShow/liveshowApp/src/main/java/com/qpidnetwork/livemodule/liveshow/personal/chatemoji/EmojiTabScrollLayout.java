package com.qpidnetwork.livemodule.liveshow.personal.chatemoji;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.canadapter.CanAdapter;
import com.qpidnetwork.livemodule.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.livemodule.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.livemodule.httprequest.item.EmotionCategory;
import com.qpidnetwork.livemodule.httprequest.item.EmotionItem;
import com.qpidnetwork.livemodule.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.livemodule.liveshow.model.HttpReqStatus;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.SystemUtils;
import com.qpidnetwork.livemodule.view.ScrollLayout;
import com.squareup.picasso.Picasso;
import com.squareup.picasso.Target;

import java.io.File;
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
     * GridView中item的水平间距，表情控件可不设置，默认为0
     */
    private int gridViewHorizontalSpacing = 0;
    private int itemHeight;
    private int itemNumbPerPage;

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
        TypedArray a = mContext.obtainStyledAttributes(attrs, R.styleable.EmojiTabScrollLayout);
        columnNumbPerPage = a.getInteger(R.styleable.EmojiTabScrollLayout_columnNumbPerPage,columnNumbPerPage);
        lineNumbPerPage = a.getInteger(R.styleable.EmojiTabScrollLayout_lineNumbPerPage,lineNumbPerPage);
        a.recycle();

        itemHeight = DisplayUtil.getScreenWidth(mContext)/columnNumbPerPage;
        itemNumbPerPage = columnNumbPerPage*lineNumbPerPage;
    }

    private void initView(){
        ll_emojiRootView = findViewById(R.id.ll_emojiRootView);
        tpi_tabIndicator = (TabPageIndicator)findViewById(R.id.tpi_tabIndicator);
        sl_pagerContainer = (ScrollLayout)findViewById(R.id.sl_pagerContainer);
        sl_pagerContainer.setOnScreenChangeListener(new ScrollLayout.OnScreenChangeListener() {
            @Override
            public void onScreenChange(int currentIndex) {
                updatePageIndicStatus(currentIndex);
            }
        });
        ll_pageIndicator = (LinearLayout) findViewById(R.id.ll_pageIndicator);
        tv_itemUnusableTip = (TextView) findViewById(R.id.tv_itemUnusableTip);
        tv_itemUnusableTip.setVisibility(View.GONE);
        ll_emojiLoading =  findViewById(R.id.ll_emojiLoading);
        ll_emojiLoading.setVisibility(View.GONE);
        ll_emptyEmojiData =  findViewById(R.id.ll_emptyEmojiData);
        ll_emptyEmojiData.setVisibility(View.GONE);
        ll_retryLoadEmoji =  findViewById(R.id.ll_retryLoadEmoji);
        fl_emojiContainer =  findViewById(R.id.fl_emojiContainer);
        ll_emojiContainer =  findViewById(R.id.ll_emojiContainer);
        tv_reloadEmojiList = (TextView) findViewById(R.id.tv_reloadEmojiList);
        ll_retryLoadEmoji.setVisibility(View.GONE);
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
                int pageCount = emotionItems.size()/itemNumbPerPage+
                        (0 == emotionItems.size()%itemNumbPerPage ? 0 : 1);
                int maxPageIndex = 0;
                for(int pageIndex = 0; pageIndex<pageCount; pageIndex++){
                    gridView = new GridView(mContext);
                    gridView.setVerticalSpacing(gridViewVerticalSpacing);
                    gridView.setHorizontalSpacing(gridViewHorizontalSpacing);
                    gridView.setGravity(Gravity.CENTER);
                    gridView.setStretchMode(GridView.STRETCH_COLUMN_WIDTH);
                    gridView.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
                    gridView.setNumColumns(columnNumbPerPage);
                    maxPageIndex = (pageIndex+1)*itemNumbPerPage;
                    final CanAdapter gridViewAdapter = new CanAdapter(mContext,
                            R.layout.item_emoji_gridview) {
                        @Override
                        protected void setView(final CanHolderHelper helper, int position, Object bean) {
                            EmotionItem emotionItem = (EmotionItem)bean;
                            String localPath = FileCacheManager.getInstance().parseEmotionImgLocalPath(
                                    emotionItem.emotionId,emotionItem.emoUrl);
                            Log.d(TAG,"updatePageGridView-localPath:"+localPath);
                            if(SystemUtils.fileExists(localPath)){
                                Picasso.with(mContext).load(new File(localPath))
                                        .into(new Target() {
                                            @Override
                                            public void onBitmapLoaded(Bitmap bitmap, Picasso.LoadedFrom loadedFrom) {
                                                Log.d(TAG,"updatePageGridView-onBitmapLoaded");
                                                helper.getImageView(R.id.iv_emoji).setImageBitmap(bitmap);
                                            }

                                            @Override
                                            public void onBitmapFailed(Drawable drawable) {
                                                Log.d(TAG,"updatePageGridView-onBitmapFailed");
                                            }

                                            @Override
                                            public void onPrepareLoad(Drawable drawable) {
                                                Log.d(TAG,"updatePageGridView-onPrepareLoad");
                                            }
                                        });
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
                            ViewGroup.LayoutParams.MATCH_PARENT,itemHeight*columnNumbPerPage);
                    Log.d(TAG,"updatePageGridView-itemHeight:"+itemHeight*columnNumbPerPage);
                    sl_pagerContainer.addView(gridView,gridViewLp);
                }
                updatePageIndicView(pageCount);
                updatePageIndicStatus(0);

            }else{
                //更新页面展示状态
            }
        }else{
            //如果没有map数据或者map数据不包含title的数据，判断req状态
            if(HttpReqStatus.Reqing == ChatEmojiManager.getInstance().emojiListReqStatus){

            }
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
        int indicatorWidth = DisplayUtil.dip2px(mContext,6f);
        int indicatorMargin = DisplayUtil.dip2px(mContext,4f);
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
            LinearLayout.LayoutParams lp_indicator = new LinearLayout.LayoutParams(indicatorWidth, indicatorWidth);
            lp_indicator.gravity = Gravity.CENTER;
            lp_indicator.leftMargin = 0 == index ? 0 : indicatorMargin;
            lp_indicator.rightMargin = endIndex == index ? 0 : indicatorMargin;
            indicator.setLayoutParams(lp_indicator);
            indicator.setBackgroundDrawable(mContext.getResources().getDrawable(R.drawable.selector_emoji_indicator));
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
        tpi_tabIndicator.setVisibility(View.VISIBLE);
        tpi_tabIndicator.setTitles(tabTitles.toArray(new String[tabTitles.size()]));
        tpi_tabIndicator.setDefaultPosition(0);
        tpi_tabIndicator.setIndicatorMode(TabPageIndicator.IndicatorMode.MODE_WEIGHT_NOEXPAND_SAME);
        tpi_tabIndicator.setOnTabClickListener(new TabPageIndicator.OnTabClickListener() {
            @Override
            public void onTabClicked(int position, String title) {
                currTabTitle = title;
                updatePageGridView(currTabTitle);
                sl_pagerContainer.setToScreen(0);
                if(null != onViewStatusChangeListener){
                    onViewStatusChangeListener.onTabClick(position, title);
                }
            }
        });
    }

    /**
     * 设置tab导航数据源
     * @param tabTitles
     */
    public void setTabTitles(List<String> tabTitles){
        this.tabTitles = tabTitles;
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
