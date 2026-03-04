
## Project Overview
This project demonstrates controlling an LED connected to a **Raspberry Pi Pico** using an **ESP8266 WiFi module** running AT firmware.

**Flutter Windows desktop application**
sends HTTP requests to the ESP8266, which forwards them to the Pico via UART communication. The Pico processes the request and controls the LED accordingly.

This project demonstrates a complete IoT communication pipeline using HTTP over a local WiFi network.

---

## System Architecture

Flutter App (HTTP Client)  
↓  
ESP8266 (WiFi Access Point + Web Server)  
↓  
Raspberry Pi Pico (MicroPython Controller)  
↓  
LED  

---

## Network Configuration

The ESP8266 operates in **Access Point (AP) mode**.

- **SSID:** Pico_LED  
- **Password:** 12345678  
- **IP Address:** 192.168.4.1  
- **Port:** 80  

The laptop must connect to the `Pico_LED` network before running the Flutter application.

Internet connection is not required.

---

## Working Principle

1. The Flutter application displays a toggle switch for LED control.
2. When the switch is toggled:
   - `/on` request is sent to turn the LED ON.
   - `/off` request is sent to turn the LED OFF.
3. The ESP8266 receives the HTTP request and sends the raw data to the Pico via UART.
4. The Pico extracts:
   - Connection link ID
   - HTTP request line
5. The Pico compares the request:
   - `GET /on` → LED is turned ON.
   - `GET /off` → LED is turned OFF.
6. The Pico sends a proper HTTP response back to the client.
7. The Flutter app updates:
   - LED state text
   - AppBar connection indicator

---

## Circuit Diagram

<img width="1589" height="1080" alt="image" src="https://github.com/user-attachments/assets/92d4a1c9-a10c-4bf2-b719-42df3d7b2d44" />


---
## Screenshots and Photographs

<img width="269" height="356" alt="image" src="https://github.com/user-attachments/assets/7ebde7a8-2fe2-44ed-adcc-5c6f5b5ed80c" />

<img width="346" height="370" alt="image" src="https://github.com/user-attachments/assets/f606eea3-907b-465b-910e-6672a76f53a4" />


## Common Errors Faced

### 1. Substring Parsing Bug

Initial implementation used:

```python
if "on" in request:
```

This caused incorrect LED behavior because the word `"on"` exists inside the `"Connection"` header of the HTTP request. As a result, the LED turned ON even when it should not.

**Fix:**

```python
if request_line == "GET /on":
```

Using exact string comparison ensures accurate command detection.

---

### 2. LED Default State Issue

The LED turned ON automatically during startup due to an undefined initial GPIO state.

**Fix:**

```python
led.value(0)
```

Setting the LED state explicitly during initialization prevents unintended behavior.

---

### 3. Flutter Web Blank Screen

When connected to the ESP8266 WiFi network (which has no internet access), Flutter Web failed to load properly and displayed a blank screen.

**Solution:**

Run the Flutter project as a Windows desktop application instead:

```
flutter run -d windows
```

---

### 4. Windows Build Failure

The Windows build failed due to:

- Missing Visual Studio C++ development tools  
- Long or complex project directory paths  

**Solution:**

- Install Visual Studio with the **Desktop development with C++** workload  
- Move the project to a simple directory (e.g., `C:\flutter_projects`)

---

## Conclusion

This project successfully demonstrates WiFi-based LED control using a Raspberry Pi Pico and ESP8266 module operating in Access Point mode.

The system enables a Flutter desktop application to send HTTP requests over a local WiFi network to control hardware in real time.

This implementation showcases:

- UART communication between microcontroller and WiFi module  
- Embedded HTTP server handling  
- Real-time hardware control via a desktop application  
- Complete IoT client-server communication architecture  

The project highlights practical integration of embedded systems, networking, and application development in a unified IoT solution.
