// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICertificateNFT {
    struct Certificate {
        address student;
        uint256 courseId;
        uint256 issueDate;
        uint256 score;
        string courseName;
    }

    event CertificateMinted(
        uint256 indexed tokenId,
        address indexed student,
        uint256 indexed courseId,
        uint256 score,
        uint256 issueDate
    );

    function mintCertificate(
        address student,
        uint256 courseId,
        string memory courseName,
        uint256 score,
        string memory metadataURI
    ) external returns (uint256);

    function getCertificateData(
        uint256 tokenId
    )
        external
        view
        returns (
            address student,
            uint256 courseId,
            uint256 issueDate,
            uint256 score,
            string memory courseName
        );

    function pause() external;

    function unpause() external;

    function isValidDecentralizedURI(
        string memory uri
    ) external pure returns (bool);
}
