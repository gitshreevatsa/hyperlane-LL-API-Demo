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

//Given in docs

    ILiquidityLayerRouter liquidityLayer =
        ILiquidityLayerRouter(0x2abe0860D81FB4242C748132bD69D125D88eaE26);
//Given in docs

    IInterchainGasPaymaster igp =
        IInterchainGasPaymaster(0xF987d7edcb5890cB321437d8145E3D51131298b6);
        
//events are for debugging

    event message(bytes32 message);
    event recieve(
        uint32 _origin,
        bytes32 _sender,
        bytes _message,
        address _token,
        uint256 _amount
    );

// executes a message with USDC transfer 
// _bridge = Portal 
// _messageBody = 0x00
// _amount to be approved importing the USDC code which is a erc 20 contract on mumbai network as I had funds in that, addresses can be found below 


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



// USDC ADDRESS MUMBAI : 0x0FA8781a83E46826621b3BC094Ea2A0212e71B23
// LL CONTRACT ADDRESS MUMBAI : 0xdB9a4936dEDE3DB864730AB85c8b947fe249A628
// LL CONTRACT ADDRESS ALJAFORES : 0x57339eA16a58e53f6Eb64fa31787FcE6117B5af3

// Reciepient address for MUMBAI : 0x00000000000000000000000057339ea16a58e53f6eb64fa31787fce6117b5af3
// Reciepeint address for Alfajores : 0x000000000000000000000000db9a4936dede3db864730ab85c8b947fe249a628




