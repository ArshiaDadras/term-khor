# Term-Khor (ترم‌خوار) 🍽️📚

**Term-Khor** is an automated Bash script designed to assist Sharif University students in the stressful course selection process by interfacing with the university’s API. Let **Term-Khor** handle course registration for you, so you can sit back and relax! 😎

## ✨ Features

- ⚙️ **Automated Course Selection**: Automatically register for courses at a precise time with multiple retry attempts.
- ⏰ **Customizable Timings**: Set your own start and end times for the registration process.
- 🔒 **JWT or Credentials Authentication**: Secure access via your university token or use your Student ID and password for dynamic token generation.
- 📚 **Multi-course Support**: Register for multiple courses and corresponding units in one go.
- 🛑 **Graceful Shutdown**: Exit the script smoothly using `CTRL+C` without losing progress or leaving tasks incomplete.

## 📋 Requirements

Make sure the following tools are installed on your system:

- **gdate** (GNU date)
- **curl**

You can install them using the following commands:

```bash
# On macOS
brew install coreutils
brew install curl

# On Ubuntu/Debian
sudo apt-get install curl
```

Also, ensure **Python 3** is installed if you're using Student ID and password for authentication.

## 🚀 Usage

Run the script with either a JWT token or your Student ID and password:

### Method 1: Using JWT Token
```bash
./select_course.sh -t <token> -c <course1,course2,...> -u <unit1,unit2,...> [-s <start_time>] [-e <end_time>]
```

### Method 2: Using Student ID and Password
```bash
./select_course.sh -i <student_id> -p <password> -c <course1,course2,...> -u <unit1,unit2,...> [-s <start_time>] [-e <end_time>]
```

### 🔑 Parameters:
- `-t <token>`: Your JWT token for authentication (required if not using student ID/password).
- `-i <student_id>`: Your student ID for authentication (required if not using token).
- `-p <password>`: Your password for authentication (required if not using token).
- `-c <course1,course2,...>`: Comma-separated list of `courseID-groupID`s (required). Example: `-c 40455-1,40103-2`.
- `-u <unit1,unit2,...>`: Comma-separated list of units corresponding to each course (required). Example: `-u 3,1`.
- `-s <start_time>`: Start time for course registration in `HH:MM` format (default: `08:00`).
- `-e <end_time>`: End time for course registration in `HH:MM` format (optional).

### 💡 Example:

Using a JWT token:
```bash
./select_course.sh -t eyJhbGciOiJIUzI1... -c 40455-1,40103-2 -u 3,1 -s 08:00 -e 10:00
```

Using Student ID and password:
```bash
./select_course.sh -i 981234567 -p mypassword -c 40455-1,40103-2 -u 3,1 -s 08:00 -e 10:00
```

### 📌 Notes:
- The number of courses (`-c`) should match the number of units (`-u`).
- The script retries course registration every **50 milliseconds**. You can adjust this delay in the script.
- You can safely stop the script at any time by pressing `CTRL+C`.

## ⚙️ How It Works

1. ⏳ **Wait Until Start Time**: The script waits until the specified start time before beginning the registration process.
2. 📜 **Course Registration**: The script continuously sends registration requests for your selected courses until either the registration is successful or the end time is reached.
3. 🔧 **Graceful Exit**: If interrupted, the script will clean up all background processes and exit smoothly.

## 🛠️ Dependencies

- **gdate**: Required for handling precise time operations in the script.
- **cURL**: Utilized for sending HTTP POST requests to the university's API for course registration.
- **Python 3**: Needed if you're using your Student ID and password for dynamic JWT token retrieval.

## 📄 License

This project is licensed under the **MIT License**. Feel free to use, modify, and share!