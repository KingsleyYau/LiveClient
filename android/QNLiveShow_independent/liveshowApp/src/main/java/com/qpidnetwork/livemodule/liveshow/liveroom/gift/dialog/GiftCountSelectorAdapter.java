package com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.view.MotionEvent;
import android.view.View;
import android.widget.Button;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.canadapter.CanAdapter;
import com.qpidnetwork.livemodule.framework.canadapter.CanHolderHelper;

import java.util.List;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/6/28.
 */

public class GiftCountSelectorAdapter extends CanAdapter<Integer> {

    private int selectedPosition = 0;
    private ColorDrawable selectedColorDrawable;
    private ColorDrawable whiteColorDrawable;
    private ColorDrawable grayColorDrawable;
    private Context mContext;

    public void setSelectedPosition(int selectedPosition){
        this.selectedPosition = selectedPosition;
    }

    public GiftCountSelectorAdapter(Context context, int itemLayoutId) {
        super(context, itemLayoutId);
        mContext = context.getApplicationContext();
        selectedColorDrawable = new ColorDrawable(context.getResources().getColor(R.color.list_gift_count_selected));
        whiteColorDrawable = new ColorDrawable(Color.WHITE);
        grayColorDrawable = new ColorDrawable(context.getResources().getColor(R.color.color_giftcount_item));
    }

    @Override
    protected void setView(final CanHolderHelper helper, final int position, Integer bean) {
        final Button btn_giftCount = helper.getView(R.id.btn_giftCount);
//        final View ll_giftCountItem = helper.getView(R.id.ll_giftCountItem);
        boolean isSelected = position == selectedPosition;
        btn_giftCount.setText(String.valueOf(bean));
        final List<Integer> numList = getList();
        if(1 == numList.size()){
            //如何只有一个，那么默认选中
            btn_giftCount.setBackgroundDrawable(
                    mContext.getResources().getDrawable(R.drawable.bg_live_buttom_gift_count_list_single_green));
        }else if(position == 0){//是第一个,选中则高亮，否则白色
            btn_giftCount.setBackgroundDrawable(
                    mContext.getResources().getDrawable(
                            isSelected ? R.drawable.bg_live_buttom_gift_count_list_top_green :
                                    R.drawable.bg_live_buttom_gift_count_list_top_white));
        }else if(position == (numList.size()-1)){//是最后一个,选中则高亮，否则白色
            btn_giftCount.setBackgroundDrawable(
                    mContext.getResources().getDrawable(
                            isSelected ? R.drawable.bg_live_buttom_gift_count_list_buttom_green :
                                    R.drawable.bg_live_buttom_gift_count_list_buttom_white));
        }else if(position>0 && position<(numList.size()-1)){//中间的
            btn_giftCount.setBackgroundDrawable(
                    isSelected ? selectedColorDrawable : whiteColorDrawable);
        }

        btn_giftCount.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if(position == selectedPosition || 1 == numList.size()){
                    return false;
                }
                boolean isPressed = false;
                switch (event.getAction()){
                    case MotionEvent.ACTION_DOWN:
                        isPressed = true;
                        break;
                    case MotionEvent.ACTION_UP:
                        isPressed = false;
                        break;
                }
                if(position == 0){//是第一个,选中则高亮，否则白色
                    btn_giftCount.setBackgroundDrawable(
                            mContext.getResources().getDrawable(
                                    isPressed ? R.drawable.bg_live_buttom_gift_count_list_top_grary :
                                            R.drawable.bg_live_buttom_gift_count_list_top_white));
                }else if(position == (numList.size()-1)){//是最后一个,选中则高亮，否则白色
                    btn_giftCount.setBackgroundDrawable(
                            mContext.getResources().getDrawable(
                                    isPressed ? R.drawable.bg_live_buttom_gift_count_list_buttom_grary :
                                            R.drawable.bg_live_buttom_gift_count_list_buttom_white));
                }else if(position>0 && position<(numList.size()-1)){//中间的
                    btn_giftCount.setBackgroundDrawable(
                            isPressed ? grayColorDrawable : whiteColorDrawable);
                }
                return false ;
            }
        });
    }

    @Override
    protected void setItemListener(CanHolderHelper helper) {
        helper.setItemChildClickListener(R.id.btn_giftCount);
    }
}
