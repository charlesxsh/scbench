// hevm: flattened sources of src/DssSpell.sol
// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity =0.8.16 >=0.5.12 >=0.8.16 <0.9.0;

////// lib/dss-exec-lib/src/CollateralOpts.sol
//
// CollateralOpts.sol -- Data structure for onboarding collateral
//
// Copyright (C) 2020-2022 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/* pragma solidity ^0.8.16; */

struct CollateralOpts {
    bytes32 ilk;
    address gem;
    address join;
    address clip;
    address calc;
    address pip;
    bool    isLiquidatable;
    bool    isOSM;
    bool    whitelistOSM;
    uint256 ilkDebtCeiling;
    uint256 minVaultAmount;
    uint256 maxLiquidationAmount;
    uint256 liquidationPenalty;
    uint256 ilkStabilityFee;
    uint256 startingPriceFactor;
    uint256 breakerTolerance;
    uint256 auctionDuration;
    uint256 permittedDrop;
    uint256 liquidationRatio;
    uint256 kprFlatReward;
    uint256 kprPctReward;
}

////// lib/dss-exec-lib/src/DssExecLib.sol
//
// DssExecLib.sol -- MakerDAO Executive Spellcrafting Library
//
// Copyright (C) 2020-2022 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/* pragma solidity ^0.8.16; */

/* import { CollateralOpts } from "./CollateralOpts.sol"; */

interface Initializable {
    function init(bytes32) external;
}

interface Authorizable {
    function rely(address) external;
    function deny(address) external;
    function setAuthority(address) external;
}

interface Fileable {
    function file(bytes32, address) external;
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
    function file(bytes32, bytes32, address) external;
}

interface Drippable {
    function drip() external returns (uint256);
    function drip(bytes32) external returns (uint256);
}

interface Pricing {
    function poke(bytes32) external;
}

interface ERC20 {
    function decimals() external returns (uint8);
}

interface DssVat {
    function hope(address) external;
    function nope(address) external;
    function ilks(bytes32) external returns (uint256 Art, uint256 rate, uint256 spot, uint256 line, uint256 dust);
    function Line() external view returns (uint256);
    function suck(address, address, uint256) external;
}

interface ClipLike {
    function vat() external returns (address);
    function dog() external returns (address);
    function spotter() external view returns (address);
    function calc() external view returns (address);
    function ilk() external returns (bytes32);
}

interface DogLike {
    function ilks(bytes32) external returns (address clip, uint256 chop, uint256 hole, uint256 dirt);
}

interface JoinLike {
    function vat() external returns (address);
    function ilk() external returns (bytes32);
    function gem() external returns (address);
    function dec() external returns (uint256);
    function join(address, uint256) external;
    function exit(address, uint256) external;
}

// Includes Median and OSM functions
interface OracleLike_2 {
    function src() external view returns (address);
    function lift(address[] calldata) external;
    function drop(address[] calldata) external;
    function setBar(uint256) external;
    function kiss(address) external;
    function diss(address) external;
    function kiss(address[] calldata) external;
    function diss(address[] calldata) external;
    function orb0() external view returns (address);
    function orb1() external view returns (address);
}

interface MomLike {
    function setOsm(bytes32, address) external;
    function setPriceTolerance(address, uint256) external;
}

interface RegistryLike {
    function add(address) external;
    function xlip(bytes32) external view returns (address);
}

// https://github.com/makerdao/dss-chain-log
interface ChainlogLike {
    function setVersion(string calldata) external;
    function setIPFS(string calldata) external;
    function setSha256sum(string calldata) external;
    function getAddress(bytes32) external view returns (address);
    function setAddress(bytes32, address) external;
    function removeAddress(bytes32) external;
}

interface IAMLike {
    function ilks(bytes32) external view returns (uint256,uint256,uint48,uint48,uint48);
    function setIlk(bytes32,uint256,uint256,uint256) external;
    function remIlk(bytes32) external;
    function exec(bytes32) external returns (uint256);
}

interface LerpFactoryLike {
    function newLerp(bytes32 name_, address target_, bytes32 what_, uint256 startTime_, uint256 start_, uint256 end_, uint256 duration_) external returns (address);
    function newIlkLerp(bytes32 name_, address target_, bytes32 ilk_, bytes32 what_, uint256 startTime_, uint256 start_, uint256 end_, uint256 duration_) external returns (address);
}

interface LerpLike {
    function tick() external returns (uint256);
}

interface RwaOracleLike {
    function bump(bytes32 ilk, uint256 val) external;
}


