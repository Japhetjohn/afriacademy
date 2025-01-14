from typing import List
from app.models.students import Student

# setting placeholder for database/storage
students_db = [
    Student(id=1, name="john doe", email="johndoe@email.com"),
    Student(id=2, name="jane smith", email="janesmith@email.com"),
    Student(id=3, name="Michael brown", email="michaelbrown@email.com")
]

def get_all_students() -> List[Student]:
    return sorted(students_db, key=lambda student: student.id)


def get_student_by_id(student_id: int) -> Student:
    for student in students_db:
        if student.id == student_id:
            return student
    return None

def add_student(student: Student) -> Student:
    students_db.append(student)
    return student

def update_student(student_id: int, updated_student: Student) -> Student:
    for student in students_db:
        if student.id == student_id:
            student.name = updated_student.name
            student.email = updated_student.email
            return student
    return None

def delete_student(student_id: int) -> bool:
    global students_db
    students_db = [student for student in students_db if student.id != student_id]
    return True