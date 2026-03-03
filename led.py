from machine import UART, Pin
import time

uart = UART(0, baudrate=115200, tx=Pin(0), rx=Pin(1))
led = Pin(15, Pin.OUT)
led.value(0)

def send_at(cmd, delay=2):
    uart.write(cmd + "\r\n")
    time.sleep(delay)
    if uart.any():
        uart.read()

# ---------------- SETUP ESP ----------------
send_at("AT+RST", 3)
send_at("AT+CWMODE=2")
send_at('AT+CWSAP="Pico_LED","12345678",5,3')
send_at("AT+CIPMUX=1")
send_at("AT+CIPSERVER=1,80")

print("Server Ready")

# --------------- MAIN LOOP ----------------
while True:
    if uart.any():
        raw = uart.read()
        try:
            data = raw.decode("utf-8", "ignore")
        except:
            continue

        print("Received:", data)

        if "+IPD," in data:
            try:
                # Extract link ID safely
                start = data.find("+IPD,") + 5
                link_id = data[start]

                # Extract HTTP request line
                request_start = data.find("GET")
                request_end = data.find("HTTP")
                request_line = data[request_start:request_end].strip()

                print("Request:", request_line)

                # -------- LED CONTROL --------
                if request_line == "GET /on":
                    led.value(1)
                    body = "LED ON"

                elif request_line == "GET /off":
                    led.value(0)
                    body = "LED OFF"

                else:
                    body = "Hello"

                # Proper HTTP response
                response = (
                    "HTTP/1.1 200 OK\r\n"
                    "Content-Type: text/plain\r\n"
                    "Content-Length: {}\r\n"
                    "Connection: close\r\n"
                    "\r\n"
                    "{}"
                ).format(len(body), body)

                # Send response
                uart.write("AT+CIPSEND={},{}\r\n".format(link_id, len(response)))
                time.sleep(0.5)
                uart.write(response)

                time.sleep(0.5)
                uart.write("AT+CIPCLOSE={}\r\n".format(link_id))

            except Exception as e:
                print("Error:", e)
