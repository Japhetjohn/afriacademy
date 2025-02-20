from fastapi import APIRouter, HTTPException
from app.models.exams import Exam, Question, ExamSubmission
from typing import List
from pydantic import BaseModel
from app.services.exams_services import calculate_score


router = APIRouter()

exams_db = [
    Exam(
        id=1,
        title="Basic blockchain quiz",
        subject="Blockchain",
        duration_minutes=10,
        max_score=100,
        description="Test your knowledge on blockchain technology",
        questions=[
            Question(
                id=1,
                text="What is a blockchain?",
                options=["A chain of blocks", "A chain of chains", "a block of chains", "None of the above"],
                correct_option=0
            ),
            Question(
                id=2,
                text="Who created Bitcoin?",
                options=["Satoshi Nakamoto", "Vitalik Buterin", "Charlie Lee", "None of the above"],
                correct_option=0
            )
        ],
    )
]

class Question(BaseModel):
    id: int
    text: str
    options: List[str]
    correct_option: int  # the correct option (index)

class Exam(BaseModel):
    id: int
    title: str
    subject: str
    duration_minutes: int
    max_score: int  # max possible score for the exam
    questions: List[Question]  # list of questions


@router.get("/exams", response_model=List[Exam])
def get_all_exams():
    """"Retrieve all exams"""
    return exams_db

@router.get("/exams/{exam_id}", response_model=Exam)
def get_exam_by_id(exam_id: int):
    """Retrieve a single exam by its ID"""
    for exam in exams_db:
        if exam.id == exam_id:
            return exam
    raise HTTPException(status_code=404, detail="Exam not found")

@router.post("'exams", response_model=Exam)
def add_exam(exam: Exam):
    """Add a new exam to the database"""
    exams_db.append(exam)
    return exam

@router.put("/exams/{exam_id}", response_model=Exam)
def update_exam(exam_id: int, exam: Exam):
    """Update an existing exam"""
    for i, e in enumerate(exams_db):
        if e.id == exam_id:
            exams_db[i] = exam
            return exam
    raise HTTPException(status_code=404, detail="Exam not found")

@router.delete("/exams/{exam_id}")
def delete_exam(exam_id: int):
    """Delete an exam by ID"""
    global exams_db
    exams_db = [exam for exam in exams_db if exam.id != exam_id]
    return{"messsage": "Exam deleted successfully"}

class ScoreResponse(BaseModel):
    score: float
    result: str

@router.post("/submit_exam/{exam_id}", response_model=ScoreResponse)
async def submit_exam(exam_id: int, exam_submission: ExamSubmission):
    # Fetch the exam from the database (replace with actual DB query)
    exam = await get_exam_by_id(exam_id)  # Mocked function, to be replaced with DB query
    
    if not exam:
        raise HTTPException(status_code=404, detail="Exam not found")

    # Calculate the score
    score = calculate_score(exam, exam_submission.answers)
    
    # Determine pass/fail based on score
    result = pass_or_fail(score, exam)
    
    return {"score": score, "result": result}

def pass_or_fail(score: float, exam: Exam) -> str:
    passing_percentage = 0.5  # 50% pass mark
    if score >= (exam.max_score * passing_percentage):
        return "Pass"
    return "Fail"
