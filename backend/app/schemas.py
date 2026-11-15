from typing import List, Optional

from pydantic import BaseModel


# One product inside the order sent by the app
class OrderItemIn(BaseModel):
    product_id: int
    quantity: int = 1


# The full order sent by the app (JSON body)
# The customer is NOT sent: the server takes it from the token
class OrderCreate(BaseModel):
    restaurant_id: int
    items: List[OrderItemIn]
    address: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None