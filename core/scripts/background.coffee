setIcon = (st) ->
    switch st
        when "on"
            chrome.browserAction.setIcon({path:"image/icon_mono_on.png"})
        when "on_sec"
            chrome.browserAction.setIcon({path:"image/icon_mono_on.png"})
        when "off_alt"
            chrome.browserAction.setIcon({path:"image/icon_mono_off.png"})
            chrome.browserAction.setTitle({title: "Proxy disabled, use system settings"})
        else
            chrome.browserAction.setIcon({path:"image/icon_mono_off.png"})
            chrome.browserAction.setTitle({title: "Proxy disabled."})

setConnStat = (text) ->
    chrome.browserAction.setTitle({title: "Connect to #{text}"})

checkStatus = (isLoop, callback)->
    chrome.proxy.settings.get(
        'incognito': false,
        (config)->
            updateStatus(config)
            if isLoop == false
                setTimeout(checkStatus, 1000 * 30)
            if callback
                callback(config)
    )

updateStatus = (config)->
    controlable = false
    if config.levelOfControl == 'controlled_by_this_extension'
        if config.value.mode == 'fixed_servers' and config.value.rules.singleProxy.scheme == 'https'
            setIcon('on_sec')
        else if config.value.mode == 'system'
            setIcon('off_alt')
        else
            setIcon('on')
        controlable = true
    if config.levelOfControl == 'controllable_by_this_extension'
        setIcon('off')
        controlable = true
    if controlable
        if config.value.mode == 'direct'
            setIcon('off')
    else
      setIcon('off')
  

chrome.runtime.onMessage.addListener(
    (request, sender, sendResponse) ->
        switch request.msg
            when 'update_status'
                checkStatus(false, (config) ->
                    sendResponse({status: 'ok', config: JSON.stringify(config)})
                )
            when 'set_icon'
                setIcon(request.name)
                sendResponse({status: 'ok'})
            when 'set_conn_stat'
                setConnStat(request.name)
                sendResponse({status: 'ok'})
        return true
)
