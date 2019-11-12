package com.qpidnetwork.livemodule.framework.widget.viewpagerindicator;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Paint.Style;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
import android.os.Parcel;
import android.os.Parcelable;
import android.support.v4.view.ViewPager;
import android.support.v4.view.ViewPager.OnPageChangeListener;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import com.qpidnetwork.qnbridgemodule.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver.OnGlobalLayoutListener;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.view.DotView.DotView;

import java.util.Locale;

/**
 * 实现原理参考：http://blog.csdn.net/shan_yao/article/details/51753869
 * 源码Github；https://github.com/shanyao0/TabPagerIndicatorDemo
 */
public class TabPageIndicator<T> extends HorizontalScrollView {

    private final String TAG = TabPageIndicator.class.getSimpleName();
    private Context mContext;
    private int[] itemTabViewWidths;
    private int[] itemTabTitleWidths;
    private boolean checkedTabWidths = false;
    private Paint rectPaint;
    private Paint dividerPaint;
    private Locale locale;
    private int lastScrollX = 0;

    private LinearLayout tabsContainer;
    private ViewPager pager;

    private LinearLayout.LayoutParams wrapTabLayoutParams;
    private LinearLayout.LayoutParams weightTabLayoutParams;

    private final PageListener pageListener = new PageListener();
    public OnPageChangeListener delegatePageListener;
    private OnTabClickListener onTabClickListener;

    /**
     * 页数
     */
    private int tabCount;
    /**
     * 标题数据源
     */
    private String[] titles;
    /**
     * 当前位置
     */
    private int currentPosition = 0;
    /**
     * 记录上次的item索引
     */
    private int lastSelectedItemIndex = 0;
    /**
     * viewpager当前位置的偏移百分比
     */
    private float currentPositionOffset = 0f;
    /**
     * 指示线的颜色  #0075E7
     */
    private int indicatorColor = Color.parseColor("#ffffff");
    /**
     * 指示线的高度
     */
    private int indicatorHeight = 0;
    /**
     * 默认指示线的颜色
     */
    private int underlineColor = 0xFFdcdcdc;
    /**
     * 导航栏底部分割线的高度
     */
    private int underlineHeight = 0;
    /**
     * 分割线的颜色
     */
    private int dividerColor = 0x00000000;
    /**
     * 设置导航先是否跟文字长度一至
     */
    private boolean isSameLine;
    /**
     * 是否转换为大写
     */
    private boolean textAllCaps;
    /**
     * 是否可扩展
     */
    private boolean isExpand;
    /**
     * 可扩展并且导标一致
     */
    private boolean isExpandSameLine;
    /**
     * 当显示多个tab时，底部导航线距离左侧的位移,默认是10，请不要太小
     */
    private int scrollOffset = 10;
    /**
     * 竖线到下面的距离:可以通过设置indicator的高度设置下面横线和文字的距离
     */
    private int dividerPadding = 0;
    /**
     * 标题的间距
     */
    private int tabPadding;
    /**
     * 分割线的宽度
     */
    private int dividerWidth = 0;
    /**
     * 距离左边的距离
     */
    private int indicatorPaddingLeft = 0;
    /**
     * 距离右边的距离
     */
    private int indicatorPaddingRight = 0;
    /**
     * 标题的字体大小
     */
    private int titleTextSize = 8;

    /**
     * 字体是否加粗
     */
    private boolean isTitleTxtBold = false;

    /**
     * 标题未被选中时字体颜色
     */
    private int titleTextColorUnselected = Color.parseColor("#ffffff");
    /**
     * 标题被选中时字体颜色
     */
    private int titleTextColorSelected = Color.parseColor("#ffffff");
    /**
     * tab被选中时字体颜色
     */
    private int tabSelectedBgColor = Color.parseColor("#5d0e86");
    /**
     * tab被选中时字体颜色
     */
    private int tabUnselectedBgColor = Color.parseColor("#6b6b6b");
    /**
     * 提示数字的字体颜色
     */
    private int digitalHintTextColor = Color.WHITE;
    /**
     * 提示数字组件的背景色
     */
    private int digitalHintTextBgColor = Color.TRANSPARENT;
    /**
     * 提示数字的字体大小
     */
    private int digitalHintTextSize = 10;

