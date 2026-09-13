import sys
import os

# Set root directory for module imports
current_dir = os.path.dirname(os.path.abspath(__file__))
backend_dir = os.path.dirname(current_dir)
if backend_dir not in sys.path:
    sys.path.insert(0, backend_dir)

# Set serverless environment flag
os.environ["VERCEL"] = "1"

# Import main FastAPI application instance
from app.main import app

# Vercel serverless function entrypoint
app = app

