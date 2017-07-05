package com.qpidnetwork.liveshow.home.live;

import android.content.Intent;
import android.graphics.Bitmap;
import android.net.Uri;
import android.os.Bundle;
import android.os.Message;
import android.text.TextUtils;
import android.util.Log;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.GridView;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.framework.base.BaseFragmentActivity;
import com.qpidnetwork.framework.canadapter.CanAdapter;
import com.qpidnetwork.framework.canadapter.CanOnItemListener;
import com.qpidnetwork.framework.widget.roundedimageview.RoundedTransformationBuilder;
import com.qpidnetwork.httprequest.OnGetLiveCoverPhotoListCallback;
import com.qpidnetwork.httprequest.OnRequestCallback;
import com.qpidnetwork.httprequest.OnUploadPictureCallback;
import com.qpidnetwork.httprequest.RequestJniLiveShow;
import com.qpidnetwork.httprequest.RequestJniOther;
import com.qpidnetwork.httprequest.item.CoverPhotoItem;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.liveshow.datacache.file.FileCacheManager;
import com.qpidnetwork.liveshow.home.StartLiveFragment;
import com.qpidnetwork.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.liveshow.model.http.UploadPictureResp;
import com.qpidnetwork.utils.ActivityUtil;
import com.qpidnetwork.utils.ImageUtil;
import com.qpidnetwork.view.SimpleDoubleBtnTipsDialog;
import com.qpidnetwork.view.SimpleListPopupWindow;
import com.qpidnetwork.view.SimpleProcessLoadingDialog;
import com.squareup.picasso.Picasso;
import com.squareup.picasso.Transformation;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static com.qpidnetwork.liveshow.LiveApplication.getContext;

/**
 * Description:封面图管理界面
 * <p>
 * Created by Harry on 2017/6/15.
 */

public class CoverManagerActivity extends BaseFragmentActivity {

    private SimpleProcessLoadingDialog loadingDialog;
    private SimpleListPopupWindow slpw_cover;
    private TextView tv_tipMsg;
    private String[] coverPopupItems;
    private CoverPhotoItem[] coverPhotoItems;//审核中或者已审核通过的，审核不通过的不再显示范围内
    private List<CoverPhotoItem> coverPhotoList = new ArrayList<CoverPhotoItem>();
    private final int MSG_WHAT_CROPIMAGE = 5;
    private final int MSG_WHAT_REFRESH_COVERPHOTOLIST_RESP = 6;
    private final int MSG_WHAT_UPLOAD_COVERPHOTO_RESP = 7;
    private final int MSG_WHAT_ADD_COVERPHOTO_RESP = 8;
    private final int MSG_WHAT_DELETE_COVERPHOTO_RESP = 9;
    private final int MSG_WHAT_APPLY_COVERPHOTO_RESP = 10;
    private final int MSG_WHAT_HIDETOAST = 11;
    private final int REQ_CODE_PICKIMAGE = 1;
    private final int REQ_CODE_CROPIMAGE = 2;
    private final int REQ_CODE_CAMERA = 3;

    private GridView gv_coverPhotoList;
    private CanAdapter coverPhotoAdapter = new CoverPhotoAdapter(this,R.layout.item_coverphoto_list,coverPhotoList);
    private CanOnItemListener canOnItemListener = new CanOnItemListener(){
        @Override
        public void onItemChildClick(View view, int position) {
            switch (view.getId()){
                case R.id.iv_delectCoverPhoto:
                    deleteCoverPhotoUnUsing(view.getTag().toString());
                    break;
                case R.id.iv_addCoverPhoto:
                    showCoverChooserPupopWindow();
                    break;
                case R.id.tv_coverUseStatus:
                    applyUsingCoverPhoto(view.getTag().toString());
                    break;
                default:
                    super.onItemChildClick(view, position);
                    break;
            }

        }
    };

    private AdapterView.OnItemClickListener onCoverItemClickListener = new AdapterView.OnItemClickListener() {
        @Override
        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
            switch (position){
                case 0:
                    //Choose from album
                    ActivityUtil.chooseImage(CoverManagerActivity.this,REQ_CODE_PICKIMAGE);
                    break;
                case 1:
                    //Take a photo
                    cameraImagePath = ActivityUtil.startSystemCameraByContentUri(CoverManagerActivity.this,REQ_CODE_CAMERA);
                    Log.d(TAG,"onCoverItemClickListener-cameraImagePath:"+cameraImagePath);
                    break;
                default:
                    break;
            }
            slpw_cover.dismiss();
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        checkCoverPhotoList();
        initView();
        refreshCoverListData();
    }

