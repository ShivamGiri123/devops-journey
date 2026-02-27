from flask import Flask
import socket

app = Flask(__name__)

@app.route('/')
def home():
    return f"""
    <h1>Hello from Docker!</h1>
    <p>Container: {socket.gethostname()}</p>
    <p>This is running inside a Docker container!</p>
    """

@app.route('/health')
def health():
    return {'status': 'healthy'}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
