from app.models.exams import Exam, Question
from typing import List

def calculate_score(exam: Exam, student_answers: List[int]) -> float:
    correct_answers = 0

    # Compare the student's answers to the correct answers
    for i, student_answer in enumerate(student_answers):
        if student_answer == exam.questions[i].correct_option:
            correct_answers += 1

    # Calculate the score based on max_score
    score = (correct_answers / len(exam.questions)) * exam.max_score
    return score
