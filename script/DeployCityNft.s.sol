// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {CityNft} from "../src/CityNft.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {console} from "forge-std/console.sol";

contract DeployCityNft is Script {
    uint256 public DEFAULT_ANVIL_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    uint256 public MORPHL_PRIVATE_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    uint256 public deployerKey;

    function run() external returns (CityNft) {
        if (block.chainid == 31337) {
            deployerKey = DEFAULT_ANVIL_PRIVATE_KEY;
        } else {
            deployerKey = MORPHL_PRIVATE_KEY;
        }

        string memory beijing1 = vm.readFile("./img/beijing1.svg");
        string memory beijing2 = vm.readFile("./img/beijing2.svg");
        string memory shanghai1 = vm.readFile("./img/shanghai1.svg");
        string memory shanghai2 = vm.readFile("./img/shanghai2.svg");

        //VRFv2DirectFundingConsumer vFv2DirectFundingConsumernew  = VRFv2DirectFundingConsumer();
        console.log(beijing1);
        console.log(beijing2);
        console.log(shanghai1);
        console.log(shanghai2);

        vm.startBroadcast(deployerKey);
        CityNft moodNft = new CityNft(
            svgToImageURI(shanghai1),
            svgToImageURI(shanghai2),
            svgToImageURI(beijing1),
            svgToImageURI(beijing2),
            1
        );
        vm.stopBroadcast();
        return moodNft;
    }

    // You could also just upload the raw SVG and have solildity convert it!
    function svgToImageURI(
        string memory svg
    ) public pure returns (string memory) {
        // example:
        // '<svg width="500" height="500" viewBox="0 0 285 350" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill="black" d="M150,0,L75,200,L225,200,Z"></path></svg>'
        // would return ""
        string memory baseURI = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(svg))) // Removing unnecessary type castings, this line can be resumed as follows : 'abi.encodePacked(svg)'
        );
        return string(abi.encodePacked(baseURI, svgBase64Encoded));
    }
}
