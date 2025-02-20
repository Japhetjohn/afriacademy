// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../../src/interfaces/IStudentRegistry.sol";

/**
 * @title AfriacademyRegistry
 * @dev Core contract for managing student data, course progress, and exam results
 * Implements IStudentRegistry
 */
contract AfriacademyRegistry is
    AccessControl,
    Pausable,
    ReentrancyGuard,
    IStudentRegistry
{
    // Roles
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant EDUCATOR_ROLE = keccak256("EDUCATOR_ROLE");

    // Structs
    struct Student {
        string name;
        bool isRegistered;
        uint256 enrollmentDate;
        uint256[] enrolledCourses;
    }

    struct Course {
        string name;
        uint256 duration; // in seconds
        uint256 requiredScore; // minimum score to pass (0-100)
        bool isActive;
    }

    // State variables
    mapping(address => Student) private students;
    mapping(uint256 => Course) private courses;
    mapping(address => mapping(uint256 => uint256)) private studentProgress; // student => courseId => progress (0-100)

    uint256 private courseCounter;

    // Events
    event StudentRegistered(
        address indexed student,
        string name,
        uint256 timestamp
    );
    event CourseEnrollment(address indexed student, uint256 indexed courseId);
    event ProgressUpdated(
        address indexed student,
        uint256 indexed courseId,
        uint256 progress
    );

    // Constructor
    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function registerStudent(
        string calldata _name
    ) external override whenNotPaused {
        if (students[msg.sender].isRegistered)
            revert("StudentAlreadyRegistered");

        students[msg.sender] = Student({
            name: _name,
            isRegistered: true,
            enrollmentDate: block.timestamp,
            enrolledCourses: new uint256[]
        });

        emit StudentRegistered(msg.sender, _name, block.timestamp);
    }

    function isStudentRegistered(
        address student
    ) external view override returns (bool) {
        return students[student].isRegistered;
    }

    function enrollInCourse(
        uint256 _courseId
    ) external override whenNotPaused nonReentrant {
        if (!students[msg.sender].isRegistered) revert("StudentNotRegistered");
        if (!courses[_courseId].isActive) revert("CourseNotActive");

        uint256[] storage enrolledCourses = students[msg.sender]
            .enrolledCourses;
        for (uint256 i; i < enrolledCourses.length; i++) {
            if (enrolledCourses[i] == _courseId) revert("AlreadyEnrolled");
        }

        enrolledCourses.push(_courseId);
        emit CourseEnrollment(msg.sender, _courseId);
    }

    function getEnrolledCourses(
        address student
    ) external view override returns (uint256[] memory) {
        return students[student].enrolledCourses;
    }

    function updateProgress(
        address _student,
        uint256 _courseId,
        uint256 _progress
    ) external override onlyRole(EDUCATOR_ROLE) whenNotPaused {
        if (!students[_student].isRegistered) revert("StudentNotRegistered");
        if (!courses[_courseId].isActive) revert("CourseNotActive");
        if (_progress > 100) revert("InvalidScore");

        bool isEnrolled;
        uint256[] storage enrolledCourses = students[_student].enrolledCourses;
        for (uint256 i; i < enrolledCourses.length; i++) {
            if (enrolledCourses[i] == _courseId) {
                isEnrolled = true;
                break;
            }
        }
        if (!isEnrolled) revert("NotEnrolled");

        studentProgress[_student][_courseId] = _progress;
        emit ProgressUpdated(_student, _courseId, _progress);
    }

    function getProgress(
        address _student,
        uint256 _courseId
    ) external view override returns (uint256) {
        return studentProgress[_student][_courseId];
    }
}
