package com.qpidnetwork.livemodule.liveshow.sayhi;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.GridLayoutManager;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.SimpleItemAnimator;
import android.text.TextUtils;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.SlidingDrawer;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetSayHiResourceConfigCallback;
import com.qpidnetwork.livemodule.httprequest.OnSendSayHiCallback;
import com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.httprequest.item.LiveRoomListItem;
import com.qpidnetwork.livemodule.httprequest.item.SayHiResourceConfigItem;
import com.qpidnetwork.livemodule.httprequest.item.SayHiSendInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.SayHiTextItem;
import com.qpidnetwork.livemodule.httprequest.item.SayHiThemeItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.liveshow.manager.FollowManager;
import com.qpidnetwork.livemodule.liveshow.manager.URL2ActivityManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.liveshow.sayhi.adapter.SayHiNoteAdapter;
import com.qpidnetwork.livemodule.liveshow.sayhi.adapter.SayHiThemeAdapter;
import com.qpidnetwork.livemodule.liveshow.sayhi.view.MultipleBtnDialogFactory;
import com.qpidnetwork.livemodule.liveshow.urlhandle.AppUrlHandler;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.view.ButtonRaised;
import com.qpidnetwork.livemodule.view.dialog.CommonMultipleBtnTipDialog;
import com.qpidnetwork.qnbridgemodule.urlRouter.LiveUrlBuilder;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;
import com.qpidnetwork.qnbridgemodule.view.SlidingDrawerEx;

import java.util.Arrays;

import io.reactivex.functions.Consumer;

import static com.qpidnetwork.livemodule.liveshow.sayhi.view.MultipleBtnDialogFactory.TAB_BTN_FOLLOW;
import static com.qpidnetwork.livemodule.liveshow.sayhi.view.MultipleBtnDialogFactory.TAB_BTN_MAIL;

/**
 * SayHi编译页
 * @author Jagger 2019-5-29
 */
public class SayHiEditActivity extends BaseActionBarFragmentActivity {

    private final int TAB_THEME_INDEX = 1;
    private final int TAB_NOTE_INDEX = 2;
    //请求返回
    private final int GET_SAYHI_CONFIG_CALLBACK = 1;
    private final int SEND_SAYHI_CALLBACK = 2;
    //参数
    private static final String ANCHOR_ID = "anchorId";
    private static final String ANCHOR_NAME = "anchorName";

    //控件
    private SimpleDraweeView img_bg;
    private SlidingDrawerEx sd_content;
    private LinearLayout ll_tab_theme, ll_tab_note;
    private View v_line1;
    private ImageView img_theme, img_note;
    private TextView tv_theme, tv_note;
    private FrameLayout fl_theme, fl_note;
    private RecyclerView rv_theme, rv_note;
    private TextView tv_anchor_name, tv_note_content, tv_man_name;
    private ButtonRaised btn_book;
    private CommonMultipleBtnTipDialog mDialogResult;

    //变量
    private int mDrawerSelectedIndex = TAB_THEME_INDEX;
    private SayHiThemeAdapter mThemeAdapter;
    private SayHiNoteAdapter mNoteAdapter;
    private String mAnchorId = "";
    private String mAnchorName = "";
    private int mThemeLastSelectIndex = 2, mNoteLastSelectIndex = 2;
    private String mThemeId, mNoteId;
    private LocalPreferenceManager mLocalPreferenceManager;
    private CommonMultipleBtnTipDialog.OnDialogItemClickListener mErrorDialogItemListener;

    public static void startAct(Context context, String anchorId, String anchorName) {
        Intent intent = new Intent(context, SayHiEditActivity.class);
        intent.putExtra(ANCHOR_ID, anchorId);
        intent.putExtra(ANCHOR_NAME, anchorName);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_say_hi_edit);
        initData();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if(mDialogResult != null){
            mDialogResult.destroy();
        }
    }

    @Override
    protected void initCustomView() {
        super.initCustomView();

        //title
        setTitle(getString(R.string.say_hi_edit_title), R.color.black);

        //背景图
        img_bg = findViewById(R.id.img_bg);
        img_bg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                closeDrawer();
            }
        });

        //文字内容
        tv_anchor_name = findViewById(R.id.tv_anchor_name);
        tv_note_content = findViewById(R.id.tv_note_content);
