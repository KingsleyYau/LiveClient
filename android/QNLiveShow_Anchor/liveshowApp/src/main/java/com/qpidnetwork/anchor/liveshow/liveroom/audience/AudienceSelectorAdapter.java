package com.qpidnetwork.anchor.liveshow.liveroom.audience;

import android.content.Context;
import android.widget.Button;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.canadapter.CanAdapter;
import com.qpidnetwork.anchor.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.anchor.httprequest.item.AudienceInfoItem;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/6/28.
 */

public class AudienceSelectorAdapter extends CanAdapter<AudienceInfoItem> {

    public AudienceSelectorAdapter(Context context, int itemLayoutId) {
        super(context, itemLayoutId);
    }

    @Override
    protected void setView(final CanHolderHelper helper, final int position, AudienceInfoItem bean) {
        final Button btn_userNickName = helper.getView(R.id.btn_userNickName);
        btn_userNickName.setText(bean.nickName);
    }

    @Override
    protected void setItemListener(CanHolderHelper helper) {
        helper.setItemChildClickListener(R.id.btn_userNickName);
    }
}