    private void refreshCoverListData(){
        showLoadingDialog(R.string.tip_loading,false,false);
        RequestJniLiveShow.GetLiveCoverPhotoList(new OnGetLiveCoverPhotoListCallback() {
            @Override
            public void onGetLiveCoverPhotoList(boolean isSuccess, int errCode, String errMsg, CoverPhotoItem[] photoList) {
                HttpRespObject object = new HttpRespObject(isSuccess,errCode,errMsg,photoList);
                Message msg = mHandler.obtainMessage(MSG_WHAT_REFRESH_COVERPHOTOLIST_RESP);
                msg.obj = object;
                sendUiMessage(msg);
            }
        });
    }

    /**
     * 检查服务器返回的封面图列表数量
     */
    private void checkCoverPhotoList(){
        if(null == coverPhotoList && coverPhotoList.size() == 0){
            coverPhotoList.add(new CoverPhotoItem(null,null, 0,false));
        }else if(coverPhotoList.size()<3){
            coverPhotoList.add(new CoverPhotoItem(null,null, 0,false));
        }
    }

    private void initView(){
        setTitle(R.string.txt_manageCover);
        gv_coverPhotoList = (GridView) findViewById(R.id.gv_coverPhotoList);
        coverPhotoAdapter.setOnItemListener(canOnItemListener);
        gv_coverPhotoList.setAdapter(coverPhotoAdapter);
        tv_tipMsg = (TextView) findViewById(R.id.tv_tipMsg);
        tv_tipMsg.setVisibility(View.GONE);
    }


    private String localImagePath = null, cameraImagePath = null;

    /**
     * 加载封面图，并显示圆角，边框
     * @param coverUrl
     * @param ivCover
     * @param borderColorId
     * @param cornetRadiusDp
     * @param borderWidthDp
     */
    public void loadCoverPhotoWithCornerRadiu(String coverUrl, final ImageView ivCover, int borderColorId, int cornetRadiusDp, int borderWidthDp){
        Transformation mTransformation = new RoundedTransformationBuilder()
                .cornerRadiusDp(cornetRadiusDp)
                .borderColor(getResources().getColor(borderColorId))
                .borderWidthDp(borderWidthDp)
                .oval(false)
                .build();
        //Fit cannot be used with a Target.
        Picasso.with(getContext()).load(coverUrl).fit()
            .transform(mTransformation).into(ivCover);
    }

    /**
     * 提示错误信息
     * @param msg
     */
    private void showFailedMsgToast(String msg){
        tv_tipMsg.setText(msg);
        tv_tipMsg.setVisibility(View.VISIBLE);
        sendEmptyUiMessageDelayed(MSG_WHAT_HIDETOAST,getResources().getInteger(R.integer.toast_failed_max_show_time));
    }

    @Override
    protected void handleUiMessage(Message msg) {
        switch (msg.what){
            case MSG_WHAT_HIDETOAST:
                tv_tipMsg.setVisibility(View.GONE);
                break;
            case MSG_WHAT_APPLY_COVERPHOTO_RESP:
                HttpRespObject applyUsingObj = (HttpRespObject) msg.obj;
                if(applyUsingObj.isSuccess){
                    refreshCoverListData();
                }else{
                    dimissLoadingDialog();
                    showFailedMsgToast(applyUsingObj.errMsg);
                }
                break;
            case MSG_WHAT_DELETE_COVERPHOTO_RESP:
                HttpRespObject deleteObj = (HttpRespObject) msg.obj;
                if(deleteObj.isSuccess){
                    refreshCoverListData();
                }else{
                    dimissLoadingDialog();
                    showFailedMsgToast(deleteObj.errMsg);
                }
                break;
            case MSG_WHAT_ADD_COVERPHOTO_RESP:
                HttpRespObject addObj = (HttpRespObject) msg.obj;
                if(addObj.isSuccess){
                    refreshCoverListData();
                }else{
                    dimissLoadingDialog();
                    showFailedMsgToast(addObj.errMsg);
                }
                break;
            case MSG_WHAT_UPLOAD_COVERPHOTO_RESP:
                UploadPictureResp resp = (UploadPictureResp) msg.obj;
                if(resp.isSuccess){
                    addCoverPhoto(resp.photoId);
                }else{
                    dimissLoadingDialog();
                    showFailedMsgToast(resp.errMsg);
                }
                break;
            case MSG_WHAT_REFRESH_COVERPHOTOLIST_RESP:
                HttpRespObject refreshObj = (HttpRespObject) msg.obj;
                dimissLoadingDialog();
                if(refreshObj.isSuccess){
                    coverPhotoItems = (CoverPhotoItem[])refreshObj.data;
                    if(null != coverPhotoItems && coverPhotoItems.length>0){
                        Arrays.sort(coverPhotoItems,new CoverPhotoItemComprator());
                    }
                    coverPhotoList.clear();
                    if(null != coverPhotoItems && coverPhotoItems.length>0){
                        coverPhotoList.addAll(Arrays.asList(coverPhotoItems));
                    }
                    checkCoverPhotoList();
                    updateUsingCoverPhoto();
                }else{
                    showFailedMsgToast(refreshObj.errMsg);
                }
                coverPhotoAdapter.setList(coverPhotoList);
                coverPhotoAdapter.notifyDataSetChanged();
                break;
            case MSG_WHAT_CROPIMAGE:
                Uri inputUri = Uri.fromFile(new File(cameraImagePath));
                localImagePath = FileCacheManager.getInstance().getImagePath()+System.currentTimeMillis()+".jpg";
                Uri outputUri = Uri.fromFile(new File(localImagePath));
                Log.d(TAG,"MSG_WHAT_CROPIMAGE-inputUri:"+inputUri+" outputUri:"+outputUri);
                ActivityUtil.cropImage(this,REQ_CODE_CROPIMAGE,inputUri, outputUri ,true,true,true,
                        1,1,Float.valueOf(getResources().getDimension(R.dimen.coverphoto_min_width)).intValue(),Float.valueOf(getResources().getDimension(R.dimen.coverphoto_min_height)).intValue(), Bitmap.CompressFormat.JPEG.toString(),true,true);
                break;
            default:
                super.handleUiMessage(msg);
                break;
        }
    }

