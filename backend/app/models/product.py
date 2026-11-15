from sqlalchemy import Column, Integer, String, Float, ForeignKey

from app.database import Base


class Product(Base):

    __tablename__ = "products"

    id = Column(Integer, primary_key=True, index=True)

    name = Column(String)

    price = Column(Float)

    image = Column(String)

    restaurant_id = Column(
        Integer,
        ForeignKey("restaurants.id")
    )