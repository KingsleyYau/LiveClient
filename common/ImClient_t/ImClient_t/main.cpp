//
//  main.cpp
//  ImClient_t
//
//  Created by  Samson on 09/05/2017.
//  Copyright © 2017 Samson. All rights reserved.
//

#include <iostream>
#include "IImClient.h"


class ImClientCallback : public IImClientListener
{
public:
    ImClientCallback() {};
    virtual ~ImClientCallback() {};
    
public:
    virtual void OnLogin(LCC_ERR_TYPE err, const string& errmsg) {
        printf("OnLogin() err:%d, errmsg:%s"
               , err, errmsg.c_str());
    }
    virtual void OnLogout(LCC_ERR_TYPE err, const string& errmsg) {
        printf("OnLogout() err:%d, errmsg:%s"
               , err, errmsg.c_str());
    }
};

int main(int argc, const char * argv[]) {
    ImClientCallback callback;
    IImClient* client = IImClient::CreateClient();
    if (NULL != client) {
        list<string> urls;
        urls.push_back("ws://192.168.88.17:3006");
        client->Init(urls);
        client->AddListener(&callback);
        client->Login("Samson", "12s3adf4564sdf89");
    }
    
    while (true) {
        Sleep(1000);
    }
    
    return 0;
}