    private String inUsingPhotoId = "";
    private String inUsingPhotoUrl = "";
    private void updateUsingCoverPhoto(){
        if(null != coverPhotoList && coverPhotoList.size()>0){
            for(CoverPhotoItem item : coverPhotoList){
                if(item.isInUse){
                    inUsingPhotoId = item.photoId;
                    inUsingPhotoUrl = item.photoUrl;
                }
            }
        }
    }

    @Override
    public void onBackTitleClicked() {
        Intent data = new Intent();
        data.putExtra("inUsingPhotoId",inUsingPhotoId);
        data.putExtra("inUsingPhotoUrl",inUsingPhotoUrl);
        setResult(StartLiveFragment.RES_CODE_COVERMANAGER,data);
        super.onBackTitleClicked();
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        return super.onKeyDown(keyCode, event);
    }

    private void dimissLoadingDialog(){
        if(null != loadingDialog && loadingDialog.isShowing()){
            loadingDialog.dismiss();
        }
    }

    private void showLoadingDialog(int strId, boolean cancelable, boolean canceledOnTouckOutside){
        dimissLoadingDialog();
        if(null == loadingDialog){
            loadingDialog = new SimpleProcessLoadingDialog(this);
        }
        loadingDialog.setCancelable(cancelable);
        loadingDialog.setCanceledOnTouchOutside(canceledOnTouckOutside);
        loadingDialog.show(strId);
    }

    /**
     * 弹出底部菜单栏
     */
    private void showCoverChooserPupopWindow(){
        if(null == coverPopupItems){
            coverPopupItems = getResources().getStringArray(R.array.coverPopupItems);
        }

        if(null == slpw_cover){
            slpw_cover = new SimpleListPopupWindow(CoverManagerActivity.this.getApplicationContext(),0, ViewGroup.LayoutParams.FILL_PARENT,ViewGroup.LayoutParams.WRAP_CONTENT,ViewGroup.LayoutParams.FILL_PARENT);
            slpw_cover.setViewData(coverPopupItems,0);
            slpw_cover.setItemClickListener(onCoverItemClickListener);
        }
        slpw_cover.showAtLocation(CoverManagerActivity.this.findViewById(R.id.ll_coverManager), Gravity.BOTTOM|Gravity.CENTER_HORIZONTAL,0,0);
    }

