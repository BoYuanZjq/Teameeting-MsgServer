//
//  main.cpp
//  MsgServerStorage
//
//  Created by hp on 1/16/16.
//  Copyright © 2016 DYNC. All rights reserved.
//

#include <iostream>
#include "rtklog.h"
#include "SRTStorage.h"
#include "RTZKClient.hpp"
#include <google/protobuf/message.h>

#ifndef _TEST_
#define _TEST_ 1
#endif

static void sighandler(int sig_no)
{
    printf("catch sighandler:%d\n", sig_no);
     exit(0);
}

int main(int argc, const char * argv[]) {
    //////LI("Hello, Storage!!!\n");
    SRTStorage::PrintVersion();

    if (argc <= 1) {
        std::cout << "Error: Please usage:$0 {conf_path} " << std::endl;
        std::cout << "Please enter any key to exit ..." << std::endl;
        getchar();
        exit(0);
    }
#if 0
#if _TEST_
    if (RTZKClient::Instance().InitOnly(argv[1])!=0) {
#else
    if (RTZKClient::Instance().InitZKClient(argv[1])!=0) {
#endif
        std::cout << "Please check the config file ..." << std::endl;
        std::cout << "Please enter any key to exit ..." << std::endl;
        getchar();
        exit(0);
    }

    int level = RTZKClient::Instance().GetServerConfig().Level;
    std::string logpath = RTZKClient::Instance().GetServerConfig().LogPath;
    if (logpath.empty())
        L_Init(level, NULL);
    else
        L_Init(level, logpath.c_str());
#endif

#if 0
    L_Init(0, NULL);
#else
    L_Init(0, "./serverlog.log");
#endif
    SRTStorage::Initialize(1024);
    SRTStorage* pStorage = SRTStorage::Inst();
    //////LI("server listen port:%u\n", RTZKClient::Instance().GetServerConfig().portConfig.storage.ListenClicon);
    //int res = pStorage->Start(RTZKClient::Instance().GetServerConfig().IP.c_str(),
    //                  RTZKClient::Instance().GetServerConfig().portConfig.storage.ListenClicon
    //                  );
    //signal(SIGUSR1, sighandler);
    //signal(SIGUSR2, sighandler);
    int res = pStorage->Start("192.168.7.207", 6660);
    int test = 0;
    if (res != 0) {
        //////LI("SRTStorage start failed and goto exit, res:%d\n", res);
        goto EXIT;
    }
#if 0
    while (test++ < 60) {
#else
    while (1) {
#endif
        pStorage->DoTick();
        sleep(1);
        //break;
    }
        sleep(1);
EXIT:
    pStorage->Stop();
    SRTStorage::DeInitialize();
    L_Deinit();
    //RTZKClient::Instance().Unin();
    google::protobuf::ShutdownProtobufLibrary();
    return 0;
}
