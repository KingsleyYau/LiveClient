package com.qpidnetwork.anchor.liveshow.liveroom.vedio;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Color;
import android.graphics.drawable.GradientDrawable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.GridView;
import android.widget.HorizontalScrollView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.canadapter.CanAdapter;
import com.qpidnetwork.anchor.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.anchor.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.anchor.utils.Log;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.List;

/**
 * Description:Hang Out直播间 主播或者用户持有的吧台礼物列表
 * <p>
 * Created by Harry on 2018/4/18.
 */
public class HangoutBarGiftHorizontScrollView extends HorizontalScrollView {

    private final String TAG = HangoutBarGiftHorizontScrollView.class.getSimpleName();

    private List<HangOutBarGiftListItem> hangOutBarGiftItems = new ArrayList<>();

    private LinearLayout circleImageContainer;

    private CanAdapter<HangOutBarGiftListItem> gridViewAdapter;
    private GridView gridView;

    private int horizontSpace = 0;
    private int itemWidth = 0;

    public HangoutBarGiftHorizontScrollView(Context context) {
        this(context,null);
    }

    public HangoutBarGiftHorizontScrollView(Context context, AttributeSet attrs) {
        this(context,attrs,0);
    }

    public HangoutBarGiftHorizontScrollView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context,attrs,defStyleAttr);
        setFillViewport(true);
        initAttrs(context,attrs);
        initView(context);
    }


    private void initAttrs(Context context, AttributeSet attrs){
        DisplayMetrics dm = getResources().getDisplayMetrics();
        horizontSpace = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, horizontSpace, dm);
        itemWidth = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, itemWidth, dm);

        //自定义样式参数复用CircleImageHorizontScrollView
        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.CircleImageHorizontScrollView);
        horizontSpace = a.getDimensionPixelSize(R.styleable.CircleImageHorizontScrollView_horizontSpace, horizontSpace);
        itemWidth = a.getDimensionPixelSize(R.styleable.CircleImageHorizontScrollView_itemWidth, itemWidth);
    }

    private void initView(Context context){
        //HorizontalScrollView需要有一个直接子view LinearLayout
        circleImageContainer = new LinearLayout(context);
        circleImageContainer.setOrientation(LinearLayout.HORIZONTAL);
        LayoutParams layoutParams =
                new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
        layoutParams.gravity = Gravity.CENTER_VERTICAL|Gravity.RIGHT;
        circleImageContainer.setLayoutParams(layoutParams);
        circleImageContainer.setGravity(Gravity.CENTER_VERTICAL);
        addView(circleImageContainer);

        gridView = (GridView) View.inflate(getContext(),R.layout.item_simple_gridview_1,null);
        gridView.setHorizontalSpacing(horizontSpace);
        LinearLayout.LayoutParams gridViewLp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        gridViewLp.gravity = Gravity.CENTER_VERTICAL|Gravity.LEFT;
        gridView.setLayoutParams(gridViewLp);
        circleImageContainer.addView(gridView);
        gridView.setGravity(Gravity.CENTER_VERTICAL);
        //itemLayoutId布局
        gridViewAdapter = new CanAdapter<HangOutBarGiftListItem>(
                getContext(),R.layout.item_hangout_bargift_list, hangOutBarGiftItems) {
            @Override
            protected void setView(CanHolderHelper helper, int position, HangOutBarGiftListItem hangOutBarGiftListItem) {
                TextView tv_barGiftCount = helper.getTextView(R.id.tv_barGiftCount);
                //礼物数量
                tv_barGiftCount.setVisibility(hangOutBarGiftListItem.count <= 1 ? View.INVISIBLE : View.VISIBLE);
                tv_barGiftCount.setText(hangOutBarGiftListItem.count > 99 ? mContext.getResources().getString(R.string.live_gift_maxnum) : String.valueOf(hangOutBarGiftListItem.count));
                tv_barGiftCount.measure(0,0);
                //可动态修改属性值的shape
                GradientDrawable digitalHintGD = new GradientDrawable();
                digitalHintGD.setCornerRadius(90f);
                digitalHintGD.setColor(Color.parseColor("#FF7100"));
                digitalHintGD.setSize(tv_barGiftCount.getMeasuredHeight(),tv_barGiftCount.getMeasuredHeight());
                tv_barGiftCount.setBackgroundDrawable(digitalHintGD);

                //礼物图片
                CircleImageView civ_userHeader = (CircleImageView) helper.getImageView(R.id.civ_barGiftImg);
                if(!TextUtils.isEmpty(hangOutBarGiftListItem.middleImgUrl)){
                    Log.d(TAG,"initView-setView-position:"+position+" civ_userHeader.tag:"+civ_userHeader.getTag());
                    if(null == civ_userHeader.getTag() || !civ_userHeader.getTag().toString().equals(hangOutBarGiftListItem.middleImgUrl)){
                        Picasso.with(getContext().getApplicationContext())
                                .load(hangOutBarGiftListItem.middleImgUrl).noFade()
                                .error(R.drawable.ic_default_gift)
                                .memoryPolicy(MemoryPolicy.NO_CACHE)
                                .noPlaceholder()
                                .into(civ_userHeader);
                        civ_userHeader.setTag(hangOutBarGiftListItem.middleImgUrl);
                    }
                }else{
                    Picasso.with(getContext().getApplicationContext())
                            .load(R.drawable.ic_default_gift).noFade()
                            .noPlaceholder()
                            .into(civ_userHeader);
                    civ_userHeader.setTag(null);
                }
            }

            @Override
            protected void setItemListener(CanHolderHelper helper) {}
        };
        gridView.setAdapter(gridViewAdapter);
        gridView.setStretchMode(GridView.STRETCH_SPACING);
        gridView.setColumnWidth(itemWidth);
    }

    public synchronized void setList(List<HangOutBarGiftListItem> datas){
        if(null == hangOutBarGiftItems){
            hangOutBarGiftItems = new ArrayList<>();
        }
        this.hangOutBarGiftItems.clear();
        hangOutBarGiftItems.addAll(datas);
        notifyDataSetChanged();
    }

    public int getListNum(){
        return null == hangOutBarGiftItems ? 0 : hangOutBarGiftItems.size();
    }

    private int lastItemNumbs = 0;

    private void notifyDataSetChanged(){
        int itemNumbs = hangOutBarGiftItems.size();
        int containerWidth = itemWidth*itemNumbs+(itemNumbs-1)*horizontSpace
                +gridView.getPaddingLeft()+gridView.getPaddingRight();
        LinearLayout.LayoutParams gridViewLp = (LinearLayout.LayoutParams) gridView.getLayoutParams();
        gridViewLp.width = containerWidth;
        gridView.setNumColumns(itemNumbs);
        gridViewAdapter.setList(hangOutBarGiftItems);
    }
}
