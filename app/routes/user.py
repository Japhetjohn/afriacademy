from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from app.schemas.user import UserCreate, UserUpdate, UserResponse
from app.services.crud import create_user, get_users, update_user, delete_user
from app.services.user_service import get_user  # Imported only relevant functions
from app.services.db_connection import get_connection # Adjust the import path as needed

router = APIRouter()

# Endpoint: Get a user profile by ID
@router.get("/users/{user_id}", response_model=UserResponse)
def get_user_profile(user_id: int):
    try:
        users = get_users()
        user = next((u for u in users if u[0] == user_id), None)
        if user:
            return {
                "id": user[0],
                "name": user[1],
                "email": user[2],
                "role": user[3]
            }
        else:
            raise HTTPException(status_code=404, detail="User not found.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Endpoint: Update user profile (specific fields)
@router.patch("/users/{user_id}", response_model=UserResponse)
def update_user_profile(user_id: int, user: UserUpdate):
    try:
        update_user(user_id, user.email)  # Add more fields if needed
        users = get_users()
        updated_user = next((u for u in users if u[0] == user_id), None)
        if updated_user:
            return {
                "id": updated_user[0],
                "name": updated_user[1],
                "email": updated_user[2],
                "role": updated_user[3]
            }
        else:
            raise HTTPException(status_code=404, detail="User not found after update.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Endpoint: Create a new user
@router.post("/users", response_model=UserResponse)
def create_new_user(user: UserCreate):
    try:
        create_user(user.name, user.email, user.role)
        users = get_users()
        if users:
            new_user = users[-1]
            return {
                "id": new_user[0],
                "name": new_user[1],
                "email": new_user[2],
                "role": new_user[3]
            }
        else:
            raise HTTPException(status_code=500, detail="User creation failed.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Endpoint: Get all users
@router.get("/users")
def read_all_users():
    try:
        users = get_users()
        return users
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Endpoint: Update a user (entire object)
@router.put("/users/{user_id}", response_model=UserResponse)
def update_existing_user(user_id: int, user: UserUpdate):
    try:
        update_user(user_id, user.email)
        users = get_users()
        updated_user = next((u for u in users if u[0] == user_id), None)
        if updated_user:
            return {
                "id": updated_user[0],
                "name": updated_user[1],
                "email": updated_user[2],
                "role": updated_user[3]
            }
        else:
            raise HTTPException(status_code=404, detail="User not found.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Endpoint: Delete a user
@router.delete("/users/{user_id}")
def delete_existing_user(user_id: int):
    try:
        delete_user(user_id)
        return {"detail": "User deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
