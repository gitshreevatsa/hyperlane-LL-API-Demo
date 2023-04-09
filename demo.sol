// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity >=0.6.11;

interface ILiquidityLayerRouter {
    function dispatchWithTokens(
        uint32 _destinationDomain,
        bytes32 _recipientAddress,
        address _token,
        uint256 _amount,
        string calldata _bridge,
        bytes calldata _messageBody
    ) external returns (bytes32);
}

interface ILiquidityLayerMessageRecipient {
    function handleWithTokens(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message,
        address _token,
        uint256 _amount
    ) external;
}

interface IInterchainGasPaymaster {
    /**
     * @notice Emitted when a payment is made for a message's gas costs.
     * @param messageId The ID of the message to pay for.
     * @param gasAmount The amount of destination gas paid for.
     * @param payment The amount of native tokens paid.
     */
    event GasPayment(
        bytes32 indexed messageId,
        uint256 gasAmount,
        uint256 payment
    );

    function payForGas(
        bytes32 _messageId,
        uint32 _destinationDomain,
        uint256 _gasAmount,
        address _refundAddress
    ) external payable;

    function quoteGasPayment(uint32 _destinationDomain, uint256 _gasAmount)
        external
        view
        returns (uint256);
}

contract demo {
    ILiquidityLayerRouter liquidityLayer =
        ILiquidityLayerRouter(0x2abe0860D81FB4242C748132bD69D125D88eaE26);

    IInterchainGasPaymaster igp =
        IInterchainGasPaymaster(0xF987d7edcb5890cB321437d8145E3D51131298b6);

    event message(bytes32 message);
    event recieve(
        uint32 _origin,
        bytes32 _sender,
        bytes _message,
        address _token,
        uint256 _amount
    );

    function lowLevelCall(
        uint32 _destinationDomain,
        bytes32 _recipientAddress,
        address _token,
        uint256 _amount,
        string calldata _bridge,
        bytes calldata _messageBody
    ) public payable {
        bytes32 messageId = liquidityLayer.dispatchWithTokens(
            _destinationDomain,
            _recipientAddress,
            _token,
            _amount,
            _bridge,
            _messageBody
        );

        emit message(messageId);

        igp.payForGas{value: msg.value}(
            // The ID of the message
            messageId,
            // Destination domain
            _destinationDomain,
            // The total gas amount. This should be the
            // overhead gas amount (280,000 gas) + gas used by the call being made.
            // For example, if the handleWithTokens function uses 120,000 gas,
            // we pay for 400k gas.
            400000,
            // Refund the msg.sender
            msg.sender
        );
    }

    function handleWithTokens(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message,
        address _token,
        uint256 _amount
    ) external {
        emit recieve(_origin, _sender, _message, _token, _amount);
    }
}
