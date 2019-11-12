package com.qpidnetwork.livemodule.liveshow.personal.chatemoji;

import android.content.Context;
import android.support.annotation.Nullable;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.flyco.tablayout.CommonTabLayout;
import com.flyco.tablayout.listener.CustomTabEntity;
import com.flyco.tablayout.listener.OnTabSelectListener;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.EmotionCategory;
import com.qpidnetwork.livemodule.httprequest.item.EmotionItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.liveroom.adapter.LiveEmojiIconAdapter;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.SpacingDecoration;
import com.qpidnetwork.livemodule.view.indicator.EmojiTabEntity;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Hardy on 2019/9/5.
 * Emoji Tab 带 icon 的新版表情列表布局
 */
public class EmoJiTabIconLayout extends LinearLayout implements View.OnClickListener {

    // tab 最大数量
    private static final int MAX_TAB_COUNT = 2;
    // item 列数
    private static final int EMOJI_LIST_SPAN_COUNT = 8;

    private FrameLayout mFlListContent;
    private CommonTabLayout mTabLayout;
    private TextView mTvSend;

    private Context mContext;
    private LayoutInflater mLayoutInflater;

    // Tab title 数据源
    private List<String> mTabTitles;
    // Tab title 和数据源的映射关系表
    private Map<String, EmotionCategory> mItemMap;
    // Tab 的 view 数组
    private List<View> mTabViews;
    private List<LiveEmojiIconAdapter> mTabAdapters;

    // 表情可发送列表
    private int[] emoTypeList;

    private int hSpace;
    private int vSpace;

    public EmoJiTabIconLayout(Context context) {
        this(context, null);
    }

    public EmoJiTabIconLayout(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public EmoJiTabIconLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        this.mContext = context;

        mLayoutInflater = LayoutInflater.from(context);

        mTabTitles = new ArrayList<>();
        mItemMap = new HashMap<>();
        mTabViews = new ArrayList<>();
        mTabAdapters = new ArrayList<>();

        hSpace = 0;
        vSpace = DisplayUtil.dip2px(mContext, 18);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();

        mFlListContent = findViewById(R.id.layout_emoji_tab_icon_fl_list_content);
        mTabLayout = findViewById(R.id.layout_emoji_tab_icon_tab_layout);
        mTvSend = findViewById(R.id.layout_emoji_tab_icon_tv_send);

        mTvSend.setOnClickListener(this);
        mTabLayout.setOnTabSelectListener(onTabSelectListener);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();

        if (id == R.id.layout_emoji_tab_icon_tv_send) {
            if (mOnEmojiTabIconOperateListener != null) {
                mOnEmojiTabIconOperateListener.onSend();
            }
        }
    }

    public void setEmoTypeList(int[] emoTypeList) {
        this.emoTypeList = emoTypeList;
    }

    public void setTabTitles(List<String> mTabTitles) {
        this.mTabTitles.clear();

        // 暂时只取前面 2 个数据，与 iOS 一致做法
        if (ListUtils.isList(mTabTitles) && mTabTitles.size() > MAX_TAB_COUNT) {
            mTabTitles = mTabTitles.subList(0, MAX_TAB_COUNT);
        }

        this.mTabTitles.addAll(mTabTitles);
    }

    public void setItemMap(Map<String, EmotionCategory> mItemMap) {
        this.mItemMap.clear();
        this.mItemMap.putAll(mItemMap);
    }

    public void updateView() {
        initTabTitle();
        initTabView();
    }

    /**
     * 刷新高级表情列表的 item 遮罩状态
     */
    public void notifyAdvancedListViewClickStatus(boolean isCanClick) {
        for (LiveEmojiIconAdapter adapter : mTabAdapters) {
            // 高级表情
            if (adapter.isAdvancedEmoji()) {
                List<EmotionItem> list = adapter.getList();
                if (ListUtils.isList(list)) {
                    for (EmotionItem emotionItem : list) {
                        emotionItem.isEmoJiAdvancedCanClick = isCanClick;
                    }

                    adapter.notifyDataSetChanged();
                }
            }
        }
    }

    /**
     * 初始化 tab 标题 icon
     */
    private void initTabTitle() {
        if (ListUtils.isList(mTabTitles)) {
            ArrayList<CustomTabEntity> list = new ArrayList<>();
            EmojiTabEntity emojiTabEntity = null;

            int size = mTabTitles.size();
            for (int i = 0; i < size; i++) {
                boolean isAdvancedEmoji = isAdvancedEmojiType(mItemMap.get(mTabTitles.get(i)), i);
                if (isAdvancedEmoji) {
                    // 高级表情
                    emojiTabEntity = new EmojiTabEntity(R.drawable.ic_live_emoji_pear);
                } else {
                    // 一般表情
                    emojiTabEntity = new EmojiTabEntity(R.drawable.ic_live_emoji_face);
                }

                list.add(emojiTabEntity);
            }

            mTabLayout.setTabData(list);
        }
    }