//        tv_note_content.setMovementMethod(ScrollingMovementMethod.getInstance());   //可滚
        tv_note_content.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                closeDrawer();
            }
        });
        tv_man_name = findViewById(R.id.tv_man_name);
        tv_man_name.setText(LoginManager.getInstance().getLoginItem().nickName);

        //抽屉把手
        img_theme = findViewById(R.id.img_theme);
        img_note = findViewById(R.id.img_note);
        tv_theme = findViewById(R.id.tv_theme);
        tv_note = findViewById(R.id.tv_note);
        v_line1 = findViewById(R.id.v_line1);
        ll_tab_theme = findViewById(R.id.ll_tab_theme);
        ll_tab_theme.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                onTabSelected(TAB_THEME_INDEX);
            }
        });
        ll_tab_note = findViewById(R.id.ll_tab_note);
        ll_tab_note.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                onTabSelected(TAB_NOTE_INDEX);
            }
        });

        //抽屉
        sd_content = findViewById(R.id.sd_content);
        sd_content.setTouchableIds(R.id.ll_tab_theme, R.id.ll_tab_note);
        sd_content.setOnDrawerOpenListener(new SlidingDrawer.OnDrawerOpenListener() {
            @Override
            public void onDrawerOpened() {
                if(mDrawerSelectedIndex == TAB_THEME_INDEX){
                    setSelectedThemeUI();
                }else if(mDrawerSelectedIndex == TAB_NOTE_INDEX){
                    setSelectedNoteUI();
                }
            }
        });
        sd_content.setOnDrawerCloseListener(new SlidingDrawer.OnDrawerCloseListener() {
            @Override
            public void onDrawerClosed() {
                resetDrawerHandlerUI();
            }
        });

        //抽屉内容（列表)
        fl_theme = findViewById(R.id.fl_theme);
        fl_note = findViewById(R.id.fl_note);
        rv_theme = findViewById(R.id.rv_theme);
        rv_note = findViewById(R.id.rv_note);

        //主题列表
        mThemeAdapter = new SayHiThemeAdapter(mContext);
        mThemeAdapter.setOnThemeItemEventListener(new SayHiThemeAdapter.OnThemeItemEventListener() {
            @Override
            public void onThemeClicked(SayHiThemeItem themeItem) {
                mThemeId = themeItem.themeId;
                FrescoLoadUtil.loadUrl(img_bg, themeItem.bigImg, DisplayUtil.getActivityHeight(mContext));
                closeDrawer();
            }
        });
        GridLayoutManager manager = new GridLayoutManager(this, 2, GridLayoutManager.VERTICAL, false);
        rv_theme.setLayoutManager(manager);
        rv_theme.setAdapter(mThemeAdapter);
        ((SimpleItemAnimator)(rv_theme.getItemAnimator())).setSupportsChangeAnimations(false);  //取消itemChange动画

        //Note列表
        mNoteAdapter = new SayHiNoteAdapter(mContext);
        mNoteAdapter.setOnNoteItemEventListener(new SayHiNoteAdapter.OnNoteItemEventListener() {
            @Override
            public void onNoteClicked(SayHiTextItem textItem) {
                mNoteId = textItem.textId;
                tv_note_content.setText(textItem.text);
                tv_note_content.scrollTo(0,0);//滚回最顶
                closeDrawer();
            }
        });
        LinearLayoutManager managerNote = new LinearLayoutManager(this, LinearLayoutManager.VERTICAL, false);
        rv_note.setLayoutManager(managerNote);
        rv_note.setAdapter(mNoteAdapter);
        ((SimpleItemAnimator)(rv_note.getItemAnimator())).setSupportsChangeAnimations(false);   //取消itemChange动画

        //发送
        btn_book = findViewById(R.id.btn_book);
        btn_book.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(!TextUtils.isEmpty(mThemeId) && !TextUtils.isEmpty(mNoteId)){
                    //保存
                    mLocalPreferenceManager.saveSayHiThemeSelected(mThemeId);
                    mLocalPreferenceManager.saveSayHiNoteSelected(mNoteId);

                    //发送
                    LiveRequestOperator.getInstance().SendSayHi(mAnchorId, mThemeId, mNoteId, new OnSendSayHiCallback() {
                        @Override
                        public void onSendSayHi(boolean isSuccess, int errCode, String errMsg, SayHiSendInfoItem item) {
                            //回调界面
                            HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, item);
                            Message msg = Message.obtain();
                            msg.what = SEND_SAYHI_CALLBACK;
                            msg.obj = response;
                            sendUiMessage(msg);
                        }
                    });
                }

                //点击发送按钮
                onAnalyticsEvent(getResources().getString(R.string.Live_SayHi_Category),
                        getResources().getString(R.string.Live_SayHi_Action_SendNow_Click),
                        getResources().getString(R.string.Live_SayHi_Label_SendNow_Click));
            }
        });
    }

    public void initData(){
        //取传入参数
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(ANCHOR_ID)){
                mAnchorId = bundle.getString(ANCHOR_ID);
            }
            if(bundle.containsKey(ANCHOR_NAME)){
                mAnchorName = bundle.getString(ANCHOR_NAME);
            }
        }

        //
        mLocalPreferenceManager = new LocalPreferenceManager(mContext);

        //取主题列表
        SayHiConfigManager.getInstance().GetSayHiResourceConfig(new OnGetSayHiResourceConfigCallback() {
            @Override
            public void onGetSayHiResourceConfig(boolean isSuccess, int errCode, String errMsg, SayHiResourceConfigItem configItem) {
                //回调界面
                HttpRespObject response = new HttpRespObject(isSuccess, errCode, errMsg, configItem);
                Message msg = Message.obtain();
                msg.what = GET_SAYHI_CONFIG_CALLBACK;
                msg.obj = response;
                sendUiMessage(msg);
            }
        });

        //给UI赋值
        tv_anchor_name.setText(getString(R.string.say_hi_edit_anchor_name, mAnchorName));

    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        switch (msg.what) {
            case GET_SAYHI_CONFIG_CALLBACK:
                HttpRespObject response = (HttpRespObject) msg.obj;
                if(response.data != null) {
                    SayHiResourceConfigItem configItem = (SayHiResourceConfigItem) response.data;
                    mThemeAdapter.addData(Arrays.asList(configItem.themeList));
                    mNoteAdapter.addData(Arrays.asList(configItem.textList));

                    //读取上次选择的主题和文字
                    loadThemeNoteSelected(configItem.themeList, configItem.textList);

                    //选择默认选中项
                    mThemeAdapter.setSelectedIndex(mThemeLastSelectIndex);
                    mNoteAdapter.setSelectedIndex(mNoteLastSelectIndex);
                }
                break;
            case SEND_SAYHI_CALLBACK:
                HttpRespObject responseSend = (HttpRespObject) msg.obj;

                if(mDialogResult != null) {
                    mDialogResult.destroy();
                }

                SayHiSendInfoItem sayHiSendInfoItem = ((SayHiSendInfoItem)responseSend.data);
                initErrorDialogItemListener(sayHiSendInfoItem);

                if(responseSend.isSuccess){
                    //发送成功
                    mDialogResult = MultipleBtnDialogFactory.createSayHiSendSuccessDialog(mContext, sayHiSendInfoItem, mErrorDialogItemListener);
                    mDialogResult.show();

                }else{
                    //发送失败
                    HttpLccErrType httpLccErrType = IntToEnumUtils.intToHttpErrorType(responseSend.errCode);

                    if(httpLccErrType ==  HttpLccErrType.HTTP_LCC_ERR_SAYHI_MAN_NO_PRIV){
                        // 男士无权限(17401)
                        mDialogResult = MultipleBtnDialogFactory.createSayHiAuthFailDialog(mContext, sayHiSendInfoItem, mAnchorName, mErrorDialogItemListener);
                        mDialogResult.show();

                    }else if(httpLccErrType ==  HttpLccErrType.HTTP_LCC_ERR_SAYHI_LADY_NO_PRIV){
                        // 女士无权限(174012)
                        mDialogResult = MultipleBtnDialogFactory.createSayHiAuthFailDialog(mContext, sayHiSendInfoItem, mAnchorName, mErrorDialogItemListener);
                        mDialogResult.show();

                    }else if(httpLccErrType ==  HttpLccErrType.HTTP_LCC_ERR_SAYHI_ANCHOR_ALREADY_SEND_LOI){
                        // 主播发过意向信(17403)
                        mDialogResult = MultipleBtnDialogFactory.createSayHiAuthFailDialog(mContext, sayHiSendInfoItem, mAnchorName, mErrorDialogItemListener);
                        mDialogResult.show();

                    }else if(httpLccErrType ==  HttpLccErrType.HTTP_LCC_ERR_SAYHI_MAN_ALREADY_SEND_SAYHI){
                        // 男士发过SayHi(17404)
                        mDialogResult = MultipleBtnDialogFactory.createSayHiHasSendFailDialog(mContext, sayHiSendInfoItem, mAnchorName, mErrorDialogItemListener);
                        mDialogResult.show();

                    }else if(httpLccErrType ==  HttpLccErrType.HTTP_LCC_ERR_SAYHI_ALREADY_CONTACT){
                        // 男士主播已建立联系(17405)
                        mDialogResult = MultipleBtnDialogFactory.createSayHiHasContactFailDialog(mContext, sayHiSendInfoItem, mAnchorName, mErrorDialogItemListener);
                        mDialogResult.show();

                    }else if(httpLccErrType ==  HttpLccErrType.HTTP_LCC_ERR_SAYHI_MAN_LIMIT_NUM_DAY){
                        // 男士每日数量限制(17406)
                        mDialogResult = MultipleBtnDialogFactory.createSayHiDayLimitFailDialog(mContext, sayHiSendInfoItem, mAnchorName, mErrorDialogItemListener);
                        mDialogResult.show();

                    }else if(httpLccErrType ==  HttpLccErrType.HTTP_LCC_ERR_SAYHI_MAN_LIMIT_TOTAL_ANCHOR_REPLY){
                        // 男士总数量限制-有主播回复(17407)
                        mDialogResult = MultipleBtnDialogFactory.createSayHiLimitSendFeedBackFailDialog(mContext, sayHiSendInfoItem, mAnchorName, mErrorDialogItemListener);
                        mDialogResult.show();

                    }else if(httpLccErrType ==  HttpLccErrType.HTTP_LCC_ERR_SAYHI_MAN_LIMIT_TOTAL_ANCHOR_UNREPLY){
                        // 男士总数量限制-无主播回复(17408)
                        mDialogResult = MultipleBtnDialogFactory.createSayHiLimitSendNoFeedBackFailDialog(mContext, sayHiSendInfoItem, mAnchorName, mErrorDialogItemListener);
                        mDialogResult.show();

                    }else{
                        //其它错误
                        if(sayHiSendInfoItem != null){
                            mDialogResult = MultipleBtnDialogFactory.createSayHiAuthFailDialog(mContext, sayHiSendInfoItem, mAnchorName, mErrorDialogItemListener);
                            mDialogResult.show();

                        }else{
                            ToastUtil.showToast(mContext, responseSend.errMsg);
                        }
                    }
                }
                break;
        }
    }

    /**
     * 读取上次选择的主题和文字
     */
    private void loadThemeNoteSelected(SayHiThemeItem[] themeList, SayHiTextItem[] textList){
        String themeId = mLocalPreferenceManager.getSayHiThemeIdSelected();
        String noteId =mLocalPreferenceManager.getSayHiNoteIdSelected();

        mThemeLastSelectIndex = 0;
        for(SayHiThemeItem themeItem:themeList){
            if(themeItem.themeId.equals(themeId)){
                break;
            }
            mThemeLastSelectIndex ++;
        }

        mNoteLastSelectIndex = 0;
        for(SayHiTextItem textItem:textList){
            if(textItem.textId.equals(noteId)){
                break;
            }
            mNoteLastSelectIndex ++;
        }
    }

    /**
     * 生成发送失败对话框事件
     * @param sayHiSendInfoItem
     */
    private void initErrorDialogItemListener(final SayHiSendInfoItem sayHiSendInfoItem){
        //发送失败对话框按钮事件
        mErrorDialogItemListener = new CommonMultipleBtnTipDialog.OnDialogItemClickListener() {
            @Override
            public void onItemSelected(View v, int which) {
                if (String.valueOf(v.getTag()).equals(MultipleBtnDialogFactory.TAB_BTN_SAY_HI)) {
                    String sayHiDetailUrl = LiveUrlBuilder.createSayHiDetailActivityUrl(sayHiSendInfoItem.sayHiId);
                    AppUrlHandler appUrlHandler = new AppUrlHandler(mContext);
                    appUrlHandler.urlHandle(sayHiDetailUrl);
                }else if (String.valueOf(v.getTag()).equals(MultipleBtnDialogFactory.TAB_BTN_SAY_HI_LIST_RES)) {
                    String sayHiListUrl = LiveUrlBuilder.createSayHiListActivityUrl("2");
                    AppUrlHandler appUrlHandler = new AppUrlHandler(mContext);
                    appUrlHandler.urlHandle(sayHiListUrl);
                }else if (String.valueOf(v.getTag()).equals(MultipleBtnDialogFactory.TAB_BTN_SAY_HI_LIST_ALL)) {
                    String sayHiListUrl = LiveUrlBuilder.createSayHiListActivityUrl("");
                    AppUrlHandler appUrlHandler = new AppUrlHandler(mContext);
                    appUrlHandler.urlHandle(sayHiListUrl);
                }else if (String.valueOf(v.getTag()).equals(MultipleBtnDialogFactory.TAB_BTN_CHAT)) {
                    String chatDetailUrl = LiveUrlBuilder.createLiveChatActivityUrl(mAnchorId, mAnchorName, "");
                    AppUrlHandler appUrlHandler = new AppUrlHandler(mContext);
                    appUrlHandler.urlHandle(chatDetailUrl);
                }else if (String.valueOf(v.getTag()).equals(MultipleBtnDialogFactory.TAB_BTN_ONE_ON_ONE)) {
                    String oneOnOneUrl = LiveUrlBuilder.createOneOnOneUrl(mAnchorId, mAnchorName, "");
                    AppUrlHandler appUrlHandler = new AppUrlHandler(mContext);
                    appUrlHandler.urlHandle(oneOnOneUrl);
                }else if(String.valueOf(v.getTag()).equals(TAB_BTN_MAIL)) {
                    String mailEditUrl = LiveUrlBuilder.createSendMailActivityUrl(mAnchorId);
                    AppUrlHandler appUrlHandler = new AppUrlHandler(mContext);
                    appUrlHandler.urlHandle(mailEditUrl);
                }else if(String.valueOf(v.getTag()).equals(TAB_BTN_FOLLOW)) {
                    LiveRoomListItem liveRoomListItem = new LiveRoomListItem();
                    liveRoomListItem.isFollow = false;
                    liveRoomListItem.userId = mAnchorId;
                    FollowManager.getInstance().summitFollow(liveRoomListItem, true);
                }
            }
        };

        FollowManager.getInstance().registerSynFavResultObserver(new Consumer<FollowManager.FavResult>() {
            @Override
            public void accept(FollowManager.FavResult favResult) throws Exception {
                //关注主播成功 改图标
                if(mDialogResult != null){
                    CommonMultipleBtnTipDialog.DialogItem dialogItem = mDialogResult.getItem(TAB_BTN_FOLLOW);
                    dialogItem.setItemIconId(R.drawable.sayhi_dialog_item_followed);
                    mDialogResult.refresh();
                }
            }
        });
    }

    /************************* 控件相互约束 start  ****************************/

    /**
     * 抽屉Tab选中事件
     * @param index
     */
    private void onTabSelected(int index){
        mDrawerSelectedIndex = index;
        if(sd_content.isOpened()){
            if(index == TAB_THEME_INDEX){
                setSelectedThemeUI();
            }else if(index == TAB_NOTE_INDEX){
                setSelectedNoteUI();
            }
        }else if(!sd_content.isOpened() && !sd_content.isMoving()){
            sd_content.animateOpen();
        }
    }

    /**
     * 打开时，选中主题 UI
     */
    private void setSelectedThemeUI(){
        ll_tab_theme.setBackgroundResource(R.color.sayhi_edit_handler_open_selected_bg);
        ll_tab_note.setBackgroundResource(R.color.sayhi_edit_handler_open_unselected_bg);

        img_theme.setImageResource(R.drawable.ic_sayhi_edit_handler_theme_selected);
        img_note.setImageResource(R.drawable.ic_sayhi_edit_handler_note_unselected);

        tv_theme.setTextColor(ContextCompat.getColor(mContext, R.color.sayhi_edit_handler_selected_text_color));
        tv_note.setTextColor(ContextCompat.getColor(mContext, R.color.sayhi_edit_handler_unselected_text_color));

        fl_theme.setVisibility(View.VISIBLE);
        fl_note.setVisibility(View.GONE);
        v_line1.setVisibility(View.GONE);
    }

    /**
     * 打开时，选中文字 UI
     */
    private void setSelectedNoteUI(){
        ll_tab_theme.setBackgroundResource(R.color.sayhi_edit_handler_open_unselected_bg);
        ll_tab_note.setBackgroundResource(R.color.sayhi_edit_handler_open_selected_bg);

        img_theme.setImageResource(R.drawable.ic_sayhi_edit_handler_theme_unselected);
        img_note.setImageResource(R.drawable.ic_sayhi_edit_handler_note_selected);

        tv_theme.setTextColor(ContextCompat.getColor(mContext, R.color.sayhi_edit_handler_unselected_text_color));
        tv_note.setTextColor(ContextCompat.getColor(mContext, R.color.sayhi_edit_handler_selected_text_color));

        fl_theme.setVisibility(View.GONE);
        fl_note.setVisibility(View.VISIBLE);
        v_line1.setVisibility(View.GONE);
    }

    /**
     * 还原把手UI
     */
    private void resetDrawerHandlerUI(){
        ll_tab_theme.setBackgroundResource(R.color.sayhi_edit_handler_close_bg);
        ll_tab_note.setBackgroundResource(R.color.sayhi_edit_handler_close_bg);

        img_theme.setImageResource(R.drawable.ic_sayhi_edit_handler_theme_unselected);
        img_note.setImageResource(R.drawable.ic_sayhi_edit_handler_note_unselected);

        tv_theme.setTextColor(ContextCompat.getColor(mContext, R.color.sayhi_edit_handler_unselected_text_color));
        tv_note.setTextColor(ContextCompat.getColor(mContext, R.color.sayhi_edit_handler_unselected_text_color));

        v_line1.setVisibility(View.VISIBLE);
    }

    /**
     * 关闭抽屉
     */
    private void closeDrawer(){
        if(sd_content.isOpened() && !sd_content.isMoving()) {
            sd_content.animateClose();
        }
    }

    /************************* 控件相互约束 end  ****************************/
}
