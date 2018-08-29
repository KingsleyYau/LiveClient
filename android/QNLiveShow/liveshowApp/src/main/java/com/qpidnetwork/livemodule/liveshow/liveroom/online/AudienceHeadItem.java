package com.qpidnetwork.livemodule.liveshow.liveroom.online;

import com.qpidnetwork.livemodule.R;

/**
 * Description:观众头像列表信息
 * <p>
 * Created by Harry on 2018/2/8.
 */

public class AudienceHeadItem {
    /**
     * 占位默认头像资源id
     */
    public static final int DEFAULT_ID_PLACEHOLDER = R.drawable.ic_default_photo_man_placeholder;
    /**
     * 用户默认头像资源id
     */
    public static final int DEFAULT_ID_AUDIENCEHEAD = R.drawable.ic_default_photo_man;
    /**
     * 用户实际头像url
     */
    public String photoUrl = null;
    /**
     * 非正常情况下默认头像对应的资源ID
     */
    public int defaultPhotoResId = DEFAULT_ID_PLACEHOLDER;

    public AudienceHeadItem(String photoUrl,int defaultPhotoResId){
        this.photoUrl = photoUrl;
        this.defaultPhotoResId = defaultPhotoResId;
    }

    /**
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
