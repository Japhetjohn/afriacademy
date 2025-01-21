// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/contracts/StudentRegistry.sol";
import "../src/contracts/CertificateNFT.sol";

contract SystemIntegrationTest is Test {
    StudentRegistry public registry;
    CertificateNFT public certificate;
    
    address public admin = address(1);
    address public educator = address(2);
    address public student = address(3);
    
    function setUp() public {
        vm.startPrank(admin);
        // Deploy both contracts
        registry = new StudentRegistry();
        certificate = new CertificateNFT(address(registry));
        
        // Setup roles
        registry.grantRole(registry.EDUCATOR_ROLE(), educator);
        certificate.grantRole(certificate.MINTER_ROLE(), educator);
        vm.stopPrank();
    }
    
    function testCompleteStudentJourney() public {
        // 1. Student Registration
        vm.startPrank(student);
        registry.registerStudent("John Doe");
        
        // 2. Course Enrollment
        uint256 courseId = 1;
        registry.enrollInCourse(courseId);
        
        // 3. Progress Updates
        vm.startPrank(educator);
        registry.updateProgress(student, courseId, 25);
        registry.updateProgress(student, courseId, 50);
        registry.updateProgress(student, courseId, 75);
        registry.updateProgress(student, courseId, 100);
        
        // 4. Exam Completion
        registry.recordExamResult(student, courseId, 85);
        
        // 5. Certificate Minting
        string memory uri = "ipfs://QmTest";
        uint256 tokenId = certificate.mintCertificate(student, courseId, uri);
        
        // Verify final state
        assertTrue(registry.isStudentRegistered(student));
        assertEq(certificate.ownerOf(tokenId), student);
        
        // Verify certificate data
        (
            address certStudent,
            uint256 certCourseId,
            ,  // issueDate
            uint256 score,
            
        ) = certificate.getCertificateData(tokenId);
        
        assertEq(certStudent, student);
        assertEq(certCourseId, courseId);
        assertEq(score, 85);
    }
    
    function testMultipleStudentsConcurrentProgress() public {
        address student2 = address(4);
        uint256 courseId = 1;
        
        // Register and enroll students
        vm.prank(student);
        registry.registerStudent("John Doe");
        vm.prank(student2);
        registry.registerStudent("Jane Doe");
        
        vm.prank(student);
        registry.enrollInCourse(courseId);
        vm.prank(student2);
        registry.enrollInCourse(courseId);
        
        // Update progress concurrently
        vm.startPrank(educator);
        registry.updateProgress(student, courseId, 50);
        registry.updateProgress(student2, courseId, 30);
        registry.updateProgress(student, courseId, 100);
        registry.updateProgress(student2, courseId, 60);
        
        // Complete course for first student
        registry.recordExamResult(student, courseId, 90);
        string memory uri = "ipfs://QmTest1";
        uint256 tokenId = certificate.mintCertificate(student, courseId, uri);
        
        // Verify states
        assertEq(registry.getProgress(student, courseId), 100);
        assertEq(registry.getProgress(student2, courseId), 60);
        assertEq(certificate.ownerOf(tokenId), student);
        vm.stopPrank();
    }
    
    function testSystemPauseAndResume() public {
        // Setup initial state
        vm.prank(student);
        registry.registerStudent("John Doe");
        
        // Pause both contracts
        vm.startPrank(admin);
        registry.pause();
        certificate.pause();
        
        // Verify operations are blocked
        vm.expectRevert("Pausable: paused");
        vm.prank(student);
        registry.enrollInCourse(1);
        
        // Resume operations
        registry.unpause();
        certificate.unpause();
        
        // Verify operations resume
        vm.prank(student);
        registry.enrollInCourse(1);
        assertTrue(registry.isEnrolled(student, 1));
        vm.stopPrank();
    }
}