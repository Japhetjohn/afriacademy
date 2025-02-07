from fastapi import FastAPI
from app.routes.students import router as student_router
from app.routes.exams import router as exam_router
from app.routes.user import router as user_router

app = FastAPI()

@app.get("/")
def read_root():
    return {"Welcome": "Welcome to the AfriAcademy API"}

# Include routes properly
app.include_router(student_router, prefix="/api/students", tags=["Students"])
app.include_router(user_router, prefix="/api/users", tags=["Users"])
app.include_router(exam_router, prefix="/api/exams", tags=["Exams"])
