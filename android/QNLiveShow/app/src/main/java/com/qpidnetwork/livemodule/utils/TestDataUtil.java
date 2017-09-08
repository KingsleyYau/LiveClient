package com.qpidnetwork.livemodule.utils;

import android.app.Activity;
import android.view.View;

import com.qpidnetwork.livemodule.framework.widget.swipetoloadlayout.model.Character;
import com.qpidnetwork.livemodule.im.listener.IMGiftMessageContent;
import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.im.listener.IMTextMessageContent;
import com.qpidnetwork.livemodule.liveshow.liveroom.car.CarInfo;
import com.qpidnetwork.livemodule.liveshow.liveroom.tariffprompt.TariffPromptManager;
import com.qpidnetwork.livemodule.view.CircleImageHorizontScrollView;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/6/8.
 */

public class TestDataUtil {
    private final static String TAG = TestDataUtil.class.getSimpleName();

    public static final String[] avatars = {
            "http://i.annihil.us/u/prod/marvel/i/mg/9/a0/54adb647b792d.png",
            "http://x.annihil.us/u/prod/marvel/i/mg/c/00/54adb7c4e163b.png",
            "http://x.annihil.us/u/prod/marvel/i/mg/a/10/54adb9789bc28.png",
            "http://x.annihil.us/u/prod/marvel/i/mg/b/40/54adba004fe21.png",
            "http://i.annihil.us/u/prod/marvel/i/mg/f/40/54adba8b35f8b.png"
    };
    public static final String[] names = {
            "Hunter",
            "Randy",
            "Harry",
            "Fly",
            "Martin",
            "Dannk Soydy"
    };

    public static final String[] roomBgs = {
            "http://i.annihil.us/u/prod/marvel/i/mg/9/30/538cd33e15ab7/standard_xlarge.jpg",
            "http://i.annihil.us/u/prod/marvel/i/mg/c/10/537ba5ff07aa4/standard_xlarge.jpg",
            "http://i.annihil.us/u/prod/marvel/i/mg/5/a0/538615ca33ab0/standard_xlarge.jpg",
            "http://x.annihil.us/u/prod/marvel/i/mg/5/a0/537bc7036ab02/standard_xlarge.jpg",
            "http://i.annihil.us/u/prod/marvel/i/mg/6/a0/55b6a25e654e6/standard_xlarge.jpg",
            "http://x.annihil.us/u/prod/marvel/i/mg/5/e0/537bb460046bd/standard_xlarge.jpg",
            "http://x.annihil.us/u/prod/marvel/i/mg/9/10/537ba3f27a6e0/standard_xlarge.jpg",
            "http://i.annihil.us/u/prod/marvel/i/mg/6/90/537ba6d49472b/standard_xlarge.jpg",
            "http://i.annihil.us/u/prod/marvel/i/mg/3/50/537ba56d31087/standard_xlarge.jpg",
            "http://i.annihil.us/u/prod/marvel/i/mg/2/60/537bcaef0f6cf/standard_xlarge.jpg",
            "http://x.annihil.us/u/prod/marvel/i/mg/2/03/537bc76411307/standard_xlarge.jpg",
            "http://i.annihil.us/u/prod/marvel/i/mg/9/50/537bb3780cfd2/standard_xlarge.jpg",
            "http://x.annihil.us/u/prod/marvel/i/mg/2/03/526036550cd37/standard_xlarge.jpg",
            "http://x.annihil.us/u/prod/marvel/i/mg/5/03/5390dc2225782/standard_xlarge.jpg",
            "http://x.annihil.us/u/prod/marvel/i/mg/a/10/537bc68747ccf/standard_xlarge.jpg",
            "http://i.annihil.us/u/prod/marvel/i/mg/2/f0/5260363fc40f2/standard_xlarge.jpg",
            "http://i.annihil.us/u/prod/marvel/i/mg/3/b0/5261a7e53f827/standard_xlarge.jpg",
            "http://x.annihil.us/u/prod/marvel/i/mg/3/60/53176bb096d17/standard_xlarge.jpg",
            "http://i.annihil.us/u/prod/marvel/i/mg/f/40/538cf0c2acdd9/standard_xlarge.jpg",
            "http://i.annihil.us/u/prod/marvel/i/mg/e/03/526952357d91c/standard_xlarge.jpg"
    };

