class ProfileList extends Spine.Controller
    events:
        "click #add_proxy_button": "addProfile"
        "click .mochi_radio": "selectProfile"
        "click .edit": "editProfile"

    constructor: ()->
        super
        Profile.bind("change refresh", @render)

    render: =>
        # use queue CPS to make the process more smooth
        proc = []
        Profile.each((p) =>
            if @el.find('.profile[name="'+p.name+'"]').length == 0
                proc.push(()=>
                    # console.log "render", p.name
                    @add(p, ()->$(window).dequeue('profile'))
                )
        )
        # delete removed profile
        proc.push(=>
            ps = @el.find('.profile')
            for pi in ps
                if Profile.getByName($(pi).attr('name')).length == 0
                    $(pi).attr('delete', true)
            @el.find('.profile[delete]').remove()
            $(window).dequeue('profile')
        )
        proc.push(=>
            @el.find('.profile').show()
            $(window).dequeue('profile')
        )
        $(window).queue('profile', proc)
        $(window).dequeue('profile')
    
    add: (profile, callback) =>
        selected = localStorage.getItem('selected')
        @sandbox.mandate(
            'render',
            {tmpl: 'profile', data: profile.toTemplateMapping()},
            (result) =>
                @el.prepend(result)
                if profile.name == selected
                    @el.find('.mochi_radio[value="'+profile.name+'"]').attr('checked', true).prop('checked', true)
                callback()
        )

    addProfile: (event) =>
        app.profileDetail.reset()
        app.profileDetail.show()
        @hide()

    selectProfile: (event) =>
        btn = $(event.currentTarget)
        p = Profile.getByName(btn.val())
        if p.length == 0
            return
        else
            p = p[0]
        # change the profile ?
        if btn.prop('checked')
            localStorage.setItem("selected", btn.val())
            if app.state
                Agent.enable(p.name)

    editProfile: (event) ->
        btn = $(event.currentTarget)
        p = Profile.getByName(btn.attr('href').substring(1))[0]
        app.profileDetail.setProfile(p)
        app.profileDetail.show()
        @.hide()

    remove: (profile) =>
        @el.find("profile[name=#{profile.name}]").remove()
        Profile.destroy(profile.id)

    getCurrent: () ->
        name = @el.find('.mochi_radio:checked').val()
        return name

    setPingText: (name, text) ->
        $(".mochi_list_item[name=\"#{name}\"]").find('.ping').text(text)

    setRateText: (name, text) ->
        $(".mochi_list_item[name=\"#{name}\"]").find('.rate').text(text)

    show: ->
        $('#profile_list_page').slideDown()

    hide: ->
        $('#profile_list_page').slideUp()

    
root = exports ? this
root.ProfileList = ProfileList

