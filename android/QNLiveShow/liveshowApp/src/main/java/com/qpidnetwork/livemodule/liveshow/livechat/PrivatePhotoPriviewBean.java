package com.qpidnetwork.livemodule.liveshow.livechat;


import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

/**
 * 封装以便实现Activity间传递
 *
 * @author Hunter
 */
public class PrivatePhotoPriviewBean implements Serializable {

    private static final long serialVersionUID = 8227109403765824646L;

    public List<IdBean> msgList;

    public int currPosition;

    public String anchorId;

    public PrivatePhotoPriviewBean() {
        currPosition = 0;
        msgList = new ArrayList<>();
        anchorId = "";
    }

    public PrivatePhotoPriviewBean(int currPosition, List<IdBean> msgList) {
        this.msgList = msgList;
        this.currPosition = currPosition;
    }

    /**
     * 2019/5/6 Hardy
     */
    public static class IdBean implements Serializable {
        private static final long serialVersionUID = 4522962061873297031L;

        public String userId;
        public int msgId;

        /**
         *
         * @param userId 主播ID
         * @param msgId
         */
        public IdBean(String userId, int msgId) {
            this.userId = userId;
            this.msgId = msgId;
        }
    }
}
