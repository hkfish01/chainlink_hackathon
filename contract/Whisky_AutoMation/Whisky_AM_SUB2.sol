// SPDX-License-Identifier: MIT
// Author BABAR R.
pragma solidity >=0.8.9 <0.9.0;

//import './ERC721A.sol';
import 'erc721a/contracts/ERC721A.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/token/common/ERC2981.sol';

contract Whisky is ERC721A, 
                   ReentrancyGuard,
                   Ownable, 
                   ERC2981{

    using Strings for uint;
    
    // contract
    uint public cost = 0.0000002 ether;
    uint constant public maxSupply = 1000;
    uint public maxMintAmountPerTx = 20;
    string public contractURI = '';  // URL for the storefront-level metadata for contract
    bool public isSaleActive = false;   // is sale?

    string public uriPrefix = '';    // base uri
    string public uriSuffix = '.json';   // base extension

    // Transfer event emitted _from address _to address
    event TransferReceived(address _from, uint _amount);
    event Burn(address indexed addr);

    constructor(string memory _uriPrefix,
                string memory _contractUri) 
                ERC721A("Whisky", "WKY")Ownable(msg.sender){

        setUriPrefix(_uriPrefix);
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
        _safeMint(msg.sender, _mintAmount);
    }

    function open(uint _tokenId) external {
        require(_exists(_tokenId), 'nonexistent token');

        address ownerOfToken = ownerOf(_tokenId);
        require(msg.sender == getApproved(_tokenId) || msg.sender == ownerOfToken,'no permission');

        _burn(_tokenId, true);
        emit Burn(ownerOfToken);
    }

    // ~~~~~~~~~~~~~~~~~~~~ Various Checks ~~~~~~~~~~~~~~~~~~~~ 
    function tokenURI(uint _tokenId) public view virtual override returns (string memory) {
        require(_exists(_tokenId), 'nonexistent token');

        return bytes(uriPrefix).length > 0
                                ? string(abi.encodePacked(uriPrefix, _tokenId.toString(), uriSuffix))
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

    function setUriSuffix(string memory _uriSuffix) public onlyOwner {
        uriSuffix = _uriSuffix;
    }

    function totalMint() public view returns (uint256){
        return _totalMinted();
    }

    function emergencyWithdraw() public onlyOwner nonReentrant {
        (bool os, ) = payable(owner()).call{value: address(this).balance}('');
        require(os);
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