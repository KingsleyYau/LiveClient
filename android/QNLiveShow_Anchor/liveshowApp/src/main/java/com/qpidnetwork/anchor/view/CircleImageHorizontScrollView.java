package com.qpidnetwork.anchor.view;

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
 * Description:
 * <p>
 * Created by Harry on 2017/8/21.
 */

public class CircleImageHorizontScrollView extends HorizontalScrollView {

    private final String TAG = CircleImageHorizontScrollView.class.getSimpleName();

    private List<CircleImageObj> imageUrlList = new ArrayList<>();

    private LinearLayout circleImageContainer;

    private CanAdapter<CircleImageObj> gridViewAdapter;
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
        layoutParams.gravity = Gravity.CENTER_VERTICAL|Gravity.LEFT;
        circleImageContainer.setLayoutParams(layoutParams);
        circleImageContainer.setGravity(Gravity.CENTER_VERTICAL);
        addView(circleImageContainer);

        gridView = (GridView)View.inflate(getContext(),R.layout.item_simple_gridview_1,null);
        gridView.setHorizontalSpacing(horizontSpace);

        LinearLayout.LayoutParams gridViewLp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        gridViewLp.gravity = Gravity.CENTER_VERTICAL|Gravity.LEFT;
        gridView.setLayoutParams(gridViewLp);
        circleImageContainer.addView(gridView);
        gridView.setGravity(Gravity.CENTER_VERTICAL);
        //itemLayoutId布局
        gridViewAdapter = new CanAdapter<CircleImageObj>(
                getContext(),R.layout.item_simple_online,imageUrlList) {
            @Override
            protected void setView(CanHolderHelper helper, int position, CircleImageObj bean) {
                CircleImageView civ_userHeader = (CircleImageView) helper.getImageView(R.id.civ_userHeader);
                ViewGroup.LayoutParams imageViewLp = civ_userHeader.getLayoutParams();
                imageViewLp.width = itemWidth;
                imageViewLp.height = itemWidth;
                civ_userHeader.setScaleType(ImageView.ScaleType.CENTER_CROP);
                if(!TextUtils.isEmpty(bean.imgUrl)){
                    if(null == civ_userHeader.getTag() || !civ_userHeader.getTag().toString().equals(bean.imgUrl)){
                        Picasso.with(getContext().getApplicationContext())
                                .load(bean.imgUrl).noFade()
                                .placeholder(R.drawable.ic_default_photo_man)
                                .error(R.drawable.ic_default_photo_man)
                                .memoryPolicy(MemoryPolicy.NO_CACHE)
                                .into(civ_userHeader);
                        civ_userHeader.setTag(bean.imgUrl);
                    }
                }else{
                    Picasso.with(getContext().getApplicationContext())
                            .load(R.drawable.ic_default_blank_photo).noFade()
                            .noPlaceholder()
                            .into(civ_userHeader);
                    civ_userHeader.setTag(null);
                }
                //add by Jagger 2018-5-4
                //是否购票
                ImageView imgHasTicket = helper.getImageView(R.id.img_has_ticket);
                imgHasTicket.setVisibility(bean.isHasTicket()?VISIBLE:GONE);
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
                CircleImageObj obj = gridViewAdapter.getList().get(position);
                if(null != listener){
                    listener.onCircleImageClicked(obj);
                }
                Log.d(TAG,"onItemClick-imageUrl:"+obj.imgUrl);
            }
        });
    }

    public synchronized void addOnLinePerson(CircleImageObj obj){
        if(null == imageUrlList){
            imageUrlList = new ArrayList<>();
        }
        imageUrlList.add(obj);
        notifyDataSetChanged();
    }

    public synchronized void deleteOnLinePerson(){
        if(null != imageUrlList && imageUrlList.size()>0){
            imageUrlList.remove(imageUrlList.size()-1);
        }
        notifyDataSetChanged();
    }

    public synchronized void setList(List<CircleImageObj> datas){
        if(null == imageUrlList){
            imageUrlList = new ArrayList<>();
        }
        this.imageUrlList.clear();
        imageUrlList.addAll(datas);
        notifyDataSetChanged();
    }

    public int getListNum(){
        return null == imageUrlList ? 0 : imageUrlList.size();
    }

    private void notifyDataSetChanged(){
        int itemNumbs = imageUrlList.size();
        int containerWidth = itemWidth*itemNumbs+(itemNumbs-1)*horizontSpace
                +gridView.getPaddingLeft()+gridView.getPaddingRight();
        LinearLayout.LayoutParams gridViewLp = (LinearLayout.LayoutParams) gridView.getLayoutParams();
        gridViewLp.width = containerWidth;
        gridView.setNumColumns(itemNumbs);
        gridViewAdapter.setList(imageUrlList);
    }

    private OnCircleImageClickListener listener;
    public void setCircleImageClickListener(OnCircleImageClickListener listener){
        this.listener = listener;
    }
    public interface OnCircleImageClickListener{
        void onCircleImageClicked(CircleImageObj obj);
    }

    public class CircleImageObj{
        public String imgUrl;
        public Object obj;

        public CircleImageObj(String imgUrl,Object obj){
            this.imgUrl = imgUrl;
            this.obj = obj;
        }

        /**
         * add by Jagger 2018-5-4
         * 是否已购票
         */
        private boolean isHasTicket ;

        public boolean isHasTicket() {
            return isHasTicket;
        }

        public void setHasTicket(boolean hasTicket) {
            isHasTicket = hasTicket;
        }
    }

}
