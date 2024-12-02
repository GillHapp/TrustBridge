// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Importing ERC20 interface
interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract TradeContract {
    uint256 public tradeID = 1;

    struct Proposal {
        address buyer;
        address seller;
        address tokenAddress;
        uint256 nativeAmount; // Amount of native token the buyer is willing to send
        uint256 goodsAmount; // Amount of ERC20 tokens the buyer wants to receive
        bool isAccepted; // Whether the proposal has been accepted by the seller
        bool buyerClaimed; // Whether the buyer has claimed their tokens
        bool sellerClaimed; // Whether the seller has claimed their native tokens
    }

    // Mapping of trade ID to Proposal
    mapping(uint256 => Proposal) public proposals;

    // Events
    event ProposalCreated(
        uint256 tradeID,
        address indexed buyer,
        address indexed seller,
        address tokenAddress,
        uint256 nativeAmount,
        uint256 goodsAmount
    );
    event ProposalAccepted(uint256 tradeID, address indexed seller);
    event BuyerClaimed(
        uint256 tradeID,
        address indexed buyer,
        uint256 goodsAmount
    );
    event SellerClaimed(
        uint256 tradeID,
        address indexed seller,
        uint256 nativeAmount
    );

    function createProposal(
        address _seller,
        address _tokenAddress,
        uint256 _nativeAmount,
        uint256 _goodsAmount
    ) external payable {
        uint256 nativeAmountInWei = _nativeAmount * 1 ether;
        require(
            msg.value >= nativeAmountInWei,
            "Insufficient native token amount sent"
        );

        // Create a new proposal
        Proposal memory newProposal = Proposal({
            buyer: msg.sender,
            seller: _seller,
            tokenAddress: _tokenAddress,
            nativeAmount: nativeAmountInWei,
            goodsAmount: _goodsAmount,
            isAccepted: false,
            buyerClaimed: false,
            sellerClaimed: false
        });

        proposals[tradeID] = newProposal;

        emit ProposalCreated(
            tradeID,
            msg.sender,
            _seller,
            _tokenAddress,
            nativeAmountInWei,
            _goodsAmount
        );
        tradeID++;
    }

    // Function for the seller to accept a proposal
    function acceptProposal(uint256 _tradeID) external {
        Proposal storage proposal = proposals[_tradeID];

        // Ensure only the seller can accept the proposal
        require(
            msg.sender == proposal.seller,
            "Only the seller can accept the proposal"
        );
        require(!proposal.isAccepted, "Proposal already accepted");

        // Check if the seller has enough ERC20 tokens to fulfill the trade
        IERC20 goodsToken = IERC20(proposal.tokenAddress);
        uint256 sellerBalance = goodsToken.balanceOf(proposal.seller);
        require(
            sellerBalance >= proposal.goodsAmount,
            "Seller does not have enough goods tokens"
        );

        // Transfer ERC20 goods tokens from the seller to the contract
        require(
            goodsToken.transferFrom(
                proposal.seller,
                address(this),
                proposal.goodsAmount
            ),
            "Failed to transfer goods tokens to contract"
        );

        // Mark the proposal as accepted
        proposal.isAccepted = true;

        emit ProposalAccepted(_tradeID, msg.sender);
    }

    // Function for the buyer to claim their goods tokens
    function claimGoods(uint256 _tradeID) external {
        Proposal storage proposal = proposals[_tradeID];

        require(proposal.isAccepted, "Proposal not yet accepted");
        require(
            !proposal.buyerClaimed,
            "Buyer has already claimed the goods tokens"
        );
        require(
            msg.sender == proposal.buyer,
            "Only the buyer can claim the goods tokens"
        );

        // Transfer ERC20 goods tokens from the contract to the buyer
        IERC20 goodsToken = IERC20(proposal.tokenAddress);
        require(
            goodsToken.transfer(proposal.buyer, proposal.goodsAmount),
            "Failed to transfer goods tokens"
        );

        // Mark buyer's claim as completed
        proposal.buyerClaimed = true;

        emit BuyerClaimed(_tradeID, proposal.buyer, proposal.goodsAmount);
    }

    // Function for the seller to claim their native tokens
    function claimNativeTokens(uint256 _tradeID) external {
        Proposal storage proposal = proposals[_tradeID];

        require(proposal.isAccepted, "Proposal not yet accepted");
        require(
            !proposal.sellerClaimed,
            "Seller has already claimed the native tokens"
        );
        require(
            msg.sender == proposal.seller,
            "Only the seller can claim the native tokens"
        );
        // Transfer native tokens from the contract to the seller
        payable(proposal.seller).transfer(proposal.nativeAmount);
        // Mark seller's claim as completed
        proposal.sellerClaimed = true;

        emit SellerClaimed(_tradeID, proposal.seller, proposal.nativeAmount);
    }

    // Function to allow the contract to accept native tokens (msg.value)
    receive() external payable {}
}
