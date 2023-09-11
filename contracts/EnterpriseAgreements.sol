// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract EnterpriseAgreements is ERC721Enumerable  {
  using Counters for Counters.Counter;
  Counters.Counter private _nextTokenId;

  // rental agreements
  struct RentalAgreement {
    uint256 tokenId;
    address wallet;
    string uuid; // offline db id
    uint256 startTime;
    uint256 endTime;
    bool allowUpdatesByWallet;
    bool insurance;
  }
  mapping(uint256 => RentalAgreement) tokenIdToRentalAgreement;
  mapping(string => RentalAgreement) uuidToRentalAgreement;

  constructor(
    string memory name_,
    string memory symbol_
  ) ERC721(name_, symbol_) {
    // start at token id = 1
    _nextTokenId.increment();
  }

  /**
  ////////////////////////////////////////////////////
  // External Functions 
  ///////////////////////////////////////////////////
  */

  // create rental agreement (mint NFT)
  // called by Enterprise - add access control
  function issueRentalAgreement(
    address wallet_,
    string memory uuid_,
    uint256 startTime_,
    uint256 endTime_,
    bool allowUpdatesByWallet_,
    bool insurance_
  ) external returns (uint256) {
    require(wallet_ != address(0), "WALLET_EMPTY");
    require(bytes(uuid_).length != 0, "UUID_EMPTY");
    require(endTime_ >= startTime_, "END_BEFORE_START");
    
    uint256 tokenId = mintRentalAgreement(wallet_);
    RentalAgreement memory rentalAgreement = RentalAgreement(
      tokenId,
      wallet_,
      uuid_,
      startTime_,
      endTime_,
      allowUpdatesByWallet_,
      insurance_
    );
    tokenIdToRentalAgreement[tokenId] = rentalAgreement;
    uuidToRentalAgreement[uuid_] = rentalAgreement;

    return tokenId;
  }

  // update rental agreement - extend rental
  // called by user 
  function extendRental(uint256 tokenId_, uint256 endTime_) external {
    RentalAgreement storage rentalAgreement = tokenIdToRentalAgreement[tokenId_];
    require(rentalAgreement.allowUpdatesByWallet == true, "NO_USER_UPDATES");
    require(endTime_ > rentalAgreement.endTime, "INVALID_END_TIME");
    require(block.timestamp <= rentalAgreement.endTime, "RENTAL_EXPIRED");
    require(msg.sender == rentalAgreement.wallet, "SENDER_INVALID");
    rentalAgreement.endTime = endTime_;
  }

  /**
  ////////////////////////////////////////////////////
  // Internal Functions 
  ///////////////////////////////////////////////////
  */

  // mint nft
  function mintRentalAgreement(address wallet_) internal returns (uint256) {
    uint256 tokenId = _nextTokenId.current();
    _mint(wallet_, tokenId);
    _nextTokenId.increment();
    return tokenId;
  }

  /**
  ////////////////////////////////////////////////////
  // View only functions
  ///////////////////////////////////////////////////
  */

  // get rental agreement by token id
  function getRentalByTokenId(uint256 tokenId) external view returns (RentalAgreement memory) {
    return tokenIdToRentalAgreement[tokenId];
  }

  // get rental agreement by uuid
  function getRentalByUUID(string memory uuid) external view returns (RentalAgreement memory) {
    return uuidToRentalAgreement[uuid];
  }
}