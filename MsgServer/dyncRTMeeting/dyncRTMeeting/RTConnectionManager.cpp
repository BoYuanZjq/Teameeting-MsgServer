//
//  RTConnectionManager.cpp
//  dyncRTMeeting
//
//  Created by hp on 12/3/15.
//  Copyright (c) 2015 hp. All rights reserved.
//

#include "RTConnectionManager.h"
#include <assert.h>
#include "md5.h"
#include "md5digest.h"
#include "OSMutex.h"
#include "RTRoomManager.h"

static char          s_curMicroSecStr[32];
static unsigned char s_digest[16];
static OSMutex       s_mutex;

void RTConnectionManager::GenericSessionId(std::string& strId)
{
    SInt64 curTime = OS::Microseconds();
    MD5_CTX context;
    StrPtrLen hashStr;
    OSMutexLocker locker(&s_mutex);
    memset(s_curMicroSecStr, 0, 128);
    memset(s_digest, 0, 16);
    qtss_sprintf(s_curMicroSecStr, "%lld", curTime);
    MD5_Init(&context);
    MD5_Update(&context, (unsigned char*)s_curMicroSecStr, (unsigned int)strlen((const char*)s_curMicroSecStr));
    MD5_Update(&context, (unsigned char*)m_lastUpdateTime.c_str(), (unsigned int)m_lastUpdateTime.length());
    MD5_Final(s_digest, &context);
    HashToString(s_digest, &hashStr);
    strId = hashStr.GetAsCString();
    m_lastUpdateTime = s_curMicroSecStr;
}


RTConnectionManager::ModuleInfo* RTConnectionManager::findModuleInfo(const std::string& userid, TRANSFERMODULE module)
{
    RTConnectionManager::ModuleInfo* pInfo = NULL;
    RTConnectionManager::ModuleInfoMaps* maps = GetModuleInfo();
    RTConnectionManager::ModuleInfoMaps::iterator it = maps->begin();
    for (; it!=maps->end(); it++) {
        if ((it->second) && (it->second)->othModuleType == module) {
            pInfo = it->second;
            break;
        }
    }
    return pInfo;
}

bool RTConnectionManager::ConnectConnector()
{
    if (m_ipList.size() == 0) {
        return false;
    }
    std::list<std::string>::iterator it;
    for (it=m_ipList.begin(); it!=m_ipList.end(); it++) {
        std::string s = *it;
        char ip[16] = {0};
        unsigned int port = 0;
        sscanf(s.c_str(), "%s %u", ip, &port);
        printf("ip:%s, port:%u\n", ip, port);
        if (strlen(ip)>0 && port > 8192) {
            DoConnectConnector(ip, port);
        }
    }
    return true;
}

bool RTConnectionManager::DoConnectConnector(const std::string ip, unsigned short port)
{
    RTTransferSession* connectorSession = new RTTransferSession();
    connectorSession->Init();
    // conn to connector
    
    while(!connectorSession->Connect(ip, port)) {
        LI("connecting to connector server %s:%u, waiting...\n", ip.c_str(), port);
        sleep(1);
    }
    connectorSession->EstablishConnection();
    return true;
}

void RTConnectionManager::RefreshConnection()
{
    if (GetModuleInfo()->size()==0) {
        return;
    }
    ModuleInfo* pmi = NULL;
    ModuleInfoMaps::iterator it = GetModuleInfo()->begin();
    for (; it!=GetModuleInfo()->end(); it++) {
        pmi = it->second;
        if (pmi && pmi->othModuleType == TRANSFERMODULE::mconnector) {
            if (pmi->pModule->RefreshTime()) {
                pmi->pModule->KeepAlive();
            }
        }
    }
}


bool RTConnectionManager::AddModuleInfo(RTConnectionManager::ModuleInfo* pmi, const std::string& sid)
{
    GetModuleInfo()->insert(make_pair(sid, pmi));
    return true;
}

bool RTConnectionManager::DelModuleInfo(const std::string& sid)
{
    ModuleInfo* pmi = NULL;
    ModuleInfoMaps::iterator it = GetModuleInfo()->find(sid);
    if (it!=GetModuleInfo()->end()) {
        pmi = it->second;
        if (pmi && pmi->othModuleType == TRANSFERMODULE::mmsgqueue) {
            LE("RTConnectionManager::DelModuleInfo sid:%s\n", sid.c_str());
            RTRoomManager::Instance()->ClearMsgQueueSession(sid);
        }
        GetModuleInfo()->erase(sid);
        pmi = NULL;
    }
    return true;
}

bool RTConnectionManager::AddTypeModuleSession(TRANSFERMODULE mtype, const std::string& mid, const std::string& sid)
{
    bool found = false;
    TypeModuleSessionInfoLists* infoList = GetTypeModuleSessionInfo();
    TypeModuleSessionInfoLists::iterator it = infoList->begin();
    TypeModuleSessionInfo* pInfo = NULL;
    for (; it!=infoList->end(); it++) {
        if ((*it) && (*it)->moduleId.compare(mid) == 0) {
            pInfo = *it;
            found = true;
            break;
        }
    }
    if (found) {
        pInfo->sessionIds.push_front(sid);
    } else {
        pInfo = new TypeModuleSessionInfo();
        pInfo->moduleType = mtype;
        pInfo->moduleId = mid;
        pInfo->sessionIds.push_front(sid);
        infoList->push_front(pInfo);
    }
    return true;
}

bool RTConnectionManager::DelTypeModuleSession(const std::string& sid)
{
    bool found = false;
    TypeModuleSessionInfoLists* infoList = GetTypeModuleSessionInfo();
    TypeModuleSessionInfoLists::iterator it = infoList->begin();
    TypeModuleSessionInfo* pInfo = NULL;
    for (; it!=infoList->end(); it++) {
        pInfo = *it;
        std::list<std::string>::iterator sit = std::find(pInfo->sessionIds.begin(), pInfo->sessionIds.end(), sid);
        if (sit!=pInfo->sessionIds.end()) {
            pInfo->sessionIds.erase(sit);
            found = true;
        }
        
    }
    return found;
}

void RTConnectionManager::TransferSessionLostNotify(const std::string& sid)
{
    DelModuleInfo(sid);
    DelTypeModuleSession(sid);
    LI("RTConnectionManager::TransferSessionLostNotify sessionid:%s\n", sid.c_str());
}
