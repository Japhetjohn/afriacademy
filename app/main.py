from fastapi import FastAPI
from app.routes.students import router as student_router  # Correct import and alias

app = FastAPI()

@app.get("/")
def read_root():
    return {"Welcome": "Welcome to the AfriAcademy API"}


# Include routes (we will set these up later)
app.include_router(student_router, prefix="/api", tags=["Students"])
