package com.qpidnetwork.livemodule.liveshow.sayhi;


import android.os.Message;
import android.view.View;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetAllSayHiListCallback;
import com.qpidnetwork.livemodule.httprequest.item.SayHiAllListInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.SayHiAllListItem;
import com.qpidnetwork.livemodule.httprequest.item.SayHiBaseListItem;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.sayhi.view.SayHiListEmptyView;

import java.util.List;

/**
 * 2019/5/30 Hardy
 * <p>
 * Say Hi 列表 all 标签
 */
public class SayHiListAllFragment extends SayHiBaseListFragment implements OnGetAllSayHiListCallback {

    public SayHiListAllFragment() {
        // Required empty public constructor
    }

    @Override
    protected void initView(View view) {
        super.initView(view);

    }

    @Override
    protected void initData() {
        super.initData();
    }

    @Override
    protected SayHiListEmptyView.EmptyViewType getEmptyViewType() {
        return SayHiListEmptyView.EmptyViewType.VIEW_ALL;
    }

    @Override
    protected void loadListData(boolean isLoadMore, int startSize) {
        LiveRequestOperator.getInstance().GetAllSayHiList(startSize, Default_Step, this);
    }

    @Override
    protected void onListItemClick(SayHiBaseListItem item, int pos) {
        openSayHiDetailAct(item);
    }

    @Override
    protected void openSayHiDetailAct(SayHiBaseListItem item) {
        if (item == null) {
            return;
        }
        // 2019/5/30  跳转详情
        SayHiAllListItem subItem = (SayHiAllListItem) item;
        SayHiDetailsActivity.launch(mContext, subItem.avatar, subItem.nickName, subItem.age, subItem.sayHiId, "");
    }

    @Override
    protected void onItemDataChange() {

    }

    @Override
    public void onGetAllSayHiList(boolean isSuccess, int errCode, String errMsg, SayHiAllListInfoItem allItem) {
        List<SayHiBaseListItem> list = null;

        if (allItem != null) {
            setDataTotalCount(allItem.totalCount);
            list = getFormatDataList(allItem.allList);
        }

        HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, list);

        Message msg = Message.obtain();
        msg.what = GET_LIST_CALLBACK;
        msg.obj = response;

        sendUiMessage(msg);
    }
}
