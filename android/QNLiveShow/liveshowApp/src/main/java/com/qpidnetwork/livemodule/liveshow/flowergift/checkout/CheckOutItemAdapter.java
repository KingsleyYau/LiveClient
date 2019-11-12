package com.qpidnetwork.livemodule.liveshow.flowergift.checkout;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.v7.widget.RecyclerView;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.LSCheckoutGiftItem;
import com.qpidnetwork.livemodule.liveshow.flowergift.mycart.MyCartGiftsSynManager;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

import java.util.List;
import java.util.concurrent.TimeUnit;

import io.reactivex.Observable;
import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.Observer;
import io.reactivex.android.schedulers.AndroidSchedulers;
import io.reactivex.disposables.Disposable;
import io.reactivex.schedulers.Schedulers;

/**
 * 购物车某主播礼物列表Adapter
 * @author Jagger 2019-10-9
 */
public class CheckOutItemAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    private final int MAX_SUM = 99;
    private Context mContext;
    private OnCheckOutListEventListener mOnCartEventListener;
    private List<CheckOutListItem> mList ;
    private String mAnchorId = "";

    public CheckOutItemAdapter(Context context, List<CheckOutListItem> list, String anchorId) {
        mContext = context;
        mList = list;
        mAnchorId = anchorId;
    }

    public void setOnEventListener(OnCheckOutListEventListener listener){
        mOnCartEventListener = listener;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int viewType) {
        if(viewType == CheckOutListItem.Type.Gift.ordinal()){
            View view = LayoutInflater.from(mContext).inflate(R.layout.item_checkout_list_flower, viewGroup, false);
            return new ViewHolderFlower(view);
        }else if(viewType == CheckOutListItem.Type.Card.ordinal()){
            View view = LayoutInflater.from(mContext).inflate(R.layout.item_checkout_list_card, viewGroup, false);
            return new ViewHolderGreetingCard(view);
        }else {
            return null;
        }
    }

    @Override
    public int getItemViewType(int position) {
        return mList.get(position).type.ordinal();
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder viewHolder, int position) {

        if(viewHolder instanceof ViewHolderFlower){
            //花
            final ViewHolderFlower viewHolderFlower = (ViewHolderFlower)viewHolder;
            final LSCheckoutGiftItem giftItem =  mList.get(position).giftItem;

            FrescoLoadUtil.loadUrl(viewHolderFlower.img_gift, giftItem.giftImg, mContext.getResources().getDimensionPixelSize(R.dimen.my_cart_flower_img_size));
            viewHolderFlower.tv_flower_name.setText(giftItem.giftId + " - " + giftItem.giftName);
            viewHolderFlower.setUIEnabled(true);
            if(giftItem.giftNumber > 0){
                viewHolderFlower.edt_sum.setText(String.valueOf(giftItem.giftNumber));
                viewHolderFlower.tv_price.setText( mContext.getString(R.string.my_cart_price, ApplicationSettingUtil.formatCoinValue(giftItem.giftPrice*giftItem.giftNumber)));
            }

            //点击事件
            //-1
            viewHolderFlower.img_des.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    viewHolderFlower.setUIEnabled(false);
                    String s = viewHolderFlower.edt_sum.getText().toString();
                    if(TextUtils.isEmpty(s)) {
                        viewHolderFlower.setUIEnabled(true);
                        return;
                    }

                    viewHolderFlower.isInput = false;
                    int sum = Integer.valueOf(s);
                    int desSum = sum - 1;
                    if(desSum == 0){
                        if(mOnCartEventListener != null){
                            mOnCartEventListener.onDelGift(mAnchorId, giftItem);
                        }
                    }else{
//                        viewHolderFlower.edt_sum.setText(String.valueOf(desSum));
                        if(mOnCartEventListener != null){
                            mOnCartEventListener.onChangeGiftSum(mAnchorId, giftItem, desSum);
                        }
                    }
                }
            });

            //+1
            viewHolderFlower.img_inc.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {

                    viewHolderFlower.setUIEnabled(false);
                    String s = viewHolderFlower.edt_sum.getText().toString();
                    if(TextUtils.isEmpty(s)) {
                        viewHolderFlower.setUIEnabled(true);
                        return;
                    }

                    viewHolderFlower.isInput = false;
                    int sum = Integer.valueOf(s);
                    if(sum == MAX_SUM) {
                        ToastUtil.showToast(mContext, R.string.my_cart_num_out_range);
                        viewHolderFlower.setUIEnabled(true);
                        return;
                    }

                    int incSum = sum + 1;
//                    viewHolderFlower.edt_sum.setText(String.valueOf(incSum));
                    if(mOnCartEventListener != null){
                        mOnCartEventListener.onChangeGiftSum(mAnchorId, giftItem, incSum);
                    }
                }
            });

            //输入
