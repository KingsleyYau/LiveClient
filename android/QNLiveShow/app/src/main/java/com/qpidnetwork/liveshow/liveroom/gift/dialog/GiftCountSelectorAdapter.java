package com.qpidnetwork.liveshow.liveroom.gift.dialog;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.widget.TextView;

import com.qpidnetwork.framework.canadapter.CanAdapter;
import com.qpidnetwork.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.liveshow.R;

import java.util.List;

import static com.qpidnetwork.utils.DisplayUtil.getResources;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/6/28.
 */

public class GiftCountSelectorAdapter extends CanAdapter<String> {

    private int selectedPosition = 0;
    private ColorDrawable selectedColorDrawable;
    private ColorDrawable whiteColorDrawable;

    public void setSelectedPosition(int selectedPosition){
        this.selectedPosition = selectedPosition;
    }

    public GiftCountSelectorAdapter(Context context, int itemLayoutId, List<String> mList) {
        super(context, itemLayoutId, mList);
        selectedColorDrawable = new ColorDrawable(getResources().getColor(R.color.list_gift_count_selected));
        whiteColorDrawable = new ColorDrawable(Color.WHITE);
    }

    @Override
    protected void setView(CanHolderHelper helper, int position, String bean) {
        TextView text1 = helper.getTextView(android.R.id.text1);
        text1.setText(bean);
        text1.setBackgroundDrawable(position == selectedPosition ? selectedColorDrawable : whiteColorDrawable);
        text1.setSelected(position == selectedPosition);
    }

    @Override
    protected void setItemListener(CanHolderHelper helper) {
        helper.setItemChildClickListener(android.R.id.text1);
    }
}
