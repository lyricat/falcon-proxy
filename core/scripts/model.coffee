class Profile extends Spine.Model
    @configure "Profile",
        "name",
        "type",
        "scheme", 
        "pac_url",
        "host", "port",
        "bypass", 
        "use_auth", "username", "password",
        "testlink"

    @extend Spine.Model.Local

    @getByName: (name) ->
        @select((profile) -> profile.name == name)

    toTemplateMapping: ->
        xx = {}
        for k, v of @attributes()
            xx[k] = v
        return xx


 

root = exports ? this
root.Profile = Profile
