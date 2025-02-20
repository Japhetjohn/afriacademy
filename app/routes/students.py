from fastapi import APIRouter
from app.models.students import Student
from app.services.students import get_all_students, get_student_by_id, add_student, update_student, delete_student

router = APIRouter()

# Get all students
@router.get("/students", response_model=list[Student])
def get_all_students_route():
    return get_all_students()

# Get student by ID
@router.get("/students/{student_id}", response_model=Student)
def get_student_by_id_route(student_id: int):
    student = get_student_by_id(student_id)
    if student:
        return student
    return {"detail": "Student not found"}

# Add a student
@router.post("/students", response_model=Student)
def add_student_route(student: Student):
    return add_student(student)

# Update a student
@router.put("/students/{student_id}", response_model=Student)
def update_student_route(student_id: int, student: Student):
    return update_student(student_id, student)

# Delete a student
@router.delete("/students/{student_id}")
def delete_student_route(student_id: int):
    if delete_student(student_id):
        return {"detail": f"Student {student_id} deleted"}
    return {"detail": "Student not found"}
