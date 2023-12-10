// SPDX-License-Identifier: GPL-3.0-only
pragma solidity >=0.7.0 <0.8.20;

import "./Enum.sol";
import "./SignatureDecoder.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";

interface GnosisSafe {
    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction.
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation
    ) external returns (bool success);
}

contract CrossSafe is SignatureDecoder, CCIPReceiver {

    address public safe;

    constructor(address router, address _safe) CCIPReceiver(router) {
        safe = _safe;
    }

    string public constant NAME = "xSafeController Module";
    string public constant VERSION = "0.1.0";

    event MessageReceived(
        bytes32 indexed messageId, // The unique ID of the message.
        uint64 indexed sourceChainSelector, // The chain selector of the source chain.
        address sender, // The address of the sender from the source chain.
        string text // The text that was received.
    );

    bytes32 public s_lastReceivedMessageId; // Store the last received messageId.
    string public s_lastReceivedText; // Store the last received text.

    function _ccipReceive(
        Client.Any2EVMMessage memory any2EvmMessage
    ) internal override {
        s_lastReceivedMessageId = any2EvmMessage.messageId; // fetch the messageId
        s_lastReceivedText = abi.decode(any2EvmMessage.data, (string)); // abi-decoding of the sent text

        // (uint256 value, address to, bytes memory data) = abi.decode(any2EvmMessage.data, (uint256, address, bytes));

        // exec(to, data, value);

        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector, // fetch the source chain identifier (aka selector)
            abi.decode(any2EvmMessage.sender, (address)), // abi-decoding of the sender address,
            abi.decode(any2EvmMessage.data, (string))
        );
    }

    function getLastReceivedMessageDetails()
        external
        view
        returns (bytes32 messageId, string memory text)
    {
        return (s_lastReceivedMessageId, s_lastReceivedText);
    }

    function exec(address to, bytes memory data, uint256 value) internal  {
        require(GnosisSafe(safe).execTransactionFromModule(to, value, data, Enum.Operation.Call), "Could not execute transaction call");
    }
}