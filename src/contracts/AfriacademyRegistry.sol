// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title AfriacademyRegistry
 * @dev Core contract for managing student data, course progress, and exam results
 */
contract AfriacademyRegistry is AccessControl, Pausable, ReentrancyGuard {
    // Roles
    bytes32 public constant override DEFAULT_ADMIN_ROLE = keccak256("DEFAULT_ADMIN_ROLE") ;
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

    struct ExamResult {
        uint256 courseId;
        uint256 score;
        uint256 timestamp;
        bool isPassed;
    }

    // State variables
    mapping(address => Student) private students;
    mapping(uint256 => Course) private courses;
    mapping(address => mapping(uint256 => uint256)) private studentProgress; // student => courseId => progress (0-100)
    mapping(address => mapping(uint256 => ExamResult)) private examResults; // student => courseId => result

    uint256 private courseCounter;

    // Events
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

    // Custom errors
    error StudentAlreadyRegistered();
    error StudentNotRegistered();
    error CourseNotFound();
    error CourseNotActive();
    error InvalidScore();
    error AlreadyEnrolled();
    error NotEnrolled();

    constructor() {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    // Student Management Functions
    function registerStudent(string calldata _name) external whenNotPaused {
        if (students[msg.sender].isRegistered)
            revert StudentAlreadyRegistered();

        students[msg.sender] = Student({
            name: _name,
            isRegistered: true,
            enrollmentDate: block.timestamp,
            enrolledCourses: new uint256[](0)
        });

        emit StudentRegistered(msg.sender, _name, block.timestamp);
    }

    function enrollInCourse(
        uint256 _courseId
    ) external whenNotPaused nonReentrant {
        if (!students[msg.sender].isRegistered) revert StudentNotRegistered();
        if (!courses[_courseId].isActive) revert CourseNotActive();

        uint256[] storage enrolledCourses = students[msg.sender]
            .enrolledCourses;
        uint256 len = enrolledCourses.length;
        for (uint256 i; i < len; ) {
            if (enrolledCourses[i] == _courseId) revert AlreadyEnrolled();
            unchecked {
                ++i;
            }
        }

        enrolledCourses.push(_courseId);
        emit CourseEnrollment(msg.sender, _courseId);
    }

    // Course Management Functions
    function createCourse(
        string calldata _name,
        uint256 _duration,
        uint256 _requiredScore
    ) external onlyRole(EDUCATOR_ROLE) whenNotPaused {
        if (_requiredScore > 100) revert InvalidScore();

        uint256 courseId = ++courseCounter;
        courses[courseId] = Course({
            name: _name,
            duration: _duration,
            requiredScore: _requiredScore,
            isActive: true
        });

        emit CourseCreated(courseId, _name, _duration);
    }

    // Progress Tracking Functions
    function updateProgress(
        address _student,
        uint256 _courseId,
        uint256 _progress
    ) external onlyRole(EDUCATOR_ROLE) whenNotPaused {
        if (!students[_student].isRegistered) revert StudentNotRegistered();
        if (!courses[_courseId].isActive) revert CourseNotActive();
        if (_progress > 100) revert InvalidScore();

        bool isEnrolled;
        uint256[] storage enrolledCourses = students[_student].enrolledCourses;
        uint256 len = enrolledCourses.length;
        for (uint256 i; i < len; ) {
            if (enrolledCourses[i] == _courseId) {
                isEnrolled = true;
                break;
            }
            unchecked {
                ++i;
            }
        }
        if (!isEnrolled) revert NotEnrolled();

        studentProgress[_student][_courseId] = _progress;
        emit ProgressUpdated(_student, _courseId, _progress);
    }

    // Exam Management Functions
    function recordExamResult(
        address _student,
        uint256 _courseId,
        uint256 _score
    ) external onlyRole(EDUCATOR_ROLE) whenNotPaused {
        if (!students[_student].isRegistered) revert StudentNotRegistered();
        if (!courses[_courseId].isActive) revert CourseNotActive();
        if (_score > 100) revert InvalidScore();

        bool passed = _score >= courses[_courseId].requiredScore;
        examResults[_student][_courseId] = ExamResult({
            courseId: _courseId,
            score: _score,
            timestamp: block.timestamp,
            isPassed: passed
        });

        emit ExamResultRecorded(_student, _courseId, _score, passed);
    }

    // View Functions
    function getStudent(
        address _student
    )
        external
        view
        returns (
            string memory name,
            bool isRegistered,
            uint256 enrollmentDate,
            uint256[] memory enrolledCourses
        )
    {
        Student storage student = students[_student];
        return (
            student.name,
            student.isRegistered,
            student.enrollmentDate,
            student.enrolledCourses
        );
    }

    function getCourse(
        uint256 _courseId
    )
        external
        view
        returns (
            string memory name,
            uint256 duration,
            uint256 requiredScore,
            bool isActive
        )
    {
        Course storage course = courses[_courseId];
        return (
            course.name,
            course.duration,
            course.requiredScore,
            course.isActive
        );
    }

    function getProgress(
        address _student,
        uint256 _courseId
    ) external view returns (uint256) {
        return studentProgress[_student][_courseId];
    }

    function getExamResult(
        address _student,
        uint256 _courseId
    ) external view returns (uint256 score, uint256 timestamp, bool isPassed) {
        ExamResult storage result = examResults[_student][_courseId];
        return (result.score, result.timestamp, result.isPassed);
    }

    // Admin Functions
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }
}