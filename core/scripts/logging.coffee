class Logging
    @log: (msg) ->
        if console
            console.log(msg)

    @error: (msg) ->
        if console
            console.error(msg)

    @warn: (msg) ->
        if console
            console.warn(msg)

    @info: (msg, level=0) ->
        space = (n) ->
            s = ''
            s += '  ' for i in [0...n]
            return s
        if console
            console.log((new Date()).toLocaleTimeString(), space(level), msg)

root = exports ? this
root.Logging = Logging
