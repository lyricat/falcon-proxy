class ProfileDetail extends Spine.Controller
    events:
        "click .detail_delete_button": "deleteProfile"
        "click .detail_save_button": "save"
        "click .detail_cancel_button": "discard"
        "click .proxy_type_button_group a": "switchProxyType"
        "click .auth_proxy_toggle": "switchAuth"

    elements:
        ".action_id": "actionId"
        ".proxy_name_entry": "proxyNameEntry"
        ".proxy_type_button_group": "proxyTypeButtonGroup"
        ".pac_url_entry":"pacUrlEntry"
        ".scheme_combo": "schemeCombo"
        ".host_entry": "hostEntry"
        ".port_entry": "portEntry"
        ".bypass_entry": "bypassEntry"
        ".auth_proxy_toggle": "authToggle"
        ".auth_proxy_block": "authBlock"
        ".username_entry": "usernameEntry"
        ".password_entry": "passwordEntry"
        ".detail_delete_button": "deleteButton"

    constructor: ->
        super

    render: =>
        @el.empty()

    switchProxyType: (event) =>
        type = @getProxyType()
        @el.find('.block').hide()
        @el.find(".#{type}_proxy_block").show()

    getProxyType: () ->
        return @proxyTypeButtonGroup.find(".selected").attr('href').substring(1)

    deleteProfile: (event) =>
        name = @proxyNameEntry.val()
        p = Profile.getByName(name)
        if p.length == 0
            return
        p = p[0]
        Profile.destroy(p.id)
        # switch page
        @.hide()
        app.profileList.show()

    switchAuth: (event) =>
        if @authToggle.prop('checked')
            @authBlock.slideDown()
        else
            @authBlock.slideUp()

    save: (event) =>
        act = @actionId.val()
        p = null
        if act == 'add'
            p = new Profile()
            p.name = $.trim(@proxyNameEntry.val())
            p.selected = false
            p.testlink = ""
        else
            name = $.trim(@proxyNameEntry.val())
            p = Profile.getByName(name)
            if p.length == 0
                Logging.error("Error: no such a profile named `#{name}`")
                return
            p = p[0]
        p.type = @getProxyType()
        p.scheme = @schemeCombo.val()
        p.pac_url = $.trim(@pacUrlEntry.val())
        p.host = $.trim(@hostEntry.val())
        p.port = $.trim(@portEntry.val())
        bypass = $.trim(@bypassEntry.val())
        if bypass.length == 0
            p.bypass = []
        else
            p.bypass = bypass.split(',').map((x)->x.trim())
        p.use_auth = $('.auth_proxy_toggle').prop('checked')
        p.username = $.trim(@usernameEntry.val())
        p.password = @passwordEntry.val()
        p.save()
        if localStorage.getItem('selected') == p.name and app.state
            # if QP is using it, update settings.
            Agent.enable(p.name)
        # switch page
        @.hide()
        app.profileList.show()

    discard: =>
        # switch page
        @.hide()
        app.profileList.show()

    setProfile: (profile) ->
        @el.find('.block').hide()
        @el.find(".#{profile.type}_proxy_block").show()
        @actionId.val('edit')
        @deleteButton.css('visibility', 'visible')
        @proxyNameEntry.val(profile.name).prop('disabled', true)
        @proxyTypeButtonGroup.find('.selected').removeClass('selected')
        @proxyTypeButtonGroup.find("a[href=\##{profile.type}]").addClass('selected')
        #
        @schemeCombo.val(profile.scheme)
        @pacUrlEntry.val(profile.pac_url)
        @hostEntry.val(profile.host)
        @portEntry.val(profile.port)
        @authToggle.attr('checked', profile.use_auth)
        @authToggle.prop('checked', profile.use_auth)
        if profile.use_auth
            @authBlock.show()
        else
            @authBlock.hide()
        @bypassEntry.val(profile.bypass)
        @usernameEntry.val(profile.username)
        @passwordEntry.val(profile.password)

    reset: ->
        @el.find('.block').hide()
        @el.find(".off_proxy_block").show()
        @actionId.val('add')
        @deleteButton.css('visibility', 'hidden')
        @proxyNameEntry.val("").prop('disabled', false)
        @proxyTypeButtonGroup.find("a[href=off]").addClass('selected')
        #
        @pacUrlEntry.val("")
        @hostEntry.val("")
        @portEntry.val("")
        @authToggle.attr('checked', false).prop('checked', false)
        @authBlock.hide()
        @bypassEntry.val("<local>")
        @usernameEntry.val("")
        @passwordEntry.val("")

    toggleAuth: (event) ->
        # Authorization? but not support yet.
        if @authToggle.prop('checked')
            @authBlock.slideDown()
        else
            @authBlock.slideUp()

    show: ->
        @el.slideDown()

    hide: ->
        @el.slideUp()
    
root = exports ? this
root.ProfileDetail = ProfileDetail