    /**
     * 定义6种模式
     */
    public enum IndicatorMode {
        /**
         * 平均分配，导航线跟标题相等
         */
        MODE_WEIGHT_NOEXPAND_SAME(0),
        /**
         * 平均分配，导航线跟标题不相等
         */
        MODE_WEIGHT_NOEXPAND_NOSAME(1),
        /**
         * 非平均分配，非扩展，导标相等
         */
        MODE_NOWEIGHT_NOEXPAND_SAME(2),
        /**
         * 非平均分配，非扩展，导标不相等
         */
        MODE_NOWEIGHT_NOEXPAND_NOSAME(3),
        /**
         * 可扩展，导标相等
         */
        MODE_NOWEIGHT_EXPAND_SAME(4),
        /**
         * 不可扩展，导标不相等
         */
        MODE_NOWEIGHT_EXPAND_NOSAME(5);
        private int value;

        IndicatorMode(int value) {
            this.value = value;
        }

        public int getValue() {
            return value;
        }
    }

    private IndicatorMode currentIndicatorMode = IndicatorMode.MODE_WEIGHT_NOEXPAND_SAME;


    /*
        2018/11/26  Hardy
        未读数字、红点的位置
        默认在右上角
     */
    public static final int RED_DOT_LOCATION_GRAVITY_RIGHT_TOP = 1;
    public static final int RED_DOT_LOCATION_GRAVITY_RIGHT_CENTER = 2;
    private int curRedDotLocation = RED_DOT_LOCATION_GRAVITY_RIGHT_TOP;


    public TabPageIndicator(Context context) {
        this(context, null);
        this.mContext = context;
    }

    public TabPageIndicator(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
        this.mContext = context;
    }

