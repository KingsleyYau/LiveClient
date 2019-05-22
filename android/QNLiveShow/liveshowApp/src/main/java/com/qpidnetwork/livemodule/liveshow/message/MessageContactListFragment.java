package com.qpidnetwork.livemodule.liveshow.message;

import android.app.Activity;
import android.os.Bundle;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseListFragment;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.livemessage.LMLiveRoomEventListener;
import com.qpidnetwork.livemodule.livemessage.LMManager;
import com.qpidnetwork.livemodule.livemessage.item.LMPrivateMsgContactItem;
import com.qpidnetwork.livemodule.livemessage.item.LiveMessageItem;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.home.MainFragmentPagerAdapter4Top;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

/**
 * Created by Hunter on 18/7/19.
 */

public class MessageContactListFragment extends BaseListFragment implements LMLiveRoomEventListener {

    private MessageContactAdapter mAdapter;
    private List<LMPrivateMsgContactItem> mContactList;

    private boolean mIsNeedRefreshContact = true;

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        mContactList = new ArrayList<LMPrivateMsgContactItem>();
        mAdapter = new MessageContactAdapter(getActivity(), mContactList);
        mAdapter.setOnContactItemClickListener(new MessageContactAdapter.OnContactItemClickListener() {
            @Override
            public void onContactItemClick(LMPrivateMsgContactItem item) {
                ChatTextActivity.launchChatTextActivity(getActivity(), item.userId, item.nickName);
            }
        });
        getPullToRefreshListView().setAdapter(mAdapter);

        //关闭上啦刷新
        closePullUpRefresh(true);

//        //刷新列表，显示菊花，解决setUserVisibleHint比onCreateView先执行，导致loading未加载完成无法显示
//        showLoadingProcess();

        //获取本地数据刷新
        refreshContactList();
        //绑定私信监听事件
        LMManager.getInstance().registerLMLiveRoomEventListener(this);
    }


    @Override
    public void onResume() {
        super.onResume();
//        if(mIsNeedRefreshContact){
//            //与服务器同步联系人列表未成功，重新同步
//            queryContactList();
//        }

        //edit by Jagger 2018-8-31
        //测试妹妹说返回列表，人的顺序没有改变。　所以改为全刷新 BUG#13583
        queryContactList();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        //解除私信事件监听
//        LMManager.getInstance().registerLMLiveRoomEventListener(this);

        // 2018/11/6 Hardy
        LMManager.getInstance().unregisterLMLiveRoomEventListener(this);
    }

    @Override
    protected void onDefaultEmptyGuide() {
        super.onDefaultEmptyGuide();
        //点击空页引导，跳转回主页
//        MainFragmentActivity.launchActivityWithListType(getActivity(), 0);
        MainFragmentActivity.launchActivityWithListType(getActivity(), MainFragmentPagerAdapter4Top.TABS.TAB_INDEX_DISCOVER);
    }

    /**
     * 显示无数据页
     */
    private void showEmptyView(){
        setDefaultEmptyMessage(getResources().getString(R.string.message_contactlist_empty_desc));
        setDefaultEmptyButtonText(getResources().getString(R.string.live_common_btn_search));//无按钮，隐藏
        showNodataPage();
    }

    /**
     * 下拉刷新
     */
    @Override
    public void onPullDownToRefresh() {
        super.onPullDownToRefresh();
        //下拉刷新
        if(!queryContactList()){
            onRefreshComplete();
        }
    }

    @Override
    public void onReloadDataInEmptyView() {
        super.onReloadDataInEmptyView();
        queryContactList();
    }

    /**
     * 刷新试聊券列表
     */
    private boolean queryContactList(){
        return  LMManager.getInstance().GetPrivateMsgFriendList();
    }

    /**
     * 读取本地缓存数据，刷新联系人列表
     */
    private void refreshContactList(){
        LMManager manager = LMManager.getInstance();
        LMPrivateMsgContactItem[] contactArray = manager.GetLocalPrivateMsgFriendList();
        if(contactArray != null){
            mContactList.clear();
            mContactList.addAll(Arrays.asList(contactArray));
            mAdapter.notifyDataSetChanged();
        }
    }

    /**
     * 测试数据
     * @return
     */
    private  LMPrivateMsgContactItem[] createTest(){
        long day=(60*60*24)*1000;
        long now = new Date().getTime();
        LMPrivateMsgContactItem[] contactArray = new LMPrivateMsgContactItem[6];
        contactArray[0] = new LMPrivateMsgContactItem("111", "Jenny", "", 2, "Hello , how are you!", (int)(now/1000), 0, true);
        contactArray[1] = new LMPrivateMsgContactItem("222", "Nicky", "", 1, "Hello , how are you! You are so beautiful", (int)((now - day)/1000), 0, true);
        contactArray[2] = new LMPrivateMsgContactItem("333", "Hello name Test", "", 2, "Hello , how are you!", (int)((now - 3 * day)/1000), 5, true);
        contactArray[3] = new LMPrivateMsgContactItem("444", "Henry", "", 1, "Hello , how are you! You are so beautiful", (int)((now - 7 * day)/1000), 5, true);
        contactArray[4] = new LMPrivateMsgContactItem("555", "Hello name Test Hello name Test Hello name Test", "", 2, "Hello , how are you!", (int)((now - 3 * day)/1000), 1000, true);
        contactArray[5] = new LMPrivateMsgContactItem("666", "Test", "", 1, "Hello , how are you! You are so beautiful hhhhhhhhello , how are you! You are so beautiful", (int)((now - 7 * day)/1000), 1000, true);
        return contactArray;
    }

    /**************************************  私信事件监听器  ******************************************/
    @Override
    public void OnUpdateFriendListNotice(final boolean success, HttpLccErrType errType, String errMsg) {
        //联系人列表回调
        Activity acitity = getActivity();
        if(acitity != null){
            acitity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if(success){
                        mIsNeedRefreshContact = false;
                        //获取本地联系人列表刷新
                        refreshContactList();

                        //请求返回增加数据空页逻辑
                        if(mContactList.size() <= 0 ){
                            showEmptyView();
                        }else{
                            hideNodataPage();
                        }
                    }
                    //刷新返回
                    onRefreshComplete();
                }
            });
        }
    }

    @Override
    public void OnRefreshPrivateMsgWithUserId(boolean success, HttpLccErrType errType, String errMsg, String userId, LiveMessageItem[] messageList, int reqId) {

    }

    @Override
    public void OnGetMorePrivateMsgWithUserId(boolean success, HttpLccErrType errType, String errMsg, String userId, LiveMessageItem[] messageList, int reqId, boolean isMuchMore) {

    }

    @Override
    public void OnUpdatePrivateMsgWithUserId(String userId, LiveMessageItem[] messageList) {

    }

    @Override
    public void OnSendPrivateMessage(boolean success, IMClientListener.LCC_ERR_TYPE errType, String errMsg, String userId, LiveMessageItem messageItem) {

    }

    @Override
    public void OnRecvUnReadPrivateMsg(LiveMessageItem messageItem) {

    }

    @Override
    public void OnRepeatSendPrivateMsgNotice(String userId, LiveMessageItem[] messageList) {

    }
}
