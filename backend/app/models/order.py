from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.sql import func

from app.database import Base


class Order(Base):
    __tablename__ = "orders"

    id = Column(Integer, primary_key=True, index=True)

    # Old field - kept so the current apps keep working
    customer_name = Column(String)

    total_price = Column(Float)

    status = Column(String, default="pending")

    driver_id = Column(Integer, nullable=True)

    # ===== New fields (phase 1) =====

    customer_id = Column(Integer, ForeignKey("users.id"), nullable=True)

    restaurant_id = Column(Integer, ForeignKey("restaurants.id"), nullable=True)

    address = Column(String, nullable=True)

    latitude = Column(Float, nullable=True)

    longitude = Column(Float, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now())