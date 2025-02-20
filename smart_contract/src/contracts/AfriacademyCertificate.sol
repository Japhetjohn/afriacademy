// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "../../src/interfaces/ICertificateNFT.sol";

contract CertificateNFT is
    ERC721URIStorage,
    AccessControl,
    Pausable,
    ICertificateNFT
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 private _tokenIdCounter;

    mapping(uint256 => Certificate) public certificates;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721URIStorage, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mintCertificate(
        address student,
        uint256 courseId,
        string memory courseName,
        uint256 score,
        string memory metadataURI
    ) external override onlyRole(MINTER_ROLE) whenNotPaused returns (uint256) {
        require(bytes(metadataURI).length > 0, "Metadata URI cannot be empty");
        require(
            isValidDecentralizedURI(metadataURI),
            "Metadata URI must point to IPFS or Arweave"
        );

        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _safeMint(student, tokenId);
        _setTokenURI(tokenId, metadataURI);

        certificates[tokenId] = Certificate(
            student,
            courseId,
            block.timestamp,
            score,
            courseName
        );

        emit CertificateMinted(
            tokenId,
            student,
            courseId,
            score,
            block.timestamp
        );

        return tokenId;
    }

    function isValidDecentralizedURI(
        string memory uri
    ) public pure override returns (bool) {
        bytes memory uriBytes = bytes(uri);
        if (uriBytes.length < 7) {
            return false;
        }

        // Check if the URI starts with "ipfs://" or "ar://"
        bytes memory ipfsPrefix = bytes("ipfs://");
        bytes memory arweavePrefix = bytes("ar://");

        for (uint256 i = 0; i < ipfsPrefix.length; i++) {
            if (uriBytes[i] != ipfsPrefix[i]) {
                break;
            }
            if (i == ipfsPrefix.length - 1) {
                return true;
            }
        }

        for (uint256 i = 0; i < arweavePrefix.length; i++) {
            if (uriBytes[i] != arweavePrefix[i]) {
                break;
            }
            if (i == arweavePrefix.length - 1) {
                return true;
            }
        }

        return false;
    }

    function getCertificateData(
        uint256 tokenId
    )
        public
        view
        override
        returns (
            address student,
            uint256 courseId,
            uint256 issueDate,
            uint256 score,
            string memory courseName
        )
    {
        Certificate memory certificate = certificates[tokenId];
        return (
            certificate.student,
            certificate.courseId,
            certificate.issueDate,
            certificate.score,
            certificate.courseName
        );
    }

    function pause() external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}
