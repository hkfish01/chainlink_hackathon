// SPDX-License-Identifier: MIT
// Author BABAR R.
pragma solidity >=0.8.9 <0.9.0;

//import './ERC721A.sol';
import 'erc721a/contracts/ERC721A.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/common/ERC2981.sol';

import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

contract Whisky is ERC721A, 
                   ReentrancyGuard, 
                   ERC2981,
                   VRFConsumerBaseV2Plus{

    using Strings for uint;
    
    // contract
    uint public cost = 0.0000002 ether;
    uint constant public maxSupply = 100;
    uint public maxMintAmountPerTx = 20;
    string public contractURI = '';  // URL for the storefront-level metadata for contract
    bool public isSaleActive = false;   // is sale?

    string public uriPrefix = '';    // base uri
    string public uriOpenPrefix = ''; // open status uri 
    string public uriSuffix = '.json';   // base extension

    mapping (uint=>bool) public openStatus;
    struct OpenTokenLevel{
        string level;
        uint openTokenId;
    }
    mapping (uint=>OpenTokenLevel) public tokenId2openTokenId;

    string[5] Levels = ['legendary','epic','rare','uncommon','common'];
    uint8[5] LevelPercentage = [2,8,15,25,50];
    uint16[5] LevelUsedCount = [0,0,0,0,0];

    // VRF
    struct RequestStatus {
        uint tokenId;
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */

    IVRFCoordinatorV2Plus COORDINATOR;

    // subscription ID.
    uint256 s_subscriptionId;
    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // arb sepolia
    address constant VRFCoordinator = 0x5CE8D5A2BC84beb22a398CCA51996F7930313D61;
    bytes32 keyHash = 0x1770bdc7eec7771f7ba4ffd640f34260d7f095b79c92d34a5b2551d6f6cfd2be;

    // eth sepolia
    // address constant VRFCoordinator = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    // bytes32 keyHash = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    uint32 callbackGasLimit = 2500000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    // Transfer event emitted _from address _to address
    event TransferReceived(address _from, uint _amount);
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint tokenId, uint256[] randomWords);

    constructor(string memory _uriPrefix,
                string memory _uriOpenPrefix,
                string memory _contractUri,
                uint256 subscriptionId) 
                ERC721A("Whisky", "WKY")
                VRFConsumerBaseV2Plus(VRFCoordinator){

        COORDINATOR = IVRFCoordinatorV2Plus(VRFCoordinator);
        s_subscriptionId = subscriptionId;
        setUriPrefix(_uriPrefix);
        setUriOpenPrefix(_uriOpenPrefix);

        contractURI = _contractUri;
    }

    // ~~~~~~~~~~~~~~~~~~~~ Modifiers ~~~~~~~~~~~~~~~~~~~~
    modifier mintCompliance(uint256 _mintAmount) {
        require(isSaleActive, 'not started');
        require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, 'invalid mint amount!');
        require(_totalMinted() + _mintAmount <= maxSupply, 'max supply exceeded!');
        require(msg.value >= cost * _mintAmount, 'insufficient funds!');
        _;
    }

    // ~~~~~~~~~~~~~~~~~~~~ Public Functions ~~~~~~~~~~~~~~~~~~~~
    function mint(uint _mintAmount) public payable mintCompliance(_mintAmount) {
        uint startId = _totalMinted();
        _safeMint(msg.sender, _mintAmount);
        uint endId = startId + _mintAmount;
        for(uint i = startId; i < endId; i++) {
            openStatus[i] = false;
        }
    }

    function burn(uint256 tokenId) public {
        _burn(tokenId, true);
        return;
    }


    function open(uint _tokenId) public{
        require(_exists(_tokenId), 'nonexistent token');
        require(!openStatus[_tokenId], 'opened');
        require(msg.sender == getApproved(_tokenId) || msg.sender == ownerOf(_tokenId),'no permission');
        openStatus[_tokenId] = true;
        requestRandomWords(_tokenId);
    }

    function requestRandomWords(uint _tokenId) internal returns (uint256 requestId)
    {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
        s_requests[requestId] = RequestStatus({
            tokenId: _tokenId,
            randomWords: new uint256[](0),
            exists: true,
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }


    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].exists, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;

        _getOpenTokenId(s_requests[_requestId].tokenId, _randomWords[0]);
        emit RequestFulfilled(_requestId, s_requests[_requestId].tokenId, _randomWords);
    }

    function _getOpenTokenId(uint _tokenId, uint _randomNum) private returns(OpenTokenLevel memory){
        uint nid =  (_randomNum % 100)+1;
        if(nid <=2){
            tokenId2openTokenId[_tokenId] = _getLevelId(0);
        }else if(nid>2 && nid <=10){
            tokenId2openTokenId[_tokenId] = _getLevelId(1);
        }else if(nid>10 && nid <=25){
            tokenId2openTokenId[_tokenId] = _getLevelId(2);
        }else if(nid>25 && nid <=50){
            tokenId2openTokenId[_tokenId] = _getLevelId(3);
        }else{
            tokenId2openTokenId[_tokenId] = _getLevelId(4);
        }
        return tokenId2openTokenId[_tokenId];
    }

    function _getLevelId(uint levelsIndex)private returns(OpenTokenLevel memory){
        if(levelsIndex<0 || levelsIndex>=5) revert("exceeds data boundaries");
        OpenTokenLevel memory tokenlevel;

        // 
        if(LevelUsedCount[levelsIndex]< (LevelPercentage[levelsIndex]* maxSupply)/100 ){
            tokenlevel.level = Levels[levelsIndex];
            tokenlevel.openTokenId = LevelUsedCount[levelsIndex];
            LevelUsedCount[levelsIndex] += 1;
        }else{
            tokenlevel = _getLevelId(levelsIndex+1);
        }
        return tokenlevel;
    }

    // ~~~~~~~~~~~~~~~~~~~~ Various Checks ~~~~~~~~~~~~~~~~~~~~ 
    function tokenURI(uint _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), 'nonexistent token');

        if(!openStatus[_tokenId]){
            return bytes(uriPrefix).length > 0
                                ? string(abi.encodePacked(uriPrefix, _tokenId.toString(), uriSuffix))
                                : '';
        }else{
            string memory strLevel = tokenId2openTokenId[_tokenId].level;
            uint id = tokenId2openTokenId[_tokenId].openTokenId;
            if(bytes(strLevel).length == 0){
                return bytes(uriOpenPrefix).length > 0
                    ? string(abi.encodePacked(uriOpenPrefix, "temp", uriSuffix))
                    : '';
            }
            return bytes(uriOpenPrefix).length > 0
                    ? string(abi.encodePacked(uriOpenPrefix, strLevel,"/", id.toString(), uriSuffix))
                    : '';
        }
        
    }

    // ~~~~~~~~~~~~~~~~~~~~ onlyOwner Functions ~~~~~~~~~~~~~~~~~~~~
    function setContractURI(string memory _contractUri) public onlyOwner{
        contractURI = _contractUri;
    }

    function setSaleActive() public onlyOwner{
        isSaleActive = !isSaleActive;
    }

    function setCost(uint _cost) public onlyOwner {
        cost = _cost;
    }

    function setMaxMintAmountPerTx(uint _maxMintAmountPerTx) public onlyOwner {
        maxMintAmountPerTx = _maxMintAmountPerTx;
    }

    function setUriPrefix(string memory _uriPrefix) public onlyOwner {
        uriPrefix = _uriPrefix;
    }

    function setUriOpenPrefix(string memory _uriOpenPrefix) public onlyOwner {
        uriOpenPrefix = _uriOpenPrefix;
    }

    function setUriSuffix(string memory _uriSuffix) public onlyOwner {
        uriSuffix = _uriSuffix;
    }

    function emergencyWithdraw() public onlyOwner nonReentrant {
        (bool os, ) = payable(owner()).call{value: address(this).balance}('');
        require(os);
    }

    function totalMint() public view returns (uint256){
        return _totalMinted();
    }

    //This function is to overide supportInterface function of ERC721A and ERC2981
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    receive() payable external{
        // Transfer event
         emit TransferReceived(msg.sender, msg.value);
    }

}