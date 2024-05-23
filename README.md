<div align="center">

# asdf-tealdeer [![Build](https://github.com/sarg3nt/asdf-tealdeer/actions/workflows/build.yml/badge.svg)](https://github.com/sarg3nt/asdf-tealdeer/actions/workflows/build.yml) [![Lint](https://github.com/sarg3nt/asdf-tealdeer/actions/workflows/lint.yml/badge.svg)](https://github.com/sarg3nt/asdf-tealdeer/actions/workflows/lint.yml)

[tealdeer](https://github.com/dbrgn/tealdeer) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

- `bash`, `curl` and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).

# Install

Plugin:

```shell
asdf plugin add tealdeer
# or
asdf plugin add tealdeer https://github.com/sarg3nt/asdf-tealdeer.git
```

tealdeer:

```shell
# Show all installable versions
asdf list-all tealdeer

# Install specific version
asdf install tealdeer latest

# Set a version globally (on your ~/.tool-versions file)
asdf global tealdeer latest

# Now tealdeer commands are available
tldr
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/sarg3nt/asdf-tealdeer/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [Dave Sargent](https://github.com/sarg3nt/)
