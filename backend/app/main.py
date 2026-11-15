from fastapi import FastAPI, Depends, WebSocket, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from sqlalchemy.orm import Session

import asyncio
import random

from app.database import SessionLocal

from app.auth import (
    hash_password,
    verify_password,
    create_access_token
)

from app.models.user import User
from app.models.driver import Driver
from app.models.restaurant import Restaurant
from app.models.product import Product
from app.models.order import Order
from app.models.order_item import OrderItem

from app.schemas import OrderCreate

# =========================================================
# FASTAPI + CORS
# =========================================================
# Tables are created and changed by Alembic only
# (alembic upgrade head), not here.

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================================================
# DATABASE SESSION
# =========================================================

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# =========================================================
# HOME
# =========================================================

@app.get("/")
def home():
    return {"message": "Livraison API is running"}

# =========================================================
# AUTHENTICATION
# =========================================================

@app.post("/register")
def register(
    username: str,
    password: str,
    role: str = "customer",
    db: Session = Depends(get_db)
):
    existing_user = db.query(User).filter(User.username == username).first()

    if existing_user:
        return {"error": "Username already exists"}

    new_user = User(
        username=username,
        password=hash_password(password),
        role=role
    )

    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {"message": "User created successfully"}


@app.post("/login")
def login(
    username: str,
    password: str,
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(User.username == username).first()

    if not user:
        return {"error": "Invalid username"}

    if not verify_password(password, user.password):
        return {"error": "Invalid password"}

    access_token = create_access_token(
        data={"sub": user.username, "role": user.role}
    )

    return {
        "access_token": access_token,
        "user": {
            "username": user.username,
            "role": user.role
        }
    }

# =========================================================
# DRIVERS
# =========================================================

@app.post("/drivers")
def create_driver(name: str, db: Session = Depends(get_db)):
    driver = Driver(
        name=name,
        latitude=18.0735,
        longitude=-15.9582,
        status="online"
    )

    db.add(driver)
    db.commit()
    db.refresh(driver)

    return {
        "message": "Driver created successfully",
        "driver_id": driver.id
    }


@app.get("/drivers")
def get_drivers(db: Session = Depends(get_db)):
    return db.query(Driver).all()


@app.put("/drivers/{driver_id}/location")
def update_driver_location(
    driver_id: int,
    latitude: float,
    longitude: float,
    db: Session = Depends(get_db)
):
    driver = db.query(Driver).filter(Driver.id == driver_id).first()

    if not driver:
        raise HTTPException(status_code=404, detail="Driver not found")

    driver.latitude = latitude
    driver.longitude = longitude
    driver.status = "online"

    db.commit()

    return {"message": "Location updated successfully"}


@app.get("/drivers/{driver_id}/location")
def get_driver_location(driver_id: int, db: Session = Depends(get_db)):
    driver = db.query(Driver).filter(Driver.id == driver_id).first()

    if not driver:
        raise HTTPException(status_code=404, detail="Driver not found")

    return {
        "driver_id": driver.id,
        "name": driver.name,
        "latitude": driver.latitude,
        "longitude": driver.longitude,
        "status": driver.status
    }

# =========================================================
# RESTAURANTS
# =========================================================

@app.post("/restaurants")
def create_restaurant(
    name: str,
    category: str,
    latitude: float,
    longitude: float,
    image: str,
    db: Session = Depends(get_db)
):
    restaurant = Restaurant(
        name=name,
        category=category,
        latitude=latitude,
        longitude=longitude,
        image=image
    )

    db.add(restaurant)
    db.commit()
    db.refresh(restaurant)

    return {
        "message": "Restaurant created successfully",
        "restaurant_id": restaurant.id
    }


@app.get("/restaurants")
def get_restaurants(db: Session = Depends(get_db)):
    return db.query(Restaurant).all()


@app.delete("/restaurants/{restaurant_id}")
def delete_restaurant(restaurant_id: int, db: Session = Depends(get_db)):
    restaurant = db.query(Restaurant).filter(Restaurant.id == restaurant_id).first()

    if not restaurant:
        raise HTTPException(status_code=404, detail="Restaurant not found")

    # Cannot delete a restaurant that still has products or orders
    if db.query(Product).filter(Product.restaurant_id == restaurant_id).first():
        raise HTTPException(status_code=400, detail="Delete the restaurant's products first")

    if db.query(Order).filter(Order.restaurant_id == restaurant_id).first():
        raise HTTPException(status_code=400, detail="This restaurant has orders and cannot be deleted")

    db.delete(restaurant)
    db.commit()

    return {"message": "Restaurant deleted successfully"}

# =========================================================
# PRODUCTS
# =========================================================

@app.post("/products")
def create_product(
    name: str,
    price: float,
    image: str,
    restaurant_id: int,
    db: Session = Depends(get_db)
):
    restaurant = db.query(Restaurant).filter(Restaurant.id == restaurant_id).first()

    if not restaurant:
        raise HTTPException(status_code=404, detail="Restaurant not found")

    product = Product(
        name=name,
        price=price,
        image=image,
        restaurant_id=restaurant_id
    )

    db.add(product)
    db.commit()
    db.refresh(product)

    return {
        "message": "Product created successfully",
        "product_id": product.id
    }


@app.get("/restaurants/{restaurant_id}/products")
def get_restaurant_products(restaurant_id: int, db: Session = Depends(get_db)):
    return db.query(Product).filter(Product.restaurant_id == restaurant_id).all()


@app.delete("/products/{product_id}")
def delete_product(product_id: int, db: Session = Depends(get_db)):
    product = db.query(Product).filter(Product.id == product_id).first()

    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    # Cannot delete a product that is part of an order
    if db.query(OrderItem).filter(OrderItem.product_id == product_id).first():
        raise HTTPException(status_code=400, detail="This product is in orders and cannot be deleted")

    db.delete(product)
    db.commit()

    return {"message": "Product deleted successfully"}

# =========================================================
# ORDERS
# =========================================================

@app.post("/orders")
def create_order(data: OrderCreate, db: Session = Depends(get_db)):

    if not data.items:
        raise HTTPException(status_code=400, detail="Order must contain at least one product")

    restaurant = db.query(Restaurant).filter(Restaurant.id == data.restaurant_id).first()

    if not restaurant:
        raise HTTPException(status_code=404, detail="Restaurant not found")

    # Load all requested products in one query
    product_ids = [item.product_id for item in data.items]
    products = db.query(Product).filter(Product.id.in_(product_ids)).all()
    products_by_id = {p.id: p for p in products}

    order = Order(
        customer_name=data.customer_name,
        restaurant_id=data.restaurant_id,
        address=data.address,
        latitude=data.latitude,
        longitude=data.longitude,
        status="pending",
        driver_id=None,
    )

    total = 0

    for item in data.items:
        product = products_by_id.get(item.product_id)

        if not product:
            raise HTTPException(status_code=404, detail=f"Product {item.product_id} not found")

        if product.restaurant_id != data.restaurant_id:
            raise HTTPException(
                status_code=400,
                detail=f"Product {product.id} does not belong to this restaurant",
            )

        if item.quantity < 1:
            raise HTTPException(status_code=400, detail="Quantity must be at least 1")

        # The price comes from the database, never from the app
        order.items.append(
            OrderItem(product_id=product.id, quantity=item.quantity, price=product.price)
        )
        total += product.price * item.quantity

    order.total_price = total

    db.add(order)
    db.commit()
    db.refresh(order)

    return {
        "message": "Order created successfully",
        "order_id": order.id,
        "total_price": order.total_price,
    }


@app.get("/orders")
def get_orders(db: Session = Depends(get_db)):
    orders = db.query(Order).all()

    result = []

    for order in orders:
        driver_name = None

        if order.driver_id:
            driver = db.query(Driver).filter(Driver.id == order.driver_id).first()
            if driver:
                driver_name = driver.name

        result.append({
            "id": order.id,
            "customer_name": order.customer_name,
            "total_price": order.total_price,
            "status": order.status,
            "driver_id": order.driver_id,
            "driver_name": driver_name,
        })

    return result


@app.get("/orders/{order_id}")
def get_order(order_id: int, db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.id == order_id).first()

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    # Product names for the items
    product_ids = [i.product_id for i in order.items]
    names = {}
    if product_ids:
        names = {
            p.id: p.name
            for p in db.query(Product).filter(Product.id.in_(product_ids))
        }

    return {
        "id": order.id,
        "customer_name": order.customer_name,
        "restaurant_id": order.restaurant_id,
        "address": order.address,
        "status": order.status,
        "total_price": order.total_price,
        "driver_id": order.driver_id,
        "created_at": order.created_at,
        "items": [
            {
                "product_id": i.product_id,
                "name": names.get(i.product_id),
                "quantity": i.quantity,
                "price": i.price,
                "subtotal": i.price * i.quantity,
            }
            for i in order.items
        ],
    }


@app.put("/orders/{order_id}/accept")
def accept_order(order_id: int, db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.id == order_id).first()

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    order.status = "accepted"
    order.driver_id = 1  # will be fixed in phase 3

    db.commit()

    return {"message": "Order accepted successfully"}


@app.put("/orders/{order_id}/deliver")
def deliver_order(order_id: int, db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.id == order_id).first()

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    order.status = "delivered"

    db.commit()

    return {"message": "Order delivered successfully"}


@app.put("/orders/{order_id}/assign-driver")
def assign_driver(
    order_id: int,
    driver_id: int,
    db: Session = Depends(get_db)
):
    order = db.query(Order).filter(Order.id == order_id).first()

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    driver = db.query(Driver).filter(Driver.id == driver_id).first()

    if not driver:
        raise HTTPException(status_code=404, detail="Driver not found")

    order.driver_id = driver_id

    db.commit()

    return {"message": "Driver assigned successfully"}


@app.get("/orders/{order_id}/driver")
def get_order_driver(order_id: int, db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.id == order_id).first()

    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    if not order.driver_id:
        raise HTTPException(status_code=404, detail="No driver assigned")

    driver = db.query(Driver).filter(Driver.id == order.driver_id).first()

    if not driver:
        raise HTTPException(status_code=404, detail="Driver not found")

    return {
        "driver_id": driver.id,
        "name": driver.name,
        "latitude": driver.latitude,
        "longitude": driver.longitude,
        "status": driver.status
    }

# =========================================================
# DASHBOARD STATS
# =========================================================

@app.get("/dashboard/stats")
def dashboard_stats(db: Session = Depends(get_db)):
    return {
        "restaurants": db.query(Restaurant).count(),
        "products": db.query(Product).count(),
        "orders": db.query(Order).count(),
        "drivers": db.query(Driver).count(),
    }

# =========================================================
# REALTIME DRIVER TRACKING (simulation - will be fixed in phase 4)
# =========================================================

@app.websocket("/ws/driver-location")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()

    latitude = 18.0735
    longitude = -15.9582

    while True:
        latitude += random.uniform(-0.0005, 0.0005)
        longitude += random.uniform(-0.0005, 0.0005)

        await websocket.send_json({
            "latitude": latitude,
            "longitude": longitude
        })

        await asyncio.sleep(2)