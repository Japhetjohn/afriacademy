from fastapi import APIRouter, HTTPException
from app.schemas.user import UserCreate, UserUpdate, UserResponse
from app.services.crud import create_user, get_users, update_user, delete_user

router = APIRouter()

# Endpoint: Create a new user
@router.post("/users", response_model=UserResponse)
def create_new_user(user: UserCreate):
    try:
        # Call the CRUD function to create a user
        create_user(user.name, user.email, user.role)
        # Fetch all users to locate the newly created one
        users = get_users()
        # (Assuming the newly created user is the last in the list)
        if users:
            new_user = users[-1]
            return {
                "id": new_user[0],
                "name": new_user[1],
                "email": new_user[2],
                "role": new_user[3]
            }
        else:
            raise HTTPException(status_code=500, detail="User creation failed: No users returned.")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Endpoint: Get all users
@router.get("/users")
def read_all_users():
    try:
        users = get_users()
        return users  # returning raw tuple data; you might want to transform this into a list of dicts
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Endpoint: Update a user
@router.put("/users/{user_id}", response_model=UserResponse)
def update_existing_user(user_id: int, user: UserUpdate):
    try:
        update_user(user_id, user.email)
        # After update, fetch the updated user
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

# Endpoint: Delete a user
@router.delete("/users/{user_id}")
def delete_existing_user(user_id: int):
    try:
        delete_user(user_id)
        return {"detail": "User deleted successfully"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
