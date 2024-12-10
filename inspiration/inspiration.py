#! /usr/bin/env python3

"""
Inspirational quote display module that fetches and beautifully formats random quotes
from a CSV file. Supports colored output, word wrapping, and terminal-aware formatting.
"""

import csv
import os
import random
import re
import textwrap

# Colors from starship theme
RESET = "\033[0m"
BOLD = "\033[1m"
BG_DARK = "\033[48;2;26;26;46m"  # #1a1a2e
FG_PURPLE = "\033[38;2;57;42;86m"  # #392a56
FG_PINK = "\033[38;2;102;48;98m"  # #663062
FG_MAGENTA = "\033[38;2;127;60;117m"  # #7f3c75
FG_RED = "\033[38;2;167;61;101m"  # #a73d65
FG_ORANGE = "\033[38;2;204;81;59m"  # #cc513b


def wrap_text(text, width, initial_indent, subsequent_indent):
    """
    Wrap text with proper indentation, accounting for ANSI color codes.

    Args:
        text (str): The text to wrap
        width (int): The maximum width of wrapped lines
        initial_indent (str): Indentation for the first line
        subsequent_indent (str): Indentation for subsequent lines
    """

    def strip_ansi(s):
        # Remove ANSI escape codes when calculating text width
        return re.compile(r"\x1b[^m]*m").sub("", s)

    # Adjust width calculations by removing ANSI codes
    effective_init_indent = len(strip_ansi(initial_indent))

    # Adjust the wrapping width to account for the real indent length
    effective_width = width + (len(initial_indent) - effective_init_indent)

    wrapped = textwrap.fill(
        text,
        width=effective_width,
        initial_indent=initial_indent,
        subsequent_indent=subsequent_indent,
        break_long_words=True,
        break_on_hyphens=True,
    )
    return wrapped


def pick_random_quote(filename="inspiration.csv"):
    """
    Read and return a random quote from the specified CSV file.

    Args:
        filename (str): Path to the CSV file containing quotes. Default is 'inspiration.csv'.

    Returns:
        list: A list containing [quote, attribution, context, emoji] or None if an error occurs.
    """
    # Get the directory where the script is located
    script_dir = os.path.dirname(os.path.abspath(__file__))
    csv_path = os.path.join(script_dir, filename)

    # Check if the file exists
    if not os.path.isfile(csv_path):
        print(f"Error: {filename} not found in {script_dir}")
        return None

    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        # Skip header
        headers = next(reader, None)
        if not headers or len(headers) < 4:
            print("Error: CSV file does not have the required columns.")
            return None

        quotes = list(reader)
        if not quotes:
            print("Error: No quotes found in the CSV file.")
            return None
        return random.choice(quotes)


def print_beautiful_quote(quote_data):
    """
    Format and print a quote with beautiful styling and proper word wrapping.

    Args:
        quote_data (list): A list containing [quote, attribution, context, emoji].
    """
    # quote_data is expected to be [quote, attribution, context, emoji]
    quote, attribution, context, emoji = quote_data

    # Get terminal width with fallback to minimum of 80
    try:
        term_width = max(os.get_terminal_size().columns, 80)
    except OSError:
        # Fallback if terminal size detection fails
        term_width = 80

    # Use 80% of terminal width, with minimum of 80 characters
    text_width = max(int(term_width * 0.8), 80)

    # Format the attribution line with context if it exists
    # Store color codes separately to avoid them being part of the text wrapping calculation
    attribution_prefix = f"{BOLD}{FG_PINK}✧ {RESET}{FG_ORANGE}"
    if context.strip():
        attribution_text = f"{attribution} ({context})"
    else:
        attribution_text = attribution

    # Add decorative top accent
    print()
    print(f"  {FG_ORANGE}· · ·{RESET}")

    # Wrap and print the quote with emoji
    quote_initial_indent = f'  {FG_ORANGE}{emoji}{RESET} {BOLD}{FG_MAGENTA}"'
    quote_subsequent_indent = "     " + f"{BOLD}{FG_MAGENTA}"
    wrapped_quote = wrap_text(
        f"{BOLD}{quote}", text_width - 5, quote_initial_indent, quote_subsequent_indent
    )
    print(f'{wrapped_quote}"{RESET}')

    # Wrap and print the attribution
    attr_initial_indent = "      " + attribution_prefix
    attr_subsequent_indent = "      " + f"{FG_ORANGE}"
    wrapped_attr = wrap_text(
        attribution_text, text_width - 5, attr_initial_indent, attr_subsequent_indent
    )
    print(f"{wrapped_attr}{RESET}")

    # Add decorative bottom accent
    print(f"  {FG_ORANGE}· · ·{RESET}")
    print()


if __name__ == "__main__":
    chosen = pick_random_quote()
    if chosen:
        print_beautiful_quote(chosen)
