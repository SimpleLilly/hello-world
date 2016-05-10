#!/bin/bash -x

##############################################################################
# parameters:
#   <job_id> <local_loction> [remote_location 1] [remote_location2] [remote_...
#
# create local copy of DVD and sync it to remotes
##############################################################################

exec 2>&1
#global var
job_id=$1

echo "sync dvd initiated at: "`date`
echo "User:$USER, logname:$LOGNAME"

if test $# -lt 2
then
  echo "Usage error!"
  echo "$0 <job_id> <local_location> [remote_location1} [remote_locations2] ..."
  exit 1
fi

#TODO - satti - create a common config file for this
#Users and hosts for various locations
noida_user=buildagent
noida_host=10.164.24.50
#noida_host=172.25.11.175
noida_dvd_dir="/c/LDK_DVD/DVD_Copy_from_Munich/devel/QAInWork/"
noida_dvd_dir="/data/devel/QAInWork/"
noida_sandbox_dir="/data/sandbox/"
munich_user=www-data
munich_host=orion-6
#munich_dvd_dir="/data/devel/QAInWork/"
munich_dvd_dir="/data/devel/"
munich_sandbox_dir="/data/sandbox/"
#tlv_user=fzahn
#tlv_host=hercules.ealaddin.org
tlv_user=buildagent
tlv_host=10.1.1.102
tlv_dvd_dir="/data/devel/QAInWork/"
tlv_sandbox_dir="/data/muc-sand/"
china_user=buildagent
china_host=172.25.22.106
china_dvd_dir="/data/devel/QAInWork/"
china_sandbox_dir="/data/sandbox/"

dvdver=0
file_iso=0
file_md5=0

echo "sync dvd script ( $* )"
shift
local_site=$1
shift

eval sand=\$${local_site}_sandbox_dir
jobfolder="job"$job_id"_ldk_dvd_iso"


echo "Scanning $sand$jobfolder for iso"
cd $sand
file_iso=`find $sand$jobfolder -name Sentinel-LDK-R-*.iso -printf %P`
file_md5=`find $sand$jobfolder -name Sentinel-LDK-R-*.md5 -printf %P`
dvdver=`find $sand$jobfolder -name Sentinel-LDK-R-*.iso -printf %P | grep -Eo "R-[0-9]\.[0-9]{1,2}" | grep -Eo "[0-9\.]*"`
andromeda_dvddir=$andromeda"DVD_"$dvdver.$job_id"/";

echo "Got:"
echo "file_iso=$file_iso"
echo "file_md5=$file_md5"
echo "dvdver=$dvdver"

#copy to local
eval local_dvd_dir=\$${local_site}_dvd_dir

#generic sync function
# parameters: <to_site>
sync2remote ()
{
    echo "syncing to $1"
    loc_src=$local_site
    loc_dst=$1
    eval sandbox_dir_src=\$${loc_src}_sandbox_dir
    eval user_dst=\$${loc_dst}_user
    eval host_dst=\$${loc_dst}_host
    eval dvd_dir=\$${loc_dst}_dvd_dir


    ssh ${user_dst}@${host_dst}  "mkdir ${dvd_dir}current "
    echo "rsync-ing ${local_dvd_dir}current/ ${user_dst}@${host_dst}:${dvd_dir}current"
    rsync -ahzP  -e "ssh -C " ${local_dvd_dir}current/ ${user_dst}@${host_dst}:${dvd_dir}current
    #scp $sand$jobfolder/$file_iso ${user_dst}@${host_dst}:${dvd_dir}current/current_${dvdver}.iso
    #scp $sand$jobfolder/$file_md5 ${user_dst}@${host_dst}:${dvd_dir}current/current_${dvdver}.md5

    ssh ${user_dst}@${host_dst}  "mkdir ${dvd_dir}DVD_${dvdver}.$job_id ; cp ${dvd_dir}/current/current_${dvdver}.iso ${dvd_dir}DVD_${dvdver}.$job_id/$file_iso &&  cp ${dvd_dir}/current/current_${dvdver}.md5 ${dvd_dir}DVD_${dvdver}.$job_id/$file_md5  && cd ${dvd_dir}DVD_$dvdver.$job_id && md5sum -c ${dvd_dir}DVD_$dvdver.$job_id/$file_md5; chgrp -R rndandqc ${dvd_dir}DVD_$dvdver.$job_id; chmod -R 775 ${dvd_dir}DVD_$dvdver.$job_id"
    echo "ssh  ${user_dst}@${host_dst} \"ls -l ${dvd_dir}DVD_${dvdver}.$job_id/$file_iso ${dvd_dir}DVD_${dvdver}.$job_id/$file_md5 2> /dev/null;\""
    ssh  ${user_dst}@${host_dst} "ls -l ${dvd_dir}DVD_${dvdver}.$job_id/$file_iso ${dvd_dir}DVD_${dvdver}.$job_id/$file_md5 "
}


#make local copies
chmod -R 770 $sand"current/"
cp -v $sand$jobfolder/$file_iso ${local_dvd_dir}"current/current_"$dvdver".iso"
cp -v $sand$jobfolder/$file_md5 ${local_dvd_dir}"current/current_"$dvdver".md5"
zsyncmake -e -Z -u http://10.20.3.10/current/current_$dvdver.iso -o ${local_dvd_dir}"current/current_"$dvdver".iso.zsync" ${local_dvd_dir}"current/current_"$dvdver".iso" 
#cp -v "/data/www/htdocs/build/tmp/changelog_"$job_id".html" ${local_dvd_dir}"current/"
cp -v $sand$jobfolder/files.md5 ${local_dvd_dir}"current/files_"$dvdver".md5"
mkdir -v ${local_dvd_dir}DVD_${dvdver}.$job_id
cp -v $sand$jobfolder/$file_iso ${local_dvd_dir}DVD_${dvdver}.$job_id/$file_iso
cp -v $sand$jobfolder/$file_md5 ${local_dvd_dir}DVD_${dvdver}.$job_id/$file_md5
chmod -R 755 ${local_dvd_dir}DVD_${dvdver}.$job_id

echo "starting sync with $*"
for f in $*
do
    echo "====== processing for $f ======"
    sync2remote $f
    echo "====== done ==================="
done

echo "sync dvd finished at: "`date`