library DssExecLib {

    /* WARNING

The following library code acts as an interface to the actual DssExecLib
library, which can be found in its own deployed contract. Only trust the actual
library's implementation.

    */

    address constant public LOG = 0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F;
    uint256 constant internal WAD      = 10 ** 18;
    uint256 constant internal RAY      = 10 ** 27;
    uint256 constant internal RAD      = 10 ** 45;
    uint256 constant internal THOUSAND = 10 ** 3;
    uint256 constant internal MILLION  = 10 ** 6;
    uint256 constant internal BPS_ONE_PCT             = 100;
    uint256 constant internal BPS_ONE_HUNDRED_PCT     = 100 * BPS_ONE_PCT;
    uint256 constant internal RATES_ONE_HUNDRED_PCT   = 1000000021979553151239153027;
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {}
    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {}
    function mkr()        public view returns (address) { return getChangelogAddress("MCD_GOV"); }
    function vat()        public view returns (address) { return getChangelogAddress("MCD_VAT"); }
    function dog()        public view returns (address) { return getChangelogAddress("MCD_DOG"); }
    function jug()        public view returns (address) { return getChangelogAddress("MCD_JUG"); }
    function pot()        public view returns (address) { return getChangelogAddress("MCD_POT"); }
    function vow()        public view returns (address) { return getChangelogAddress("MCD_VOW"); }
    function end()        public view returns (address) { return getChangelogAddress("MCD_END"); }
    function reg()        public view returns (address) { return getChangelogAddress("ILK_REGISTRY"); }
    function spotter()    public view returns (address) { return getChangelogAddress("MCD_SPOT"); }
    function flap()       public view returns (address) { return getChangelogAddress("MCD_FLAP"); }
    function autoLine()   public view returns (address) { return getChangelogAddress("MCD_IAM_AUTO_LINE"); }
    function lerpFab()    public view returns (address) { return getChangelogAddress("LERP_FAB"); }
    function clip(bytes32 _ilk) public view returns (address _clip) {}
    function flip(bytes32 _ilk) public view returns (address _flip) {}
    function calc(bytes32 _ilk) public view returns (address _calc) {}
    function getChangelogAddress(bytes32 _key) public view returns (address) {}
    function setAuthority(address _base, address _authority) public {}
    function canCast(uint40 _ts, bool _officeHours) public pure returns (bool) {}
    function nextCastTime(uint40 _eta, uint40 _ts, bool _officeHours) public pure returns (uint256 castTime) {}
    function updateCollateralPrice(bytes32 _ilk) public {}
    function setValue(address _base, bytes32 _what, uint256 _amt) public {}
    function setValue(address _base, bytes32 _ilk, bytes32 _what, uint256 _amt) public {}
    function increaseGlobalDebtCeiling(uint256 _amount) public {}
    function decreaseGlobalDebtCeiling(uint256 _amount) public {}
    function setDSR(uint256 _rate, bool _doDrip) public {}
    function setIlkDebtCeiling(bytes32 _ilk, uint256 _amount) public {}
    function increaseIlkDebtCeiling(bytes32 _ilk, uint256 _amount, bool _global) public {}
    function setIlkAutoLineParameters(bytes32 _ilk, uint256 _amount, uint256 _gap, uint256 _ttl) public {}
    function setIlkAutoLineDebtCeiling(bytes32 _ilk, uint256 _amount) public {}
    function removeIlkFromAutoLine(bytes32 _ilk) public {}
    function setIlkLiquidationPenalty(bytes32 _ilk, uint256 _pct_bps) public {}
    function setIlkLiquidationRatio(bytes32 _ilk, uint256 _pct_bps) public {}
    function setKeeperIncentivePercent(bytes32 _ilk, uint256 _pct_bps) public {}
    function setKeeperIncentiveFlatRate(bytes32 _ilk, uint256 _amount) public {}
    function setIlkStabilityFee(bytes32 _ilk, uint256 _rate, bool _doDrip) public {}
    function linearInterpolation(bytes32 _name, address _target, bytes32 _ilk, bytes32 _what, uint256 _startTime, uint256 _start, uint256 _end, uint256 _duration) public returns (address) {}
}

////// lib/dss-exec-lib/src/DssAction.sol
//
// DssAction.sol -- DSS Executive Spell Actions
//
// Copyright (C) 2020-2022 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/* pragma solidity ^0.8.16; */

/* import { DssExecLib } from "./DssExecLib.sol"; */
/* import { CollateralOpts } from "./CollateralOpts.sol"; */

interface OracleLike_1 {
    function src() external view returns (address);
}

