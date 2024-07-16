# E-commerce

- Text Color: #000
- Background Color: #fd5c01
- Button Color: #fff

## How to Run the Backend

1. Clone the project:

   ```bash

   ```

2. Navigate to the backend directory:

   ```bash
   cd backend
   ```

3. Activate the virtual environment (for Windows):

   ```bash
   python -m venv venv
   .\venv\Scripts\activate
   ```

4. Move to the 'dailyGrocery' directory:

   ```bash
   cd dailyGrocery
   pip install -r requirements.txt
   ```

5. Apply database migrations:

   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

6. Start the Django development server:

   ```bash
   python manage.py runserver
   ```

   This command will start the server.

## Running the Frontend

Open a new terminal window.

1. Navigate to the frontend directory:

   ```bash
   cd frontend
   ```

2. Open pubspec.yamal file and run

   ```bash
   pub get
   ```

   This command will install all packages we are using.

3. Run the Flutter application:

   ```bash
   flutter run
   ```

   This command will start the Flutter application.

Now, your backend server and Flutter frontend should be up and running.
