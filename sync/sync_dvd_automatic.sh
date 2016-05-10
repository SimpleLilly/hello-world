#!/bin/bash -x

##############################################################################
# parameters: 
#   <job_id> <local_loction> [remote_location 2] [remote_location3] [remote_...
#
# Runs the sync script from the remote where job got built
##############################################################################

#global var
job_id=$1
job_site=$2

if test $# -lt 2
then
  echo "Usage error!"
  echo "$0 <job_id> <local_location> [remote_location1} [remote_locations2] ..."
  exit 1
fi


#Users and hosts for various locations
noida_user=buildagent
noida_host=10.164.24.50
#noida_host=172.25.11.175
munich_user=www-data
munich_host=orion-6
#tlv_user=fzahn
#tlv_host=hercules.ealaddin.org
tlv_user=buildagent
tlv_host=10.1.1.102
china_user=buildagent
china_host=172.25.22.106

eval user_remote=\$${job_site}_user
eval host_remote=\$${job_site}_host

#scp the script to remote and execute it
scp /usr/local/sbin/sync_dvd_remote_script.sh $user_remote@$host_remote:/tmp/alphabeta.sh 2>&1
ret=$?
echo "<br><pre>script deployed with exit status:$?\n:$ret<\pre><br>"
if test $ret -ne 0
then
	echo "Unable to deploy script"
	exit 0
fi

ssh $user_remote@$host_remote " \
    chmod +x /tmp/alphabeta.sh; \
    /tmp/alphabeta.sh $* > /tmp/alphabeta_logs 2>&1; \
    echo $? > /tmp/alphabeta.result; \
    sleep 5; \
    "
scp $user_remote@$host_remote:/tmp/alphabeta.result /tmp/sync_${job_id}.result
scp $user_remote@$host_remote:/tmp/alphabeta_logs /tmp/sync_${job_id}.logs
ssh $user_remote@$host_remote " \
    rm /tmp/alphabeta* 2> /dev/null; \
    "
 
echo "Results:"
cat /tmp/sync_${job_id}.logs

mailx -s 'SCM Notification: New automatic DVD Submission JobID:'${job_id} -a 'Content-Type: text/html' -a 'From: Config Management <sm-cmnotification@safenet-inc.com>' SM-CMnotification@safenet-inc.com < /data/www/htdocs/build/tmp/autosubmit_changelog_${job_id}.html 
