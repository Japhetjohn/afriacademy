from fastapi import APIRouter
from app.models.students import Student

router = APIRouter()

@router.get("/students", response_model=list[Student])
def get_students():

    students = [
        Student(id=1, name="John doe", email="johndoe@gmail.com"),
        Student(id=2, name="Jane Smith", email="janesmith@gmail.com"),
        Student(id=3, name="Michael Brown", email="michaelbrown@gmail.com")
    ]
    return students
