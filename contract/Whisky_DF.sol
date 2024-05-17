// SPDX-License-Identifier: MIT
// Author BABAR R.
pragma solidity >=0.8.9 <0.9.0;

//import './ERC721A.sol';
import 'erc721a/contracts/ERC721A.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/common/ERC2981.sol';

import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {VRFV2WrapperConsumerBase} from "@chainlink/contracts/src/v0.8/vrf/VRFV2WrapperConsumerBase.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";

contract Whisky is ERC721A, 
                   ReentrancyGuard, 
                   ERC2981,
                   VRFV2WrapperConsumerBase,
                   ConfirmedOwner {

    using Strings for uint;
    
    // contract
    uint public cost = 0.0000002 ether;
    uint public maxSupply = 10000;
    uint public maxMintAmountPerTx = 20;
    string public contractURI = '';  // URL for the storefront-level metadata for contract
    bool public isSaleActive = false;   // is sale?

    string public uriPrefix = '';    // base uri
    string public uriOpenPrefix = ''; // open status uri 
    string public uriSuffix = '.json';   // base extension

    mapping (uint=>bool) public openStatus;
    mapping (uint=>uint) public tokenId2Num;

    string constant Common ='common';
    string constant Uncommon ='uncommon';
    string constant Rare ='rare';
    string constant Epic ='epic';
    string constant Legendary ='legendary';


    // VRF
    struct RequestStatus {
        uint tokenId;
        uint256 paid; // amount paid in link
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus ) public s_requests; /* requestId --> requestStatus */
    uint32 callbackGasLimit = 2500000;
    uint16 requestConfirmations = 3;   // The default is 3, but you can set this higher.
    uint32 numWords = 1;
    address linkAddress = 0x779877A7B0D9E8603169DdbD7836e478b4624789;   // Address LINK - hardcoded for Sepolia
    address wrapperAddress = 0xab18414CD93297B0d12ac29E63Ca20f515b3DB46;  // address WRAPPER - hardcoded for Sepolia

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // Transfer event emitted _from address _to address
    event TransferReceived(address _from, uint _amount);
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(
        uint256 requestId,
        uint tokenId,
        uint256[] randomWords,
        uint256 payment
    );

    constructor(string memory _uriPrefix,
                string memory _uriOpenPrefix,
                string memory _contractUri) 
                ERC721A("Whisky", "WKY") 
                ConfirmedOwner(msg.sender) 
                VRFV2WrapperConsumerBase(linkAddress, wrapperAddress){

        // ConfirmedOwner(msg.sender);
        // VRFV2WrapperConsumerBase(linkAddress, wrapperAddress);

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
        requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
        s_requests[requestId] = RequestStatus({
            tokenId: _tokenId,
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWords: new uint256[](0),
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
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        tokenId2Num[s_requests[_requestId].tokenId] = _randomWords[0];
        emit RequestFulfilled(
            _requestId,
            s_requests[_requestId].tokenId,
            _randomWords,
            s_requests[_requestId].paid
        );
    }


    // ~~~~~~~~~~~~~~~~~~~~ Various Checks ~~~~~~~~~~~~~~~~~~~~ 
    function tokenURI(uint _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), 'nonexistent token');

        string memory currentBaseURI = uriPrefix;
        uint nid = _tokenId;
        
        if(openStatus[_tokenId]){
            currentBaseURI = uriOpenPrefix;
            string memory level;
            
            if(tokenId2Num[_tokenId] == 0){
                return bytes(currentBaseURI).length > 0
                    ? string(abi.encodePacked(currentBaseURI, "temp", uriSuffix))
                    : '';
            }
            nid =  (tokenId2Num[_tokenId] % 100)+1;
            if(nid <=2){
                level = Legendary;
            }else if(nid>2 && nid <=10){
                level = Epic;
            }else if(nid>10 && nid <=25){
                level = Rare;
            }else if(nid>25 && nid <=50){
                level = Uncommon;
            }else{
                level = Common;
            }

            return bytes(currentBaseURI).length > 0
                    ? string(abi.encodePacked(currentBaseURI, nid.toString(),level, uriSuffix))
                    : '';
        }
        
        return bytes(currentBaseURI).length > 0
                    ? string(abi.encodePacked(currentBaseURI, nid.toString(), uriSuffix))
                    : '';
        
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

    /**
     * Allow withdraw of Link tokens from the contract
     */
    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(linkAddress);
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
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