    public TabPageIndicator(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        this.mContext = context;
        setFillViewport(true);
        setWillNotDraw(false);

        tabsContainer = new LinearLayout(context);
        tabsContainer.setOrientation(LinearLayout.HORIZONTAL);
        LayoutParams layoutParams = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
        tabsContainer.setLayoutParams(layoutParams);
        addView(tabsContainer);

        DisplayMetrics dm = getResources().getDisplayMetrics();

        scrollOffset = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, scrollOffset, dm);
        indicatorHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, indicatorHeight, dm);
        underlineHeight = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, underlineHeight, dm);
        dividerPadding = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dividerPadding, dm);
        tabPadding = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, tabPadding, dm);
        dividerWidth = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dividerWidth, dm);
        titleTextSize = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, titleTextSize, dm);

        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.TabPageIndicator);
        titleTextColorUnselected = a.getColor(R.styleable.TabPageIndicator_titleTextColorUnselected, titleTextColorUnselected);
        titleTextColorSelected = a.getColor(R.styleable.TabPageIndicator_titleTextColorSelected, titleTextColorSelected);
        titleTextSize = a.getDimensionPixelSize(R.styleable.TabPageIndicator_titleTextSize, titleTextSize);
        tabSelectedBgColor = a.getColor(R.styleable.TabPageIndicator_tabSelectedBgColor, tabSelectedBgColor);
        tabUnselectedBgColor = a.getColor(R.styleable.TabPageIndicator_tabUnselectedBgColor, tabUnselectedBgColor);

        indicatorColor = a.getColor(R.styleable.TabPageIndicator_indicatorColor, indicatorColor);
        indicatorHeight = a.getDimensionPixelSize(R.styleable.TabPageIndicator_indicatorHeight, indicatorHeight);
        underlineColor = a.getColor(R.styleable.TabPageIndicator_underlineColor, underlineColor);
        underlineHeight = a.getDimensionPixelSize(R.styleable.TabPageIndicator_underlineHeight, underlineHeight);
        dividerColor = a.getColor(R.styleable.TabPageIndicator_dividerColor, dividerColor);
        dividerPadding = a.getDimensionPixelSize(R.styleable.TabPageIndicator_pst_dividerPadding, dividerPadding);
        tabPadding = a.getDimensionPixelSize(R.styleable.TabPageIndicator_tabPaddingLeftRight, tabPadding);
        scrollOffset = a.getDimensionPixelSize(R.styleable.TabPageIndicator_scrollOffset, scrollOffset);
        textAllCaps = a.getBoolean(R.styleable.TabPageIndicator_pst_textAllCaps, textAllCaps);
        //数字提示
        digitalHintTextColor = a.getColor(R.styleable.TabPageIndicator_digitalHintTextColor, digitalHintTextColor);
        digitalHintTextBgColor = a.getColor(R.styleable.TabPageIndicator_digitalHintTextBgColor, digitalHintTextBgColor);
        digitalHintTextSize = a.getDimensionPixelSize(R.styleable.TabPageIndicator_digitalHintTextSize, digitalHintTextSize);
        isTitleTxtBold = a.getBoolean(R.styleable.TabPageIndicator_isTitleTxtBold, isTitleTxtBold);

        // 2018/11/26 Hardy
        curRedDotLocation = a.getInt(R.styleable.TabPageIndicator_red_dot_location, RED_DOT_LOCATION_GRAVITY_RIGHT_TOP);

        a.recycle();

        rectPaint = new Paint();
        rectPaint.setAntiAlias(true);
        rectPaint.setStyle(Style.FILL);
        dividerPaint = new Paint();
        dividerPaint.setAntiAlias(true);
        dividerPaint.setStrokeWidth(dividerWidth);
        wrapTabLayoutParams = new LinearLayout.LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.MATCH_PARENT);
        weightTabLayoutParams = new LinearLayout.LayoutParams(0, LayoutParams.MATCH_PARENT, 1.0f);
        if (locale == null) {
            locale = getResources().getConfiguration().locale;
        }
    }


    // 根据不同的Mode设置不同的展现效果
    public void setIndicatorMode(IndicatorMode indicatorMode) {
        switch (indicatorMode) {
            case MODE_WEIGHT_NOEXPAND_SAME:
                isExpand = false;
                isSameLine = true;
                break;
            case MODE_WEIGHT_NOEXPAND_NOSAME:
                isExpand = false;
                isSameLine = false;
                break;
            case MODE_NOWEIGHT_NOEXPAND_SAME:
                isExpand = false;
                isSameLine = true;
                isExpandSameLine = true;
                tabPadding = dip2px(10);
                break;
            case MODE_NOWEIGHT_NOEXPAND_NOSAME:
                isExpand = false;
                isSameLine = true;
                isExpandSameLine = true;
                tabPadding = dip2px(10);
                break;
            case MODE_NOWEIGHT_EXPAND_SAME:
                isExpand = true;
                isExpandSameLine = true;
                tabPadding = dip2px(10);
                break;
            case MODE_NOWEIGHT_EXPAND_NOSAME:
                isExpand = true;
                isExpandSameLine = false;
                tabPadding = dip2px(10);
                break;
        }
        this.currentIndicatorMode = indicatorMode;
        notifyDataSetChanged();
    }

    public void notifyDataSetChanged() {
        if (null != pager) {
            tabsContainer.removeAllViews();
            tabCount = pager.getAdapter().getCount();
            for (int i = 0; i < tabCount; i++) {
                addDigitalHintTextTab(i, pager.getAdapter().getPageTitle(i).toString());
            }
            updateTabStyles(null != pager ? pager.getCurrentItem() : currentPosition);
        } else if (null != titles) {
            tabsContainer.removeAllViews();
            tabCount = titles.length;
            for (int i = 0; i < tabCount; i++) {
                addDigitalHintTextTab(i, titles[i]);
            }
            updateTabStyles(currentPosition);
        } else {
            return;
        }

        checkedTabWidths = false;
        getViewTreeObserver().addOnGlobalLayoutListener(new OnGlobalLayoutListener() {
            @SuppressWarnings("deprecation")
            @SuppressLint("NewApi")
            @Override
            public void onGlobalLayout() {
                if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN) {
                    getViewTreeObserver().removeGlobalOnLayoutListener(this);
                } else {
                    getViewTreeObserver().removeOnGlobalLayoutListener(this);
                }
                if (null != pager) {
                    currentPosition = pager.getCurrentItem();
                } else {
                    //pager == null 时需要另一个变量记录
                    currentPosition = lastSelectedItemIndex;
                }
                scrollToChild(currentPosition, 0);
            }
        });

    }

    /**
     * 添加包含未读提示的tab view
     *
     * @param position 当前tab的位置
     * @param title    tab标题
     */
    private void addDigitalHintTextTab(final int position, final String title) {
        View tabItemView = View.inflate(getContext(), R.layout.tabpageindicator_view_custom_tab, null);
        tabItemView.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (null != pager) {
                    pager.setCurrentItem(position);
                } else {
                    lastSelectedItemIndex = position;
                    if (null != onTabClickListener) {
                        onTabClickListener.onTabClicked(position, title);
                    }
                    onTabSelected(position);
                }
            }
        });

        TextView tv_tabTitle = (TextView) tabItemView.findViewById(R.id.tv_tabTitle);
        tv_tabTitle.setText(title);

        //edit by Jagger 2017-12-13
        DotView dv_digitalHint = (DotView) tabItemView.findViewById(R.id.dv_digitalHint);
        dv_digitalHint.setTextSize(TypedValue.COMPLEX_UNIT_PX, digitalHintTextSize);
        dv_digitalHint.setTextColor(digitalHintTextColor);

        // 2018/11/26 Hardy
        if (curRedDotLocation == RED_DOT_LOCATION_GRAVITY_RIGHT_CENTER) {
            ViewGroup.MarginLayoutParams marginLayoutParams = (MarginLayoutParams) dv_digitalHint.getLayoutParams();
            marginLayoutParams.bottomMargin = 0;                // 如果位置在右上角，在布局中，默认设置了距离底部 6dp
            marginLayoutParams.leftMargin = dip2px(4);  // 距离左边 4dp
            dv_digitalHint.setLayoutParams(marginLayoutParams);
        }

        dv_digitalHint.setVisibility(View.GONE);

        if (isExpand && !isExpandSameLine) {
            tabItemView.setPadding(tabPadding, 0, tabPadding, 0);
        } else {
            wrapTabLayoutParams.setMargins(tabPadding, 0, tabPadding, 0);
            weightTabLayoutParams.setMargins(tabPadding, 0, tabPadding, 0);
        }
        tabsContainer.addView(tabItemView, position, isSameLine ? wrapTabLayoutParams : weightTabLayoutParams);
    }

    /**
     * 更改红点未读数字提示显示状态
     *
     * @param position
     * @param showHint
     * @param onlyShowRedPoint
     * @param unReadNumb
     */
    public void updateTabDiginalHint(final int position, boolean showHint, boolean onlyShowRedPoint, int unReadNumb) {
        View tabItemView = tabsContainer.getChildAt(position);
        if(tabItemView != null) {
            DotView dv_digitalHint = (DotView) tabItemView.findViewById(R.id.dv_digitalHint);
            if (showHint) {
                if (!onlyShowRedPoint && unReadNumb > 0) {
                    dv_digitalHint.setText(String.valueOf(unReadNumb));
                }
                dv_digitalHint.setVisibility(View.VISIBLE);
            } else {
                dv_digitalHint.setVisibility(View.GONE);
            }
        }
    }

    /**
     * 更新Title对应的view的styles
     */
    private void updateTabStyles(int position) {
        itemTabViewWidths = new int[tabCount];
        itemTabTitleWidths = new int[tabCount];
        for (int i = 0; i < tabCount; i++) {
            View tabItemView = tabsContainer.getChildAt(i);
            tabItemView.setBackgroundDrawable(
                    new ColorDrawable(i == position ? tabSelectedBgColor : tabUnselectedBgColor));

            TextView tv_tabTitle = (TextView) tabItemView.findViewById(R.id.tv_tabTitle);
            tv_tabTitle.setTextSize(TypedValue.COMPLEX_UNIT_PX, titleTextSize);
            tv_tabTitle.getPaint().setFakeBoldText(isTitleTxtBold);
            tv_tabTitle.setTextColor(i == position ? titleTextColorSelected : titleTextColorUnselected);
            //大小写切换
            if (textAllCaps) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.ICE_CREAM_SANDWICH) {
                    tv_tabTitle.setAllCaps(true);
                } else {
                    tv_tabTitle.setText(tv_tabTitle.getText().toString().toUpperCase(locale));
                }
            }
        }
    }

    private void scrollToChild(int position, int offset) {
        if (tabCount == 0 || offset == 0) {
            return;
        }
        int newScrollX = tabsContainer.getChildAt(position).getLeft() + offset;
        if (position > 0 || offset > 0) {
            newScrollX -= scrollOffset;
        }
        if (newScrollX != lastScrollX) {
            lastScrollX = newScrollX;
            scrollTo(newScrollX, 0);
        }

    }

    //--------------------------------------重写的父类方法-------------------------------------------
    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        if (isExpand) return;

        /**
         * 一下这些代码是为了在设置weight的情况下，导航线也能跟标题长度一致
         */
        int myWidth = getMeasuredWidth();// 其实就是屏幕的宽度
        int childWidth = 0;
        for (int i = 0; i < tabCount; i++) {
            View tabItemView = tabsContainer.getChildAt(i);
            childWidth += tabItemView.getMeasuredWidth();

            if (itemTabViewWidths[i] == 0) {
                //已经重新布局，需要重新获取文本大小
                itemTabViewWidths[i] = tabItemView.getMeasuredWidth();
            }
            TextView tv_tabTitle = (TextView) tabItemView.findViewById(R.id.tv_tabTitle);
            tv_tabTitle.measure(0, 0);
            if (itemTabTitleWidths[i] == 0) {
                itemTabTitleWidths[i] = tv_tabTitle.getMeasuredWidth();
            }
        }
