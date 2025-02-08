// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

interface SmartWalletChecker {
    function check(address) external view returns (bool);
}

contract SmartWalletWhitelist {

    mapping(address => bool) public wallets;
    address public operator;
    address public checker;
    address public future_checker;

    event ApproveWallet(address);
    event RevokeWallet(address);

    constructor(address _operator) {
        operator = _operator;
        wallets[0x151D751565DDe0474773747f1b61FFe4Fb291cc1] = true;
        wallets[0x9B2Abe6d884B294B39271565eDe2353F3a3f9692] = true;
        wallets[0xc39E0B012c53FaB0410A4F140af4151740dB7646] = true;
        wallets[0x0ef92ec4A74D755E12E5d57f80bc5435FB2c7Ee3] = true;
        wallets[0x15b4B69866a93D2FEC3B06551E5026f30c3a7691] = true;
        wallets[0x2a849503160A606a40DA6625B7Dc0DDF490D1F15] = true;
        wallets[0x2914a556270eA59Af3fbb78C757E61aa049Ad898] = true;
        wallets[0xF5B2DEB7D684e262063CF0049A531BB8F161857e] = true;
        wallets[0x17856076A3FA100A806618eAcFa9a13e49C4940D] = true;
        wallets[0xC9DF88762F9D882E2cF88224DE4f27d45100B7Db] = true;
        wallets[0xBF257E399147ca7FC0d9fC0c6dc4C6Eb2B9Bf5CA] = true;
        wallets[0x0A54a7b87f6e58B064c44Ec4725Fb1429fb3cFC8] = true;
        wallets[0xece736d82FD756E50c9F93b3c2fa9b350963703d] = true;
        wallets[0x8d297b42A699fBE4bf31d32E9Cc089C797A3438A] = true;
        wallets[0xeA83F862ca15Fbc4F6300580F698C22e20be43d2] = true;
        wallets[0x3a9a04f2aDa317A23696b9975B66B312BC8cE9Bc] = true;
        wallets[0x22be572AbC731e006a80121558915ba624bF3486] = true;
        wallets[0x90481d1dc72D6e31fEDefc29457Ccd9359EE9295] = true;
        wallets[0x16BDaf30dC94eEA159BB6D87ba46161E538a4D8f] = true;
        wallets[0x50A1b3486f269cd281D6756d8F916C5E8395c6F4] = true;
        wallets[0x732Fec3B91466F77C5132BC82fbf51743Ddb44Cd] = true;
        wallets[0x151D751565DDe0474773747f1b61FFe4Fb291cc1] = true;
    }

    function commitSetChecker(address _checker) external {
        require(msg.sender == operator, "!operator");
        future_checker = _checker;
    }

    function applySetChecker() external {
        require(msg.sender == operator, "!operator");
        checker = future_checker;
    }

    function approveWallet(address _wallet) public {
        require(msg.sender == operator, "!operator");
        wallets[_wallet] = true;

        emit ApproveWallet(_wallet);
    }
    function revokeWallet(address _wallet) external {
        require(msg.sender == operator, "!operator");
        wallets[_wallet] = false;

        emit RevokeWallet(_wallet);
    }

    function check(address _wallet) external view returns (bool) {
        bool _check = wallets[_wallet];
        if (_check) {
            return _check;
        } else {
            if (checker != address(0)) {
                return SmartWalletChecker(checker).check(_wallet);
            }
        }
        return false;
    }

}