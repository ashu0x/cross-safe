// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity >=0.7.0 <0.8.20;

/// @title Enum - Collection of enums
/// @author Richard Meissner - <richard@gnosis.pm>
contract Enum {
    enum Operation {
        Call,
        DelegateCall
    }
}