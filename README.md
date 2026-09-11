# black-desk curl feedstock

This repository builds the `curl`, `libcurl`, and `libcurl-static` packages
with [rattler-build](https://github.com/prefix-dev/rattler-build).

`libcurl` includes a wrapper around `curl-config`. During conda-build or
rattler-build, the wrapper reports the conda package itself. In an ordinary
activated conda environment, it prefers `/usr/bin/curl-config` when available so
that interactive source builds do not accidentally mix conda headers with the
host compiler. Set `CURL_CONFIG_NO_SYSTEM_FALLBACK=1` to opt out.

The upstream recipe is maintained at
[conda-forge/curl-feedstock](https://github.com/conda-forge/curl-feedstock).
