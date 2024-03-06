# Hello World

Basic stock flask hello world.

For testing AWS and Terraform EKS/ECS/EC2


## How to Serve

Using a basic `requirements.txt`.  You can install the dependencies globally (not recommended) or use a virtual environment manager that understands the basic `requirements.txt`, for example the build in `venv`.

Built on python 3, for this example, your code is in ~/Code/flask-hello-world

```bash
cd ~/Code
git clone https://github.com/mreschke/flask-hello-world.git
cd flask-hello-world
python -m venv env
source env/bin/activate
pip install -r requirements.txt
flask run

# CTRL+C to stop the server
# type `deactivate` to exit the venv environment
```

To serve directly from the venv without activate/deactive, simply run
```
~/Code/env/bin/python -m flask run
```


## How to Terraform to AWS

That is the challenge, make it so!
