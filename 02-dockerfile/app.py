from fastapi import FastAPI

app = FastAPI()
visit_count = 0

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/hello")
def hello(name: str = "DevOps"):
    return {"message": f"Hello, {name}!"}

@app.get("/visits")
def visits():
    global visit_count
    visit_count += 1
    return {"visits": visit_count}