    /**
     * 删除未使用的房间封面图
     * @param photoId
     */
    private void deleteCoverPhotoUnUsing(final String photoId){
        showCustomDialog(R.string.txt_cancel, R.string.txt_ok, R.string.txt_sureDeleteCover, true, true, new SimpleDoubleBtnTipsDialog.OnTipsDialogBtnClickListener() {
            @Override
            public void onCancelBtnClick() {
                dismissCustomDialog();
            }

            @Override
            public void onConfirmBtnClick() {
                dismissCustomDialog();
                showLoadingDialog(R.string.tip_deleting,false,false);
                RequestJniLiveShow.DeleteLiveCoverPhoto(photoId, new OnRequestCallback() {
                    @Override
                    public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                        HttpRespObject object = new HttpRespObject(isSuccess,errCode,errMsg,null);
                        Message msg = mHandler.obtainMessage(MSG_WHAT_DELETE_COVERPHOTO_RESP);
                        msg.obj = object;
                        sendUiMessage(msg);
                    }
                });
            }
        });
    }

    /**
     * 切换使用中的房间封面图
     * @param photoId
     */
    private void applyUsingCoverPhoto(final String photoId){
        showLoadingDialog(R.string.tip_updating,false,false);
        RequestJniLiveShow.SetDefaultUsedCoverPhoto(photoId, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                HttpRespObject object = new HttpRespObject(isSuccess,errCode,errMsg,null);
                Message msg = mHandler.obtainMessage(MSG_WHAT_APPLY_COVERPHOTO_RESP);
                msg.obj = object;
                sendUiMessage(msg);
            }
        });
    }

    /**
     * 添加封面图
     * @param photoId
     */
    private void addCoverPhoto(String photoId){
        RequestJniLiveShow.AddLiveCoverPhoto(photoId, new OnRequestCallback() {
            @Override
            public void onRequest(boolean isSuccess, int errCode, String errMsg) {
                Message msg = mHandler.obtainMessage(MSG_WHAT_ADD_COVERPHOTO_RESP);
                msg.obj = new HttpRespObject(isSuccess,errCode,errMsg,null);
                sendUiMessage(msg);
            }
        });
    }

    /**
     * 上传封面图照片到服务器
     * Note: PNG and JPG format only, less than 3MB. Size: 640px * 640px
     */
    private void uploadCoverPhoto(){
        showLoadingDialog(R.string.tip_uploading,false,false);
        RequestJniOther.UploadPicture(RequestJniOther.UploadPhotoType.CoverPhoto,localImagePath, new OnUploadPictureCallback() {
            @Override
            public void onUploadPicture(boolean isSuccess, int errCode, String errMsg, String photoId, String photoUrl) {
                //删除本地的临时文件
                if(!TextUtils.isEmpty(cameraImagePath)){
                    boolean deleteCameraImage = ImageUtil.realDeleteFile(CoverManagerActivity.this, cameraImagePath);
                    Log.d(TAG,"onUploadPicture-deleteCameraImage:"+cameraImagePath+" result:"+deleteCameraImage);
                    cameraImagePath = null;
                }
                if(!TextUtils.isEmpty(localImagePath)){
                    boolean deleteLocalImage = ImageUtil.realDeleteFile(CoverManagerActivity.this, localImagePath);
                    Log.d(TAG,"onUploadPicture-deleteLocalImage:"+localImagePath+" result:"+deleteLocalImage);
                    localImagePath = null;
                }

                //上传成功，获取photoId
                UploadPictureResp resp = new UploadPictureResp(isSuccess,errCode,errMsg,photoId,photoUrl);
                Message msg = mHandler.obtainMessage(MSG_WHAT_UPLOAD_COVERPHOTO_RESP);
                msg.obj = resp;
                sendUiMessage(msg);
            }
        });
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d(TAG,"onActivityResult-requestCode:"+requestCode+" resultCode:"+resultCode);
        if(requestCode == REQ_CODE_PICKIMAGE && null != data || null != data.getData()){
            File localImageFile = null;
            Uri localSelectedPicUri = data.getData();
            cameraImagePath = ImageUtil.getFilePathFromUri(this,localSelectedPicUri);
            Uri localImageUri = null;
            localImagePath = FileCacheManager.getInstance().getImagePath()+System.currentTimeMillis()+".jpg";
            localImageFile = new File(localImagePath);
            localImageUri = Uri.fromFile(localImageFile);
            ActivityUtil.cropImage(this,REQ_CODE_CROPIMAGE,localSelectedPicUri,
                    localImageUri,true,true,true, 1,1,
                    Float.valueOf(getResources().getDimension(R.dimen.coverphoto_min_width)).intValue(),
                    Float.valueOf(getResources().getDimension(R.dimen.coverphoto_min_height)).intValue(),
                    Bitmap.CompressFormat.JPEG.toString(),true,true);
        }else if(requestCode == REQ_CODE_CROPIMAGE){
            //还是有部分照片选择后会出现无法加载的情况
            File localImageFile = new File(localImagePath);
            if(localImageFile.length()>0){
                uploadCoverPhoto();
            }
        }else if(requestCode == REQ_CODE_CAMERA && !TextUtils.isEmpty(cameraImagePath)){
            File cameraImageFile = new File(cameraImagePath);
            if(cameraImageFile.exists()){
                new Thread(){
                    @Override
                    public void run() {
                        ImageUtil.adjustImageDegree(cameraImagePath);
                        sendEmptyUiMessage(MSG_WHAT_CROPIMAGE);
                    }
                }.start();
            }
        }
        super.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public int getActivityViewId() {
        return R.layout.activity_live_cover_manager;
    }
}
