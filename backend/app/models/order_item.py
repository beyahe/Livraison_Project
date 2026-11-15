from sqlalchemy import Column, Integer, Float, ForeignKey

from app.database import Base


class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(Integer, primary_key=True, index=True)

    order_id = Column(
        Integer,
        ForeignKey("orders.id", name="fk_order_items_order_id_orders", ondelete="CASCADE"),
        nullable=False,
    )

    product_id = Column(
        Integer,
        ForeignKey("products.id", name="fk_order_items_product_id_products"),
        nullable=False,
    )

    quantity = Column(Integer, nullable=False, default=1)

    # Unit price at the moment of the order
    price = Column(Float, nullable=False)