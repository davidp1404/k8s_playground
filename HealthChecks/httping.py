import requests,sys,time,os
from datetime import datetime
class bcolors:
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
while (True):
    try:
        #time.sleep(0.5)
        host=os.getenv('PYWEB_URL')
        r =requests.get(host, timeout=2)   # Timeout = time your customer wait at most for a response
        if r.status_code != 500:
            print(bcolors.OKGREEN + "{} {} code: {}".format(host,datetime.now(),r.status_code))
        else:
            print(bcolors.WARNING + "{} date: {} code: {}".format(host,datetime.now(),r.status_code))
    except Exception as err:
        print(bcolors.FAIL + "{} {} code: {}".format(host,datetime.now(),501))
        pass