//        int bottomMargin = underlineHeight>indicatorHeight ? underlineHeight : indicatorHeight;
        int bottomMargin = indicatorHeight;
        if (currentIndicatorMode == IndicatorMode.MODE_NOWEIGHT_NOEXPAND_SAME) {
            setIndicatorPaddingRight(myWidth - childWidth - tabPadding * 2 * tabCount);
            tabsContainer.setPadding(indicatorPaddingLeft, 0, indicatorPaddingRight, bottomMargin);
        }
        if (currentIndicatorMode == IndicatorMode.MODE_NOWEIGHT_NOEXPAND_NOSAME) {
            setIndicatorPaddingRight(myWidth - childWidth - tabPadding * 2 * tabCount);
            tabsContainer.setPadding(indicatorPaddingLeft, 0, indicatorPaddingRight, bottomMargin);
        }
        if (!checkedTabWidths && childWidth > 0 && myWidth > 0) {
            // tab标题的长度为超过屏幕的宽度
            if (childWidth <= myWidth) {
                for (int i = 0; i < tabCount; i++) {
                    weightTabLayoutParams.bottomMargin = bottomMargin;
                    tabsContainer.getChildAt(i).setLayoutParams(weightTabLayoutParams);
                }
            } else {
                for (int i = 0; i < tabCount; i++) {
                    wrapTabLayoutParams.bottomMargin = bottomMargin;
                    tabsContainer.getChildAt(i).setLayoutParams(wrapTabLayoutParams);
                }
            }

            checkedTabWidths = true;
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if (isInEditMode() || tabCount == 0) {
            return;
        }
        final int height = getHeight();
        /**
         * draw underline
         */
        rectPaint.setColor(underlineColor);
        canvas.drawRect(0, height - underlineHeight, tabsContainer.getWidth(), height, rectPaint);
        /**
         * draw底部的导航线
         */
        rectPaint.setColor(indicatorColor);
        // 默认在Tab标题的下面
        View currentTab = tabsContainer.getChildAt(currentPosition);
        float currentOffWid;
        if (isExpand) {
            currentOffWid = 0;
        } else {
            currentOffWid = (currentTab.getWidth() - itemTabViewWidths[currentPosition]) / 2;
        }

        float lineLeft = currentTab.getLeft() + currentOffWid;
        float lineRight = currentTab.getRight() - currentOffWid;

        if (currentPositionOffset > 0f && currentPosition < tabCount - 1) {
            View nextTab = tabsContainer.getChildAt(currentPosition + 1);
            float nextOffWid;
            if (isExpand) {
                nextOffWid = 0;
            } else {
                nextOffWid = (nextTab.getWidth() - itemTabViewWidths[currentPosition + 1]) / 2;
            }
            float nextTabLeft = nextTab.getLeft() + nextOffWid;
            float nextTabRight = nextTab.getRight() - nextOffWid;

            lineLeft = (currentPositionOffset * nextTabLeft + (1f - currentPositionOffset) * lineLeft);
            lineRight = (currentPositionOffset * nextTabRight + (1f - currentPositionOffset) * lineRight);
        }
        if (currentIndicatorMode == IndicatorMode.MODE_NOWEIGHT_NOEXPAND_NOSAME) {
            canvas.drawRect(lineLeft - tabPadding, height - indicatorHeight - underlineHeight,
                    lineRight + tabPadding, height - underlineHeight, rectPaint);
        } else {
            canvas.drawRect(lineLeft, height - indicatorHeight - underlineHeight, lineRight, height - underlineHeight, rectPaint);
        }
        /**
         * draw divider：分割线
         */
        dividerPaint.setColor(dividerColor);
        for (int i = 0; i < tabCount - 1; i++) {
            View tab = tabsContainer.getChildAt(i);
            if (!isExpandSameLine) {
                canvas.drawLine(tab.getRight(), dividerPadding, tab.getRight(), height - dividerPadding, dividerPaint);
            } else {
                canvas.drawLine(tab.getRight() + tabPadding, dividerPadding,
                        tab.getRight() + tabPadding, height - dividerPadding, dividerPaint);
            }
        }
    }

    @Override
    public void onRestoreInstanceState(Parcelable state) {
        SavedState savedState = (SavedState) state;
        super.onRestoreInstanceState(savedState.getSuperState());
        currentPosition = savedState.lastSelectedItemIndex;
        requestLayout();
    }

    @Override
    public Parcelable onSaveInstanceState() {
        Parcelable superState = super.onSaveInstanceState();
        SavedState savedState = new SavedState(superState);
        savedState.lastSelectedItemIndex = currentPosition;
        return savedState;
    }

