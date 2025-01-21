// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "../../lib/forge-std/src/Test.sol";
import "../../src/contracts/AfriacademyCertificate.sol";
import "../../src/contracts/AfriacademyRegistry.sol";

contract AfriacademyCertificateTest is Test {
    AfriacademyCertificate public certificate;
    AfriacademyRegistry public registry;

    address public admin = address(1);
    address public minter = address(2);
    address public student1 = address(3);
    address public student2 = address(4);

    // Events to test
    event CertificateMinted(
        uint256 indexed tokenId,
        address indexed student,
        uint256 indexed courseId,
        uint256 score,
        uint256 issueDate
    );
    event RegistryUpdated(address newRegistry);

    function setUp() public {
        vm.startPrank(admin);
        // Deploy registry first
        registry = new AfriacademyRegistry();
        registry.grantRole(registry.EDUCATOR_ROLE(), minter);

        // Deploy certificate contract
        certificate = new AfriacademyCertificate(
            "AfriacademyCertificate",
            "AFCERT",
            address(registry)
        );

        // Grant roles
        certificate.grantRole(certificate.MINTER_ROLE(), minter);
        vm.stopPrank();

        // Setup test course
        vm.startPrank(minter);
        registry.createCourse("Blockchain Basics", 12 weeks, 70);
        vm.stopPrank();
    }

    function testMintCertificate() public {
        // Setup: Register student and complete course
        vm.prank(student1);
        registry.registerStudent("John Doe");

        vm.prank(student1);
        registry.enrollInCourse(1);

        vm.prank(minter);
        registry.recordExamResult(student1, 1, 85); // Pass the exam

        // Test successful certificate minting
        vm.startPrank(minter);
        string memory uri = "ipfs://QmTest";
        vm.expectEmit(true, true, true, false);
        emit CertificateMinted(1, student1, 1, 85, block.timestamp);

        uint256 tokenId = certificate.mintCertificate(student1, 1, uri);
        assertEq(tokenId, 1);

        // Verify certificate data
        (
            address studentAddr,
            uint256 courseId,
            uint256 issueDate,
            uint256 score,
            string memory courseName
        ) = certificate.getCertificateData(tokenId);

        assertEq(studentAddr, student1);
        assertEq(courseId, 1);
        assertEq(score, 85);
        assertEq(courseName, "Blockchain Basics");
        assertTrue(issueDate > 0);

        // Verify token ownership
        assertEq(certificate.ownerOf(tokenId), student1);
        assertEq(certificate.tokenURI(tokenId), uri);
        vm.stopPrank();
    }

    function testCannotMintDuplicateCertificate() public {
        // Setup: Mint first certificate
        vm.prank(student1);
        registry.registerStudent("John Doe");

        vm.prank(student1);
        registry.enrollInCourse(1);

        vm.prank(minter);
        registry.recordExamResult(student1, 1, 85);

        vm.prank(minter);
        certificate.mintCertificate(student1, 1, "ipfs://QmTest1");

        // Try to mint duplicate certificate
        vm.prank(minter);
        vm.expectRevert(
            AfriacademyCertificate.CertificateAlreadyIssued.selector
        );
        certificate.mintCertificate(student1, 1, "ipfs://QmTest2");
    }

    function testCannotMintWithoutPassingCourse() public {
        vm.prank(student1);
        registry.registerStudent("John Doe");

        vm.prank(student1);
        registry.enrollInCourse(1);

        vm.prank(minter);
        registry.recordExamResult(student1, 1, 65); // Failed exam

        vm.prank(minter);
        vm.expectRevert(AfriacademyCertificate.CourseNotCompleted.selector);
        certificate.mintCertificate(student1, 1, "ipfs://QmTest");
    }

    function testAccessControl() public {
        // Test non-minter cannot mint certificate
        vm.prank(student1);
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000003 is missing role 0x9f2df0fed2c77648de5860a4cc508cd0818c85b8b8a1ab4ceeef8d981c8956a6"
        );
        certificate.mintCertificate(student1, 1, "ipfs://QmTest");

        // Test non-admin cannot update registry
        vm.prank(student1);
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000003 is missing role 0xa49807205ce4d355092ef5a8a18f56e8913cf4a201fbe287825b095693c21775"
        );
        certificate.setRegistry(address(1));
    }

    function testPauseFunctionality() public {
        // Setup
        vm.prank(student1);
        registry.registerStudent("John Doe");

        vm.prank(student1);
        registry.enrollInCourse(1);

        vm.prank(minter);
        registry.recordExamResult(student1, 1, 85);

        // Pause contract
        vm.prank(admin);
        certificate.pause();

        // Test minting while paused
        vm.prank(minter);
        vm.expectRevert("Pausable: paused");
        certificate.mintCertificate(student1, 1, "ipfs://QmTest");

        // Unpause and verify minting works
        vm.prank(admin);
        certificate.unpause();

        vm.prank(minter);
        uint256 tokenId = certificate.mintCertificate(
            student1,
            1,
            "ipfs://QmTest"
        );
        assertEq(tokenId, 1);
    }

    function testUpdateRegistry() public {
        AfriacademyRegistry newRegistry = new AfriacademyRegistry();

        vm.prank(admin);
        vm.expectEmit(true, false, false, true);
        emit RegistryUpdated(address(newRegistry));
        certificate.setRegistry(address(newRegistry));

        assertEq(address(certificate.registry()), address(newRegistry));
    }
}
