python -m venv venv
source venv/bin/activate
python -m pip install --upgrade pip
pip install -e .\[test\]
pip install -r requirements.txt

# Run Tests
# docker compose up -d postgres
# export DATABASE_PORT=5432
# export DATABASE_HOST=localhost
# export DATABASE_PASSWORD=postgres
# export DATABASE_USER=postgres
# pytest 

# Run Sandbox Site
# make sandbox
# sandbox/manage.py runserver