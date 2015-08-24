import xml.dom.minidom
import os
dom1 = xml.dom.minidom.parse("jobAcknowledge1.xml")
for i in range(1, 10):
        vendorID1 = dom1.getElementsByTagName('apiSet')[i].getAttribute('vendorId')
        platform1 = dom1.getElementsByTagName('apiSet')[i].getAttribute('platform')
        status1 = dom1.getElementsByTagName('api')[i].getAttribute('status')
        rebuild1 = dom1.getElementsByTagName('api')[i].getAttribute('rebuild')
        apiVersion1 = dom1.getElementsByTagName('apiVersion')[i].firstChild.data
        apiType1 = dom1.getElementsByTagName('apiType')[i].firstChild.data
        record1 = vendorID1,rebuild1,status1,apiVersion1,apiType1
        f = open("api1.txt","a")
        print >>f,record1
        f.close()
#print('End of loop2!')
#vendorID = dom.getElementsByTagName('apiSet')[0].getAttribute('vendorId')
#platform = dom.getElementsByTagName('apiSet')[0].getAttribute('platform')
#status = dom.getElementsByTagName('api')[0].getAttribute('status')
#rebuild = dom.getElementsByTagName('api')[0].getAttribute('rebuild')
#apiVersion = dom.getElementsByTagName('apiVersion')[0].firstChild.data
#apiType = dom.getElementsByTagName('apiType')[0].firstChild.data
#print "====================="
#print "VendorID =",vendorID
#print "Platform =",platform
#print "Rebuild =",rebuild
#print "Status =",status
#print "APIVersion =",apiVersion
#print "APIType =",apiType

#print vendorID,rebuild,status,apiVersion,apiType

#f=open('api.txt','w')
#print>> f,apiVersion;f,apiType
#print>>f,apiType
#f.close()

#vendorID = dom.getElementsByTagName('apiSet')[2].getAttribute('vendorId')
#platform = dom.getElementsByTagName('apiSet')[2].getAttribute('platform')
#status = dom.getElementsByTagName('api')[2].getAttribute('status')
#rebuild = dom.getElementsByTagName('api')[2].getAttribute('rebuild')
#apiVersion = dom.getElementsByTagName('apiVersion')[2].firstChild.data
#print "====================="
#print "VendorID =",vendorID
#print "Platform =",platform
#print "Rebuild =",rebuild
#print "Status =",status
#print "APIVersion =",apiVersion
#print vendorID,rebuild,status,apiVersion,apiType
