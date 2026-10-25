# Kurefm Tap

## How do I install these formulae?

`brew install kurefm/tap/<formula>`

Or `brew tap kurefm/tap` and then `brew install <formula>`.

## Available formulae

- [REA](https://github.com/morluto/rea): `brew install kurefm/tap/rea`
- [jadx-headless-mcp](https://github.com/1013503897/jadx-headless-mcp): `brew install kurefm/tap/jadx-headless-mcp`

For REA's Android APK analysis, we recommend installing jadx-headless-mcp separately
(it installs OpenJDK), then configuring the JAR path and a full JDK 17+:

```sh
brew install kurefm/tap/jadx-headless-mcp
export REA_JADX_MCP_JAR="$(brew --prefix jadx-headless-mcp)/libexec/jadx-headless-mcp.jar"
export PATH="$(brew --prefix openjdk)/bin:$PATH"
```

If `JAVA_HOME` is set, it must point to a full JDK 17+.

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