abstract contract DssAction {

    using DssExecLib for *;

    // Modifier used to limit execution time when office hours is enabled
    modifier limited {
        require(DssExecLib.canCast(uint40(block.timestamp), officeHours()), "Outside office hours");
        _;
    }

    // Office Hours defaults to true by default.
    //   To disable office hours, override this function and
    //    return false in the inherited action.
    function officeHours() public view virtual returns (bool) {
        return true;
    }

    // DssExec calls execute. We limit this function subject to officeHours modifier.
    function execute() external limited {
        actions();
    }

    // DssAction developer must override `actions()` and place all actions to be called inside.
    //   The DssExec function will call this subject to the officeHours limiter
    //   By keeping this function public we allow simulations of `execute()` on the actions outside of the cast time.
    function actions() public virtual;

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://<executive-vote-canonical-post> -q -O - 2>/dev/null)"
    function description() external view virtual returns (string memory);

    // Returns the next available cast time
    function nextCastTime(uint256 eta) external view returns (uint256 castTime) {
        require(eta <= type(uint40).max);
        castTime = DssExecLib.nextCastTime(uint40(eta), uint40(block.timestamp), officeHours());
    }
}

////// lib/dss-exec-lib/src/DssExec.sol
//
// DssExec.sol -- MakerDAO Executive Spell Template
//
// Copyright (C) 2020-2022 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/* pragma solidity ^0.8.16; */

interface PauseAbstract {
    function delay() external view returns (uint256);
    function plot(address, bytes32, bytes calldata, uint256) external;
    function exec(address, bytes32, bytes calldata, uint256) external returns (bytes memory);
}

interface Changelog {
    function getAddress(bytes32) external view returns (address);
}

interface SpellAction {
    function officeHours() external view returns (bool);
    function description() external view returns (string memory);
    function nextCastTime(uint256) external view returns (uint256);
}

contract DssExec {

    Changelog      constant public log   = Changelog(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);
    uint256                 public eta;
    bytes                   public sig;
    bool                    public done;
    bytes32       immutable public tag;
    address       immutable public action;
    uint256       immutable public expiration;
    PauseAbstract immutable public pause;

    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://<executive-vote-canonical-post> -q -O - 2>/dev/null)"
    function description() external view returns (string memory) {
        return SpellAction(action).description();
    }

    function officeHours() external view returns (bool) {
        return SpellAction(action).officeHours();
    }

    function nextCastTime() external view returns (uint256 castTime) {
        return SpellAction(action).nextCastTime(eta);
    }

    // @param _description  A string description of the spell
    // @param _expiration   The timestamp this spell will expire. (Ex. block.timestamp + 30 days)
    // @param _spellAction  The address of the spell action
    constructor(uint256 _expiration, address _spellAction) {
        pause       = PauseAbstract(log.getAddress("MCD_PAUSE"));
        expiration  = _expiration;
        action      = _spellAction;

        sig = abi.encodeWithSignature("execute()");
        bytes32 _tag;                    // Required for assembly access
        address _action = _spellAction;  // Required for assembly access
        assembly { _tag := extcodehash(_action) }
        tag = _tag;
    }

    function schedule() public {
        require(block.timestamp <= expiration, "This contract has expired");
        require(eta == 0, "This spell has already been scheduled");
        eta = block.timestamp + PauseAbstract(pause).delay();
        pause.plot(action, tag, sig, eta);
    }

    function cast() public {
        require(!done, "spell-already-cast");
        done = true;
        pause.exec(action, tag, sig, eta);
    }
}

////// lib/dss-test/lib/dss-interfaces/src/ERC/GemAbstract.sol
/* pragma solidity >=0.5.12; */

// A base ERC-20 abstract class
// https://eips.ethereum.org/EIPS/eip-20
interface GemAbstract {
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

////// lib/dss-test/lib/dss-interfaces/src/dss/VatAbstract.sol
/* pragma solidity >=0.5.12; */

// https://github.com/makerdao/dss/blob/master/src/vat.sol
interface VatAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function can(address, address) external view returns (uint256);
    function hope(address) external;
    function nope(address) external;
    function ilks(bytes32) external view returns (uint256, uint256, uint256, uint256, uint256);
    function urns(bytes32, address) external view returns (uint256, uint256);
    function gem(bytes32, address) external view returns (uint256);
    function dai(address) external view returns (uint256);
    function sin(address) external view returns (uint256);
    function debt() external view returns (uint256);
    function vice() external view returns (uint256);
    function Line() external view returns (uint256);
    function live() external view returns (uint256);
    function init(bytes32) external;
    function file(bytes32, uint256) external;
    function file(bytes32, bytes32, uint256) external;
    function cage() external;
    function slip(bytes32, address, int256) external;
    function flux(bytes32, address, address, uint256) external;
    function move(address, address, uint256) external;
    function frob(bytes32, address, address, address, int256, int256) external;
    function fork(bytes32, address, address, int256, int256) external;
    function grab(bytes32, address, address, address, int256, int256) external;
    function heal(uint256) external;
    function suck(address, address, uint256) external;
    function fold(bytes32, address, int256) external;
}

