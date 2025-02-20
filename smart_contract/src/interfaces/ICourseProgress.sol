// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface ICourseProgress {
    // Events
    event CourseCreated(
        uint256 indexed courseId,
        string name,
        uint256 duration,
        uint256 requiredScore
    );
    event CourseStatusUpdated(uint256 indexed courseId, bool isActive);

    // Functions
    function createCourse(
        string memory name,
        uint256 duration,
        uint256 requiredScore
    ) external;

    function activateCourse(uint256 courseId) external;

    function deactivateCourse(uint256 courseId) external;

    function isCourseActive(uint256 courseId) external view returns (bool);

    function getCourse(uint256 courseId)
        external
        view
        returns (
            string memory name,
            uint256 duration,
            uint256 requiredScore,
            bool isActive
        );
}
