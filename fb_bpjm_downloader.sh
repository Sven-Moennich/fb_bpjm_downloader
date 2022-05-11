#!/bin/bash

VERSION=0.0.1

TEMP=$(getopt -o vdh \
              --long fb_hw:,fb_major:,fb_minor:,fb_patch:,fb_build:,fb_type:,fb_oem:,fb_lang:,fb_country:,fb_annex:,help \
              -n 'fb_bpjm_downloader' -- "$@")

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

eval set -- "$TEMP"

fb_HW=${VARIABLE:-226}
fb_Major=${VARIABLE:-226}
fb_Minor=${VARIABLE:-7}
fb_Patch=${VARIABLE:-39}
fb_Build=${VARIABLE:-1000}
fb_Type=${VARIABLE:-1}
fb_OEM=${VARIABLE:-avm}
fb_Lang=${VARIABLE:-de}
fb_Country=${VARIABLE:-049}
fb_Annex=${VARIABLE:-B}

VERBOSE=false
DEBUG=false
HELP=false

while true; do
  case "$1" in
    -h | --help ) HELP=true; shift ;;
    -d | --debug ) DEBUG=true; shift ;;
    -v | --verbose ) VERBOSE=true; shift;;
    --fb_hw ) fb_HW="$2"; shift 2 ;;
    --fb_major ) fb_Major="$2"; shift 2 ;;
    --fb_minor ) fb_Minor="$2"; shift 2 ;;
    --fb_patch ) fb_Patch="$2"; shift 2 ;;
    --fb_build ) fb_Build="$2"; shift 2 ;;
    --fb_type ) fb_Type="$2"; shift 2 ;;
    --fb_oem ) fb_OEM="$2"; shift 2 ;;
    --fb_lang ) fb_Lang="$2"; shift 2 ;;
    --fb_country ) fb_Country="$2"; shift 2 ;;
    --fb_annex ) fb_Annex="$2"; shift 2 ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ "$HELP" = "true" ]; then
echo "Help"
exit
fi

read -r -d '' message << EOM
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soap-enc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:e="http://juis.avm.de/updateinfo" xmlns:q="http://juis.avm.de/request">
<soap:Header/>
<soap:Body>
<e:BPjMUpdateCheck>
<e:RequestHeader>
<q:Nonce>Quq+UIUqpztL3gqWNAbHpA==</q:Nonce>
<q:UserAgent>BoxInternetCheck</q:UserAgent>
<q:ManualRequest>true</q:ManualRequest>
</e:RequestHeader>
<e:BoxInfo>
<q:Name>FRITZ!Box Dummy</q:Name>
<q:HW>226</q:HW>
<q:Major>154</q:Major>
<q:Minor>7</q:Minor>
<q:Patch>29</q:Patch>
<q:Buildnumber>1000</q:Buildnumber>
<q:Buildtype>1</q:Buildtype>
<q:Serial>000000001</q:Serial>
<q:OEM>avm</q:OEM>
<q:Lang>de</q:Lang>
<q:Country>049</q:Country>
<q:Annex>B</q:Annex>
<q:Flag>crashreport</q:Flag>
<q:Flag>avm_acs</q:Flag>
<q:Flag>myfritz_letsencrypt</q:Flag>
<q:Flag>medium_dsl</q:Flag>
<q:Flag>mesh_master</q:Flag>
<q:UpdateConfig>3</q:UpdateConfig>
<q:Provider>vodafone2_vdsl</q:Provider>
<q:ProviderName>Vodafone</q:ProviderName>
</e:BoxInfo>
<e:BPjMVersion>$(date +%Y%m%d)</e:BPjMVersion>
</e:BPjMUpdateCheck>
</soap:Body>
</soap:Envelope>
EOM

RET=$(curl -s -X POST http://185.jws.avm.de:80/Jason/UpdateInfoService -H "Content-Type: application/xml" -H "Accept: application/xml" -d "$message")

Found=$( echo $RET | grep -o -P '(?<=Found>).*(?=<\/ns3:Found)')
CheckInterval=$( echo $RET | grep -o -P '(?<=CheckInterval>).*(?=<\/ns3:CheckInterval)')
Name=$( echo $RET | grep -o -P '(?<=Name>).*(?=<\/ns3:Name)')
Version=$( echo $RET | grep -o -P '(?<=Version>).*(?=<\/ns3:Version)')
Type=$( echo $RET | grep -o -P '(?<=Type>).*(?=<\/ns3:Type)')
DownloadURL=$( echo $RET | grep -o -P '(?<=DownloadURL>).*(?=<\/ns3:DownloadURL)')
InfoURL=$( echo $RET | grep -o -P '(?<=InfoURL>).*(?=<\/ns3:InfoURL)')
InfoText=$( echo $RET | grep -o -P '(?<=InfoText>).*(?=<\/ns3:InfoText)')
HintURL=$( echo $RET | grep -o -P '(?<=HintURL>).*(?=<\/ns3:HintURL)')
IconURL=$( echo $RET | grep -o -P '(?<=IconURL>).*(?=<\/ns3:IconURL)')
Priority=$( echo $RET | grep -o -P '(?<=Priority>).*(?=<\/ns3:Priority)')
AutoUpdateStartTime=$( echo $RET | grep -o -P '(?<=AutoUpdateStartTime>).*(?=<\/ns3:AutoUpdateStartTime)')
AutoUpdateEndTime=$( echo $RET | grep -o -P '(?<=AutoUpdateEndTime>).*(?=<\/ns3:AutoUpdateEndTime)')
AutoUpdateKeepServices=$( echo $RET | grep -o -P '(?<=AutoUpdateKeepServices>).*(?=<\/ns3:AutoUpdateKeepServices)')

echo "[fb_bpjm_downloader] Found: $Found"
echo "[fb_bpjm_downloader] DownloadURL: $DownloadURL"


FILE=$( basename $DownloadURL )
if [ ! -f $FILE ]; then
wget -N $DownloadURL -O /usr/share/bpjm/$FILE >/dev/null 2>&1
fi

