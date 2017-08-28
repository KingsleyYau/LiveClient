package com.qpidnetwork.livemodule.liveshow.personal.chatemoji;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.FrameLayout;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.qpidnetwork.livemodule.framework.canadapter.CanAdapter;
import com.qpidnetwork.livemodule.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.livemodule.framework.widget.viewpagerindicator.TabPageIndicator;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.view.ScrollLayout;

import java.util.ArrayList;
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
    private ScrollLayout sl_pagerContainer;
    private LinearLayout ll_pageIndicator;
    private TextView tv_itemUnusableTip;
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
    private Map <String,List<T>> itemMap = new HashMap();
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
    /**
     * GridView的背景色，不设置该值则默认为透明色，以避免item在click时显示系统默认的选择背景色
     */
    private int gridViewBgColor = 0;

    public EmojiTabScrollLayout(Context context) {
        this(context, null);
    }

    public EmojiTabScrollLayout(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public EmojiTabScrollLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        this.mContext = context;
        View.inflate(context, R.layout.view_tab_indicator_scrolllayout,this);
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
        gridViewBgColor = a.getColor(R.styleable.EmojiTabScrollLayout_gridViewBgColor, gridViewBgColor);
        columnNumbPerPage = a.getInteger(R.styleable.EmojiTabScrollLayout_columnNumbPerPage,columnNumbPerPage);
        lineNumbPerPage = a.getInteger(R.styleable.EmojiTabScrollLayout_lineNumbPerPage,lineNumbPerPage);
        a.recycle();
    }

    private void initView(){
        tpi_tabIndicator =
                (TabPageIndicator)findViewById(R.id.tpi_tabIndicator);
        sl_pagerContainer = (ScrollLayout)findViewById(R.id.sl_pagerContainer);
        sl_pagerContainer.setOnScreenChangeListener(new ScrollLayout.OnScreenChangeListener() {
            @Override
            public void onScreenChange(int currentIndex) {
                updatePageIndicStatus(currentIndex);
            }
        });
        ll_pageIndicator = (LinearLayout) findViewById(R.id.ll_pageIndicator);
        tv_itemUnusableTip = (TextView) findViewById(R.id.tv_itemUnusableTip);
        tv_itemUnusableTip.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Toast.makeText(mContext,"对不起，不可用表情",Toast.LENGTH_SHORT).show();
            }
        });
        tv_itemUnusableTip.setVisibility(View.GONE);
    }

    /**
     * 视图刷新
     */
    public void notifyDataChanged(){
        initTabTitle();
        if(null != tabTitles && tabTitles.size()>0){
            updatePageGridView(tabTitles.get(0));
        }
    }

    /**
     * 设置表情不可用时的提示文案，unusableTip为empty时标识表情可用
     * @param unusableTip
     */
    public void setUnusableTip(String unusableTip){
        if(TextUtils.isEmpty(unusableTip)){
            tv_itemUnusableTip.setVisibility(View.GONE);
        }else{
            tv_itemUnusableTip.setVisibility(View.VISIBLE);
            tv_itemUnusableTip.setText(unusableTip);
        }
    }

    /**
     * 更新tabTitle下的表情列表
     * @param tabTitle
     */
    private void updatePageGridView(final String tabTitle){
        if(null != itemMap && itemMap.containsKey(tabTitle)){
            List itemList = itemMap.get(tabTitle);
            int itemNumbPerPage = columnNumbPerPage*lineNumbPerPage;
            int itemHeight = DisplayUtil.getScreenWidth(mContext)/columnNumbPerPage;
            if(null != itemList && itemList.size()>0){
                sl_pagerContainer.removeAllViews();
                GridView gridView = null;
                int pageCount = itemList.size()/itemNumbPerPage+
                        (0 == itemList.size()%itemNumbPerPage ? 0 : 1);
                int maxPageIndex = 0;
                for(int pageIndex = 0; pageIndex<pageCount; pageIndex++){
                    gridView = new GridView(mContext);
                    gridView.setVerticalSpacing(gridViewVerticalSpacing);
                    gridView.setHorizontalSpacing(gridViewHorizontalSpacing);
                    gridView.setGravity(Gravity.CENTER);
                    gridView.setStretchMode(GridView.STRETCH_COLUMN_WIDTH);
                    gridView.setBackgroundDrawable(
                                new ColorDrawable(0 != gridViewBgColor ? gridViewBgColor :
                                        mContext.getResources().getColor(android.R.color.transparent)));

                    gridView.setNumColumns(columnNumbPerPage);
                    maxPageIndex = (pageIndex+1)*itemNumbPerPage;

                    final CanAdapter gridViewAdapter = new CanAdapter(mContext,
                            R.layout.item_emoji_gridview) {
                        @Override
                        protected void setView(CanHolderHelper helper, int position, Object bean) {
                            ChatEmoji chatEmoji = (ChatEmoji)bean;
                            helper.getImageView(R.id.iv_emoji).setImageResource(chatEmoji.resId);
                            helper.getTextView(R.id.tv_emojiId).setText(String.valueOf(chatEmoji.id));
                        }

                        @Override
                        protected void setItemListener(CanHolderHelper helper) {

                        }
                    };

                    gridViewAdapter.setList(itemList.subList(itemNumbPerPage*pageIndex,
                            maxPageIndex>itemList.size() ? itemList.size() : maxPageIndex));
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
            }
            //动态设置sl_emojiPagerContainer的高度
            LinearLayout.LayoutParams sl_lp = (LinearLayout.LayoutParams) sl_pagerContainer.getLayoutParams();
            sl_lp.height = itemHeight*lineNumbPerPage+ sl_pagerContainer.getPaddingTop()
                    + sl_pagerContainer.getPaddingBottom();
            sl_pagerContainer.setLayoutParams(sl_lp);
            ll_pageIndicator.measure(0,0);
            //动态设置tv_emojiUnusableTip的高度
            FrameLayout.LayoutParams tv_lp = (FrameLayout.LayoutParams) tv_itemUnusableTip.getLayoutParams();
            tv_lp.height = sl_lp.height+ ll_pageIndicator.getMeasuredHeight()
                    + ll_pageIndicator.getPaddingTop()+ ll_pageIndicator.getPaddingBottom();
            tv_itemUnusableTip.setLayoutParams(tv_lp);
        }
    }

    /**
     * 添加表情页下方的圆点指示器
     * @param pageCount 页数
     */
    private void updatePageIndicView(int pageCount){
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
        if(null == tabTitles || tabTitles.size() == 0){
            tpi_tabIndicator.setVisibility(View.GONE);
            return;
        }
        tpi_tabIndicator.setVisibility(View.VISIBLE);
        tpi_tabIndicator.setTitles(tabTitles.toArray(new String[tabTitles.size()]));
        tpi_tabIndicator.setDefaultPosition(0);
        tpi_tabIndicator.setIndicatorMode(TabPageIndicator.IndicatorMode.MODE_WEIGHT_NOEXPAND_SAME);
        tpi_tabIndicator.setOnTabClickListener(new TabPageIndicator.OnTabClickListener() {
            @Override
            public void onTabClicked(int position, String title) {
                Toast.makeText(mContext,"title:"+title +" position:"+position,Toast.LENGTH_SHORT).show();
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
    public void setItemMap(Map<String,List<T>> itemMap){
        this.itemMap = itemMap;
    }

    /**
     * 设置gridview最多展示的行数
     * @param lineNumbPerPage
     */
    public void setLineNumbPerPage(int lineNumbPerPage){
        this.lineNumbPerPage = lineNumbPerPage;
    }

    /**
     * 设置gridView的列数
     * @param columnNumbPerPage
     */
    public void setColumnNumbPerPage(int columnNumbPerPage){
        this.columnNumbPerPage = columnNumbPerPage;
    }

    /**
     * 设置girdview item之间的垂直间距
     * @param gridViewVerticalSpacing
     */
    public void setGridViewVerticalSpacing(int gridViewVerticalSpacing){
        this.gridViewVerticalSpacing = gridViewVerticalSpacing;
    }

    /**
     * 设置girdview item之间的水平间距
     * @param gridViewHorizontalSpacing
     */
    public void setGridViewHorizontalSpacing(int gridViewHorizontalSpacing){
        this.gridViewHorizontalSpacing = gridViewHorizontalSpacing;
    }

    /**
     * 设置gridview的背景色
     * @param colorId
     */
    public void setGridViewBgColor(int colorId){
        this.gridViewBgColor = mContext.getResources().getColor(colorId);
    }

    /**
     * 设置gridview的背景色
     * @param color
     */
    public void setGridViewBgDrawable(String color){
        this.gridViewBgColor = Color.parseColor(color);
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
