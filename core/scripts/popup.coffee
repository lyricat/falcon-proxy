
error = (msg) ->
    $(".prompt").hide()
    $("#error").text(msg).slideDown()

info = (msg) ->
    $(".prompt").hide()
    $("#info").text(msg).slideDown()

basicAuth = (username, password) ->
    return 'Basic ' + encodeBase64(username + ':' + password)

testRequestSpeed = (url, callback) ->
    st = Date.now()
    jQuery.ajax(
        type: "GET", url: url + '', processData: true, data: {rnd: Math.random()},
        success: (data, textStatus, jqXHR) ->
            size = parseInt(jqXHR.getResponseHeader('content-length'))
            duration = Date.now() - st
            rate = (size/duration).toFixed(2)
            callback(duration, rate)
        ,
        error: (jqXHR, textStatus, errorThrown) ->
            if jqXHR.status == 0
                callback(-1, -1)
            else
                size = parseInt(jqXHR.getResponseHeader('content-length'))
                duration = Date.now() - st
                rate = (size/duration).toFixed(2)
                callback(duration, rate)
    )

class QuickProxyApp extends Spine.Controller
    events:
        "change #proxy_switch": "switchProxy"
        "click #speed_test_button": "startSpeedTest"

    elements:
        "#proxy_switch": "proxySwitch"
        "#speed_test_button": "speedTestButton"
        "#sec_mode_username_entry": "secUsernameEntry"
        "#sec_mode_password_entry": "secPasswordEntry"

    constructor: ->
        super
        @sandbox = new SandBoxCtrl('#sandbox')
        @sandbox.register()
        @state = false
        proc = []
        proc.push(() => @initUI(() => $(window).dequeue('init') ) )
        proc.push(() => @fetchData(() => $(window).dequeue('init') ) )
        proc.push(() => @updateState(() => $(window).dequeue('init') ) )
        $(window).queue('init', proc)
        $(window).dequeue('init')

    initUI: (callback) =>
        if not @sandbox.ready
            setTimeout( =>
                    @initUI(callback)
                , 100)
        else
            Logging.info("Init UI")
            @profileList = new ProfileList(
                el: $('#profile_list')
                sandbox: @sandbox
            )
            @profileDetail = new ProfileDetail(
                el: $('#profile_detail_page')
                sandbox: @sandbox
            )
            callback()

    fetchData: (callback) =>
        Logging.info("Fetch data from storage")
        Profile.fetch()
        callback()

    switchProxy: (event) =>
        # turn on/off selected proxy
        if @proxySwitch.prop('checked')
            Agent.enable(@profileList.getCurrent())
            @state = true
        else
            Logging.info("Disable all proxies.")
            Agent.disable()
            @state = false
        @speedTestButton.attr('disabled', @proxySwitch.prop('checked'))

    switchPage: (name) ->
        @el.find('.page:visible').slideUp()
        $("#profile_#{name}_page").slideDown()

    updateState: (callback) =>
        Logging.info("Update proxy status")
        chrome.proxy.settings.get('incognito': false, (config) =>
            controlable = false
            console.log(config)
            if config.levelOfControl == 'controlled_by_this_extension'
                @proxySwitch.attr('checked', true).prop('checked', true)
                controlable = true

            if config.levelOfControl == 'controllable_by_this_extension'
                @proxySwitch.attr('checked', false)
                @proxySwitch.prop('checked', false)
                controlable = true

            if controlable
                if config.value.mode == 'direct'
                    @proxySwitch.attr('checked', false)
                    @proxySwitch.prop('checked', false)
            else
                @proxySwitch.attr({'disabled':true, 'checked': false}).prop({'disabled':true, 'checked': false})
            @speedTestButton.attr('disabled', @proxySwitch.prop('checked'))
            @state = @proxySwitch.prop('checked')
            callback()
        )

    doRequest: (method, url, data, headers, success, error) ->
        jQuery.ajax(
            type: method
            url: url
            processData: (data != null)
            data: data
            beforeSend:
                (xhr) ->
                    for k, v of headers
                        xhr.setRequestHeader(k, v)
                    xhr.overrideMimeType('text/plain; charset=x-user-defined')
            ,
            success: (data) ->
                success(data)
            error: (xhr, textStatus, err) ->
                error(xhr, textStatus, err)
        )

    fakeHTTPAuth: (p, success, error) ->
        Logging.info('Test Authorization')
        headers = {'Authorization': basicAuth(p.username, p.password)}
        @doRequest("GET", "http://google.com", {rnd: Math.random()}, headers, (data) ->
            Logging.info(data)
            if success then success(data)
        , (jqXHR, textStatus, errorThrown) ->
            Logging.error('Failed to Authorize')
            console.log jqXHR, textStatus, errorThrown
            if error then error(jqXHR, textStatus, errorThrown)
        )

    startSpeedTest: () =>
        procs = []
        _load = (name, link) =>
            procs.push(()=>
                @profileList.setPingText(name, 'testing ...')
                testRequestSpeed(link, (duration, rate) =>
                    if duration == -1
                        @profileList.setPingText(name, '??')
                    else
                        Logging.info("#{name}, #{duration}, #{rate} kb/s")
                        @profileList.setPingText(name,(duration/1000.0).toFixed(2)+'s')
                        @profileList.setRateText(name, ', ' + rate + 'kb/s')
                    $(window).dequeue('_test_speed')
                )
            )
        for profile in Profile.all()
            # @TODO
            if profile.type == 'manual' and (profile.scheme == 'http' or profile.scheme=='https')
                @profileList.setPingText(name, 'waiting ...')
                @profileList.setRateText(name, '')
                req_link = profile.scheme+"://"+profile.host+":"+profile.port
                _load(profile.name, req_link)
            else
                @profileList.setPingText(name, '??')
                @profileList.setRateText(name, '')
        $(window).queue('_test_speed', procs)
        $(window).dequeue('_test_speed')

window.app = null
$(document).ready(() ->
    window.app = new QuickProxyApp(el: $('body'))
)

test = () ->
  $('#test_speed_button').click(()->

    return
  )





