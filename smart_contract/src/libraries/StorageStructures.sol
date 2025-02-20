// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library StorageStructures {
    struct Student {
        string name;
        bool isRegistered;
        uint256 enrollmentDate;
        uint256[] completedCourses;
        mapping(uint256 => uint8) courseProgress; // courseId => completed modules
    }

    struct Course {
        string name;
        uint256 duration; // in seconds
        uint8 requiredScore; // minimum score to pass (0-100)
        bool isActive;
        uint256 totalEnrolled;
        mapping(address => bool) enrolledStudents;
    }

    struct Certificate {
        address student;
        uint256 courseId;
        uint256 issueDate;
        uint256 score;
        string ipfsHash;
        bool isValid;
        string issuer; // Name of issuing institution
        string additionalData; // IPFS hash for extended metadata
    }

    struct ExamResult {
        uint256 courseId;
        uint256 score;
        uint256 timestamp;
        bool verified;
        string examHash; // IPFS hash of exam details
    }

    error InvalidStudent();
    error CourseNotActive();
    error UnauthorizedAccess();
}
