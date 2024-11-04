## Download test data

You can download [a SQLite database](https://drive.google.com/file/d/1UR7HJ0UqRCUD5vygN4nBZlT1gzT1B_C_/view?usp=drive_link).

Store this file in `sandbox/db.sqlite`, or as specified by sandbox/settings.py.

## Instructions to generate fixture data

First setup your environment:

```
python -m venv venv
source venv/bin/activate
python -m pip install --upgrade pip
pip install -e .\[test\]
pip install -r requirements.txt
```

For example to generate 100k fake books you'd run

```
python utility/generate_fake_books.py 100000 sandbox/fixtures/books.generated.csv
```

This would create the following
```
$ wc -l sandbox/fixtures/books.generated.csv
  100000 sandbox/fixtures/books.generated.csv
```

Then you'd build the sandbox
```
make sandbox 
```

It will create the necessary requirements then it will load all the csv files in the fixtures directory.
```
# Import some fixtures. Order is important as JSON fixtures include primary keys
sandbox/manage.py loaddata sandbox/fixtures/child_products.json
Installed 35 object(s) from 1 fixture(s)
sandbox/manage.py oscar_import_catalogue sandbox/fixtures/*.csv
[2024-09-17 21:17:47,685] Starting catalogue import
[2024-09-17 21:17:47,685]  - Importing records from 'sandbox/fixtures/books.computers-in-fiction.csv'
[2024-09-17 21:17:47,687] Processing batch of size: 86
[2024-09-17 21:17:47,970] New items: 86, updated items: 0
[2024-09-17 21:17:47,971]  - Importing records from 'sandbox/fixtures/books.essential.csv'
[2024-09-17 21:17:47,972] Processing batch of size: 82
[2024-09-17 21:17:48,233] New items: 82, updated items: 0
[2024-09-17 21:17:48,234]  - Importing records from 'sandbox/fixtures/books.generated.csv'
[2024-09-17 21:17:48,236] Processing batch of size: 1000
[2024-09-17 21:17:51,330] Processing batch of size: 1000
[2024-09-17 21:17:54,458] Processing batch of size: 1000
[2024-09-17 21:17:57,742] Processing batch of size: 1000
<snip>
Installed 5 object(s) from 1 fixture(s)
sandbox/manage.py clear_index --noinput
Removing all documents from your index because you said so.
All documents removed.
sandbox/manage.py update_index catalogue
Indexing 110176 Products
```

I had made some changes to batch process 1000 at a time to get an idea the time it would take to do an import.  There are some performance optimizations that might need to happen to get to 3m records.  Inserting gets slower over time.  I tried to use postgresql on docker but performance was much worse.

Create a superuser
```
python sandbox/manage.py createsuperuser
```

After the import completes you can run the sandbox site
```
sandbox/manage.py runserver
```

And then connect [to the URL](http://127.0.0.1:8000/)
Or to the [management portal](http://127.0.0.1:8000/en-gb/dashboard/) and login with the superuser you created before.

<img width="878" alt="Screenshot 2024-09-17 at 5 10 52 PM" src="https://github.com/user-attachments/assets/054ef280-efe6-43b9-8a82-fa03a89c41d2">
