#!/usr/bin/env python3

import requests
from icalendar import Calendar
from urllib.parse import urljoin
import os
import time
from bs4 import BeautifulSoup

# Configuration from environment variables
NEXTCLOUD_URL = os.environ['NEXTCLOUD_URL']
USERNAME = os.environ['NEXTCLOUD_USERNAME']
PASSWORD = os.environ['NEXTCLOUD_PASSWORD']
CALENDAR_NAME = os.environ['NEXTCLOUD_CALENDAR_NAME']
ICS_FILE_PATH = os.environ['ICS_FILE_PATH']

CALENDAR_URL = f"{NEXTCLOUD_URL}/remote.php/dav/calendars/{USERNAME}/{CALENDAR_NAME}/"

def delete_all_events():
    """Delete all events from the calendar"""
    print("Step 1: Deleting all events from the calendar...")

    # First, retrieve all event URLs from the calendar
    propfind_body = '''
    <d:propfind xmlns:d="DAV:" xmlns:cs="http://calendarserver.org/ns/" xmlns:c="urn:ietf:params:xml:ns:caldav">
        <d:prop>
            <d:resourcetype />
            <d:getcontenttype />
        </d:prop>
    </d:propfind>
    '''

    response = requests.request(
        "PROPFIND",
        CALENDAR_URL,
        auth=(USERNAME, PASSWORD),
        headers={
            "Depth": "1",
            "Content-Type": "application/xml",
        },
        data=propfind_body
    )

    if response.status_code != 207:
        print(f"Error retrieving events: {response.status_code}")
        return False

    # Parse the response to find all event URLs
    soup = BeautifulSoup(response.text, 'xml')
    events = []

    for response_elem in soup.find_all('response'):
        href_elem = response_elem.find('href')
        if not href_elem:
            continue

        href = href_elem.text
        resourcetype = response_elem.find('resourcetype')

        # Check if it's an event (not a collection)
        if resourcetype and not resourcetype.find('collection'):
            events.append(href)

    # Delete each event
    for event_url in events:
        full_url = urljoin(NEXTCLOUD_URL, event_url)
        print(f"Deleting: {full_url}")
        response = requests.delete(
            full_url,
            auth=(USERNAME, PASSWORD),
            headers={
            }
        )
        response = requests.delete(
            full_url,
            auth=(USERNAME, PASSWORD),
            headers={
                "X-NC-CalDAV-No-Trashbin": "1"
            }
        )

        if response.status_code not in [200, 204]:
            print(f"Error deleting event {event_url}: [{response.status_code}] {response.content}")

    print("Deletion complete.")
    return True

def upload_events():
    """Upload events from ICS file"""
    print("Step 2: Uploading events from ICS file...")

    # Read and parse the ICS file
    with open(ICS_FILE_PATH, 'r', encoding='utf-8') as f:
        cal_data = f.read()

    cal = Calendar.from_ical(cal_data)

    # Count events
    event_count = 0
    for component in cal.walk():
        if component.name == "VEVENT":
            event_count += 1

    print(f"Found {event_count} events in the ICS file.")

    # Upload each event individually
    index = 1
    for component in cal.walk():
        if component.name != "VEVENT":
            continue

        # Create a new calendar for this single event
        event_cal = Calendar()
        event_cal.add('prodid', '-//Nextcloud Calendar Sync//EN')
        event_cal.add('version', '2.0')

        # Add timezone information if available
        for tz_component in cal.walk():
            if tz_component.name == "VTIMEZONE":
                event_cal.add_component(tz_component)

        # Add the event
        event_cal.add_component(component)

        # Get the UID
        uid = component.get('uid')
        if not uid:
            print(f"Warning: Could not extract UID for event {index}. Skipping.")
            index += 1
            continue

        try:
            # Upload the event
            event_filename = f"{uid}.ics"
            event_url = urljoin(CALENDAR_URL, event_filename)

            print(f"[{index}] Uploading: {uid}")

            response = requests.put(
                event_url,
                auth=(USERNAME, PASSWORD),
                headers={"Content-Type": "text/calendar; charset=utf-8"},
                data=event_cal.to_ical()
            )

            if response.status_code in [201, 204]:
                pass
            else:
                print(f"Error uploading event {uid}: {response.status_code}")
                print(response.text)

            index += 1
        except Exception as e:
            print(f"Error processing event {uid}: {str(e)}")
        finally:
            pass

    print("Upload complete.")

if __name__ == "__main__":
    # Delete all existing events
    if delete_all_events():
        time.sleep(0)
        # Upload new events
        # upload_events()