//--------------------------------------listener相关-------------------------------------------

    public interface OnTabClickListener {
        void onTabClicked(int position, String title);
    }

    private class PageListener implements OnPageChangeListener {
        @Override
        public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
            onTabScrolled(position, positionOffset, positionOffsetPixels);
        }

        @Override
        public void onPageScrollStateChanged(int state) {
            onTabScroolStateChanged(state, pager.getCurrentItem());
        }

        @Override
        public void onPageSelected(int position) {
            onTabSelected(position);
        }
    }

    public void onTabScroolStateChanged(int state, int currentItem) {
        Log.d(TAG, "onTabScroolStateChanged-state:" + state);
        if (state == ViewPager.SCROLL_STATE_IDLE) {
            scrollToChild(currentItem, 0);
        }
        if (null != pager && delegatePageListener != null) {
            delegatePageListener.onPageScrollStateChanged(state);
        }
    }

    public void onTabSelected(int position) {
        Log.d(TAG, "onTabSelected-position:" + position);
        if (null != pager && delegatePageListener != null) {
            delegatePageListener.onPageSelected(position);
        }

        //可能跟onPage*的回调顺序有关
        for (int i = 0; i < tabCount; i++) {
            View tabItemView = tabsContainer.getChildAt(i);
            tabItemView.setBackgroundDrawable(new ColorDrawable(i == position ? tabSelectedBgColor : tabUnselectedBgColor));
            TextView tv_tabTitle = (TextView) tabItemView.findViewById(R.id.tv_tabTitle);
            tv_tabTitle.setTextColor(i == position ? titleTextColorSelected : titleTextColorUnselected);
        }

        invalidate();
    }

    public void onTabScrolled(int position, float positionOffset, int positionOffsetPixels) {
        currentPosition = position;
        currentPositionOffset = positionOffset;
        Log.d(TAG, "onTabScrolled-position:" + position
                + " positionOffset:" + positionOffset
                + " positionOffsetPixels:" + positionOffsetPixels);
        scrollToChild(position, (int) (positionOffset * tabsContainer.getChildAt(position).getWidth()));
        invalidate();
        if (null != pager && delegatePageListener != null) {
            delegatePageListener.onPageScrolled(position, positionOffset, positionOffsetPixels);
        }
    }

    public void setOnTabClickListener(OnTabClickListener onTabClickListener) {
        this.onTabClickListener = onTabClickListener;
    }

    public void setOnPageChangeListener(OnPageChangeListener listener) {
        this.delegatePageListener = listener;
    }

