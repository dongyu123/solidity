# The Solidity Contract-Oriented Programming Language
[![Join the chat at https://gitter.im/ethereum/solidity](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/ethereum/solidity?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Solidity is a statically typed, contract-oriented, high-level language for implementing smart contracts on the Ethereum platform.

## Table of Contents

- [Background](#background)
- [Build and Install](#build-and-install)
- [Example](#example)
- [Documentation](#documentation)
- [Development](#development)
- [Maintainers](#maintainers)
- [License](#license)

## Background

Solidity is a statically-typed curly-braces programming language designed for developing smart contracts
that run on the Ethereum Virtual Machine. Smart contracts are programs that are executed inside a peer-to-peer
network where nobody has special authority over the execution, and thus they allow to implement tokens of value,
ownership, voting and other kinds of logics.

When deploying contracts, you should use the latest released version of Solidity. This is because breaking changes as well as new features and bug fixes are introduced regularly. We currently use a 0.x version number [to indicate this fast pace of change](https://semver.org/#spec-item-4).

## Build and Install

Instructions about how to build and install the Solidity compiler can be found in the [Solidity documentation](https://solidity.readthedocs.io/en/latest/installing-solidity.html#building-from-source).


## Example

A "Hello World" program in Solidity is of even less use than in other languages, but still:

```
pragma solidity ^0.5.0;

contract HelloWorld {
  function helloWorld() external pure returns (string memory) {
    return "Hello, World!";
  }
}
```

To get started with Solidity, you can use [Remix](https://remix.ethereum.org/), which is an
browser-based IDE. Here are some example contracts:

1. [Voting](https://solidity.readthedocs.io/en/v0.4.24/solidity-by-example.html#voting)
2. [Blind Auction](https://solidity.readthedocs.io/en/v0.4.24/solidity-by-example.html#blind-auction)
3. [Safe remote purchase](https://solidity.readthedocs.io/en/v0.4.24/solidity-by-example.html#safe-remote-purchase)
4. [Micropayment Channel](https://solidity.readthedocs.io/en/v0.4.24/solidity-by-example.html#micropayment-channel)

## Documentation

The Solidity documentation is hosted at [Read the docs](https://solidity.readthedocs.io).

## Development

Solidity is still under development. Contributions are always welcome!
Please follow the
[Developers Guide](https://solidity.readthedocs.io/en/latest/contributing.html)
if you want to help.

## Maintainers
* [@axic](https://github.com/axic)
* [@chriseth](https://github.com/chriseth)

## License
Solidity is licensed under [GNU General Public License v3.0](LICENSE.txt).

Some third-party code has its [own licensing terms](cmake/templates/license.h.in).

Any contributions are welcome!

# Formal Verification Extension

This is an extended version of the compiler that is able to perform automated formal verification on Solidity code using annotations and modular program verification. For more information on building, installing and examples, see [SOLC-VERIFY-README.md](SOLC-VERIFY-README.md).

A preliminary [paper](https://arxiv.org/abs/1907.04262) was also presented at [VSTTE'19](https://sri-csl.github.io/VSTTE19/) but the tool had major improvements since then. Up-to-date information can be found in [SOLC-VERIFY-README.md](SOLC-VERIFY-README.md).
