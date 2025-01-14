from fastapi import FastAPI
from app.routes.students import router as student_router 

app = FastAPI()

@app.get("/")
def read_root():
    return {"Welcome": "Welcome to the AfriAcademy API"}


# Include routes (i'll set these up later)
app.include_router(student_router, prefix="/api", tags=["Students"])
