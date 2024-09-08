# Term-Khor (ترم‌خوار) 🍽️📚

**Term-Khor** is an automated Bash script designed to help Sharif University students breeze through the stressful course selection process via the university’s API. Let **Term-Khor** take care of the registration, while you sit back and relax! 😎

## ✨ Features

- ⚙️ **Automated Course Selection**: Register for your desired courses at a precise time with repeated retry attempts.
- ⏰ **Customizable Timings**: Set your own start and end times for course registration.
- 🔒 **JWT Authentication**: Secure access with your unique university token.
- 📚 **Multi-course Support**: Register for multiple courses and corresponding units in one go.
- 🛑 **Graceful Shutdown**: Exit the script smoothly using `CTRL+C` without losing progress.

## 📋 Requirements

Ensure the following tools are installed on your system:
- **gdate** (GNU date)
- **curl**

Install them using:
```bash
brew install coreutils
```
For cURL:
```bash
sudo apt-get install curl    # On Ubuntu/Debian
brew install curl            # On macOS
```

## 🚀 Usage

Run the script with the following format:

```bash
./select_course.sh -t <token> -c <course1,course2,...> -u <unit1,unit2,...> [-s <start_time>] [-e <end_time>]
```

### 🔑 Parameters:
- `-t <token>`: Your JWT token for authentication (required).
- `-c <course1,course2,...>`: Comma-separated list of `courseID-groupID`s (required). Example: `-c 40455-1,40103-2`.
- `-u <unit1,unit2,...>`: Comma-separated list of units for each course (required). Example: `-u 3,1`.
- `-s <start_time>`: Start time for registration in `HH:MM` format (default: `08:00`).
- `-e <end_time>`: End time for registration in `HH:MM` format (optional).

### 💡 Example:

```bash
./select_course.sh -t eyJhbGciOiJIUzI1... -c 40455-1,40103-2 -u 3,1 -s 08:00 -e 10:00
```

### 📌 Notes:
- Ensure that the number of courses matches the number of units.
- The script retries course registration every **50 milliseconds**. You can adjust this delay if necessary.
- Use `CTRL+C` anytime to stop the script gracefully.

## ⚙️ How It Works

1. ⏳ **Wait for Start**: The script patiently waits until your specified start time before attempting registration.
2. 📜 **Course Registration**: It continuously sends requests to register for the courses you've selected, retrying until the end time.
3. 🔧 **Graceful Exit**: If you need to stop the script early, hit `CTRL+C`, and it will safely clean up all processes before exiting.

## 🛠️ Dependencies

- **gdate**: Required for handling precise time formats.
- **cURL**: Used for sending HTTP requests to the university's API.

## 📄 License

This project is licensed under the **MIT License**. Feel free to use, modify, and share!