    public static final String[] roomTitles = {
            "Spider-Man",
            "Captain Marvel",
//            "Hulk",
//            "Thor",
//            "Iron Man",
            "Luke Cage",
            "Black Widow",
            "Daredevil",
            "Captain America",
            "Wolverine",
            "Ultron",
//            "Loki",
            "Red Skull",
            "Mystique",
            "Thanos",
//            "Ronan",
            "Magneto",
            "Dr. Doom",
            "Green Goblin",
            "Black Cat"
    };

    public static final String[] senderNames = {
            "Jonn","Tommy","Dannk Soydy","Doris"
    };


    public static final String[] liveMsgEgs = {
            "You can't judge a tree by its bark.",
            "To be both a speaker of words and a doer of deeds.",
            "Variety is the spice of life.",
            "Bad times make a good man.",
            "Courtesy is the inseparable companion of virtue.",
            "Plain living and high thinking.",
            "Politeness costs nothing and gains everything.",
            "Honesty is the best policy.",
            "He that makes a good war makes a good peace.",
            "Being neither jealous nor greedy, being without desires, and remaining the same under all circumstances, this is nobility."
    };

    public static List<Character> initBannerData(List<Character> bannerDatas){
        if(null == bannerDatas || bannerDatas.size() == 0){
            bannerDatas = new ArrayList<Character>();
            Character characterItem = null;
            for(int index = 0; index < avatars.length; index++){
                characterItem = new Character();
                characterItem.setAvatar(avatars[index]);
                characterItem.setName(names[index]);
                bannerDatas.add(characterItem);
            }
        }
        return bannerDatas;
    }

    public static double localCoins = 99.99;

    public static boolean isContinueTestTask = false;



