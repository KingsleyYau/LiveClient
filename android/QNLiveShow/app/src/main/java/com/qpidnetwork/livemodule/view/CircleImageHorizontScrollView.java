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
import com.qpidnetwork.livemodule.liveshow.LiveApplication;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.Log;
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

    private List<String> imageUrlList = new ArrayList<>();

    private LinearLayout circleImageContainer;

    private CanAdapter<String> gridViewAdapter;
    private GridView gridView;

    private int horizontSpace = 0;
    private int itemWidth = 0;
    private int showItemNumb = 0;

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
        showItemNumb = a.getInteger(R.styleable.CircleImageHorizontScrollView_showItemNumb,showItemNumb);
    }

    private void initView(Context context){
        //HorizontalScrollView需要有一个直接子view LinearLayout
        circleImageContainer = new LinearLayout(context);
        circleImageContainer.setOrientation(LinearLayout.HORIZONTAL);
        HorizontalScrollView.LayoutParams layoutParams =
                new HorizontalScrollView.LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
        layoutParams.gravity = Gravity.CENTER_VERTICAL|Gravity.LEFT;
        circleImageContainer.setLayoutParams(layoutParams);
        addView(circleImageContainer);
    }

    public synchronized void addOnLinePerson(String imgUrl){
        if(null == imageUrlList){
            imageUrlList = new ArrayList<>();
        }
        imageUrlList.add(imgUrl);
        notifyDataSetChanged();
    }

    public synchronized void deleteOnLinePerson(){
        if(null != imageUrlList && imageUrlList.size()>0){
            imageUrlList.remove(imageUrlList.size()-1);
        }
        notifyDataSetChanged();
    }

    public synchronized void setList(List<String> datas){
        if(null == imageUrlList){
            imageUrlList = new ArrayList<>();
        }
        this.imageUrlList.clear();
        imageUrlList.addAll(datas);
        notifyDataSetChanged();
    }

    //TODO:DELETE
    public int getListNum(){
        return null == imageUrlList ? 0 : imageUrlList.size();
    }

    private void notifyDataSetChanged(){
        circleImageContainer.removeAllViews();
        int itemNumbs = imageUrlList.size();
        int paddingDp = DisplayUtil.dip2px(getContext(),2f);
        gridView = (GridView)View.inflate(getContext(),R.layout.item_simple_gridview_1,null);
        gridView.setPadding(paddingDp,paddingDp,paddingDp,paddingDp);
        gridView.setHorizontalSpacing(horizontSpace);
        int containerWidth = itemWidth*itemNumbs+(itemNumbs-1)*horizontSpace
                +gridView.getPaddingLeft()+gridView.getPaddingRight();
        LinearLayout.LayoutParams gridViewLp = new LinearLayout.LayoutParams(
                containerWidth, ViewGroup.LayoutParams.MATCH_PARENT);
        gridViewLp.width =containerWidth;
        gridViewLp.gravity = Gravity.CENTER_VERTICAL|Gravity.LEFT;
        gridView.setLayoutParams(gridViewLp);
        circleImageContainer.addView(gridView);
        //itemLayoutId布局
        gridViewAdapter = new CanAdapter<String>(
                getContext(),R.layout.item_simple_online,imageUrlList) {
            @Override
            protected void setView(CanHolderHelper helper, int position, String bean) {
                CircleImageView civ_userHeader = (CircleImageView) helper.getImageView(R.id.civ_userHeader);
                civ_userHeader.setTag(bean);
                ViewGroup.LayoutParams imageViewLp = civ_userHeader.getLayoutParams();
                imageViewLp.width = itemWidth;
                imageViewLp.height = itemWidth;
                civ_userHeader.setScaleType(ImageView.ScaleType.CENTER_CROP);
                if(!TextUtils.isEmpty(bean)){
                    Picasso.with(LiveApplication.getContext())
                            .load(bean).noFade()
                            .into(civ_userHeader);
                }
            }

            @Override
            protected void setItemListener(CanHolderHelper helper) {}
        };
        gridView.setAdapter(gridViewAdapter);
        gridView.setStretchMode(GridView.STRETCH_SPACING);
        gridView.setColumnWidth(itemWidth);
        gridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                String imageUrl = gridViewAdapter.getList().get(position);
                if(null != listener){
                    listener.onCircleImageClicked(imageUrl);
                }
                Log.d(TAG,"onItemClick-imageUrl:"+imageUrl);
            }
        });
        gridView.setNumColumns(itemNumbs);
        int parentWidth = itemWidth*showItemNumb;
        ViewGroup.LayoutParams parentLp = getLayoutParams();
        parentLp.width =parentWidth;
        setLayoutParams(parentLp);
    }

    private OnCircleImageClickListener listener;
    public void setCircleImageClickListener(OnCircleImageClickListener listener){
        this.listener = listener;
    }
    public interface OnCircleImageClickListener{
        void onCircleImageClicked(String url);
    }
}
