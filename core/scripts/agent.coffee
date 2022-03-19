class Agent
    @enable: (name) ->
        profile = Profile.getByName(name)
        if profile.length != 0
            profile = profile[0]
            try
                Logging.info("Enable Proxy: `#{profile.name}`, #{profile.type}")
                if profile.type == 'auto'
                    Agent.enableProxyAuto(profile)
                else if profile.type == 'manual'
                    Agent.enableProxyManual(profile)
                else if profile.type == 'system'
                    Agent.enableProxySystem(profile)
                else # off
                    Agent.setIcon('off')
                    return
                # set icon and tooltips
                if profile.scheme == 'https'
                    Agent.setIcon('on_sec')
                    Agent.setConnStat(name)
                else
                    Agent.setIcon('on')
                    Agent.setConnStat(name)
            catch e
                Logging.error(e)
                Agent.setIcon('off')

    @enableProxyManual: (profile) ->
        # @TODO
        # if profile.use_auth
        #  fakeHTTPAuth(profile)
        config = {
            mode: "fixed_servers",
            rules: {
                singleProxy: {
                    scheme: profile.scheme,
                    host: profile.host,
                    port: parseInt(profile.port)
                },
                bypassList: profile.bypass or []
            }
        }
        chrome.proxy.settings.set({value: config, scope: 'regular'}, ()-> 
            if profile.use_auth
                app.fakeHTTPAuth(profile)
        )

    @enableProxyAuto: (profile) ->
        setProxy = (result) ->
            result = result.replace(/[^\x00-\xff]/g, '')
            config = {
                mode: "pac_script",
                pacScript: {
                    data: result
                }
            }
            chrome.proxy.settings.set({value: config, scope: 'regular'}, ()-> )

        $.ajax({url: profile.pac_url, cache: false }).done((data, textStatus, jqXHR) ->
            setProxy(data)
        ).fail((jqXHR, txt, err) ->
            setProxy(jqXHR.responseText)
        )

    @enableProxySystem: () ->
        config = {
            mode: "system"
        }
        chrome.proxy.settings.set({value:config,scope:'regular'}, ()->
            Agent.setIcon('off_alt')
        )

    @disable: () ->
        config = {
            mode: "direct"
        }
        chrome.proxy.settings.set({value:config,scope:'regular'},()->
            Agent.setIcon('off')
        )

    @setIcon: (name) ->
        chrome.runtime.sendMessage({msg: 'set_icon', name: name}, () -> )
        return

    @setConnStat: (name) ->
        chrome.runtime.sendMessage({msg: 'set_conn_stat', name: name}, () -> )
        return



root = exports ? this
root.Agent = Agent

