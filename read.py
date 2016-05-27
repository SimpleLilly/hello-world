#!C:\Python27\python.exe
#encoding:gb2312

import httplib, urllib, urllib2, string, ctypes

httpClient = None
try:
  httpClient = httplib.HTTPConnection("localhost", 8080, timeout=30)
  httpClient.request("POST", "/buildno.txt")
  response = httpClient.getresponse()
  print response.read()
  BUILD_ID=urllib.urlopen("http://localhost:8080/buildno.txt").read()
  NEXT_ID = int(BUILD_ID)+1
#  print NEXT_ID
  f=open('buildno.txt','w')
  f.write(str(NEXT_ID))
  f.close()
  
except Exception, e:
  print e
finally:
  if httpClient:
    httpClient.close()
