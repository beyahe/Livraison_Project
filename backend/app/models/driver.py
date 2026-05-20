from sqlalchemy import Column, Integer, String, Float
from app.database import Base


class Driver(Base):
    __tablename__ = "drivers"

    id = Column(Integer, primary_key=True, index=True)

    name = Column(String)

    latitude = Column(Float)

    longitude = Column(Float)

    status = Column(String, default="offline")