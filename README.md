# crubot

*(If you are RX14: replace "crubot" with "crystal" mentally when reading
anything here.)*

crubot is a Crystal reimplementation of [rubot](https://github.com/meew0/rubot)
using [discordcr](https://github.com/meew0/discordcr) and
[kemal](https://github.com/sdogruyol/kemal). It isn't specifically optimised for
performance or memory usage but should be more performant regardless.

## Installation

Make sure you have [Crystal](https://crystal-lang.org/) installed. Then, clone
the repo, run
```
crystal deps
```
to install dependencies, and run
```
crystal build --release src/crubot.cr
```
to build crubot to `./crubot`.

## Usage

First, configure a webhook that points to your server, port 3000 by default
(although you can change that). Make sure to configure a secret of some sort.
The content type should be JSON; you can select the events you want.

Then, make sure you have a `crubot-auth` file in the directory you're running it
from, that has the following format:

```
Bot token.token.token
12345678
secret
```

The first line should be the token for your Discord bot (prefixed with "Bot"),
the second should be the bot's client ID, and the third should be the secret
you configured on the webhook.

You can invoke crubot with `-h` to get a list of options you can set, like the
port and SSL options. If you don't need any of that, just run `./crubot` and
use it. To configure a repo as being linked to a particular channel, use
`crubot, link this: meew0/crubot` in that channel (obviously replacing the repo
with yours).

## Contributing

1. Fork it (https://github.com/meew0/crubot/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [meew0](https://github.com/meew0) - creator, maintainer
