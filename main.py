import fastapi
import uvicorn
import marimo

# Create a marimo asgi app with multiple pages
server = (
    marimo.create_asgi_app()
    .with_app(path="", root="./pages/index.py")
    .with_app(path="/dashboard", root="./pages/dashboard.py")
)

# Create a FastAPI app
app = fastapi.FastAPI(title="Data App", description="Multi-page Marimo Data Application")

# Mount the marimo server
app.mount("/", server.build())

# Run the server
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=7860)
