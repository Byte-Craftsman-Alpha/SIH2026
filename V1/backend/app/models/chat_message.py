from sqlalchemy import Column, String, ForeignKey, JSON
from app.database import Base, TimestampMixin

class ChatMessage(Base, TimestampMixin):
    __tablename__ = "chat_messages"
    id = Column(String, primary_key=True)
    visit_id = Column(String, ForeignKey("visits.id"))
    sender = Column(String)
    input_type = Column(String)
    question_id = Column(String)
    question_text = Column(String)
    answer_json = Column(JSON)
    language = Column(String)
