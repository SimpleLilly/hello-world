#!/bin/sh
pwd
rm -fr ParseBlackboxResult
mkdir ParseBlackboxResult
cd ParseBlackboxResult
#Build 182 is an example for failed blackbox test:
#BAMBOO_buildResultKey=XGEN-UTX-RB-182
#Build 177 is an example for successful blackbox test:
BAMBOO_buildResultKey=XGEN-UTX-RB-177
rm -fr jobAcknowledge*.xml
wget http://muc1bamboo/download/XGEN-UTX-RB/build_logs/$BAMBOO_buildResultKey.log
awk '{for (i=4;i<=100;i++) printf($i" ");printf("\n")}' ./$BAMBOO_buildResultKey.log >temp1.log
sed -i "s/recived\ response\ from\ server//g" temp1.log
cat -n temp1.log|grep jobAcknowledge >temp2.log
awk '{print $1}' temp2.log >temp3.log
start_line1=`awk 'NR==1 {print $1}' temp3.log`
end_line1=`awk 'NR==2 {print $1}' temp3.log`
start_line2=`awk 'NR==3 {print $1}' temp3.log`
end_line2=`awk 'NR==4 {print $1}' temp3.log`
echo $start_line1
echo $end_line1
echo $start_line2
echo $end_line2
awk "NR>=$start_line1&&NR<=$end_line1" temp1.log >jobAcknowledge1.xml
awk "NR>=$start_line2&&NR<=$end_line2" temp1.log >jobAcknowledge2.xml
rm -fr XGEN-UTX-RB-*
rm -fr temp*.log
cp /home/buildagent/readXML*.py . 
python readXML1.py
python readXML2.py
cat api1.txt > api.txt
cat api2.txt >> api.txt
sed -i "s/(u//g" api.txt
sed -i "s/)//g" api.txt
sed -i "s/,\ u//g" api.txt
cat api.txt
grep "in progress" api.txt
if [ $? -eq 0 ]; then
    echo "API/VLIB rebuild failed! Blackbox test failed!"
        exit -1
	else
	    echo "API/VLIB rebuild finished! Blackbox test successfully!"
	        exit 0
		fi
