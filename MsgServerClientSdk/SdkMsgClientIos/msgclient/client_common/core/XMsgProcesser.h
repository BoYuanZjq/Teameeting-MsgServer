//
//  XMsgProcesser.h
//  dyncRTCMsgClient
//
//  Created by hp on 12/22/15.
//  Copyright (c) 2015 Dync. All rights reserved.
//

#ifndef __dyncRTCMsgClient__XMsgProcesser__
#define __dyncRTCMsgClient__XMsgProcesser__

#include <stdio.h>
#include <iostream>
#include <vector>
#include "core/XMsgCallback.h"

#include "RTMsgCommon.h"

#define DEF_PROTO 1

class XMsgClientHelper;

class XMsgProcesser{
public:
    XMsgProcesser(XMsgClientHelper& helper):m_helper(helper){}
    ~XMsgProcesser(){}
public:

    int EncodeLogin(std::string& outstr, const std::string& userid, const std::string& token, const std::string& nname, int module);
    int EncodeSndMsg(std::string& outstr, const std::string& userid, const std::string& token, const std::string& nname, const std::string& roomid, const std::string& rname, const std::vector<std::string>& to, const std::string& msg, int tag, int type, int module, int flag);
    int EncodeGetMsg(std::string& outstr, const std::string& userid, const std::string& token, int tag, int module);
    int EncodeLogout(std::string& outstr, const std::string& userid, const std::string& token, int module);
    int EncodeKeepAlive(std::string& outstr, const std::string& userid, int module);

    int EncodeSyncSeqn(std::string& outstr, const std::string& userid, const std::string& token, int64 seqn, int module, int tag, int flag);
    int EncodeSyncData(std::string& outstr, const std::string& userid, const std::string& token, int64 seqn, int module, int tag, int flag);
    int EncodeSyncGroupSeqn(std::string& outstr, const std::string& userid, const std::string& groupid, const std::string& token, int64 seqn, int module, int tag, int flag);
    int EncodeSyncGroupData(std::string& outstr, const std::string& userid, const std::string& token, const std::string& groupid, int64 seqn, int module, int tag, int flag);

    int DecodeRecvData(const char* pData, int nLen);

protected:
    int DecodeLogin(int code, const std::string& cont);
    int DecodeSndMsg(int code, const std::string& cont);
    int DecodeGetMsg(int code, const std::string& cont);
    int DecodeLogout(int code, const std::string& cont);
    int DecodeKeepAlive(int code, const std::string& cont);
    int DecodeSyncSeqn(int code, const std::string& cont);
    int DecodeSyncData(int code, const std::string& cont);
    int DecodeGroupNotify(int code, const std::string& cont);
    int DecodeSyncGroupData(int code, const std::string& cont);
private:
    XMsgClientHelper    &m_helper;
};

#endif /* defined(__dyncRTCMsgClient__XMsgProcesser__) */
