// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../../src/contracts/AfriacademyRegistry.sol";

contract AfriacademyRegistryTest is Test {
    AfriacademyRegistry public registry;

    address public admin = address(1);
    address public educator = address(2);
    address public student1 = address(3);
    address public student2 = address(4);

    // Events to test
    event StudentRegistered(
        address indexed student,
        string name,
        uint256 timestamp
    );
    event CourseCreated(
        uint256 indexed courseId,
        string name,
        uint256 duration
    );
    event CourseEnrollment(address indexed student, uint256 indexed courseId);
    event ProgressUpdated(
        address indexed student,
        uint256 indexed courseId,
        uint256 progress
    );
    event ExamResultRecorded(
        address indexed student,
        uint256 indexed courseId,
        uint256 score,
        bool passed
    );

    function setUp() public {
        vm.startPrank(admin);
        registry = new AfriacademyRegistry();
        registry.grantRole(registry.EDUCATOR_ROLE(), educator);
        vm.stopPrank();
    }

    function testStudentRegistration() public {
        vm.startPrank(student1);

        // Test successful registration
        vm.expectEmit(true, false, false, true);
        emit StudentRegistered(student1, "John Doe", block.timestamp);
        registry.registerStudent("John Doe");

        // Verify registration
        (string memory name, bool isRegistered, , ) = registry.getStudent(
            student1
        );
        assertEq(name, "John Doe");
        assertTrue(isRegistered);

        // Test duplicate registration should fail
        vm.expectRevert(AfriacademyRegistry.StudentAlreadyRegistered.selector);
        registry.registerStudent("John Doe");

        vm.stopPrank();
    }

    function testCourseCreation() public {
        vm.startPrank(educator);

        // Test successful course creation
        vm.expectEmit(true, false, false, true);
        emit CourseCreated(1, "Blockchain Basics", 12 weeks);
        registry.createCourse("Blockchain Basics", 12 weeks, 70);

        // Verify course details
        (
            string memory name,
            uint256 duration,
            uint256 requiredScore,
            bool isActive
        ) = registry.getCourse(1);
        assertEq(name, "Blockchain Basics");
        assertEq(duration, 12 weeks);
        assertEq(requiredScore, 70);
        assertTrue(isActive);

        // Test invalid score should fail
        vm.expectRevert(AfriacademyRegistry.InvalidScore.selector);
        registry.createCourse("Invalid Course", 12 weeks, 101);

        vm.stopPrank();
    }

    function testCourseEnrollment() public {
        // Setup
        vm.prank(student1);
        registry.registerStudent("John Doe");

        vm.prank(educator);
        registry.createCourse("Blockchain Basics", 12 weeks, 70);

        // Test successful enrollment
        vm.startPrank(student1);
        vm.expectEmit(true, true, false, true);
        emit CourseEnrollment(student1, 1);
        registry.enrollInCourse(1);

        // Verify enrollment
        (, , , uint256[] memory courses) = registry.getStudent(student1);
        assertEq(courses.length, 1);
        assertEq(courses[0], 1);

        // Test duplicate enrollment should fail
        vm.expectRevert(AfriacademyRegistry.AlreadyEnrolled.selector);
        registry.enrollInCourse(1);

        vm.stopPrank();
    }

    function testProgressUpdate() public {
        // Setup
        vm.prank(student1);
        registry.registerStudent("John Doe");

        vm.prank(educator);
        registry.createCourse("Blockchain Basics", 12 weeks, 70);

        vm.prank(student1);
        registry.enrollInCourse(1);

        // Test progress update
        vm.startPrank(educator);
        vm.expectEmit(true, true, false, true);
        emit ProgressUpdated(student1, 1, 50);
        registry.updateProgress(student1, 1, 50);

        // Verify progress
        assertEq(registry.getProgress(student1, 1), 50);

        // Test invalid progress should fail
        vm.expectRevert(AfriacademyRegistry.InvalidScore.selector);
        registry.updateProgress(student1, 1, 101);

        vm.stopPrank();
    }

    function testExamResults() public {
        // Setup
        vm.prank(student1);
        registry.registerStudent("John Doe");

        vm.prank(educator);
        registry.createCourse("Blockchain Basics", 12 weeks, 70);

        vm.prank(student1);
        registry.enrollInCourse(1);

        // Test recording exam result
        vm.startPrank(educator);
        vm.expectEmit(true, true, false, true);
        emit ExamResultRecorded(student1, 1, 85, true);
        registry.recordExamResult(student1, 1, 85);

        // Verify exam result
        (uint256 score, , bool passed) = registry.getExamResult(student1, 1);
        assertEq(score, 85);
        assertTrue(passed);

        // Test invalid score should fail
        vm.expectRevert(AfriacademyRegistry.InvalidScore.selector);
        registry.recordExamResult(student1, 1, 101);

        vm.stopPrank();
    }

    function testAccessControl() public {
        // Test non-educator cannot create course
        vm.prank(student1);
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000003 is missing role 0x91b59cd25b3ffe6578b30ee4914fdc05b48f0ace322e68702c939db26f48696e"
        );
        registry.createCourse("Unauthorized Course", 12 weeks, 70);

        // Test non-educator cannot update progress
        vm.prank(student1);
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000003 is missing role 0x91b59cd25b3ffe6578b30ee4914fdc05b48f0ace322e68702c939db26f48696e"
        );
        registry.updateProgress(student1, 1, 50);

        // Test non-admin cannot grant roles
        vm.prank(student1);
        vm.expectRevert(
            "AccessControl: account 0x0000000000000000000000000000000000000003 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000"
        );
        registry.grantRole(registry.EDUCATOR_ROLE(), student2);
    }

    function testPauseFunctionality() public {
        // Setup
        vm.prank(student1);
        registry.registerStudent("John Doe");

        // Pause contract
        vm.prank(admin);
        registry.pause();

        // Test operations while paused
        vm.startPrank(student2);
        vm.expectRevert("Pausable: paused");
        registry.registerStudent("Jane Doe");
        vm.stopPrank();

        // Unpause and verify operations resume
        vm.prank(admin);
        registry.unpause();

        vm.prank(student2);
        registry.registerStudent("Jane Doe");
        (string memory name, , , ) = registry.getStudent(student2);
        assertEq(name, "Jane Doe");
    }
}
