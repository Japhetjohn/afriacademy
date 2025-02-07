from pydantic import BaseModel

class UserCreate(BaseModel):
    name: str
    email: str
    role: str

class UserUpdate(BaseModel):
    email: str

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    role: str
