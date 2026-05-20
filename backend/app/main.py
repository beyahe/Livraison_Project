from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from app.database import engine, Base, SessionLocal
from app.models.driver import Driver

app = FastAPI()

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)


def get_db():
    db = SessionLocal()

    try:
        yield db

    finally:
        db.close()


@app.get("/")
def home():
    return {
        "message": "Livraison API is running"
    }


@app.post("/drivers")
def create_driver(
    name: str,
    db: Session = Depends(get_db)
):
    driver = Driver(
        name=name,
        latitude=0,
        longitude=0,
        status="offline"
    )

    db.add(driver)

    db.commit()

    db.refresh(driver)

    return {
        "message": "Driver created successfully",
        "driver_id": driver.id
    }


@app.put("/drivers/{driver_id}/location")
def update_driver_location(
    driver_id: int,
    latitude: float,
    longitude: float,
    db: Session = Depends(get_db)
):
    driver = db.query(Driver).filter(
        Driver.id == driver_id
    ).first()

    if not driver:
        return {
            "error": "Driver not found"
        }

    driver.latitude = latitude
    driver.longitude = longitude
    driver.status = "online"

    db.commit()

    return {
        "message": "Location updated successfully"
    }


@app.get("/drivers/{driver_id}/location")
def get_driver_location(
    driver_id: int,
    db: Session = Depends(get_db)
):
    driver = db.query(Driver).filter(
        Driver.id == driver_id
    ).first()

    if not driver:
        return {
            "error": "Driver not found"
        }

    return {
        "driver_id": driver.id,
        "name": driver.name,
        "latitude": driver.latitude,
        "longitude": driver.longitude,
        "status": driver.status
    }