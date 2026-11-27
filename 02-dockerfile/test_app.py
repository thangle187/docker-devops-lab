from fastapi.testclient import TestClient
from app import app

client = TestClient(app)

def test_health():
    res = client.get("/health")
    assert res.status_code == 200
    assert res.json() == {"status": "ok"}

def test_hello():
    res = client.get("/hello?name=Linux")
    assert res.status_code == 200
    assert res.json() == {"message": "Hello, Linux!"}

def test_visits():
    res1 = client.get("/visits")
    res2 = client.get("/visits")
    assert res2.json()["visits"] == res1.json()["visits"] + 1