//--------------------------------------set方法-------------------------------------------

    public void setViewPager(ViewPager pager) {
        this.pager = pager;
        if (pager.getAdapter() == null) {
            throw new IllegalStateException("ViewPager does not have adapter instance.");
        }
        pager.setOnPageChangeListener(pageListener);
        currentPosition = pager.getCurrentItem();
        notifyDataSetChanged();
    }

    public void setIndicatorColor(int indicatorColor) {
        this.indicatorColor = indicatorColor;
        invalidate();
    }

    public void setIndicatorHeight(int indicatorLineHeightPx) {
        this.indicatorHeight = indicatorLineHeightPx;
        invalidate();
    }

    public void setUnderlineColor(int underlineColor) {
        this.underlineColor = underlineColor;
        invalidate();
    }

    public void setDividerColor(int dividerColor) {
        this.dividerColor = dividerColor;
        invalidate();
    }

    public void setUnderlineHeight(int underlineHeightPx) {
        this.underlineHeight = underlineHeightPx;
        invalidate();
    }

    public void setDividerPadding(int dividerPaddingPx) {
        this.dividerPadding = dividerPaddingPx;
        invalidate();
    }

    public void setScrollOffset(int scrollOffsetPx) {
        this.scrollOffset = scrollOffsetPx;
        invalidate();
    }

    public void setSameLine(boolean sameLine) {
        this.isSameLine = sameLine;
        requestLayout();
    }

    public void setAllCaps(boolean textAllCaps) {
        this.textAllCaps = textAllCaps;
    }

    /**
     * 设置默认的选中位置
     *
     * @param defaultPosition
     */
    public void setDefaultPosition(int defaultPosition) {
        this.currentPosition = defaultPosition;
        this.lastSelectedItemIndex = defaultPosition;
        updateTabStyles(defaultPosition);
        invalidate();
    }

    /**
     * 设置tab标题的字体大小
     *
     * @param textSizePx
     */
    public void setTitleTextSize(int textSizePx) {
        this.titleTextSize = textSizePx;
        updateTabStyles(null != pager ? pager.getCurrentItem() : currentPosition);
    }

    /**
     * 设置tab未被选中时标题的颜色
     *
     * @param titleTextColorUnselected
     */
    public void setTitleUnselectedColor(int titleTextColorUnselected) {
        this.titleTextColorUnselected = titleTextColorUnselected;
        updateTabStyles(null != pager ? pager.getCurrentItem() : currentPosition);
    }

    public void setTabSelectedBgColor(int tabSelectedBgColor) {
        this.tabSelectedBgColor = tabSelectedBgColor;
        invalidate();
    }

    public void setTabUnselectedBgColor(int tabUnselectedBgColor) {
        this.tabUnselectedBgColor = tabUnselectedBgColor;
        invalidate();
    }

    /**
     * 设置tab被选中时标题的颜色
     *
     * @param textColorSelected
     */
    public void setTextColorSelected(int textColorSelected) {
        this.titleTextColorSelected = textColorSelected;
        updateTabStyles(null != pager ? pager.getCurrentItem() : currentPosition);
    }

    /**
     * 设置数字提示文本的字体颜色
     *
     * @param digitalHintTextColor
     */
    public void setDigitalHintTextColor(int digitalHintTextColor) {
        this.digitalHintTextColor = digitalHintTextColor;
        invalidate();
    }

    /**
     * 设置数字提示txtview的背景色
     *
     * @param digitalHintTextBgColor
     */
    public void setDigitalHintTextBgColor(int digitalHintTextBgColor) {
        this.digitalHintTextBgColor = digitalHintTextBgColor;
        invalidate();
    }

    /**
     * 设置是否显示数字提示组件
     *
     * @param hasDigitalHint
     */
    public void setHasDigitalHint(boolean hasDigitalHint) {
        invalidate();
    }

    /**
     * 设置标题数据源
     *
     * @param titles
     */
    public void setTitles(String[] titles) {
        this.titles = titles;
        notifyDataSetChanged();
    }

    public void setTabPaddingLeftRight(int paddingPx) {
        this.tabPadding = paddingPx;
        updateTabStyles(null != pager ? pager.getCurrentItem() : currentPosition);
    }

    public void setIndicatorPaddingLeft(int indicatorPaddingLeft) {
        this.indicatorPaddingLeft = indicatorPaddingLeft;
    }

    public void setIndicatorPaddingRight(int indicatorPaddingRight) {
        this.indicatorPaddingRight = indicatorPaddingRight;
    }

    static class SavedState extends BaseSavedState {
        int lastSelectedItemIndex;

        public SavedState(Parcelable superState) {
            super(superState);
        }

        private SavedState(Parcel in) {
            super(in);
            lastSelectedItemIndex = in.readInt();
        }

        @Override
        public void writeToParcel(Parcel dest, int flags) {
            super.writeToParcel(dest, flags);
            dest.writeInt(lastSelectedItemIndex);
        }

        public static final Creator<SavedState> CREATOR = new Creator<SavedState>() {
            @Override
            public SavedState createFromParcel(Parcel in) {
                return new SavedState(in);
            }

            @Override
            public SavedState[] newArray(int size) {
                return new SavedState[size];
            }
        };
    }

    /**
     * dip转化成px
     */
    public int dip2px(float dpValue) {
        float scale = mContext.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }


    /**
     * 2018/11/19 Hardy
     * 设置所有未读红点的内容数字 padding
     *
     * @param pxSize
     */
    public void setTabDiginalAllSize(int pxSize) {
        int count = tabsContainer.getChildCount();
        for (int i = 0; i < count; i++) {
            setTabDigitalSize(i, pxSize);
        }
    }

    /**
     * 2018/11/26 Hardy
     * 设置指定小红点的大小
     *
     * @param position
     * @param pxSize
     */
    public void setTabDigitalSize(int position, int pxSize) {
        View tabItemView = tabsContainer.getChildAt(position);
        DotView dv_digitalHint = (DotView) tabItemView.findViewById(R.id.dv_digitalHint);
        dv_digitalHint.setDotPadding(pxSize);
    }

    /**
     * 2018/11/28 Hardy
     * 获取指定的 Tab view
     *
     * @param position
     * @return
     */
    public View getCurTabView(int position) {
        View tabItemView = tabsContainer.getChildAt(position);
        return tabItemView;
    }
}