    public static void testMulitGift(final OnIMMessageItemProducedListener listener){
        new Thread(){
            @Override
            public void run() {
                Random random = new Random();
                while(isContinueTestTask){
                    try {
                        Thread.sleep(2000l);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    int randomStart = random.nextInt(20);
                    int randomEnd = randomStart+random.nextInt(10);
                    IMMessageItem imMessageItem = new IMMessageItem("0",random.nextInt(Integer.MAX_VALUE),
                            "1",names[random.nextInt(names.length)], random.nextInt(100), IMMessageItem.MessageType.Gift,
                            null,new IMGiftMessageContent("1","kiss",random.nextInt(100),
                            false,randomStart,randomEnd,random.nextInt(Integer.MAX_VALUE)));
                    if(null != listener){
                        listener.onIMMessageItemProduced(imMessageItem);
                    }
                }
            }
        }.start();

    }

    public static void testBarrage(final OnIMMessageItemProducedListener listener){
        new Thread(){
            @Override
            public void run() {
                Random random = new Random();
                while (isContinueTestTask){
                    try {
                        Thread.sleep(5000l);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    IMMessageItem imMessageItem = new IMMessageItem("0",random.nextInt(Integer.MAX_VALUE),
                            "1",names[random.nextInt(names.length)], random.nextInt(100), IMMessageItem.MessageType.Barrage,
                            new IMTextMessageContent("Harry said that he love you! [勾引]"),null);
                    if(null != listener){
                        listener.onIMMessageItemProduced(imMessageItem);
                    }
                }
            }
        }.start();
    }

    public static void testRoomIn(final OnIMMessageItemProducedListener listener){
        new Thread(){
            @Override
            public void run() {
                Random random = new Random();
                while(isContinueTestTask){
                    try {
                        Thread.sleep(4000l);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    IMMessageItem imMessageItem = new IMMessageItem("0",random.nextInt(Integer.MAX_VALUE),
                            "1",names[random.nextInt(names.length)], random.nextInt(100), IMMessageItem.MessageType.RoomIn,
                            null,null);
                    if(null != listener){
                        listener.onIMMessageItemProduced(imMessageItem);
                    }
                }
            }
        }.start();
    }

    public static void testTariffPrompt(final Activity activity, final TariffPromptManager.OnGetRoomTariffInfoListener listener){
        final Random random = new Random();
        new Thread(){
            @Override
            public void run() {
                if(isContinueTestTask){
                    try {
                        Thread.sleep(2000l);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    String nickName = roomTitles[random.nextInt(roomTitles.length)];
                    IMRoomInItem imRoomInItem = new IMRoomInItem(null,nickName,null,null,random.nextInt(4)+1 ,
                            0d,false,0,null,0,null,false,0,false,null,0,0.2d,0d,0);
                    Log.d(TAG,"testTariffPrompt-nickName:"+nickName+" roomType:"+imRoomInItem.roomType.toString());
                    TariffPromptManager.getInstance().init(activity,imRoomInItem).getRoomTariffInfo(listener);
                }
            }
        }.start();
    }

    private static boolean addOrDelete = false;
    public static void testOnLineHeader(final Activity activity,final CircleImageHorizontScrollView childView){
        childView.setList(Arrays.asList(roomBgs));
        new Thread(){
            @Override
            public void run() {
                while(isContinueTestTask){
                    try {
                        Thread.sleep(1000l);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    if(0 == childView.getListNum()){
                        addOrDelete = true;
                    }
                    if(roomBgs.length == childView.getListNum()){
                        addOrDelete = false;
                    }
                    activity.runOnUiThread(
                            new Runnable() {
                               @Override
                               public void run() {
                                   if(addOrDelete){
                                       childView.addOnLinePerson(roomBgs[childView.getListNum()]);
                                   }else{
                                       childView.deleteOnLinePerson();
                                   }
                               }
                           });
                }
            }
        }.start();
    }

    public static void testFollow(final OnIMMessageItemProducedListener listener){
        new Thread(){
            @Override
            public void run() {
                Random random = new Random();
                while(isContinueTestTask){
                    try {
                        Thread.sleep(1500l);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    IMMessageItem imMessageItem = new IMMessageItem("0",random.nextInt(Integer.MAX_VALUE),
                            "1",names[random.nextInt(names.length)], random.nextInt(100), IMMessageItem.MessageType.FollowHost,
                            new IMTextMessageContent(""),null);
                    if(null != listener){
                        listener.onIMMessageItemProduced(imMessageItem);
                    }
                }
            }
        }.start();
    }

    public interface OnIMMessageItemProducedListener {
        void onIMMessageItemProduced(IMMessageItem imMessageItem);
    }

    public static void testLiveRoomCarAnim(final OnAudienceInfoItemProducedListener listener){
        new Thread(){
            @Override
            public void run() {
                Random random = new Random();
                while(isContinueTestTask){
                    try {
                        Thread.sleep(500l);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    CarInfo audienceInfoItem = new CarInfo();
                    audienceInfoItem.nickName = roomTitles[random.nextInt(roomTitles.length)];
                    if(null != listener){
                        listener.onAudienceInfoItemProduced(audienceInfoItem);
                    }
                }
            }
        }.start();
    }

    public interface OnAudienceInfoItemProducedListener{
        void onAudienceInfoItemProduced(CarInfo item);
    }

    public static void changeViewVisityStatus(final View view , final Activity activity, final int visity){
        new Thread(){
            @Override
            public void run() {
                while(isContinueTestTask){
                    try {
                        Thread.sleep(1000l);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    activity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            view.setVisibility(visity);
                        }
                    });
                }
            }
        }.start();
    }
}
