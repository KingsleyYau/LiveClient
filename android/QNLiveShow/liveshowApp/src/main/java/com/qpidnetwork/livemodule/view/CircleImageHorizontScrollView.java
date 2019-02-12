package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.GridView;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.canadapter.CanAdapter;
import com.qpidnetwork.livemodule.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.livemodule.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.livemodule.liveshow.liveroom.online.AudienceHeadItem;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;
import java.util.List;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/8/21.
 */

public class CircleImageHorizontScrollView extends HorizontalScrollView {

    private final String TAG = CircleImageHorizontScrollView.class.getSimpleName();

    private List<AudienceHeadItem> audienceHeadItems = new ArrayList<>();

    private LinearLayout circleImageContainer;

    private CanAdapter<AudienceHeadItem> gridViewAdapter;
    private GridView gridView;

    private int horizontSpace = 0;
    private int itemWidth = 0;

    public CircleImageHorizontScrollView(Context context) {
        this(context,null);
    }

    public CircleImageHorizontScrollView(Context context, AttributeSet attrs) {
        this(context,attrs,0);
    }

    public CircleImageHorizontScrollView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context,attrs,defStyleAttr);
        setFillViewport(true);
        initAttrs(context,attrs);
        initView(context);
    }


    private void initAttrs(Context context, AttributeSet attrs){
        DisplayMetrics dm = getResources().getDisplayMetrics();
        horizontSpace = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, horizontSpace, dm);
        itemWidth = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, itemWidth, dm);

        TypedArray a = context.obtainStyledAttributes(attrs, R.styleable.CircleImageHorizontScrollView);
        horizontSpace = a.getDimensionPixelSize(R.styleable.CircleImageHorizontScrollView_horizontSpace, horizontSpace);
        itemWidth = a.getDimensionPixelSize(R.styleable.CircleImageHorizontScrollView_itemWidth, itemWidth);
    }

    private void initView(Context context){
        //HorizontalScrollView需要有一个直接子view LinearLayout
        circleImageContainer = new LinearLayout(context);
        circleImageContainer.setOrientation(LinearLayout.HORIZONTAL);
        HorizontalScrollView.LayoutParams layoutParams =
                new HorizontalScrollView.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
        layoutParams.gravity = Gravity.CENTER_VERTICAL;
        circleImageContainer.setLayoutParams(layoutParams);
        circleImageContainer.setGravity(Gravity.CENTER_VERTICAL);
        addView(circleImageContainer);

        gridView = (GridView) View.inflate(getContext(),R.layout.item_simple_gridview_1,null);
        gridView.setHorizontalSpacing(horizontSpace);

        LinearLayout.LayoutParams gridViewLp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        gridViewLp.gravity = Gravity.CENTER_VERTICAL|Gravity.RIGHT;
        gridView.setLayoutParams(gridViewLp);
        circleImageContainer.addView(gridView);
        gridView.setGravity(Gravity.CENTER_VERTICAL|Gravity.RIGHT);
        //itemLayoutId布局
        gridViewAdapter = new CanAdapter<AudienceHeadItem>(
                getContext(),R.layout.item_simple_online, audienceHeadItems) {
            @Override
            protected void setView(CanHolderHelper helper, int position, AudienceHeadItem bean) {
                //头像
                CircleImageView civ_userHeader = (CircleImageView) helper.getImageView(R.id.civ_userHeader);
                civ_userHeader.setTag(bean);
                ViewGroup.LayoutParams imageViewLp = civ_userHeader.getLayoutParams();
                imageViewLp.width = itemWidth;
                imageViewLp.height = itemWidth;
                civ_userHeader.setScaleType(ImageView.ScaleType.CENTER_CROP);
                if(!TextUtils.isEmpty(bean.photoUrl)){
//                    Picasso.with(getContext().getApplicationContext())
                    Picasso.get()
                            .load(bean.photoUrl)
                            .noFade()
                            .error(bean.defaultPhotoResId)
                            .memoryPolicy(MemoryPolicy.NO_CACHE)
                            .noPlaceholder()
                            .into(civ_userHeader);

                }else{
//                    Picasso.with(getContext().getApplicationContext())
                    Picasso.get()
                            .load(bean.defaultPhotoResId)
                            .noFade()
                            .into(civ_userHeader);
                }
                //是否购票
                ImageView imgHasTicket = helper.getImageView(R.id.img_has_ticket);
                imgHasTicket.setVisibility(bean.isHasTicket()?VISIBLE:GONE);

            }

            @Override
            protected void setItemListener(CanHolderHelper helper) {}
        };
        gridView.setAdapter(gridViewAdapter);
        gridView.setStretchMode(GridView.NO_STRETCH);
        gridView.setColumnWidth(itemWidth);
        gridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                AudienceHeadItem audienceHeadItem = gridViewAdapter.getList().get(position);
                if(null != listener){
                    listener.onCircleImageClicked(audienceHeadItem.photoUrl);
                }
                Log.d(TAG,"onItemClick-imageUrl:"+audienceHeadItem.photoUrl);
            }
        });
    }

    public synchronized void setList(List<AudienceHeadItem> audienceHeadItems){
        if(null == this.audienceHeadItems){
            this.audienceHeadItems = new ArrayList<>();
        }
        this.audienceHeadItems.clear();
        this.audienceHeadItems.addAll(audienceHeadItems);
        notifyDataSetChanged();
    }

    private void notifyDataSetChanged(){
        int itemNumbs = audienceHeadItems.size();
        int containerWidth = itemWidth*itemNumbs+(itemNumbs-1)*horizontSpace
                +gridView.getPaddingLeft()+gridView.getPaddingRight();
        LinearLayout.LayoutParams gridViewLp = (LinearLayout.LayoutParams) gridView.getLayoutParams();
        gridViewLp.width = containerWidth;
        gridView.setNumColumns(itemNumbs);
        gridViewAdapter.setList(this.audienceHeadItems);
    }

    private OnCircleImageClickListener listener;
    public void setCircleImageClickListener(OnCircleImageClickListener listener){
        this.listener = listener;
    }
    public interface OnCircleImageClickListener{
        void onCircleImageClicked(String url);
    }
}
