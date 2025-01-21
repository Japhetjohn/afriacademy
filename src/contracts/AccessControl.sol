// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title EducationAccessControl
 * @dev Manages roles and permissions for the education certificate system
 */
contract EducationAccessControl is AccessControl, Pausable {
    // Role definitions
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant EDUCATOR_ROLE = keccak256("EDUCATOR_ROLE");
    bytes32 public constant VERIFIER_ROLE = keccak256("VERIFIER_ROLE");
    
    // Events
    event RoleAssigned(bytes32 indexed role, address indexed account, address indexed assigner);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed revoker);
    
    // Errors
    error UnauthorizedRole(bytes32 role, address account);
    error InvalidAddress();
    
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        
        // Set role hierarchies
        _setRoleAdmin(EDUCATOR_ROLE, ADMIN_ROLE);
        _setRoleAdmin(VERIFIER_ROLE, ADMIN_ROLE);
    }
    
    // Role management functions
    function assignEducatorRole(address account) external onlyRole(ADMIN_ROLE) {
        if(account == address(0)) revert InvalidAddress();
        grantRole(EDUCATOR_ROLE, account);
        emit RoleAssigned(EDUCATOR_ROLE, account, msg.sender);
    }
    
    function assignVerifierRole(address account) external onlyRole(ADMIN_ROLE) {
        if(account == address(0)) revert InvalidAddress();
        grantRole(VERIFIER_ROLE, account);
        emit RoleAssigned(VERIFIER_ROLE, account, msg.sender);
    }
    
    function revokeEducatorRole(address account) external onlyRole(ADMIN_ROLE) {
        revokeRole(EDUCATOR_ROLE, account);
        emit RoleRevoked(EDUCATOR_ROLE, account, msg.sender);
    }
    
    function revokeVerifierRole(address account) external onlyRole(ADMIN_ROLE) {
        revokeRole(VERIFIER_ROLE, account);
        emit RoleRevoked(VERIFIER_ROLE, account, msg.sender);
    }
    
    // System pause controls
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }
    
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
    
    // Role checks
    function isEducator(address account) external view returns (bool) {
        return hasRole(EDUCATOR_ROLE, account);
    }
    
    function isVerifier(address account) external view returns (bool) {
        return hasRole(VERIFIER_ROLE, account);
    }
    
    function isAdmin(address account) external view returns (bool) {
        return hasRole(ADMIN_ROLE, account);
    }
    
    // Required override
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}