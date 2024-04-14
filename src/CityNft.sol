// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {VRFv2DirectFundingConsumer} from "../src/VRFv2DirectFundingConsumer.sol";

contract CityNft is ERC721 {
    string private s_shanghaiSvgUri1;
    string private s_shanghaiSvgUri2;
    string private s_beijingSvgUri1;
    string private s_beijingSvgUri2;
    VRFv2DirectFundingConsumer private s_randomWords;
    //fixme 需要对接chainlink的随机数
    uint256 private s_cityIndex;

    uint256 private s_tokenCounter;

    mapping(uint256 => CityNFTState) private s_tokenIdToState;
    mapping(address => mapping(CityNFTState => uint256)) s_userCityCount;

    enum CityNFTState {
        BEIJING,
        SHANGHAI
    }

    constructor(
        string memory shanghaiSvgUri1,
        string memory shanghaiSvgUri2,
        string memory beijingSvgUri1,
        string memory beijingvgUri2,
        uint256 randomNum
    ) ERC721("CITY NFT", "CITYNFT") {
        s_tokenCounter = 0;
        s_shanghaiSvgUri1 = shanghaiSvgUri1;
        s_shanghaiSvgUri2 = shanghaiSvgUri2;
        s_beijingSvgUri1 = beijingSvgUri1;
        s_beijingSvgUri2 = beijingvgUri2;
        s_cityIndex = randomNum;
    }

    function mintNft() public {
        uint256 tokenCounter = s_tokenCounter;
        uint256 cityIndex = s_cityIndex;
        _safeMint(msg.sender, tokenCounter);
        s_tokenCounter += 1;
        CityNFTState city = CityNFTState(cityIndex);

        s_userCityCount[msg.sender][city] == 0
            ? 0
            : s_userCityCount[msg.sender][city] + 1;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    /**
     *
     * @param tokenId tokenId
     */
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        //根据随机数的结果选择不同的城市
        uint256 cityIndex = s_cityIndex;
        CityNFTState city = CityNFTState(cityIndex);
        string memory imageURI;

        //  根据同一城市的去到的次数进行level的更新
        uint256 cityLevel = s_userCityCount[msg.sender][city];

        //pick city
        if (CityNFTState.BEIJING == city) {
            if (s_userCityCount[msg.sender][city] != 0) {
                imageURI = s_beijingSvgUri2;
                cityLevel = 1;
            } else {
                imageURI = s_beijingSvgUri1;
                cityLevel = 0;
            }
        } else {
            if (s_userCityCount[msg.sender][city] != 0) {
                imageURI = s_shanghaiSvgUri2;
                cityLevel = 1;
            } else {
                imageURI = s_shanghaiSvgUri1;
                cityLevel = 0;
            }
        }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                name(),
                                '", "description":"An NFT is describe China City, 100% on Chain!", ',
                                '"attributes": [{"cityLevel": "',
                                cityLevel,
                                '", "value": 100000}], "image":"',
                                imageURI,
                                '"}'
                            )
                        )
                    )
                )
            );
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
