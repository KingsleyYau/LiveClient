package com.qpidnetwork.livemodule.liveshow.authorization;

/**
 * Created by Hunter Mun on 2017/12/25.
 */

public class MailLoginManager implements ILoginManager{

    @Override
    public boolean Autologin() {
        return false;
    }

    @Override
    public boolean login(String email, String password) {
        return false;
    }

    @Override
    public boolean logout(boolean isManal) {
        return false;
    }

    @Override
    public boolean register(String email, String password, int gender, String nickName, String birthday, String inviteCode) {
        return false;
    }
}