    /**
     * 初始化 tab 下的 view
     */
    private void initTabView() {
        if (ListUtils.isList(mTabTitles)) {
            // 初始化默认
            mFlListContent.removeAllViews();
            mTabViews.clear();
            mTabAdapters.clear();

            // 遍历添加 view
            int size = mTabTitles.size();
            for (int i = 0; i < size; i++) {
                String title = mTabTitles.get(i);
                View v = getTabListView(mItemMap.get(title), i);
                if (v != null) {
                    mFlListContent.addView(v);
                    mTabViews.add(v);
                }
            }

            // 默认展示第一个 view
            showTabView(0);
        }
    }

    /**
     * 获取 tab 下对应的列表 view
     */
    private View getTabListView(EmotionCategory emotionCategory, int tabPos) {
        RecyclerView view = null;

        if (emotionCategory != null) {
            view = (RecyclerView) mLayoutInflater.inflate(R.layout.layout_emoji_tab_icon_list, mFlListContent, false);
            // recyclerView 属性设置
            view.setLayoutManager(new GridLayoutManager(mContext, EMOJI_LIST_SPAN_COUNT));
            SpacingDecoration spacingDecoration = new SpacingDecoration(hSpace, vSpace, true);
            view.addItemDecoration(spacingDecoration);
            view.setHasFixedSize(true);
            view.setFocusable(false);

            // 是否为高级表情，除了第 0 个为标准表情，其余都是
            boolean isAdvancedEmoji = isAdvancedEmojiType(emotionCategory, tabPos);

            LiveEmojiIconAdapter adapter = new LiveEmojiIconAdapter(mContext, isAdvancedEmoji);
            adapter.setOnItemClickListener(onItemClickListener);
            view.setAdapter(adapter);

            // 过滤 emoji item 是否可点击，即等级
            if (emotionCategory.emotionList != null && emotionCategory.emotionList.length > 0) {
                List<EmotionItem> emotionItemList = new ArrayList<>();
                boolean isCanClick = isEmojiCanClick(isAdvancedEmoji, tabPos);

                for (EmotionItem emotionItem : emotionCategory.emotionList) {
                    emotionItem.isEmoJiAdvancedCanClick = isCanClick;
                    emotionItemList.add(emotionItem);
                }

                adapter.setData(emotionItemList);
            }

            // 保存 adapter
            mTabAdapters.add(adapter);
        }

        return view;
    }

    /**
     * 是否为高级表情
     */
    private boolean isAdvancedEmojiType(EmotionCategory emotionCategory, int tabPos) {
        return ((emotionCategory != null && emotionCategory.emotionTag == EmotionCategory.EmotionTag.Advanced) || tabPos != 0);
    }

    /**
     * 初始化时，判断高级表情是否满足等级限制
     */
    private boolean isEmojiCanClick(boolean isAdvancedEmoji, int tabPos) {
        boolean isCanClick = !isAdvancedEmoji;  // 一般表情，默认可点击

        if (isAdvancedEmoji && emoTypeList != null) {
            for (int i : emoTypeList) {
                if (i == tabPos) {
                    isCanClick = true;
                    break;
                }
            }
        }

        return isCanClick;
    }

    /**
     * 展示指定的 tab view
     */
    private void showTabView(int showTabPos) {
        int childCount = mFlListContent.getChildCount();

        for (int i = 0; i < childCount; i++) {
            View childView = mFlListContent.getChildAt(i);
            if (childView != null) {
                childView.setVisibility(i == showTabPos ? VISIBLE : GONE);
            }
        }
    }

    /**
     * emoji item 的点击事件回调
     */
    BaseRecyclerViewAdapter.OnItemClickListener onItemClickListener = new BaseRecyclerViewAdapter.OnItemClickListener() {
        @Override
        public void onItemClick(View v, int position) {
            int tabPos = mTabLayout.getCurrentTab();

            LiveEmojiIconAdapter adapter = mTabAdapters.get(tabPos);
            if (adapter != null) {
                EmotionItem bean = adapter.getItemBean(position);
                if (bean != null && mOnEmojiTabIconOperateListener != null) {
                    mOnEmojiTabIconOperateListener.onEmojiClick(tabPos, position, mTabTitles.get(tabPos), bean);
                }
            }
        }
    };

    /**
     * tab 的点击事件
     */
    OnTabSelectListener onTabSelectListener = new OnTabSelectListener() {
        @Override
        public void onTabSelect(int position) {
            showTabView(position);

            if (mOnEmojiTabIconOperateListener != null) {
                mOnEmojiTabIconOperateListener.onTabClick(position);
            }
        }

        @Override
        public void onTabReselect(int position) {

        }
    };

    //*****************************     interface   ********************************
    private OnEmojiTabIconOperateListener mOnEmojiTabIconOperateListener;

    public void setOnEmojiTabIconOperateListener(OnEmojiTabIconOperateListener mOnEmojiTabIconOperateListener) {
        this.mOnEmojiTabIconOperateListener = mOnEmojiTabIconOperateListener;
    }

    public interface OnEmojiTabIconOperateListener {
        /**
         * 文本发送
         */
        void onSend();

        /**
         * tab 标题点击
         */
        void onTabClick(int tabPos);

        /**
         * 指定 tab 下的 emoji 表情 item 点击
         */
        void onEmojiClick(int tabPos, int emojiPos, String tabTitle, EmotionItem emotionItem);
    }
}
