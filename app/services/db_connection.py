from sqlalchemy.orm import Session
from app.models import User  # Replace with your actual model

def get_user(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()
