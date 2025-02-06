from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class Question(BaseModel):
    id: int
    text: str  # The question text
    options: List[str]  # A list of possible answers
    correct_option: int  # Index of the correct answer in the options list (e.g., 0, 1, 2, 3)

class Exam(BaseModel):
    id: int
    title: str  # Title of the quiz
    subject: str
    duration_minutes: int
    max_score: int
    description: Optional[str] = None
    questions: List[Question] = []  # A list of questions for the quiz

class ExamSubmission(BaseModel):
    exam_id: int
    correct_options : List[int]  # list of student's answers as indices

class ScoreResponse(BaseModel):
    score: float  # The score the student received
    result: str  # The result (e.g., "Pass" or "Fail")


