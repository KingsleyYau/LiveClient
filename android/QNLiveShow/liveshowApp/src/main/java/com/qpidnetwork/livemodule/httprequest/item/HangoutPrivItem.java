package com.qpidnetwork.livemodule.httprequest.item;

/**
 * Created by Hunter Mun on 2017/5/17.
 */

public class HangoutPrivItem {

	public HangoutPrivItem(){

	}

	/**
	 * LiveChat相关
     * @param isHangoutPriv            Hangout总权限（false：禁止，true：正常，默认：false）
	 */
    public HangoutPrivItem(
            boolean isHangoutPriv
            ) {
        this.isHangoutPriv = isHangoutPriv;
    }

    // Hangout总权限（false：禁止，true：正常，默认：false）
    public boolean isHangoutPriv;

}
