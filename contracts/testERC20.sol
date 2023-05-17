// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract TestERC20 is 
    ERC20,
    AccessControl
{
    event Whitelist(address addr, bool status);
    mapping(address=>bool) public whitelist;
    bytes32 ROLE_OPERATOR = keccak256('ROLE_OPERATOR');
    
    constructor(
        string memory _name,
        string memory _ticker,
        uint256 _supply
    ) ERC20(_name, _ticker) {
        _grantRole(ROLE_OPERATOR, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _mint(msg.sender, _supply);
    }

    function whitelistUser(address[] calldata _addrs, bool _status)     
        onlyRole(ROLE_OPERATOR) 
        external 
        {
            uint256 len = _addrs.length;
            require(len <= 251, "TestERC20: OUT_OF_GAS");
            require(len > 0, "TestERC20: WRONG_LENGTH");
            for(
                uint256 i;
                i<len;
                i++
            ){
                whitelist[_addrs[i]] =_status;
                emit Whitelist(_addrs[i], _status);
            }
        }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal 
        virtual 
        override
    {
        if (!hasRole(ROLE_OPERATOR, to)){
            require(
                whitelist[from] && whitelist[to],
                "TestERC20: NOT_WHITELISTED"
            );
        }
        super._beforeTokenTransfer(from, to, amount);
    }
}