//            viewHolderFlower.setGiftData4InputChangeSum(giftItem);

            viewHolderFlower.edt_sum.setOnFocusChangeListener(new View.OnFocusChangeListener() {
                @Override
                public void onFocusChange(View v, boolean hasFocus) {
                    EditText edt_sum = (EditText)v;
                    if(!hasFocus){
                        //失去焦点时代表输入完成
                        if (edt_sum.getText().toString().startsWith("0") || edt_sum.getText().toString().equals("")) {
                            ToastUtil.showToast(mContext, R.string.my_cart_num_out_range);
                            edt_sum.setText(String.valueOf(viewHolderFlower.oldSum) );
                            edt_sum.setSelection(1);
                            return;
                        }

                        if(viewHolderFlower.isInput){
                            //回调
                            if(mOnCartEventListener != null){
                                viewHolderFlower.setUIEnabled(false);
                                mOnCartEventListener.onChangeGiftSum(mAnchorId, giftItem, Integer.valueOf(edt_sum.getText().toString()));
                                viewHolderFlower.isInput = false;
                            }
                        }
                    }else{
                        //获得焦点，代表用户正在输入
                        viewHolderFlower.isInput = true;
                        if(edt_sum.length() > 0){
                            viewHolderFlower.oldSum = Integer.valueOf(edt_sum.getText().toString());
                        }
                    }
                }
            });

        }else if(viewHolder instanceof ViewHolderGreetingCard){
            //礼品卡
            ViewHolderGreetingCard viewHolderGreetingCard = (ViewHolderGreetingCard)viewHolder;

            viewHolderGreetingCard.tv_price.setText( mContext.getString(R.string.my_cart_price, ApplicationSettingUtil.formatCoinValue(0)));
        }

    }

    @Override
    public int getItemCount() {
        return mList.size();
    }

    /**
     * 接收键盘输入内容，从而触发 onInputTick() 处理
     */
    protected static class InputFeed{
        public interface InputListener{
            void onInputTick(String text);
        }

        private InputListener mInputListener ;

        /**
         * 注册监听器
         * @param listener
         */
        public void register(InputListener listener){
            mInputListener = listener;
        }

        /**
         * 接收输入的文字
         * @param text
         */
        public void input(String text){
            if(mInputListener != null){
                mInputListener.onInputTick(text);
            }
        }
    }

    /**
     * 鲜花礼品ViewHolder
     */
    protected class ViewHolderFlower extends RecyclerView.ViewHolder {
        public SimpleDraweeView img_gift;
        public ImageView img_des, img_inc;
        public TextView tv_flower_name, tv_price;
        public EditText edt_sum;
//        public InputFeed inputFeed;

        public boolean isInput = false;
        public int oldSum = 1;
//        private LSCheckoutGiftItem giftItem4Input;

        public ViewHolderFlower(@NonNull View itemView) {
            super(itemView);

            img_gift = itemView.findViewById(R.id.img_gift);
            img_des = itemView.findViewById(R.id.img_des);
            img_inc = itemView.findViewById(R.id.img_inc);
            tv_flower_name = itemView.findViewById(R.id.tv_flower_name);
            tv_price = itemView.findViewById(R.id.tv_price);
            edt_sum = itemView.findViewById(R.id.edt_sum);

            FrescoLoadUtil.setHierarchy(itemView.getContext(), img_gift, R.color.black4, false, 6 , 6 ,6,6);

            //输入
//            inputFeed = new InputFeed();
//            initInputObservable();
//            edt_sum.setOnTouchListener(new View.OnTouchListener() {
//                @Override
//                public boolean onTouch(View v, MotionEvent event) {
//                    isInput = true;
//                    if(edt_sum.length() > 0){
//                        oldSum = Integer.valueOf(edt_sum.getText().toString());
//                    }
//                    return false;
//                }
//            });
//            edt_sum.addTextChangedListener(new TextWatcher() {
//
//                @Override
//                public void onTextChanged(CharSequence s, int start, int before, int count) {
//
//                }
//
//                @Override
//                public void beforeTextChanged(CharSequence s, int start, int count, int after) {
//
//                }
//
//                @Override
//                public void afterTextChanged(Editable s) {
//                    if (s.toString().startsWith("0") || s.toString().equals("")) {
////                        edt_sum.setText("1");
////                        edt_sum.setSelection(1);
//                        ToastUtil.showToast(mContext, R.string.my_cart_num_out_range);
//                        isInput = false;
//                        edt_sum.setText(String.valueOf(oldSum) );
//                        edt_sum.setSelection(1);
//                        return;
//                    }
//
//                    if(isInput){
//                        inputFeed.input(edt_sum.getText().toString());
//                    }
//                }
//            });

        }

        /**
         * 修改礼物数量时，需要先锁UI， 返回后解锁
         * @param enabled
         */
        public void setUIEnabled(boolean enabled){
            img_des.setEnabled(enabled);
            img_inc.setEnabled(enabled);
            edt_sum.setEnabled(enabled);
        }

        /**
         * 设入输入修改数目提交时所需的参数
         * @param giftItem4Input
         */
//        public void setGiftData4InputChangeSum(LSCheckoutGiftItem giftItem4Input){
//            this.giftItem4Input = giftItem4Input;
//        }

        /**
         * 输入频率控制，以免用户输入过慢而重复提交
         */
//        private void initInputObservable(){
//            Observable.create(new ObservableOnSubscribe<String>() {
//
//                @Override
//                public void subscribe(final ObservableEmitter<String> emitter) {
//                    InputFeed.InputListener listener = new InputFeed.InputListener() {
//
//                        @Override
//                        public void onInputTick(String text) {
//                            //触发发射
//                            emitter.onNext(text);
//                        }
//                    };
//
//                    //输入事件发射源
//                    inputFeed.register(listener);
//                }
//            })
//		    .throttleWithTimeout(1000, TimeUnit.MILLISECONDS)   //通过时间来限流，源Observable每次发射出来一个数据后就会进行计时，如果在设定好的时间结束前源Observable有新的数据发射出来，这个数据就会被丢弃，同时重新开始计时。
//            .subscribeOn(Schedulers.io())		//io线程接收键盘输入
//            .observeOn(AndroidSchedulers.mainThread())//主线程显示表情
//            .subscribe(new Observer<String>() {
//
//                @Override
//                public void onComplete() {
//                    // TODO Auto-generated method stub
//
//                }
//
//                @Override
//                public void onError(Throwable arg0) {
//                    // TODO Auto-generated method stub
//
//                }
//
//                @Override
//                public void onNext(String inputStr) {
//                    // TODO Auto-generated method stub
//                    //回调
//                    if(mOnCartEventListener != null){
//                        edt_sum.setEnabled(false);
//                        mOnCartEventListener.onChangeGiftSum(mAnchorId, giftItem4Input, Integer.valueOf(inputStr));
//                        isInput = false;
//                    }
//
//                }
//
//                @Override
//                public void onSubscribe(Disposable arg0) {
//                    // TODO Auto-generated method stub
//
//                }
//            });
//        }
    }

    /**
     * 礼品卡ViewHolder
     */
    protected class ViewHolderGreetingCard extends RecyclerView.ViewHolder {
        public TextView tv_price;

        public ViewHolderGreetingCard(@NonNull View itemView) {
            super(itemView);

            tv_price = itemView.findViewById(R.id.tv_price);
        }
    }
}
