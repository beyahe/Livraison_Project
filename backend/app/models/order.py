from sqlalchemy import Column, Integer, String, Float

from app.database import Base


class Order(Base):

    __tablename__ = "orders"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    customer_name = Column(
        String
    )

    total_price = Column(
        Float
    )

    status = Column(
        String,
        default="pending"
    )

    driver_id = Column(
        Integer,
        nullable=True
    )