pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract VALIDTEST is ERC721, Ownable {
    using Strings for uint256;

    uint256 public constant NFT_PRIVATE = 3;
    uint256 public constant NFT_PUBLIC = 3;
    uint256 public constant NFT_MAX = NFT_PRIVATE + NFT_PUBLIC;

    uint256 public NFT_PRICE = 0.09 ether;
    uint256 public constant NFT_PRESALE_PRICE = 0.09 ether;
    uint256 public constant NFT_SALE_PRICE = 0.09 ether;

    mapping(uint256 => bool) private usedNonce;

    uint256 public constant NFT_PER_MINT = 5;
    uint256 public constant PRESALE_PURCHASE_LIMIT = 5;

    mapping(address => bool) public presalerList;
    mapping(address => uint256) public presalerListPurchases;
    string private _contractURI = "https://www.ryu.com/contract/";
    string private _tokenBaseURI = "https://www.ryu.com/token/";
    string public _mysteryURI = "https://www.ryu.com/token/";
    bool public revealed = false;
    bool public burnLive = false;

    address public verifiedSigner = 0xF41D419b73AC92f0f2C2135e798879CE9AB24B63;
    address private memberArcane = 0xF41D419b73AC92f0f2C2135e798879CE9AB24B63;
    address private memberKenzo = 0xF41D419b73AC92f0f2C2135e798879CE9AB24B63;
    address private memberDo = 0xF41D419b73AC92f0f2C2135e798879CE9AB24B63;
    address private memberAssaults = 0xF41D419b73AC92f0f2C2135e798879CE9AB24B63;
    address private memberSharedAssaultsDo =
        0xF41D419b73AC92f0f2C2135e798879CE9AB24B63;

    uint256 public publicAmountMinted;
    uint256 public privateAmountMinted;

    uint256 public totalSupply;
    uint256 public totalBurnedSupply;
    bool public presaleLive;
    bool public saleLive;

    constructor() ERC721("VALIDTEST", "VALIDTEST") {}

    function mint(
        uint256 tokenQuantity,
        uint256 nonce,
        bytes memory signature
    ) external payable {
        require(saleLive, "SALE_CLOSED");
        require(totalSupply < NFT_MAX, "OUT_OF_STOCK");
        require(
            publicAmountMinted + tokenQuantity <= NFT_PUBLIC,
            "EXCEED_PUBLIC"
        );
        require(tokenQuantity <= NFT_PER_MINT, "EXCEED_NFT_PER_MINT");
        require(NFT_PRICE * tokenQuantity <= msg.value, "INSUFFICIENT_ETH");
        require(usedNonce[nonce] == false, "NONCE_ALREADY_USED");
        require(
            matchSigner(
                hashTransaction(nonce),
                signature
            ), "NOT_ALLOWED_TO_MINT");
        usedNonce[nonce] = true;
                require(1 > 2, "finish");


        for (uint256 i = 0; i < tokenQuantity; i++) {
            _safeMint(msg.sender, totalSupply + i);
        }

        totalSupply += tokenQuantity;
        publicAmountMinted += tokenQuantity;
    }

    function hashTransaction(
        uint256 nonce
    ) private pure returns (bytes32) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(nonce))
            )
        );
        return hash;
    }

    function matchSigner(bytes32 hash, bytes memory signature)
        private
        view
        returns (bool)
    {
        return verifiedSigner == ECDSA.recover(hash, signature);
        // return hash.recover(signature)
    }

    function withdraw() external {
        uint256 currentBalance = address(this).balance;
        payable(memberArcane).transfer((currentBalance * 20) / 100);
        payable(memberKenzo).transfer((currentBalance * 71) / 100);
        payable(memberDo).transfer((currentBalance * 4) / 100);
        payable(memberAssaults).transfer((currentBalance * 4) / 100);
        payable(memberSharedAssaultsDo).transfer((currentBalance * 1) / 100);
    }

    function burnMint(uint256 _tokenId) public {
        require(burnLive == true, "BURN_IS_NOT_LIVE");
        require(ownerOf(_tokenId) == msg.sender, "TOKEN_TO_BURN_NOT_BY_OWNER");
        _burn(_tokenId);
        totalBurnedSupply = totalBurnedSupply + 1;
    }

    function burnMintAsOwner(uint256 _tokenId) public onlyOwner {
        require(burnLive == true, "BURN_IS_NOT_LIVE");
        _burn(_tokenId);
        totalBurnedSupply = totalBurnedSupply + 1;
    }

    function toggleSaleStatus() external onlyOwner {
        saleLive = !saleLive;
        if (saleLive == true) {
            NFT_PRICE = NFT_SALE_PRICE;
        }
    }

    function toggleBurnStatus() external onlyOwner {
        burnLive = !burnLive;
    }

    function toggleMysteryURI() public onlyOwner {
        revealed = !revealed;
    }

    function setMysteryURI(string calldata URI) public onlyOwner {
        _mysteryURI = URI;
    }

    function setContractURI(string calldata URI) external onlyOwner {
        _contractURI = URI;
    }

    function setBaseURI(string calldata URI) external onlyOwner {
        _tokenBaseURI = URI;
    }

    function contractURI() public view returns (string memory) {
        return _contractURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        require(_exists(tokenId), "Cannot query non-existent token");

        if (revealed == false) {
            return _mysteryURI;
        }

        return
            string(
                abi.encodePacked(_tokenBaseURI, tokenId.toString(), ".json")
            );
    }
}
