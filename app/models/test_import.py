import sys
import os
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))


try:
	from app.models.exams import Exam
	print("Exam model imported successfully!")
except ImportError as e:
	print(f"Error importing Exam model: {e}")
print("Exam model imported successfully!")
