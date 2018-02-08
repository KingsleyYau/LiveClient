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
    virtual void OnLogin(LCC_ERR_TYPE err, const string& errmsg, const LoginReturnItem& item) {
        printf("OnLogin() err:%d, errmsg:%s\n"
               , err, errmsg.c_str());
    }
    virtual void OnLogout(LCC_ERR_TYPE err, const string& errmsg) {
        printf("OnLogout() err:%d, errmsg:%s\n"
               , err, errmsg.c_str());
    }
};

int main(int argc, const char * argv[]) {
    int iTimes = 0;
    const int MAX_TIMES = 100;
    int waitTime = 0;
    _STRUCT_TIMEVAL time = timeval();
    srand((unsigned int)(time.tv_sec + time.tv_usec));
    
    ImClientCallback callback;
    IImClient* client = IImClient::CreateClient();
    if (NULL != client) {
        list<string> urls;
        urls.push_back("ws://192.168.88.17:8816");
        string token = "CMTS09975#uid#PWBU3AME_1517899662271";
        
        client->Init(urls);
        client->AddListener(&callback);
        
//        client->Login(token, PAGENAMETYPE_MOVEPAGE, LOGINVERIFYTYPE_TOKEN);
//        while (true) {
//            Sleep(1000);
//        }

        for (iTimes = 0; iTimes < MAX_TIMES; iTimes++)
        {
            printf("%d times start\n", iTimes);
            client->Login(token, PAGENAMETYPE_MOVEPAGE, LOGINVERIFYTYPE_TOKEN);

            waitTime = rand()%1000;
            usleep(waitTime * 1000);
            client->Logout();

//            waitTime = rand()%1000;
//            usleep(waitTime * 1000);
            printf("%d times end\n", iTimes);
        }
    }
    IImClient::ReleaseClient(client);
        
    return 0;
}
