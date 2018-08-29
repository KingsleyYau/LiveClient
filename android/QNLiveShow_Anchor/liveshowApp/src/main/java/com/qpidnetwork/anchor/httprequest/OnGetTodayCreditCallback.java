package com.qpidnetwork.anchor.httprequest;


public interface OnGetTodayCreditCallback {
	/*
	 * @param monthCredit           本月产出数
	 * @param monthCompleted       	本月开播已完成天数
	 * @param monthTarget       	本月开播计划天数
	 * @param monthProgress      	本月已开播进度（整型）（取值范围为0-100）
	 */
	public void onGetTodayCredit(boolean isSuccess, int errCode, String errMsg, int monthCredit, int monthCompleted, int monthTarget, int monthProgress);
}
