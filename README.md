# Falcon Proxy

For some reasons, google took out this extension from the Chrome web store. So I decide to open source it.

## How to build

The extension is written in [CoffeeScript]([https://](https://coffeescript.org/)) and build using [Cake](https://coffeescript.org/v1/annotated-source/cake.html). 

All dependencies are put in the `scripts/` folder, them are:

- spine.js, spine.local.js, spine.route.js: old-fashioned way to create a web-app.
- mochi.js: which is a UI library I used to build the extension, you can read the source code [here](https://github.com/lyricat/mochi)
- jquery.js and base64.js
- doT.min.js: the template engine I use to render the UI.

Yes, it's not a modern Web application. 

## Looking for maintainers

I am not using falcon-proxy anymore. I prefer to use other way to access the Internet via Proxy or VPN. However, the extension is still useful for a lot of people. So I'd like to open source it, and look for maintainer.

## Alternative?

I don't use any similar extension, but I find [SwitchyOmega](https://github.com/FelisCatus/SwitchyOmega) may be a good alternative. It's opensource, has a lot of features and supports both Chrome and Firefox.
