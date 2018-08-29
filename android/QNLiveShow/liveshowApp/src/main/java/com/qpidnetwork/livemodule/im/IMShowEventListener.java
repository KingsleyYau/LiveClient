package com.qpidnetwork.livemodule.im;

import com.qpidnetwork.livemodule.im.listener.IMClientListener;
import com.qpidnetwork.livemodule.im.listener.IMProgramInfoItem;

/**
 * Created by Hunter on 18/4/24.
 */

public interface IMShowEventListener {

    /**
     * 11.1.节目开播通知
     * @param showinfo
     * @param type
     * @param msg
     */
    public void OnRecvProgramPlayNotice(IMProgramInfoItem showinfo, IMClientListener.IMProgramPlayType type, String msg);

    /**
     * 11.2.节目取消通知
     * @param showinfo
     */
    public void OnRecvCancelProgramNotice(IMProgramInfoItem showinfo);

    /**
     * 11.3.接收节目已退票通知
     * @param showinfo
     * @param leftCredit
     */
    public void OnRecvRetTicketNotice(IMProgramInfoItem showinfo, double leftCredit);

}
