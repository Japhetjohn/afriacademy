// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IStudentRegistry {
    function registerStudent(string calldata _name) external;

    function isStudentRegistered(address student) external view returns (bool);

    function enrollInCourse(uint256 _courseId) external;

    function getEnrolledCourses(
        address student
    ) external view returns (uint256[] memory);

    function updateProgress(
        address _student,
        uint256 _courseId,
        uint256 _progress
    ) external;

    function getProgress(
        address _student,
        uint256 _courseId
    ) external view returns (uint256);
}

