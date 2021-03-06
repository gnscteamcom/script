local NGCPDlg = require 'ngcp.dlgcnt'
local NGCPDlgVar = require 'ngcp.dlg_var'
require 'ngcp.avp'
require 'ngcp.utils'

local dlg
-- list of keys that we need to keep track by pair
local pair_keys = {
    'total',
    'local',
    'relay',
    'incoming',
    'outgoing'
};
local dlg_callid = NGCPDlgVar:new("lua_dlg_callid");

local function dlg_init()
    if not dlg then
        dlg = NGCPDlg:new()
        -- set config
        dlg.config.central.host = "127.0.0.1"
        dlg.config.central.port = "6379"
        dlg.config.central.db = "3"
        dlg.config.pair.host = "127.0.0.1"
        dlg.config.pair.port = "6379"
        dlg.config.pair.db = "4"
    end
end

local function _set_dlg_profile(callid, key1, opt)
    local key = key1
    if opt then
        key = key .. ":" .. opt
    end
    set_dlg_profile(callid, key)
end

local function set_dlg_profile_totals(callid, vtype, out)
    local avp = NGCPAvp:new(vtype.."_uuid");
    local type_uuid = avp();
    local type_account_id = sr.pv.get("$var("..vtype.."_account_id)");

    _set_dlg_profile(callid, "total");
    _set_dlg_profile(callid, "totaluser", type_uuid);
    _set_dlg_profile(callid, "totalaccount", type_account_id);
    if out then
        _set_dlg_profile(callid, "totaluserout", type_uuid);
        _set_dlg_profile(callid, "totalaccountout", type_account_id);
    end
end

local function set_dlg_profile_user(callid, vtype, out)
    local avp = NGCPAvp:new(vtype.."_uuid");
    local type_uuid = avp();
    local type_account_id = sr.pv.get("$var("..vtype.."_account_id)");

    _set_dlg_profile(callid, "user", type_uuid);
    _set_dlg_profile(callid, "account", type_account_id);
    if out then
        _set_dlg_profile(callid, "userout", type_uuid);
        _set_dlg_profile(callid, "accountout", type_account_id);
    end
end

local function set_dlg_callid(callid)
    if not dlg_callid() then
        dlg_callid(callid);
    end
end

function get_profile_size(key, avp)
    local avp = NGCPAvp:new(avp);
    dlg_init()
    local val = dlg:get(key)
    avp:clean()
    avp(val)
end

function set_dlg_profile(callid, key)
    if not callid then error("parameter callid is null") end
    if not key then error("parameter key is null") end
    dlg_init()
    if table.contains( pair_keys, key) then
        if not dlg:is_in_set(callid, key) then
            dlg:set(callid, key)

        end
    else
        dlg:set(callid, key)
    end
    set_dlg_callid(callid)
end

function del_dlg_profile(callid)
    dlg_init()
    if not callid or callid == "123" then
        callid = dlg_callid()
        if callid then
            sr.log("dbg", string.format("callid from $dlg_var:%s", callid))
        else
            error("can't restore callid from $dlg_var(lua_dlg_callid): is null")
        end
    end
    if dlg:exists(callid) then
        dlg:del(callid)
    else
        sr.log("info", string.format("counters for callid[%s] not found",
            callid))
    end
end

function del_dlg_profile_peer(callid)
    local avp = NGCPAvp:new("lcr_flags");
    local val = avp();

    dlg_init()
    if not callid or callid == "123" then
        callid = dlg_callid()
        if callid then
            sr.log("dbg", string.format("callid from $dlg_var:%s", callid))
        else
            error("can't restore callid from $dlg_var(lua_dlg_callid): is null")
        end
    end
    dlg:del_key(callid, "peer:" .. val)
    dlg:del_key(callid, "peerout:" .. val)
    dlg:del_key(callid, "relay")
end

function set_dlg_profile_peer(callid)
    local avp = NGCPAvp:new("lcr_flags");
    local val = avp();

    _set_dlg_profile(callid, "peer", val)
    _set_dlg_profile(callid, "peerout", val)
    _set_dlg_profile(callid, "relay")
end

function set_dlg_profile_caller_totals(callid)
    set_dlg_profile_totals(callid, "caller", true)
end

function set_dlg_profile_callee_totals(callid)
    set_dlg_profile_totals(callid, "callee", nil)
end

function set_dlg_profile_caller(callid)
    set_dlg_profile_user(callid, "caller", true)
end

function set_dlg_profile_callee(callid)
    set_dlg_profile_user(callid, "callee", nil)
end
