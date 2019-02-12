package com.qpidnetwork.livemodule.utils;

import android.content.Context;

import com.qpidnetwork.livemodule.R;


/**
 * Created by Hardy on 2018/10/31.
 * <p>
 * 个人兴趣——转换工具类
 */
public class MyProfileInterestUtil {

    private MyProfileInterestUtil() {

    }

    /**
     * 根据 id 获取 icon 资源 id
     * @param name
     * @return
     */
    public static int formatId2ImageResId(String name) {
        int result = -1;

        switch (name) {
            case "1": {
                result = R.drawable.ic_interest_label_1;
            }
            break;

            case "2": {
                result = R.drawable.ic_interest_label_2;
            }
            break;

            case "3": {
                result = R.drawable.ic_interest_label_3;
            }
            break;

            case "4": {
                result = R.drawable.ic_interest_label_4;
            }
            break;

            case "5": {
                result = R.drawable.ic_interest_label_5;
            }
            break;

            case "6": {
                result = R.drawable.ic_interest_label_6;
            }
            break;

            case "7": {
                result = R.drawable.ic_interest_label_7;
            }
            break;

            case "8": {
                result = R.drawable.ic_interest_label_8;
            }
            break;

            case "9": {
                result = R.drawable.ic_interest_label_9;
            }
            break;

            case "10": {
                result = R.drawable.ic_interest_label_10;
            }
            break;

            case "11": {
                result = R.drawable.ic_interest_label_11;
            }
            break;

            case "12": {
                result = R.drawable.ic_interest_label_12;
            }
            break;

            default:
                break;
        }

        return result;
    }

    /**
     * 根据 id 获取兴趣名字
     *
     * @param context
     * @param name
     * @return
     */
    public static String formatId2String(Context context, String name) {
        String result = "";

        switch (name) {
            case "1": {
                result = context.getResources().getString(R.string.my_profile_going_to_restaurants);
            }
            break;

            case "2": {
                result = context.getResources().getString(R.string.my_profile_cooking);
            }
            break;

            case "3": {
                result = context.getResources().getString(R.string.my_profile_travel);
            }
            break;

            case "4": {
                result = context.getResources().getString(R.string.my_profile_hiking_outdoor_activities);
            }
            break;

            case "5": {
                result = context.getResources().getString(R.string.my_profile_dancing);
            }
            break;

            case "6": {
                result = context.getResources().getString(R.string.my_profile_watching_movies);
            }
            break;

            case "7": {
                result = context.getResources().getString(R.string.my_profile_shopping);
            }
            break;

            case "8": {
                result = context.getResources().getString(R.string.my_profile_having_pets);
            }
            break;

            case "9": {
                result = context.getResources().getString(R.string.my_profile_reading);
            }
            break;

            case "10": {
                result = context.getResources().getString(R.string.my_profile_sports_exercise);
            }
            break;

            case "11": {
                result = context.getResources().getString(R.string.my_profile_playing_cards_chess);
            }
            break;

            case "12": {
                result = context.getResources().getString(R.string.my_profile_Music_play_instruments);
            }
            break;

            default:
                break;
        }
        return result;
    }

}
