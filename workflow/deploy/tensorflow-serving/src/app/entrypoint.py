import os
import signal
import subprocess

# Making sure to use virtual environment libraries
activate_this = "/home/ubuntu/tensorflow/bin/activate_this.py"
exec(open(activate_this).read(), dict(__file__=activate_this))

# Change directory to app
os.chdir("/app")
tf_server = ""
api_server = ""
s
try:
    tf_server = subprocess.Popen(["tensorflow_model_server "
                                  "--model_base_path=/model/example"
                                  "--rest_api_port=9000 --model_name=example"],
                                  stdout=subprocess.DEVNULL,
                                  shell=True,
                                  preexec_fn=os.setsid)
    print("Started TensorFlow Serving ImageClassifier server!")

    api_server = subprocess.Popen(["uvicorn app.main:app --host 0.0.0.0 --port 80"],
                                    stdout=subprocess.DEVNULL,
                                    shell=True,
                                    preexec_fn=os.setsid)
    print("Started API server!")

    while True:
        print("Type 'exit' and press 'enter' OR press CTRL+C to quit: ")
        in_str = input().strip().lower()
        if in_str == 'q' or in_str == 'exit':
            print('Shutting down all servers...')
            os.killpg(os.getpgid(tf_server.pid), signal.SIGTERM)
            os.killpg(os.getpgid(api_server.pid), signal.SIGTERM)
            print('Servers successfully shutdown!')
            break
        else:
            continue
except KeyboardInterrupt:
    print('Shutting down all servers...')
    os.killpg(os.getpgid(tf_server.pid), signal.SIGTERM)
    os.killpg(os.getpgid(api_server.pid), signal.SIGTERM)
    print('Servers successfully shutdown!')