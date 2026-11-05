# gbe-steamrt

[gbe_fork](https://github.com/Detanup01/gbe_fork) (Steam client emulator) built
inside the Steam Runtime 4 SDK (`registry.gitlab.steamos.cloud/steamrt/steamrt4/sdk`)
for cs2-docker.

Releases mirror upstream release tags (`release-YYYY_MM_DD`). A weekly job
builds the newest upstream `release-*` tag if there is no release for it yet.
Bumping `REVISION` rebuilds the same tag and replaces its release (the
`revision=` line in the release notes records which build it is).

Asset `gbe-linux-x64.tar.gz`:

| File | From |
|---|---|
| `libsteam_api.so` | `api_regular` |
| `steamclient.so` | `steamclient_regular` |
| `libsteamnetworkingsockets.so` | `lib_steamnetworkingsockets` |
| `generate_interfaces` | `tool_generate_interfaces` (linked with pthread) |
| `BUILDINFO` | upstream tag/commit, revision, toolchain |

Local build:

```bash
docker build --build-arg UPSTREAM_REF=release-2026_09_27 --output type=local,dest=out .
```
