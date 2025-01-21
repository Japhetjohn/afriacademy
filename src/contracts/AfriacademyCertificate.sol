// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IAfriacademyRegistry {
    function getExamResult(address student, uint256 courseId) external view returns (
        uint256 score,
        uint256 timestamp,
        bool isPassed
    );
    
    function getCourse(uint256 courseId) external view returns (
        string memory name,
        uint256 duration,
        uint256 requiredScore,
        bool isActive
    );
}

/**
 * @title AfriacademyCertificate
 * @dev NFT contract for issuing verifiable course completion certificates
 */
contract AfriacademyCertificate is 
    ERC721, 
    ERC721URIStorage, 
    ERC721Enumerable,
    AccessControl, 
    Pausable,
    ReentrancyGuard 
{
    // Roles
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // State variables
    uint256 private _nextTokenId;
    IAfriacademyRegistry public registry;
    
    // Certificate metadata
    struct CertificateData {
        address student;
        uint256 courseId;
        uint256 issueDate;
        uint256 score;
        string courseName;
    }
    
    mapping(uint256 => CertificateData) private _certificateData;
    mapping(address => mapping(uint256 => uint256)) private _studentCertificates; // student => courseId => tokenId

    // Events
    event CertificateMinted(
        uint256 indexed tokenId, 
        address indexed student, 
        uint256 indexed courseId,
        uint256 score,
        uint256 issueDate
    );
    event RegistryUpdated(address newRegistry);

    // Custom errors
    error CertificateAlreadyIssued();
    error CourseNotCompleted();
    error InvalidRegistry();
    error InvalidMetadataURI();

    constructor(
        string memory name,
        string memory symbol,
        address registryAddress
    ) ERC721(name, symbol) {
        if(registryAddress == address(0)) revert InvalidRegistry();
        
        registry = IAfriacademyRegistry(registryAddress);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(MINTER_ROLE, msg.sender);
    }

    // Main minting function
    function mintCertificate(
        address student,
        uint256 courseId,
        string calldata metadataURI
    ) external onlyRole(MINTER_ROLE) whenNotPaused nonReentrant returns (uint256) {
        if(bytes(metadataURI).length == 0) revert InvalidMetadataURI();
        if(_studentCertificates[student][courseId] != 0) revert CertificateAlreadyIssued();

        // Verify course completion
        (uint256 score, , bool isPassed) = registry.getExamResult(student, courseId);
        if(!isPassed) revert CourseNotCompleted();

        // Get course details
        (string memory courseName, , , ) = registry.getCourse(courseId);

        // Mint certificate
        uint256 newTokenId = ++_nextTokenId;
        
        _safeMint(student, newTokenId);
        _setTokenURI(newTokenId, metadataURI);

        // Store certificate data
        _certificateData[newTokenId] = CertificateData({
            student: student,
            courseId: courseId,
            issueDate: block.timestamp,
            score: score,
            courseName: courseName
        });

        _studentCertificates[student][courseId] = newTokenId;

        emit CertificateMinted(newTokenId, student, courseId, score, block.timestamp);
        
        return newTokenId;
    }

    // View functions
    function getCertificateData(uint256 tokenId) external view returns (
        address student,
        uint256 courseId,
        uint256 issueDate,
        uint256 score,
        string memory courseName
    ) {
        CertificateData memory cert = _certificateData[tokenId];
        return (
            cert.student,
            cert.courseId,
            cert.issueDate,
            cert.score,
            cert.courseName
        );
    }

    function getStudentCertificate(address student, uint256 courseId) external view returns (uint256) {
        return _studentCertificates[student][courseId];
    }

    // Admin functions
    function setRegistry(address newRegistry) external onlyRole(ADMIN_ROLE) {
        if(newRegistry == address(0)) revert InvalidRegistry();
        registry = IAfriacademyRegistry(newRegistry);
        emit RegistryUpdated(newRegistry);
    }

    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    // Required overrides
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}