////// src/DssSpell.sol
// SPDX-FileCopyrightText: © 2020 Dai Foundation <www.daifoundation.org>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

/* pragma solidity 0.8.16; */

/* import "dss-exec-lib/DssExec.sol"; */
/* import "dss-exec-lib/DssAction.sol"; */

/* import { VatAbstract } from "dss-interfaces/dss/VatAbstract.sol"; */
/* import { GemAbstract } from "dss-interfaces/ERC/GemAbstract.sol"; */

interface TransferOwnershipLike_1 {
    function transferOwnership(address newOwner) external;
}

interface ChangeAdminLike_1 {
    function changeAdmin(address newAdmin) external;
}

interface ACLManagerLike_1 {
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);
    function addEmergencyAdmin(address admin) external;
    function removeEmergencyAdmin(address admin) external;
    function removePoolAdmin(address admin) external;
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
}

interface PoolAddressProviderLike_1 {
    function setACLAdmin(address newAclAdmin) external;
}

interface RwaLiquidationLike_1 {
    function bump(bytes32 ilk, uint256 val) external;
}

interface ProxyLike_1 {
    function exec(address target, bytes calldata args) external payable returns (bytes memory out);
}

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: cast keccak -- "$(wget 'https://raw.githubusercontent.com/makerdao/community/15a0474494d97483d0ce3acaa288a0d3ab88d8e0/governance/votes/Executive%20vote%20-%20August%2018%2C%202023.md' -q -O - 2>/dev/null)"
    string public constant override description =
        "2023-08-18 MakerDAO Executive Spell | Hash: 0x1b764f7d01469324cbac1379bcd238e56ed26cc4df05380fd154c68a3c265461";

    // Set office hours according to the summary
    function officeHours() public pure override returns (bool) {
        return false;
    }

    // ---------- DAO Resolution for BlockTower Andromeda ----------
    // Forum: https://forum.makerdao.com/t/dao-resolution-to-facilitate-onboarding-of-taco-with-additional-third-parties/21572
    // Forum: https://forum.makerdao.com/t/dao-resolution-to-facilitate-onboarding-of-taco-with-additional-third-parties/21572/2

    // Include IPFS hash QmUNrCwKK2iK2ki5Spn97jrTCDKqFjDZWKk3wxQ2psgMP5 (not a `doc` update)
    // NOTE: by the previous convention it should be a comma-separated list of DAO resolutions IPFS hashes
    string public constant dao_resolutions = "QmUNrCwKK2iK2ki5Spn97jrTCDKqFjDZWKk3wxQ2psgMP5";

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmVp4mhhbwWGTfbh2BzwQB9eiBrQBKiqcPRZCaAxNUaar6
    //
    // uint256 internal constant X_PCT_RATE      = ;
    uint256 internal constant THREE_PT_THREE_THREE_PCT_RATE = 1000000001038735548426731741;
    uint256 internal constant THREE_PT_FIVE_EIGHT_PCT_RATE  = 1000000001115362602336059074;
    uint256 internal constant FOUR_PT_ZERO_EIGHT_PCT_RATE   = 1000000001268063427242299977;
    uint256 internal constant FIVE_PCT_RATE                 = 1000000001547125957863212448;
    uint256 internal constant FIVE_PT_TWO_FIVE_PCT_RATE     = 1000000001622535724756171269;
    uint256 internal constant FIVE_PT_FIVE_FIVE_PCT_RATE    = 1000000001712791360746325100;
    uint256 internal constant FIVE_PT_EIGHT_PCT_RATE        = 1000000001787808646832390371;
    uint256 internal constant SIX_PT_THREE_PCT_RATE         = 1000000001937312893803622469;
    uint256 internal constant SEVEN_PCT_RATE                = 1000000002145441671308778766;

    // ---------- Math ----------
    uint256 internal constant THOUSAND = 10 ** 3;
    uint256 internal constant MILLION  = 10 ** 6;
    uint256 internal constant BILLION  = 10 ** 9;
    uint256 internal constant RAY      = 10 ** 27;
    uint256 internal constant RAD      = 10 ** 45;

    // ---------- Smart Burn Engine Parameter Updates ----------
    address internal immutable MCD_VOW            = DssExecLib.vow();
    address internal immutable MCD_FLAP           = DssExecLib.flap();

    // ---------- CRVV1ETHSTETH-A 2nd Stage Offboarding ----------
    VatAbstract internal immutable vat  = VatAbstract(DssExecLib.vat());
    address internal immutable MCD_SPOT = DssExecLib.spotter();

    // ---------- Aligned Delegate Compensation for July 2023 ----------
    GemAbstract internal immutable mkr                    = GemAbstract(DssExecLib.mkr());
    address internal constant DEFENSOR                    = 0x9542b441d65B6BF4dDdd3d4D2a66D8dCB9EE07a9;
    address internal constant BONAPUBLICA                 = 0x167c1a762B08D7e78dbF8f24e5C3f1Ab415021D3;
    address internal constant QGOV                        = 0xB0524D8707F76c681901b782372EbeD2d4bA28a6;
    address internal constant TRUENAME                    = 0x612F7924c367575a0Edf21333D96b15F1B345A5d;
    address internal constant UPMAKER                     = 0xbB819DF169670DC71A16F58F55956FE642cc6BcD;
    address internal constant VIGILANT                    = 0x2474937cB55500601BCCE9f4cb0A0A72Dc226F61;
    address internal constant WBC                         = 0xeBcE83e491947aDB1396Ee7E55d3c81414fB0D47;
    address internal constant PALC                        = 0x78Deac4F87BD8007b9cb56B8d53889ed5374e83A;
    address internal constant NAVIGATOR                   = 0x11406a9CC2e37425F15f920F494A51133ac93072;
    address internal constant PBG                         = 0x8D4df847dB7FfE0B46AF084fE031F7691C6478c2;
    address internal constant VOTEWIZARD                  = 0x9E72629dF4fcaA2c2F5813FbbDc55064345431b1;
    address internal constant LIBERTAS                    = 0xE1eBfFa01883EF2b4A9f59b587fFf1a5B44dbb2f;
    address internal constant HARMONY                     = 0xF4704Aa4Ad22cAA2A3Dd7A7C529B4C32f7A421F2;
    address internal constant JAG                         = 0x58D1ec57E4294E4fe650D1CB12b96AE34349556f;
    address internal constant CLOAKY                      = 0x869b6d5d8FA7f4FFdaCA4D23FFE0735c5eD1F818;
    address internal constant SKYNET                      = 0xd4d1A446cD5976a11bd32D3e815A9F85FED2F9F3;

    // ---------- New Silver Parameter Changes ----------
    address internal immutable MIP21_LIQUIDATION_ORACLE = DssExecLib.getChangelogAddress("MIP21_LIQUIDATION_ORACLE");

    // Contracts pulled from Spark official deployment repository
    // https://github.com/marsfoundation/sparklend/blob/ca2b72af7c5fb790cc91eaca5d8d4c83fa37e74b/script/output/1/primary-latest.json
    // Spark Proxy: https://github.com/marsfoundation/sparklend/blob/ca2b72af7c5fb790cc91eaca5d8d4c83fa37e74b/script/output/1/primary-sce-latest.json#L2
    address internal constant SPARK_PROXY                          = 0x3300f198988e4C9C63F75dF86De36421f06af8c4;
    address internal constant SPARK_TREASURY_CONTROLLER            = 0x92eF091C5a1E01b3CE1ba0D0150C84412d818F7a;
    address internal constant SPARK_TREASURY                       = 0xb137E7d16564c81ae2b0C8ee6B55De81dd46ECe5;
    address internal constant SPARK_TREASURY_DAI                   = 0x856900aa78e856a5df1a2665eE3a66b2487cD68f;
    address internal constant SPARK_INCENTIVES                     = 0x4370D3b6C9588E02ce9D22e684387859c7Ff5b34;
    address internal constant SPARK_WETH_GATEWAY                   = 0xBD7D6a9ad7865463DE44B05F04559f65e3B11704;
    address internal constant SPARK_ACL_MANAGER                    = 0xdA135Cd78A086025BcdC87B038a1C462032b510C;
    address internal constant SPARK_POOL_ADDRESS_PROVIDER          = 0x02C3eA4e34C0cBd694D2adFa2c690EECbC1793eE;
    address internal constant SPARK_POOL_ADDRESS_PROVIDER_REGISTRY = 0x03cFa0C4622FF84E50E75062683F44c9587e6Cc1;
    address internal constant SPARK_EMISSION_MANAGER               = 0xf09e48dd4CA8e76F63a57ADd428bB06fee7932a4;

    // ---------- Trigger Spark Proxy Spell ----------
    address internal constant SPARK_SPELL    = 0x60cC45DaB5F0B17789C77d5FE990f1aD80e9DD65;

    function actions() public override {
        // ---------- EDSR Update ----------
        // Forum: https://forum.makerdao.com/t/request-for-gov12-1-2-edit-to-the-stability-scope-to-quickly-modify-enhanced-dsr-based-on-observed-data/21581

        // Reduce DSR by 3% from 8% to 5%
        DssExecLib.setDSR(FIVE_PCT_RATE, /* doDrip = */ true);

        // ---------- DSR-based Stability Fee Updates ----------
        // Forum: https://forum.makerdao.com/t/request-for-gov12-1-2-edit-to-the-stability-scope-to-quickly-modify-enhanced-dsr-based-on-observed-data/21581

        // Increase ETH-A SF by 0.14% from 3.44% to 3.58%
        DssExecLib.setIlkStabilityFee("ETH-A", THREE_PT_FIVE_EIGHT_PCT_RATE, /* doDrip = */ true);

        // Increase ETH-B SF by 0.14% from 3.94%% to 4.08%
        DssExecLib.setIlkStabilityFee("ETH-B", FOUR_PT_ZERO_EIGHT_PCT_RATE, /* doDrip = */ true);

        // Increase ETH-C SF by 0.14% from 3.19% to 3.33%
        DssExecLib.setIlkStabilityFee("ETH-C", THREE_PT_THREE_THREE_PCT_RATE, /* doDrip = */ true);

        // Increase WSTETH-A SF by 1.81% from 3.44% to 5.25%
        DssExecLib.setIlkStabilityFee("WSTETH-A", FIVE_PT_TWO_FIVE_PCT_RATE, /* doDrip = */ true);

        // Increase WSTETH-B SF by 1.81% from 3.19% to 5.00%
        DssExecLib.setIlkStabilityFee("WSTETH-B", FIVE_PCT_RATE, /* doDrip = */ true);

        // Increase RETH-A SF by 1.81% from 3.44% to 5.25%
        DssExecLib.setIlkStabilityFee("RETH-A", FIVE_PT_TWO_FIVE_PCT_RATE, /* doDrip = */ true);

        // Increase WBTC-A SF by 0.11% from 5.69% to 5.80%
        DssExecLib.setIlkStabilityFee("WBTC-A", FIVE_PT_EIGHT_PCT_RATE, /* doDrip = */ true);

        // Increase WBTC-B SF by 0.11% from 6.19% to 6.30%
        DssExecLib.setIlkStabilityFee("WBTC-B", SIX_PT_THREE_PCT_RATE, /* doDrip = */ true);

        // Increase WBTC-C SF by 0.11% from 5.44% to 5.55%
        DssExecLib.setIlkStabilityFee("WBTC-C", FIVE_PT_FIVE_FIVE_PCT_RATE, /* doDrip = */ true);

        // ---------- Smart Burn Engine Parameter Updates ----------
        // Poll: https://vote.makerdao.com/polling/QmTRJNNH
        // Forum: https://forum.makerdao.com/t/smart-burn-engine-parameters-update-1/21545

        // Increase vow.bump by 15,000 DAI from 5,000 DAI to 20,000 DAI
        DssExecLib.setValue(MCD_VOW, "bump", 20 * THOUSAND * RAD);

        // Increase hop by 4,731 seconds from 1,577 seconds to 6,308 seconds
        DssExecLib.setValue(MCD_FLAP, "hop", 6_308);

        // ---------- Non-DSR Related Parameter Changes ----------
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-4/21567
        // Mip: https://mips.makerdao.com/mips/details/MIP104#14-3-native-vault-engine

        // Increase WSTETH-A line by 250 million DAI from 500 million DAI to 750 million DAI (no change to gap or ttl)
        DssExecLib.setIlkAutoLineDebtCeiling("WSTETH-A", 750 * MILLION);

        // Increase WSTETH-B line by 500 million DAi from 500 million DAI to 1 billion DAI
        // Increase WSTETH-B gap by 15 million DAI from 30 million DAI to 45 million DAI
        // Reduce WSTETH-B ttl by 14,400 seconds from 57,600 seconds to 43,200 seconds
        // Forum: https://forum.makerdao.com/t/non-scope-defined-parameter-changes-wsteth-b-dc-iam/21568
        // Poll: https://vote.makerdao.com/polling/QmPxbrBZ#poll-detail
        DssExecLib.setIlkAutoLineParameters("WSTETH-B", 1 * BILLION, 45 * MILLION, 12 hours);

        // Increase RETH-A line by 25 million DAI from 50 million DAI to 75 million DAI
        DssExecLib.setIlkAutoLineDebtCeiling("RETH-A", 75 * MILLION);

        // ---------- CRVV1ETHSTETH-A 2nd Stage Offboarding ----------
        // Forum: https://forum.makerdao.com/t/stability-scope-parameter-changes-4/21567#crvv1ethsteth-a-offboarding-parameters-13
        // Mip: https://mips.makerdao.com/mips/details/MIP104#14-3-native-vault-engine

        // Set chop to 0%
        DssExecLib.setIlkLiquidationPenalty("CRVV1ETHSTETH-A", 0);

        // Set tip to 0%
        DssExecLib.setKeeperIncentiveFlatRate("CRVV1ETHSTETH-A", 0);

        // Set chip to 0%
        DssExecLib.setKeeperIncentivePercent("CRVV1ETHSTETH-A", 0);

        // Set Liquidation Ratio to 10,000%
        // NOTE: We are using low level methods because DssExecLib only allows setting `mat < 1000%`: https://github.com/makerdao/dss-exec-lib/blob/69b658f35d8618272cd139dfc18c5713caf6b96b/src/DssExecLib.sol#L717
        DssExecLib.setValue(MCD_SPOT, "CRVV1ETHSTETH-A", "mat", 100 * RAY);

        // NOTE: Update collateral price to propagate the changes
        DssExecLib.updateCollateralPrice("CRVV1ETHSTETH-A");

        // Reduce Global Debt Ceiling by 100 million DAI to account for offboarded collateral
        DssExecLib.decreaseGlobalDebtCeiling(100 * MILLION);

        // ---------- Aligned Delegate Compensation for July 2023 ----------
        // Forum: https://forum.makerdao.com/t/july-2023-aligned-delegate-compensation/21632

        // 0xDefensor - 29.76 MKR - 0x9542b441d65B6BF4dDdd3d4D2a66D8dCB9EE07a9
        mkr.transfer(DEFENSOR,       29.76 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // BONAPUBLICA - 29.76 MKR - 0x167c1a762B08D7e78dbF8f24e5C3f1Ab415021D3
        mkr.transfer(BONAPUBLICA,    29.76 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // QGov - 29.76 MKR - 0xB0524D8707F76c681901b782372EbeD2d4bA28a6
        mkr.transfer(QGOV,           29.76 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // TRUE NAME - 29.76 MKR - 0x612f7924c367575a0edf21333d96b15f1b345a5d
        mkr.transfer(TRUENAME,       29.76 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // UPMaker - 29.76 MKR - 0xbb819df169670dc71a16f58f55956fe642cc6bcd
        mkr.transfer(UPMAKER,        29.76 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // vigilant - 29.76 MKR - 0x2474937cB55500601BCCE9f4cb0A0A72Dc226F61
        mkr.transfer(VIGILANT,       29.76 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // WBC - 14.82 MKR - 0xeBcE83e491947aDB1396Ee7E55d3c81414fB0D47
        mkr.transfer(WBC,            14.82 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // PALC - 13.89 MKR - 0x78Deac4F87BD8007b9cb56B8d53889ed5374e83A
        mkr.transfer(PALC,           13.89 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // Navigator - 11.24 MKR - 0x11406a9CC2e37425F15f920F494A51133ac93072
        mkr.transfer(NAVIGATOR,      11.24 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // PBG - 9.92 MKR - 0x8D4df847dB7FfE0B46AF084fE031F7691C6478c2
        mkr.transfer(PBG,            9.92 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // VoteWizard - 9.92 MKR - 0x9E72629dF4fcaA2c2F5813FbbDc55064345431b1
        mkr.transfer(VOTEWIZARD,     9.92 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // Libertas - 9.92 MKR - 0xE1eBfFa01883EF2b4A9f59b587fFf1a5B44dbb2f
        mkr.transfer(LIBERTAS,       9.92 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // Harmony - 8.93 MKR - 0xF4704Aa4Ad22cAA2A3Dd7A7C529B4C32f7A421F2
        mkr.transfer(HARMONY,        8.93 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // JAG - 7.61 MKR - 0x58D1ec57E4294E4fe650D1CB12b96AE34349556f
        mkr.transfer(JAG,            7.61 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // Cloaky - 4.30 MKR - 0x869b6d5d8FA7f4FFdaCA4D23FFE0735c5eD1F818
        mkr.transfer(CLOAKY,         4.30 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // Skynet - 3.64 MKR - 0xd4d1A446cD5976a11bd32D3e815A9F85FED2F9F3
        mkr.transfer(SKYNET,         3.64 ether); // NOTE: ether is a keyword helper, only MKR is transferred here

        // ---------- Old D3M Parameter Housekeeping ----------
        // Forum: https://forum.makerdao.com/t/notice-of-executive-vote-date-change-and-housekeeping-changes/21613

        // NOTE: Variables to calculate decrease of the global debt ceiling
        uint256 line;
        uint256 globalLineReduction = 0;

        // Remove DIRECT-AAVEV2-DAI from autoline
        DssExecLib.removeIlkFromAutoLine("DIRECT-AAVEV2-DAI");

        // Set DIRECT-AAVEV2-DAI Debt Ceiling to 0
        (,,,line,) = vat.ilks("DIRECT-AAVEV2-DAI");
        globalLineReduction += line;
        DssExecLib.setIlkDebtCeiling("DIRECT-AAVEV2-DAI", 0);

        // Remove DIRECT-COMPV2-DAI from autoline
        DssExecLib.removeIlkFromAutoLine("DIRECT-COMPV2-DAI");

        // Set DIRECT-COMPV2-DAI Debt Ceiling to 0
        (,,,line,) = vat.ilks("DIRECT-COMPV2-DAI");
        globalLineReduction += line;
        DssExecLib.setIlkDebtCeiling("DIRECT-COMPV2-DAI", 0);

        // Reduce Global Debt Ceiling? Yes
        vat.file("Line", vat.Line() - globalLineReduction);

        // ---------- New Silver Parameter Changes ----------
        // Forum: https://forum.makerdao.com/t/rwa-002-new-silver-restructuring-risk-and-legal-assessment/21417
        // Poll: https://vote.makerdao.com/polling/QmaU1eaD#poll-detail

        // Increase RWA002-A Debt Ceiling by 30 million DAI from 20 million DAI to 50 million DAI
        DssExecLib.increaseIlkDebtCeiling(
            "RWA002-A",
            30 * MILLION,
            true // Increase global Line
        );

        // Increase RWA002-A Stability Fee by 3.5% from 3.5% to 7%
        DssExecLib.setIlkStabilityFee("RWA002-A", SEVEN_PCT_RATE, /* doDrip = */ true);

        // Reduce Liquidation Ratio by 5% from 105% to 100%
        // Forum: https://forum.makerdao.com/t/notice-of-executive-vote-date-change-and-housekeeping-changes/21613
        DssExecLib.setIlkLiquidationRatio("RWA002-A", 100_00);

        // Bump Oracle price to account for new DC and SF
        // NOTE: the formula is `Debt ceiling * [ (1 + RWA stability fee ) ^ (minimum deal duration in years) ] * liquidation ratio`
        // Since RWA002-A Termination Date is `October 11, 2032`, and spell execution time is `2023-08-18`, the distance is `3342` days
        // bc -l <<< 'scale=18; 50000000 * e(l(1.07) * (3342/365)) * 1.00' | cast --to-wei
        RwaLiquidationLike_1(MIP21_LIQUIDATION_ORACLE).bump(
            "RWA002-A",
            92_899_355_926924134500000000
        );

        // NOTE: Update collateral price to propagate the changes
        DssExecLib.updateCollateralPrice("RWA002-A");

        // ---------- Transfer Spark Proxy Admin Controls ----------
        // Forum: https://forum.makerdao.com/t/phoenix-labs-proposed-changes-for-spark-for-august-18th-spell/21612
        // Poll: https://vote.makerdao.com/polling/Qmc9fd3j

        TransferOwnershipLike_1(SPARK_TREASURY_CONTROLLER).transferOwnership(SPARK_PROXY);
        ChangeAdminLike_1(SPARK_TREASURY).changeAdmin(SPARK_PROXY);
        ChangeAdminLike_1(SPARK_TREASURY_DAI).changeAdmin(SPARK_PROXY);
        ChangeAdminLike_1(SPARK_INCENTIVES).changeAdmin(SPARK_PROXY);
        TransferOwnershipLike_1(SPARK_WETH_GATEWAY).transferOwnership(SPARK_PROXY);
        ACLManagerLike_1(SPARK_ACL_MANAGER).addEmergencyAdmin(SPARK_PROXY);
        ACLManagerLike_1(SPARK_ACL_MANAGER).removeEmergencyAdmin(address(this));
        ACLManagerLike_1(SPARK_ACL_MANAGER).removePoolAdmin(address(this));
        bytes32 defaultAdminRole = ACLManagerLike_1(SPARK_ACL_MANAGER).DEFAULT_ADMIN_ROLE();
        ACLManagerLike_1(SPARK_ACL_MANAGER).grantRole(defaultAdminRole, SPARK_PROXY);
        ACLManagerLike_1(SPARK_ACL_MANAGER).revokeRole(defaultAdminRole, address(this));
        PoolAddressProviderLike_1(SPARK_POOL_ADDRESS_PROVIDER).setACLAdmin(SPARK_PROXY);
        TransferOwnershipLike_1(SPARK_POOL_ADDRESS_PROVIDER).transferOwnership(SPARK_PROXY);
        TransferOwnershipLike_1(SPARK_POOL_ADDRESS_PROVIDER_REGISTRY).transferOwnership(SPARK_PROXY);
        TransferOwnershipLike_1(SPARK_EMISSION_MANAGER).transferOwnership(SPARK_PROXY);

        // ---------- Trigger Spark Proxy Spell ----------
        // Forum: https://forum.makerdao.com/t/phoenix-labs-proposed-changes-for-spark-for-august-18th-spell/21612

        // Mainnet - 0x60cC45DaB5F0B17789C77d5FE990f1aD80e9DD65
        ProxyLike_1(SPARK_PROXY).exec(SPARK_SPELL, abi.encodeWithSignature("execute()"));
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) {}
}

