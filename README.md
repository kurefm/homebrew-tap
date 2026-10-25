# Kurefm Tap

## How do I install these formulae?

`brew install kurefm/tap/<formula>`

Or `brew tap kurefm/tap` and then `brew install <formula>`.

## Available formulae

- [REA](https://github.com/morluto/rea): `brew install kurefm/tap/rea`
- [Ghidra 12.1](https://github.com/NationalSecurityAgency/ghidra): `brew install kurefm/tap/ghidra@12.1`
- [jadx-headless-mcp](https://github.com/1013503897/jadx-headless-mcp): `brew install kurefm/tap/jadx-headless-mcp`

Installing REA also installs `ghidra@12.1` and `jadx-headless-mcp` from this tap.
REA 6.8.0 supports Ghidra 12.1.x, with 12.1.4 as its verified version; Ghidra 12.2
is not supported. Install REA with:

```sh
brew install kurefm/tap/rea
```

The `rea` and `rea-agents` launchers set `GHIDRA_INSTALL_DIR`, `REA_JADX_MCP_JAR`
and `JAVA_HOME` to the installed backends and JDK 21 by default. Existing environment
values take precedence; no manual exports are required.

`ghidra@12.1` is keg-only, so it can coexist with the current `ghidra` formula.
REA 6.8.0 requires Node.js `^22.23.4 || ^24.22.1 || >=26.12.1`.

Both backends depend on `openjdk@21` and use JDK 21 by default.

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
