import requests
import time
import sys
import logging

logging.basicConfig(stream=sys.stdout, level=logging.INFO)


def call_api(url):
    """ Calls an API endpoint and returns the response as JSON object.
    Parameters
    url (string): The fully constructed url to test api endpoint (default is http://localhost/version) if none is provided.

    Returns
    json: A Json response object
    """
    try:
        response = requests.get(url)
        return response.json()

    except requests.exceptions.RequestException as e:
        print(f"Error calling API: {e}")
        return None


def main():
    protocol = "http"

    try:
        if sys.argv[1] != "localhost":
            protocol = "https"
        base_url = f"{protocol}://{sys.argv[1]}"
        logging.info("Setting api url provided by user: " + sys.argv[1])

    except IndexError as e:
        logging.info("Setting api url as localhost")
        base_url = f"{protocol}://localhost"

    delay = 1

    # In a more mature setup, we would take the domain name and endpoint as named arguments or environment variables.
    url = base_url + "/version"
    while True:
        data = call_api(url)
        if data:
            logging.info(data)
        else:
            logging.error(" API not healthy")
        time.sleep(delay)


if __name__ == "__main__":
    main()
