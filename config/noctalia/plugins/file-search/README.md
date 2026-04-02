# File Search Plugin

File search using fd, integrated into the launcher.

## Requirements

This plugin requires [fd](https://github.com/sharkdp/fd#installation) to be installed.

## Usage

**Access from launcher**

Type `>file` in the Noctalia launcher to activate file search.

**Toggle file search:**

```bash
noctalia-shell ipc call plugin:file-search toggle
```

**Search with pre-filled query:**

```bash
noctalia-shell ipc call plugin:file-search search "eko"
```
