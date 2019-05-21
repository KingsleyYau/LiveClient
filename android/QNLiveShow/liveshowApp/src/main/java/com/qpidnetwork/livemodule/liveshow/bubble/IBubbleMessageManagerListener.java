package com.qpidnetwork.livemodule.liveshow.bubble;

public interface IBubbleMessageManagerListener {

    //通知界面刷新数据
    public void onDataChangeNotify();

    //通知界面增加数据
    public void onDataAdd(BubbleMessageBean bean);

    //通知界面删除
    public void onDataRemove(int startPosition, int count);
}
