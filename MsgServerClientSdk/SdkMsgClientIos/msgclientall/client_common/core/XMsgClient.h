//
//  XMsgClient.h
//  dyncRTCMsgClient
//
//  Created by hp on 12/22/15.
//  Copyright (c) 2015 Dync. All rights reserved.
//

#ifndef __dyncRTCMsgClient__XMsgClient__
#define __dyncRTCMsgClient__XMsgClient__

#include <stdio.h>
#include <iostream>
#include <map>
#include <set>

#include "core/XTcpClientImpl.h"
#include "core/XMsgProcesser.h"
#include "core/XMsgCallback.h"
#include "core/XJSBuffer.h"

#include "RTMsgCommon.h"

class XMsgClientHelper {
public:
    XMsgClientHelper() {}
    ~XMsgClientHelper() {}

    virtual void OnLogin(int code, const std::string& userid) = 0;
    virtual void OnLogout(int code, const std::string& userid) = 0;
    virtual void OnSndMsg(int code, const std::string& cont) = 0;
    virtual void OnGetMsg(int code, const std::string& cont) = 0;
    virtual void OnKeepLive(int code, const std::string& cont) = 0;
    virtual void OnSyncSeqn(int code, const std::string& cont) = 0;
    virtual void OnSyncData(int code, const std::string& cont) = 0;
    virtual void OnGroupNotify(int code, const std::string& cont) = 0;
    virtual void OnSyncGroupData(int code, const std::string& cont) = 0;
    virtual void OnAddGroup(int code, const std::string& groupid) = 0;
    virtual void OnDelGroup(int code, const std::string& groupid) = 0;
};

class XMsgClient
: public XTcpClientCallback
, public XMsgClientHelper
, public XJSBuffer{
public:
    XMsgClient();
    ~XMsgClient();

    int Init(XMsgCallback* cb, const std::string& uid, const std::string& token, const std::string& nname, int module, const std::string& server="", int port=0, bool bAutoConnect=true);
    int Unin();

    int RegisterMsgCb(XMsgCallback* cb);
    int UnRegisterMsgCb(XMsgCallback* cb);


    int AddGroup(const std::string& groupid);
    int DelGroup(const std::string& groupid);

    int SndMsg(const std::string& roomid, const std::string& rname, const std::string& msg);
    int GetMsg(pms::EMsgTag tag);
    int OptRoom(pms::EMsgTag tag, const std::string& roomid, const std::string& rname, const std::string& remain);
    int SndMsgTo(const std::string& roomid, const std::string& rname, const std::string& msg, const std::vector<std::string>& uvec);
    int NotifyMsg(const std::string& roomid, const std::string& rname, pms::EMsgTag tag, const std::string& msg);

    int SyncSeqn();
    int SyncData();
    int SyncGroupSeqn();
    int SyncGroupData();
    int FetchGroupSeqn(const std::string& groupid);
    int SyncGroupSeqn(const std::string& groupid);
    int SyncGroupData(const std::string& gropuid);

    MSState MSStatus() { return m_msState; }
    void SetNickName(const std::string& nickname) { m_nname = nickname; }
    void TestSetCurSeqn(int64 seqn) { m_curSeqn = seqn; }

public:
    // For XTcpClientCallback
    virtual void OnServerConnected();
    virtual void OnServerDisconnect();
    virtual void OnServerConnectionFailure();

    virtual void OnTick();
    virtual void OnMessageSent(int err);
    virtual void OnMessageRecv(const char*pData, int nLen);

    // For XMsgClientHelper
    virtual void OnLogin(int code, const std::string& userid);
    virtual void OnLogout(int code, const std::string& userid);
    virtual void OnSndMsg(int code, const std::string& cont);
    virtual void OnGetMsg(int code, const std::string& cont);
    virtual void OnKeepLive(int code, const std::string& cont);
    virtual void OnSyncSeqn(int code, const std::string& cont);
    virtual void OnSyncData(int code, const std::string& cont);
    virtual void OnGroupNotify(int code, const std::string& cont);
    virtual void OnSyncGroupData(int code, const std::string& cont);
    virtual void OnAddGroup(int code, const std::string& groupid);
    virtual void OnDelGroup(int code, const std::string& groupid);

    // For XJSBuffer
    virtual void OnRecvMessage(const char*message, int nLen);

public:
    // <groupid, groupseqn>
    typedef std::map<std::string, int64>        GroupSeqnMap;
    typedef GroupSeqnMap::iterator              GroupSeqnMapIt;
    typedef std::set<XMsgCallback*>             MsgCallbackSet;
    typedef MsgCallbackSet::iterator            MsgCallbackSetIt;
private:
    int Login();
    int Logout();
    bool RefreshTime();
    int KeepAlive();
    int SyncGroupSeqn(const std::string& groupid, int64 seqn, bool isfirst);
    int SyncGroupData(const std::string& groupid, int64 seqn, bool isfirst);
    int SendEncodeMsg(std::string& msg);
    unsigned short readShort(char** pptr);
    void writeShort(char** pptr, unsigned short anInt);
private:

    XMsgCallback*            m_pCallback;
    XTcpClientImpl*          m_pClientImpl;
    XMsgProcesser*           m_pMsgProcesser;
    uint32_t                 m_lastUpdateTime;
    std::string              m_uid;
    std::string              m_grpid;
    std::string              m_token;
    std::string              m_nname;
    std::string              m_server;
    std::string              m_version;
    int                      m_port;
    bool                     m_autoConnect;
    bool                     m_login;
    MSState                  m_msState;
    int64                    m_curSeqn;
    int64                    m_curGroupSeqn;
    pms::EModuleType         m_module;

    GroupSeqnMap             m_mapGroupSeqn;
    MsgCallbackSet           m_setMsgCallback;
	rtc::CriticalSection     m_csGroupSeqn;
	rtc::CriticalSection     m_csMsgCallback;
};



#endif /* defined(__dyncRTCMsgClient__XMsgClient__) */
