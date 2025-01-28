// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

/**
 * @title MetadataGenerator
 * @dev Library for generating and handling certificate metadata
 */
library MetadataGenerator {
    using Strings for uint256;
    using Strings for address;

    struct CertificateMetadata {
        string studentName;
        bytes studentAddress;
        string courseName;
        uint256 courseId;
        uint256 score;
        uint256 issueDate;
        string ipfsHash;
        bytes signature;
        string institutionName;
        uint256 duration;
    }

    // Events
    event MetadataGenerated(
        string ipfsHash,
        uint256 indexed certificateId,
        address indexed studentAddress
    );

    // Errors
    error InvalidIPFSHash();
    error InvalidMetadata();

    /**
     * @dev Generates the JSON metadata for a certificate
     */
    function _generateAttributesJSON(
        CertificateMetadata memory metadata
    ) private pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"trait_type": "Student Name", "value": "',
                    metadata.studentName,
                    '"},',
                    '{"trait_type": "Student Address", "value": "',
                    address(bytes20(metadata.studentAddress)).toHexString(),
                    '"},',
                    '{"trait_type": "Course", "value": "',
                    metadata.courseName,
                    '"},',
                    '{"trait_type": "Course ID", "value": "',
                    metadata.courseId.toString(),
                    '"},',
                    '{"trait_type": "Score", "value": "',
                    metadata.score.toString(),
                    '"},',
                    '{"trait_type": "Issue Date", "value": "',
                    metadata.issueDate.toString(),
                    '"},',
                    '{"trait_type": "Verification Hash", "value": "',
                    metadata.ipfsHash,
                    '"}'
                )
            );
    }

    /**
     * @dev Generates Base64 encoded metadata
     */
    function generateBase64Metadata(
        CertificateMetadata memory metadata
    ) internal pure returns (string memory) {
        string memory json = generateBase64Metadata(metadata);
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(bytes(json))
                )
            );
    }

    /**
     * @dev Validates IPFS hash format
     */
    function validateIPFSHash(
        string memory ipfsHash
    ) internal pure returns (bool) {
        bytes memory hashBytes = bytes(ipfsHash);
        if (hashBytes.length < 7) return false;

        // Check for "ipfs://" prefix
        return (hashBytes[0] == "i" &&
            hashBytes[1] == "p" &&
            hashBytes[2] == "f" &&
            hashBytes[3] == "s" &&
            hashBytes[4] == ":" &&
            hashBytes[5] == "/" &&
            hashBytes[6] == "/");
    }

    /**
     * @dev Creates metadata verification hash
     */
    function createVerificationHash(
        CertificateMetadata memory metadata
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    metadata.studentAddress,
                    metadata.courseId,
                    metadata.score,
                    metadata.issueDate,
                    metadata.ipfsHash
                )
            );
    }

    /**
     * @dev Formats the IPFS URI with proper prefix
     */
    function formatIPFSUri(
        string memory ipfsHash
    ) internal pure returns (string memory) {
        if (!validateIPFSHash(ipfsHash)) revert InvalidIPFSHash();
        return string(abi.encodePacked("ipfs://", ipfsHash));
    }

    /**
     * @dev Validates certificate metadata
     */

    error MetadataValidationFailed(string reason);

    function validateMetadata(
        CertificateMetadata memory metadata
    ) internal pure returns (bool) {
        if (address(bytes20(metadata.studentAddress)) == address(0))
            revert MetadataValidationFailed("Invalid student address");
        if (bytes(metadata.studentName).length == 0)
            revert MetadataValidationFailed("Student name is empty");
        if (bytes(metadata.courseName).length == 0)
            revert MetadataValidationFailed("Course name is empty");
        if (metadata.courseId == 0)
            revert MetadataValidationFailed("Invalid course ID");
        if (metadata.score > 100)
            revert MetadataValidationFailed("Score exceeds maximum limit");
        if (metadata.issueDate == 0)
            revert MetadataValidationFailed("Invalid issue date");
        if (!validateIPFSHash(metadata.ipfsHash))
            revert MetadataValidationFailed("Invalid IPFS hash");
        return true;
    }
}
