from sqlalchemy import Column, Integer, String, Float

from app.database import Base


class Restaurant(Base):

    __tablename__ = "restaurants"

    id = Column(Integer, primary_key=True, index=True)

    name = Column(String)

    category = Column(String)

    latitude = Column(Float)

    longitude = Column(Float)

    image = Column(String)