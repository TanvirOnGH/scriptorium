# Based on: <https://github.com/gentoo/portage/blob/master/lib/_emerge/stdout_spinner.py>
import sys
import time

# Default messages for the spinner if none are provided
DEFAULT_MESSAGES = None
# Default latency between spinner updates
DEFAULT_LATENCY = 0.055


class TerminalSpinner:
    """
    A class to create a scrolling text animation in the terminal.

    Attributes:
        position (int): Current position in the scroll sequence.
        messages (list): List of messages to scroll through.
        current_message (str): The current message being scrolled.
        last_update_time (float): Timestamp of the last update to prevent too frequent updates.
        minimum_update_interval (float): Minimum time interval between updates.
        start_time (float): Timestamp when the spinner was started (unused).

    Methods:
        __init__(self, messages=DEFAULT_MESSAGES, latency=DEFAULT_LATENCY): Initializes the spinner with custom messages and latency.
        should_return_early(self): Checks if the method should return early to throttle the update rate.
        update_position(self): Updates the scroll position and prints the next character.
    """

    def __init__(self, messages=DEFAULT_MESSAGES, latency=DEFAULT_LATENCY):
        """
        Initializes the TerminalSpinner with custom messages and latency.

        Parameters:
            messages (list): Custom messages to be used for the spinner. Defaults to DEFAULT_MESSAGES.
            latency (float): Minimum time interval between updates. Defaults to DEFAULT_LATENCY.
        """
        self.position = 0
        self.messages = messages
        self.current_message = self.messages[
            int(time.time() * 100) % len(self.messages)
        ]
        self.last_update_time = 0
        self.minimum_update_interval = latency
        self.start_time = None

    def should_return_early(self):
        """
        Checks if the spinner should wait before updating again to maintain a minimum display latency.

        Returns:
            bool: True if the method should return early, False otherwise.
        """
        current_time = time.time()
        if current_time - self.last_update_time < self.minimum_update_interval:
            return True
        self.last_update_time = current_time
        return False

    def update_position(self):
        """
        Updates the scroll position and prints the next character in the sequence.

        Returns:
            bool: Always returns True.
        """
        if self.should_return_early():
            return True
        if self.position >= len(self.current_message):
            sys.stdout.write(
                " \b\b\b"
                + self.current_message[
                    len(self.current_message)
                    - 1
                    - (self.position % len(self.current_message))
                ]
            )
        else:
            sys.stdout.write("\b " + self.current_message[self.position])
        sys.stdout.flush()
        self.position = (self.position + 1) % (2 * len(self.current_message))
        return True


def run_spinner(messages=DEFAULT_MESSAGES, latency=DEFAULT_LATENCY):
    """
    Creates and runs a scrolling spinner animation in the terminal.

    Parameters:
        messages (list): Custom messages to be used for the spinner. Defaults to DEFAULT_MESSAGES.
        latency (float): Minimum time interval between updates. Defaults to DEFAULT_LATENCY.
    """

    def hide_cursor():
        """Hides the cursor for better spinner visibility."""
        if sys.platform.startswith("win"):
            import ctypes

            kernel32 = ctypes.WinDLL("kernel32")
            console_handle = kernel32.GetStdHandle(-11)
            mode = ctypes.c_ulong()
            kernel32.GetConsoleMode(console_handle, ctypes.byref(mode))
            mode.value &= ~0x0020  # Remove ENABLE_VIRTUAL_TERMINAL_PROCESSING
            kernel32.SetConsoleMode(console_handle, mode)
        else:
            sys.stdout.write("\033[?25l")

    def show_cursor():
        """Shows the cursor."""
        if sys.platform.startswith("win"):
            import ctypes

            kernel32 = ctypes.WinDLL("kernel32")
            console_handle = kernel32.GetStdHandle(-11)
            mode = ctypes.c_ulong()
            kernel32.GetConsoleMode(console_handle, ctypes.byref(mode))
            mode.value |= 0x0020  # Add ENABLE_VIRTUAL_TERMINAL_PROCESSING
            kernel32.SetConsoleMode(console_handle, mode)
        else:
            sys.stdout.write("\033[?25h")

    try:
        hide_cursor()
        spinner = TerminalSpinner(messages, latency)
        while True:
            spinner.update_position()
    except KeyboardInterrupt:
        pass  # Handle Ctrl+C gracefully
    finally:
        show_cursor()  # Ensure the cursor is shown again before exiting


# Example usage
example_messages = [
    "Hello, World!",
    "Standing on the shoulders of giants!",
    "The root of suffering is attachment",
    "3.1415926535",
]
run_spinner(messages=example_messages, latency=0.06)
